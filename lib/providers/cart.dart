import 'package:flutter/cupertino.dart';

class PCartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  PCartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  final Map<String, PCartItem> _items = {};

  Map<String, PCartItem> get items {
    return {..._items};
  }

  int get itemCount {
    int sum = 0;
    for (var element in _items.values) {
      sum += element.quantity;
    }
    return sum;
  }

  double get itemAmount {
    double sum = 0;
    for (var element in _items.values) {
      sum += element.quantity * element.price;
    }
    return sum;
  }

  void addItem(String title, double price, String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (value) => PCartItem(
              id: value.id,
              title: value.title,
              quantity: value.quantity + 1,
              price: value.price));
    } else {
      _items.putIfAbsent(
        productId,
        () => PCartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) return;
    if (_items[id]!.quantity > 1) {
      _items.update(
          id,
          (value) => PCartItem(
                id: value.id,
                title: value.title,
                price: value.price,
                quantity: value.quantity - 1,
              ));
    } else {
      removeItem(id);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
