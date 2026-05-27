import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/services/api_client.dart';

class PesanProvider extends ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Future<void> fetchUnreadCount({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiClient.baseUrl}/pesan/unread-count'),
        headers: ApiClient.headers(token: token),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          _unreadCount = body['count'] ?? 0;
          notifyListeners();
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAllRead({required String token}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/pesan/mark-read'),
        headers: ApiClient.headers(token: token),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          _unreadCount = 0;
          notifyListeners();
        }
      }
    } catch (e) {
      // ignore
    }
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }
  
  void clearUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
