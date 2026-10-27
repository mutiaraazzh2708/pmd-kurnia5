import 'product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  int subtotal(String tipe) => product.hargaUntuk(tipe) * qty;
}