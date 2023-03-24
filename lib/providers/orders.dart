import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final DateTime orderTime;
  final List<PCartItem> products;

  OrderItem({
    required this.id,
    required this.amount,
    required this.orderTime,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;

  Orders(this.token, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-udacity-course-default-rtdb.firebaseio.com/orders.json?auth=$token');
    final response = await http.get(url);
    if (jsonDecode(response.body) == null) {
      return;
    }
    final exractedOrders = jsonDecode(response.body) as Map<String, dynamic>;

    final List<OrderItem> tempList = [];
    exractedOrders.forEach((orderId, orderData) {
      tempList.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          orderTime: DateTime.parse(orderData['orderTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (e) => PCartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = tempList.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<PCartItem> products, double amount) async {
    final url = Uri.parse(
        'https://shop-app-udacity-course-default-rtdb.firebaseio.com/orders.json?auth=$token');
    final timestamp = DateTime.now();
    final response = await http.post(url,
        body: jsonEncode({
          'amount': amount,
          'orderTime': timestamp.toIso8601String(),
          'products': products
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity
                  })
              .toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(response.body)['name'],
        amount: amount,
        orderTime: DateTime.now(),
        products: products,
      ),
    );
    notifyListeners();
  }
}
