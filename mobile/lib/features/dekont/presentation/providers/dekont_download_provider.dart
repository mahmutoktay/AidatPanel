import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'dekont_provider.dart';

final dekontDownloadProvider = Provider((ref) => DekontDownloadService(ref));

class DekontDownloadService {
  final Ref _ref;

  DekontDownloadService(this._ref);

  Future<String> downloadAndSave(
      String dekontId, String mimeType, String fileName) async {
    try {
      final bytes = await _ref
          .read(dekontRepositoryProvider)
          .getDekontFileBytes(dekontId, download: true);

      final isImage = mimeType.startsWith('image/');

      // Dosya adında uzantı yoksa mimeType'tan üret
      var finalName = fileName;
      if (!finalName.contains('.')) {
        final ext = mimeType.split('/').last;
        finalName = '$finalName.$ext';
      }

      if (isImage) {
        await _saveImageToGallery(bytes, finalName);
        return 'Görsel telefonunuzun Galerisine (AidatPanel albümüne) kaydedildi.';
      } else {
        return await _savePdfToDownloads(bytes, finalName);
      }
    } catch (e) {
      throw Exception('Dosya indirilirken bir hata oluştu: $e');
    }
  }

  Future<void> _saveImageToGallery(List<int> bytes, String fileName) async {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw Exception('Galeriye erişim izni reddedildi.');
      }
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Gal.putImage(file.path, album: 'AidatPanel');
  }

  Future<String> _savePdfToDownloads(List<int> bytes, String fileName) async {
    if (Platform.isAndroid) {
      try {
        final dir = Directory('/storage/emulated/0/Download');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        
        var file = File('${dir.path}/$fileName');
        var counter = 1;
        while (file.existsSync()) {
          final nameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
          final ext = fileName.substring(fileName.lastIndexOf('.'));
          file = File('${dir.path}/$nameWithoutExt ($counter)$ext');
          counter++;
        }

        await file.writeAsBytes(bytes);
        return 'Dekont, telefonunuzun İndirilenler (Downloads) klasörüne kaydedildi.';
      } catch (_) {
        await _fallbackShare(bytes, fileName);
        return 'Paylaşım ekranı açıldı, buradan Dosyalara Kaydet diyebilirsiniz.';
      }
    } else {
      await _fallbackShare(bytes, fileName);
      return 'Paylaşım ekranı açıldı, buradan Dosyalara Kaydet diyebilirsiniz.';
    }
  }

  Future<void> _fallbackShare(List<int> bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: fileName,
      ),
    );
  }
}
