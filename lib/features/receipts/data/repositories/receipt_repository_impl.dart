import 'package:dio/dio.dart';

import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_remote_datasource.dart';
import '../models/receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  ReceiptRepositoryImpl(this._remote);

  final ReceiptRemoteDataSource _remote;

  @override
  Future<Receipt> getReceipt(int id) async {
    final order = await _remote.getOrder(id);
    dynamic bill;
    try {
      bill = await _remote.get(id);
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    return ReceiptModel.fromResponses(order: order, bill: bill);
  }
}
