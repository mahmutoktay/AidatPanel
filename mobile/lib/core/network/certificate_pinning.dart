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
  static const List<String> _defaultPins = [
    String.fromEnvironment(
      'CERT_PIN_SHA256',
      defaultValue: 'sbmhsbTKB9yczL2ZifgL7++jUOlOINTSG+pcBLX3xmE=',
    ),
    String.fromEnvironment(
      'CERT_PIN_SHA256_BACKUP',
      defaultValue: 'Y9mvm0exBk1JoQ57fRE0cgQiacS71fONvF9f6U=', // placeholder
    )
  ];

  static bool shouldEnable({
    required String baseUrl,
    bool enabled = _defaultEnabled,
    List<String> pinSha256s = _defaultPins,
  }) {
    if (!enabled || kIsWeb) return false;
    final validPins = pinSha256s.map(normalizePin).where((p) => p.isNotEmpty).toList();
    if (validPins.isEmpty) return false;

    final uri = Uri.tryParse(baseUrl);
    if (uri == null) return false;
    
    if (uri.scheme != 'https') {
      if (_isLocalHost(uri.host)) return false;
      throw Exception('Yalnızca HTTPS kabul edilir');
    }
    
    if (_isLocalHost(uri.host)) return false;

    return true;
  }

  static String normalizePin(String pinSha256) {
    return pinSha256.trim().replaceFirst('sha256/', '');
  }

  static bool matchesCertificateSha256(
    X509Certificate certificate,
    List<String> expectedPins,
  ) {
    final digest = sha256.convert(certificate.der).bytes;
    final certPin = base64.encode(digest);
    
    for (final expectedPin in expectedPins) {
      final normalizedExpected = normalizePin(expectedPin);
      if (normalizedExpected.isNotEmpty && certPin == normalizedExpected) {
        return true;
      }
    }
    return false;
  }

  static void configureDio(
    Dio dio, {
    required String baseUrl,
    bool enabled = _defaultEnabled,
    List<String> pinSha256s = _defaultPins,
  }) {
    if (!shouldEnable(
      baseUrl: baseUrl,
      enabled: enabled,
      pinSha256s: pinSha256s,
    )) {
      return;
    }

    final uri = Uri.parse(baseUrl);
    final adapter = dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final context = SecurityContext(withTrustedRoots: false);
      final client = HttpClient(context: context);
      client.badCertificateCallback = (cert, host, _) {
        if (host != uri.host) return false;
        return matchesCertificateSha256(cert, pinSha256s);
      };
      return client;
    };
  }

  static bool _isLocalHost(String host) {
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }
}
