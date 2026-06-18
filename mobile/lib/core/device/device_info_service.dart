import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Login/join/refresh isteklerinde sunucuya gönderilecek cihaz meta verisi.
class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  static Future<DeviceMeta> currentDeviceMeta() async {
    try {
      if (kIsWeb) {
        return const DeviceMeta(
          deviceLabel: 'Web tarayıcı',
          platform: 'unknown',
        );
      }
      if (Platform.isAndroid) {
        final info = await _plugin.androidInfo;
        final brand = info.brand.trim();
        final model = info.model.trim();
        final label = [brand, model]
            .where((part) => part.isNotEmpty)
            .join(' ')
            .trim();
        return DeviceMeta(
          deviceLabel: label.isEmpty ? 'Android cihaz' : label,
          platform: 'android',
        );
      }
      if (Platform.isIOS) {
        final info = await _plugin.iosInfo;
        final name = info.name.trim();
        return DeviceMeta(
          deviceLabel: name.isEmpty ? 'iPhone' : name,
          platform: 'ios',
        );
      }
    } catch (_) {
      // Cihaz bilgisi alınamazsa varsayılan etiket kullanılır.
    }
    return const DeviceMeta(
      deviceLabel: 'Bilinmeyen cihaz',
      platform: 'unknown',
    );
  }
}

class DeviceMeta {
  final String deviceLabel;
  final String platform;

  const DeviceMeta({
    required this.deviceLabel,
    required this.platform,
  });

  Map<String, String> toJson() => {
        'deviceLabel': deviceLabel,
        'platform': platform,
      };
}
