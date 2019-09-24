import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldStatus = isFavorite;
    _setFavValue(!isFavorite);
    final url =
        'https://flutter-shop-c61cd.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      await Dio().put(
        url,
        data: isFavorite,
      );
    } catch (error) {
      _setFavValue(oldStatus);
      print(error);
      throw error;
    }
  }
}
