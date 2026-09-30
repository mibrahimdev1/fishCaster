import 'dart:convert';
import 'dart:developer';
import 'package:fish_caster/api_services/auth_service/refresh_token_service.dart';
import 'package:fish_caster/bloc/token/token_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fish_caster/bloc/token/token_bloc.dart';
import 'package:fish_caster/bloc/token/token_event.dart';
import 'package:fish_caster/core/string_cons.dart';

class ApiHandler {
  final TokenBloc tokenBloc;
  final BuildContext context;

  ApiHandler({required this.tokenBloc, required this.context});

  Future<http.Response?> makeAuthenticatedRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Object? body,
    bool retry = true,
  }) async {
    String? token = await _getAccessToken();

    final response = await _makeRequest(
      url: url,
      method: method,
      headers: _mergeHeaders(headers, token),
      body: body,
    );

    if (response != null && response.statusCode == 401 && retry) {
      final success = await _attemptTokenRefresh();
      if (success) {
        token = await _getAccessToken(); // new token
        return await makeAuthenticatedRequest(
          url: url,
          method: method,
          headers: headers,
          body: body,
          retry: false,
        );
      } else {
        // Navigate to login
        _redirectToLogin();
        return null;
      }
    }

    return response;
  }

  Future<http.Response?> _makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse(url);

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: body);
      case 'PUT':
        return await http.put(uri, headers: headers, body: body);
      case 'DELETE':
        return await http.delete(uri, headers: headers, body: body);
      default:
        throw UnsupportedError("Unsupported HTTP method: $method");
    }
  }

  Map<String, String> _mergeHeaders(
    Map<String, String>? headers,
    String? token,
  ) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Future<String?> _getAccessToken() async {
    tokenBloc.add(GetTokenEvent());
    await Future.delayed(Duration(milliseconds: 300));
    final state = tokenBloc.state;
    if (state is TokenLoaded) return state.token;
    return null;
  }

  Future<bool> _attemptTokenRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      final newData = await RefreshTokenService.refreshToken(
        refreshToken: refreshToken,
        tokenBloc: tokenBloc,
      );
      return newData != null;
    }
    return false;
  }

  void _redirectToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
