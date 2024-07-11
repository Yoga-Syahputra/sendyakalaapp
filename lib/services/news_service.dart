import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService extends ChangeNotifier {
  List _articles = [];

  List get articles => _articles;

  Future<void> fetchNews() async {
    final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=us&category=health&apiKey=YOUR API KEY'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _articles = data['articles'] ?? [];
      notifyListeners();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
