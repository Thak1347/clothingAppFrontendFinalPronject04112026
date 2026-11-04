import '../../../checkout/domain/entities/order.dart';
import '../entities/payment.dart';

abstract interface class PaymentRepository {
  Future<PaymentInitiation> initiate(int paymentId, String provider);
  Future<Order> refreshOrder(int orderId);
  Future<Order> pollOrder(int orderId);
}
