import '../entities/receipt.dart';
abstract interface class ReceiptRepository { Future<Receipt> getReceipt(int orderId); }
