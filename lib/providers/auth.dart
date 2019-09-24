import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCfWFQFEirHKTz2fdONUB4cc76tEIBkspU';
    try {
      final dio = Dio()
        ..interceptors.add(PrettyDioLogger(
          compact: false,
          maxWidth: 120,
        ));
      final response = await dio.post(
        url,
        data: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      _token = response.data['idToken'];
      _userId = response.data['localId'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(response.data['expiresIn']),
      ));
      notifyListeners();
    } on DioError catch (error) {
      if (error.type == DioErrorType.RESPONSE) {
        throw HttpException(error.response.data['error']['message']);
      }
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
