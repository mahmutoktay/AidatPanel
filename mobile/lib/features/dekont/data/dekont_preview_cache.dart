import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Yüklenen dekont önizlemesini cihazda tutar — sunucu dosyası gecikirse
/// veya uygulama yeniden açıldığında (documents dizini) detayda gösterim.
class DekontPreviewCache {
  DekontPreviewCache._();

  static const _subdir = 'aidat_dekont_preview';

  static Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final root = Directory('${base.path}/$_subdir');
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  static String _safeName(String dekontId) =>
      '${dekontId.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '_')}.bin';

  static Future<void> save(String dekontId, Uint8List bytes) async {
    if (dekontId.isEmpty || bytes.isEmpty) return;
    final file = File('${(await _dir()).path}/${_safeName(dekontId)}');
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<Uint8List?> load(String dekontId) async {
    if (dekontId.isEmpty) return null;
    final file = File('${(await _dir()).path}/${_safeName(dekontId)}');
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    return Uint8List.fromList(bytes);
  }

  static Future<void> clearAll() async {
    final base = await getApplicationDocumentsDirectory();
    final root = Directory('${base.path}/$_subdir');
    if (!await root.exists()) return;
    await for (final entity in root.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }
}
