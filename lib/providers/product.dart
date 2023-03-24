import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String token) async {
    final oldFavorite = isFavorite;
    isFavorite = !isFavorite;
    //notifyListeners();
    final url = Uri.parse(
        'https://shop-app-udacity-course-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    try {
      final response =
          await http.patch(url, body: jsonEncode({'isFavorite': isFavorite}));
      if (response.statusCode >= 400) {
        isFavorite = oldFavorite;
        notifyListeners(); //not working
      }
    } catch (e) {
      isFavorite = oldFavorite;
      notifyListeners(); //not working
    }
    //notifyListeners();
  }
}
