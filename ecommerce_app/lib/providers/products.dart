import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exceptions.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // to filter and fetch/set only products added by that user (Only for firebase backend). Filtered by the 'creatorId' key which is equal to the logged in 'userId
    // for this to work, you must modify the rules on firebase console
    var url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://my-project-e0439-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          // set the isFavorite to false if it is null or if the value is false otherwise, the value itself favoriteData[prodId]
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
          isMan: prodData['isMan'] ?? false,
          discount: prodData['discount'] == null ? 0.0 : (prodData['discount']),
          category: prodData['category'] ?? '',
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try {
      // adding to server
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
          'isMan': product.isMan,
          'discount': product.discount,
          'category': product.category
        }),
      );
      // adding  locally
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name'],
          isMan: product.isMan,
          discount: product.discount,
          category: product.category);
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isMan': newProduct.isMan,
            'discount': newProduct.discount,
            'category': newProduct.category
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<dynamic> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://my-project-e0439-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
  }

  Future<List<Product>> getProductsFuture() async {
    return _items;
  }
}
