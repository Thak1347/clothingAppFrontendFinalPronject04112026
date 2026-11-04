import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../data/services/receipt_pdf_service.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class ReceiptController extends GetxController {
  ReceiptController(this._repository, this._pdfService);

  final ReceiptRepository _repository;
  final ReceiptPdfService _pdfService;
  final Rxn<Receipt> receipt = Rxn<Receipt>();
  final Rxn<File> pdfFile = Rxn<File>();
  final loading = false.obs;
  final isGenerating = false.obs;
  final error = ''.obs;

  int? _loadedOrderId;
  int? _loadingOrderId;
  int? _generationOrderId;
  Future<void>? _loadInFlight;
  Future<File>? _generationInFlight;

  Future<void> load(int orderId, {bool force = false}) {
    if (!force && _loadedOrderId == orderId && receipt.value != null) {
      return Future<void>.value();
    }
    final activeLoad = _loadInFlight;
    if (activeLoad != null) {
      if (_loadingOrderId == orderId) return activeLoad;
      return activeLoad.then((_) => load(orderId, force: force));
    }
    final operation = _load(orderId);
    _loadingOrderId = orderId;
    late final Future<void> trackedOperation;
    trackedOperation = operation.whenComplete(() {
      if (identical(_loadInFlight, trackedOperation)) {
        _loadInFlight = null;
        _loadingOrderId = null;
      }
    });
    _loadInFlight = trackedOperation;
    return trackedOperation;
  }

  Future<File> generatePdf(int orderId, {bool force = false}) async {
    final activeGeneration = _generationInFlight;
    if (activeGeneration != null) {
      if (_generationOrderId == orderId) return activeGeneration;
      throw StateError('Another receipt is currently being prepared.');
    }

    final existingFile = pdfFile.value;
    if (!force &&
        _loadedOrderId == orderId &&
        existingFile != null &&
        await existingFile.exists()) {
      return existingFile;
    }

    final operation = _generatePdf(orderId, force: force);
    _generationInFlight = operation;
    _generationOrderId = orderId;
    try {
      return await operation;
    } finally {
      if (identical(_generationInFlight, operation)) {
        _generationInFlight = null;
        _generationOrderId = null;
      }
    }
  }

  Future<void> _load(int orderId) async {
    loading.value = true;
    error.value = '';
    if (_loadedOrderId != orderId) {
      receipt.value = null;
      pdfFile.value = null;
    }
    try {
      receipt.value = await _repository.getReceipt(orderId);
      _loadedOrderId = orderId;
    } on DioException catch (exception) {
      receipt.value = null;
      error.value = ErrorMapper.mapDioError(exception).message;
    } catch (_) {
      receipt.value = null;
      error.value = 'Unable to load this receipt. Please try again.';
    } finally {
      loading.value = false;
    }
  }

  Future<File> _generatePdf(int orderId, {required bool force}) async {
    isGenerating.value = true;
    error.value = '';
    try {
      await load(orderId, force: force);
      final currentReceipt = receipt.value;
      if (currentReceipt == null) {
        throw StateError(
          error.value.isEmpty
              ? 'Receipt details are unavailable.'
              : error.value,
        );
      }
      final file = await _pdfService.generate(currentReceipt);
      pdfFile.value = file;
      return file;
    } catch (exception) {
      error.value = switch (exception) {
        StateError() => exception.message.toString(),
        FileSystemException() => 'Unable to access the receipt file location.',
        DioException() => ErrorMapper.mapDioError(exception).message,
        _ => 'Unable to generate the PDF. Please try again.',
      };
      rethrow;
    } finally {
      isGenerating.value = false;
    }
  }
}
