import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class CertificatePinning {
  static const bool _defaultEnabled = bool.fromEnvironment(
    'CERT_PINNING',
    defaultValue: true,
  );
  static const String _defaultPin = String.fromEnvironment(
    'CERT_PIN_SHA256',
    defaultValue: '6oLliMekGbThKbWVFlGN+1ay/PKkw62Ej5ROXu1lYcU=',
  );

  static bool shouldEnable({
    required String baseUrl,
    bool enabled = _defaultEnabled,
    String pinSha256 = _defaultPin,
  }) {
    if (!enabled || kIsWeb) return false;
    final pin = normalizePin(pinSha256);
    if (pin.isEmpty) return false;

    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.scheme != 'https') return false;
    if (_isLocalHost(uri.host)) return false;

    return true;
  }

  static String normalizePin(String pinSha256) {
    return pinSha256.trim().replaceFirst('sha256/', '');
  }

  static bool matchesCertificateSha256(
    X509Certificate certificate,
    String expectedPin,
  ) {
    final normalizedExpected = normalizePin(expectedPin);
    if (normalizedExpected.isEmpty) return false;
    final digest = sha256.convert(certificate.der).bytes;
    final certPin = base64.encode(digest);
    return certPin == normalizedExpected;
  }

  static void configureDio(
    Dio dio, {
    required String baseUrl,
    bool enabled = _defaultEnabled,
    String pinSha256 = _defaultPin,
  }) {
    if (!shouldEnable(
      baseUrl: baseUrl,
      enabled: enabled,
      pinSha256: pinSha256,
    )) {
      return;
    }

    final uri = Uri.parse(baseUrl);
    final expectedPin = normalizePin(pinSha256);
    final adapter = dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, _) {
        if (host != uri.host) return false;
        return matchesCertificateSha256(cert, expectedPin);
      };
      return client;
    };
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }
}
