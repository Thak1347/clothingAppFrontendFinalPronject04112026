import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../checkout/domain/entities/order.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../pages/payment_sucessful_screen.dart';

class PaymentController extends GetxController with WidgetsBindingObserver {
  PaymentController(this._repository);
  final PaymentRepository _repository;
  final Rxn<Order> order = Rxn<Order>();
  final Rxn<PaymentInitiation> initiation = Rxn<PaymentInitiation>();
  final isLoading = false.obs;
  final isCheckingStatus = false.obs;
  final error = ''.obs;
  final selectedMethod = 'aba_pay'.obs;
  Timer? _pollTimer;
  bool _isPolling = false;
  bool _successScreenOpened = false;

  @override
  void onInit() { super.onInit(); WidgetsBinding.instance.addObserver(this); }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ['pending', 'processing'].contains(order.value?.payment?.status)) {
      refresh();
    }
  }

  Future<void> start(Order initial) async {
    _successScreenOpened = false;
    order.value = initial;
    final payment = initial.payment;
    if (payment == null) {
      error.value = 'This order has no payment record.';
      return;
    }
    if (payment.status == 'paid' || payment.status == 'partially_paid') {
      _openSuccess(initial);
      return;
    }
    if (initial.paymentMethod == 'cash' && initial.fulfillmentStatus == 'awaiting_deposit' && (payment.status == 'unpaid' || payment.status == 'pending' || payment.status == 'expired' || payment.status == 'failed')) {
      selectedMethod.value = 'aba_pay';
      await initiate();
      return;
    }
    if (payment.provider == 'cash' || payment.provider == 'khqr' || payment.provider == 'aba_pay' || payment.provider == 'khqr_checkout') {
      selectedMethod.value = payment.provider;
    }
    if (['pending', 'processing', 'partially_paid'].contains(payment.status) &&
        ['khqr', 'aba_pay', 'khqr_checkout'].contains(payment.provider)) {
      _startPolling();
    }
  }

  Future<void> selectMethod(String method) async {
    selectedMethod.value = method;
    initiation.value = null;
    error.value = '';
  }

  Future<void> initiate() async {
    final payment = order.value?.payment;
    if (payment == null || !['pending', 'unpaid', 'expired', 'failed'].contains(payment.status) || isLoading.value) {
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      initiation.value =
          await _repository.initiate(payment.id, selectedMethod.value);
      if (initiation.value?.provider == 'khqr' || initiation.value?.provider == 'aba_pay' || initiation.value?.provider == 'khqr_checkout') {
        _startPolling();
        await refresh();
      }
    } on DioException catch (exception) {
      final response = exception.response?.data;
      final serverMessage = response is Map ? response['message']?.toString() : null;
      error.value = serverMessage?.isNotEmpty == true
          ? serverMessage!
          : 'Could not start the payment. Check your connection and retry.';
    } catch (_) {
      error.value = 'Could not start the payment. Please retry.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    final current = order.value;
    if (current == null || _isPolling) return;
    _isPolling = true;
    isCheckingStatus.value = true;
    error.value = '';
    try {
      final updated = await _repository.pollOrder(current.id);
      order.value = updated;
      if (!['pending', 'processing'].contains(updated.payment?.status)) {
        _pollTimer?.cancel();
      }
      if (!['paid', 'partially_paid'].contains(current.payment?.status) &&
          ['paid', 'partially_paid'].contains(updated.payment?.status)) {
        try {
          await Get.find<NotificationController>().showLocal(
            updated.payment?.status == 'partially_paid' ? 'Deposit received' : 'Payment successful',
            updated.payment?.status == 'partially_paid' ? 'Your 50% deposit for order ${updated.number} was confirmed.' : 'Payment for order ${updated.number} was confirmed.',
          );
        } catch (_) {
          // Payment confirmation is authoritative even if notifications are off.
        }
        _openSuccess(updated);
      }
    } on DioException catch (exception) {
      final response = exception.response?.data;
      final serverMessage = response is Map ? response['message']?.toString() : null;
      error.value = serverMessage?.isNotEmpty == true
          ? serverMessage!
          : 'Unable to reach the server. Check your connection and try again.';
    } catch (exception) {
      error.value = 'Unable to check payment status.';
      FlutterError.reportError(FlutterErrorDetails(exception: exception));
    } finally {
      _isPolling = false;
      isCheckingStatus.value = false;
    }
  }

  void _openSuccess(Order confirmedOrder) {
    if (_successScreenOpened) return;
    _successScreenOpened = true;
    Get.off(() => PaymentSuccessfulScreen(order: confirmedOrder));
  }

  Future<void> openBankApp(CambodianBank bank) async {
    final link = initiation.value?.bankDeepLinks[bank.key];
    if (link == null || isLoading.value) {
      error.value =
          'A direct link for ${bank.label} is unavailable. Scan the QR code using that app instead.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final uri = Uri.tryParse(link);
      if (uri == null || !uri.hasScheme) {
        error.value =
            'The payment service returned an invalid ${bank.label} link.';
        return;
      }
      if (await canLaunchUrl(uri)) {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          error.value =
              'Could not open ${bank.label}. Scan the QR code below instead.';
          return;
        }
        _startPolling();
      } else {
        error.value = '${bank.label} is not available. Scan the QR code below instead.';
      }
    } on Exception catch (exception) {
      error.value = 'Could not open ${bank.label}. Scan the QR code below instead.';
      FlutterError.reportError(FlutterErrorDetails(exception: exception));
    } finally {
      isLoading.value = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    var elapsed = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      elapsed += 3;
      if (elapsed >= 180 ||
          !['pending', 'processing'].contains(order.value?.payment?.status)) {
        timer.cancel();
        return;
      }
      refresh();
    });
  }

  @override
  void onClose() { _pollTimer?.cancel(); WidgetsBinding.instance.removeObserver(this); super.onClose(); }
}

enum CambodianBank {
  aba('ABA Mobile', 'aba', Icons.phone_android_outlined),
  wing('Wing Bank', 'wing', Icons.account_balance_outlined),
  acleda('ACLEDA', 'acleda', Icons.account_balance_outlined),
  bakong('Bakong', 'bakong', Icons.account_balance_wallet_outlined);

  const CambodianBank(this.label, this.key, this.icon);
  final String label;
  final String key;
  final IconData icon;
}
