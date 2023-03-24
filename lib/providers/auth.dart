import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    } else {
      return null;
    }
  }

  bool get isAuthintecated {
    return token != null;
  }

  Future<void> signUp(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDKl2rYbfq8pMErPSsv5UJuAghshujac9k');
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );

    _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(jsonDecode(response.body)['expiresIn'])));
    _token = jsonDecode(response.body)['idToken'];
    _userId = jsonDecode(response.body)['localId'];
    notifyListeners();

    if (jsonDecode(response.body)['error'] != null) {
      throw HttpException(jsonDecode(response.body)['error']['message']);
    }
  }

  Future<void> signIn(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDKl2rYbfq8pMErPSsv5UJuAghshujac9k');
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(jsonDecode(response.body)['expiresIn'])));
    _token = jsonDecode(response.body)['idToken'];
    _userId = jsonDecode(response.body)['localId'];
    notifyListeners();

    if (jsonDecode(response.body)['error'] != null) {
      throw HttpException(jsonDecode(response.body)['error']['message']);
    }
  }
}
