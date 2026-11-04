import '../../domain/entities/cart_item.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl {
  CartRepositoryImpl(this._local);
  final CartLocalDataSource _local;
  List<CartItem> getItems() => _local.read();
  Future<void> save(List<CartItem> items) => _local.write(items);
}
