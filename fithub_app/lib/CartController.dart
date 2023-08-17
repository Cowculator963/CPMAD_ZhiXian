import 'package:get/get.dart';

class CartController extends GetxController {
  var _cartItems = <String, CartItem>{}.obs;

  Map<String, CartItem> get cartItems => Map<String, CartItem>.from(_cartItems);

  void addToCart(String itemName, String itemPrice, String imagePath) {
    if (_cartItems.containsKey(itemName)) {
      final cartItem = _cartItems[itemName];
      if (cartItem != null) {
        cartItem.quantity.value++;
      }
    } else {
      _cartItems[itemName] = CartItem(
        itemName: itemName,
        itemPrice: itemPrice,
        imagePath: imagePath,
        quantity: RxInt(1),
      );
    }
    update();
  }

  void removeFromCart(String itemName) {
    _cartItems.remove(itemName);
    update();
  }

  void increaseQuantity(String itemName) {
    final cartItem = _cartItems[itemName];
    if (cartItem != null) {
      cartItem.quantity.value++;
    }
    update();
  }

  RxInt getQuantity(String itemName) {
    final cartItem = _cartItems[itemName];
    if (cartItem != null) {
      return cartItem.quantity;
    }
    return RxInt(0);
  }

  void decreaseQuantity(String itemName) {
    final cartItem = _cartItems[itemName];
    if (cartItem != null && cartItem.quantity.value > 0) {
      cartItem.quantity.value--;
    }
    update();
  }

  int getCartItemCount() {
    int itemCount = 0;
    _cartItems.forEach((itemName, cartItem) {
      itemCount += cartItem.quantity.value;
    });
    return itemCount;
  }

  void clearCart() {
    _cartItems.clear();
    update();
  }
}

class CartItem {
  final String itemName;
  final String itemPrice;
  final String imagePath;
  final RxInt quantity;

  CartItem({
    this.itemName,
    this.itemPrice,
    this.imagePath,
    this.quantity,
  });
}
