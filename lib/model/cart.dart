import 'product.dart';

class CartItem {
  final Product product;
  int qty;
  CartItem({required this.product, this.qty = 1});
}

class Cart {
  static final List<CartItem> items = [];

  static void add(Product p) {
    final idx = items.indexWhere((e) => e.product.id == p.id);
    if (idx == -1) {
      items.add(CartItem(product: p));
    } else {
      items[idx].qty += 1;
    }
  }

  static double totalPrice() =>
      items.fold(0, (sum, e) => sum + e.qty * e.product.price);

  static void clear() => items.clear();
}
