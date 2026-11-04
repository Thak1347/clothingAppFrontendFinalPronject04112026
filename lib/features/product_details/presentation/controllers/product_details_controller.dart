import 'package:get/get.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(Product product)
      : _product = product,
        _repository = null,
        _productId = null;

  ProductDetailsController.fromId(CatalogRepository repository, int productId)
      : _product = const Product(
          id: 0,
          name: '',
          description: '',
          priceMinor: 0,
          variants: [],
        ),
        _repository = repository,
        _productId = productId;

  Product _product;
  Product get product => _product;
  final CatalogRepository? _repository;
  final int? _productId;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<ProductVariant> selectedVariant = Rxn<ProductVariant>();
  final RxInt quantity = 1.obs;
  final RxString validationMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (_productId != null) loadProduct();
  }

  Future<void> loadProduct() async {
    final repository = _repository;
    final id = _productId;
    if (repository == null || id == null) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _product = await repository.getProduct(id);
      selectedVariant.value = null;
      quantity.value = 1;
    } catch (_) {
      errorMessage.value = 'Could not load this product. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  List<String> get sizes => product.variants.map((v) => v.size).where((v) => v.isNotEmpty).toSet().toList();
  List<String> get colors => product.variants.map((v) => v.color).where((v) => v.isNotEmpty).toSet().toList();
  int get availableStock => selectedVariant.value?.stock ?? 0;
  int get selectedPriceMinor => selectedVariant.value?.priceMinor ?? product.priceMinor;

  void selectSize(String size) {
    final currentColor = selectedVariant.value?.color;
    final options = product.variants.where((variant) =>
        variant.size == size &&
        (currentColor == null || variant.color == currentColor));
    final next = options.isNotEmpty
        ? options.first
        : product.variants.firstWhere((variant) => variant.size == size);
    _selectVariant(next);
  }

  void selectColor(String color) {
    final currentSize = selectedVariant.value?.size;
    final options = product.variants.where((variant) =>
        variant.color == color &&
        (currentSize == null || variant.size == currentSize));
    final next = options.isNotEmpty
        ? options.first
        : product.variants.firstWhere((variant) => variant.color == color);
    _selectVariant(next);
  }

  void _selectVariant(ProductVariant variant) {
    selectedVariant.value = variant;
    quantity.value = 1;
    validationMessage.value = '';
  }

  bool isCombinationAvailable({String? size, String? color}) {
    return product.variants.any((variant) =>
        (size == null || variant.size == size) &&
        (color == null || variant.color == color));
  }

  void increment() {
    final stock = availableStock;
    if (stock > quantity.value) quantity.value++;
  }

  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  bool validateSelection() {
    if (product.variants.isEmpty) return true;
    final variant = selectedVariant.value;
    if (variant == null) {
      validationMessage.value = 'Choose an available product option to continue.';
      return false;
    }
    if (variant.stock < 1) {
      validationMessage.value = 'This option is currently out of stock.';
      return false;
    }
    if (quantity.value > variant.stock) {
      validationMessage.value = 'Only ${variant.stock} available for this option.';
      return false;
    }
    validationMessage.value = '';
    return true;
  }
}
