import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Address of the Spring Boot server.
/// Override at run time: flutter run --dart-define=API_URL=http://192.168.1.10:8080
String get apiBaseUrl {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (kIsWeb) return 'http://localhost:8080';
  // The Android emulator reaches the host machine at 10.0.2.2
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080';
  }
  return 'http://localhost:8080';
}

/// The only place in the app that talks to the server.
class ShopRepository {
  ShopRepository({required SharedPreferences prefs, http.Client? client})
      : _prefs = prefs,
        _client = client ?? http.Client();

  static const _tokenKey = 'token';
  static const _nameKey = 'name';
  static const _emailKey = 'email';

  final SharedPreferences _prefs;
  final http.Client _client;

  // ---------- auth ----------

  Future<UserSession> login(String email, String password) async {
    final json = await _send(
      'POST',
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    return _saveSession(json as Map<String, dynamic>);
  }

  Future<UserSession> register(String name, String email, String password) async {
    final json = await _send(
      'POST',
      '/api/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    return _saveSession(json as Map<String, dynamic>);
  }

  UserSession? restoreSession() {
    final token = _prefs.getString(_tokenKey);
    if (token == null) return null;
    return UserSession(
      token: token,
      name: _prefs.getString(_nameKey) ?? '',
      email: _prefs.getString(_emailKey) ?? '',
    );
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_nameKey);
    await _prefs.remove(_emailKey);
  }

  Future<UserSession> _saveSession(Map<String, dynamic> json) async {
    final session = UserSession(
      token: json['token'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
    await _prefs.setString(_tokenKey, session.token);
    await _prefs.setString(_nameKey, session.name);
    await _prefs.setString(_emailKey, session.email);
    return session;
  }

  // ---------- shop ----------

  Future<List<Product>> fetchProducts() async {
    final json = await _send('GET', '/api/products');
    return (json as List<dynamic>)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Order> checkout(List<CartItem> items, String address) async {
    final json = await _send(
      'POST',
      '/api/orders',
      auth: true,
      body: {
        'address': address,
        'items': [
          for (final i in items) {'productId': i.product.id, 'quantity': i.quantity},
        ],
      },
    );
    return Order.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Order>> fetchOrders() async {
    final json = await _send('GET', '/api/orders', auth: true);
    return (json as List<dynamic>)
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- http ----------

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    final request = http.Request(method, Uri.parse('$apiBaseUrl$path'));
    request.headers['Content-Type'] = 'application/json; charset=utf-8';
    request.headers['Accept'] = 'application/json';
    if (auth) {
      final token = _prefs.getString(_tokenKey);
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) request.body = jsonEncode(body);

    http.Response response;
    try {
      final streamed = await _client.send(request).timeout(const Duration(seconds: 15));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException('Сервер не отвечает. Проверьте, что бэкенд запущен.');
    } catch (_) {
      throw const ApiException('Не удалось подключиться к серверу.');
    }

    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    if (response.statusCode == 401 && auth) {
      await logout();
      throw const ApiException('Сессия истекла. Войдите снова.');
    }
    throw ApiException(_errorMessage(text, response.statusCode));
  }

  String _errorMessage(String text, int status) {
    try {
      final json = jsonDecode(text);
      if (json is Map<String, dynamic> && json['message'] is String) {
        final msg = json['message'] as String;
        if (msg.isNotEmpty) return msg;
      }
    } catch (_) {
      // body is not JSON
    }
    return 'Ошибка сервера ($status)';
  }
}
