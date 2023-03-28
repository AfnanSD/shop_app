import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  late Timer _logOutTitme;

  String? get userId {
    return _userId ?? '';
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
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
    _autoLogOut();
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
    _autoLogOut();
    notifyListeners();
    final userData = jsonEncode(
      {
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate!.toIso8601String(),
      },
    );
    final pref = await SharedPreferences.getInstance();
    pref.setString('userData', userData);

    if (jsonDecode(response.body)['error'] != null) {
      throw HttpException(jsonDecode(response.body)['error']['message']);
    }
  }

  Future<bool> tryLogIn() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey('userData')) {
      return false;
    }
    final userData =
        jsonDecode(pref.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    _autoLogOut();
    notifyListeners();
    return true;
  }

  Future<void> logOut() async {
    _expiryDate = null;
    _token = null;
    _userId = null;
    _logOutTitme.cancel();
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    notifyListeners();
  }

  void _autoLogOut() {
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _logOutTitme = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
