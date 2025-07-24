import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  BackendService(this.baseUrl);

  final String baseUrl;
  String? _token;

  bool get isLoggedIn => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<bool> login(String username, String password) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      _token = data['access_token'] as String?;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      return true;
    }
    return false;
  }

  Future<http.Response> _authorizedRequest(Future<http.Response> Function(Map<String, String> headers) send) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    var resp = await send(headers);
    if (resp.statusCode == 401 && _token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      _token = null;
    }
    return resp;
  }

  Future<List<Entry>> fetchEntries() async {
    final resp = await _authorizedRequest((headers) {
      return http.get(Uri.parse('$baseUrl/entries/'), headers: headers);
    });
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => Entry.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load entries');
  }

  Stream<String> chatStream(String message) async* {
    final resp = await _authorizedRequest((headers) {
      return http.post(Uri.parse('$baseUrl/chat/'), headers: headers, body: jsonEncode({'message': message}));
    });
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final text = data['response'] as String? ?? '';
      for (var i = 1; i <= text.length; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        yield text.substring(0, i);
      }
    } else {
      throw Exception('Chat failed');
    }
  }

  Future<void> purgeCache() async {
    await _authorizedRequest((headers) {
      return http.delete(Uri.parse('$baseUrl/chat/cache'), headers: headers);
    });
  }
}

class Entry {
  Entry({required this.id, required this.content, this.summary});

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
        id: json['id'] as int,
        content: json['content'] as String,
        summary: json['summary'] as String?,
      );

  final int id;
  final String content;
  final String? summary;
}
