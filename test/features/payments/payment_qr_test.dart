import 'package:clothing_app/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:clothing_app/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:clothing_app/features/payments/presentation/widgets/qr_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('prefers the provider qr_url image over the raw payload',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QrDisplay(
            value: '000201010212',
            qrImageUrl: 'https://payments.example/provider-qr.png',
            fallbackUrl: 'https://payments.example/qr.png',
          ),
        ),
      ),
    );

    expect(find.byType(QrImageView), findsNothing);
    expect(
      tester.widget<Image>(find.byType(Image)).image,
      isA<NetworkImage>(),
    );
  });

  testWidgets('prefers a provider-generated QR image over the payload',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QrDisplay(
            value: 'backend-payload',
            qrImageUrl: 'https://payments.example/provider-qr.png',
          ),
        ),
      ),
    );

    expect(find.byType(QrImageView), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
  });

  testWidgets('renders a base64 QR image when supplied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QrDisplay(
            value: 'backend-payload',
            qrImageBase64:
                'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a0c8AAAAASUVORK5CYII=',
          ),
        ),
      ),
    );

    expect(find.byType(QrImageView), findsNothing);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<MemoryImage>());
  });

  test('parses QR image data and bank links from the backend response',
      () async {
    final remote = _FakePaymentRemoteDataSource({
      'provider': 'aba_pay',
      'qr_string': 'khqr-payload',
      'qr_image_base64': 'encoded-provider-image',
      'banking_apps': {
        'aba_mobile': {'deep_link': 'aba://returned-payment-link'},
      },
    });

    final initiation =
        await PaymentRepositoryImpl(remote).initiate(12, 'aba_pay');

    expect(initiation.qrString, 'khqr-payload');
    expect(initiation.qrImageBase64, 'encoded-provider-image');
    expect(
      initiation.bankDeepLinks['aba'],
      'aba://returned-payment-link',
    );
  });

  test('parses the hosted ABA checkout URL from the backend response',
      () async {
    final remote = _FakePaymentRemoteDataSource({
      'provider': 'khqr_checkout',
      'checkout_url': 'https://checkout.example/aba?transaction_id=order-123',
    });

    final initiation =
        await PaymentRepositoryImpl(remote).initiate(12, 'khqr_checkout');

    expect(initiation.provider, 'khqr_checkout');
    expect(
      initiation.deepLink,
      'https://checkout.example/aba?transaction_id=order-123',
    );
  });
}

class _FakePaymentRemoteDataSource implements PaymentRemoteDataSource {
  _FakePaymentRemoteDataSource(this.response);

  final Map<String, dynamic> response;

  @override
  Future<dynamic> initiate(int id, String provider) async => response;

  @override
  Future<dynamic> order(int id) async => const {};

  @override
  Future<dynamic> paymentStatus(int id) async => const {};
}
