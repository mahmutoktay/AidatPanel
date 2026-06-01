import 'dart:io';

/// Dekont / makbuz yükleme için istemci tarafı doğrulama.
class UploadFileUtils {
  UploadFileUtils._();

  /// Backend ile uyumlu üst sınır (10 MB).
  static const int maxBytes = 10 * 1024 * 1024;

  static const allowedExtensions = {'pdf', 'jpg', 'jpeg', 'png'};

  static const _mimeByExt = <String, String>{
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  static String extensionFromPath(String path) {
    final segments = path.replaceAll('\\', '/').split('/');
    final name = segments.isNotEmpty ? segments.last : path;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static String safeFileName(String path, {String fallback = 'upload.bin'}) {
    final segments = path.replaceAll('\\', '/').split('/');
    final name = segments.isNotEmpty ? segments.last : fallback;
    final sanitized = name.replaceAll(RegExp(r'[^\w.\-]'), '_');
    return sanitized.isEmpty ? fallback : sanitized;
  }

  static String? mimeTypeForExtension(String ext) => _mimeByExt[ext.toLowerCase()];

  /// Geçerliyse `null`, aksi halde hata anahtarı (i18n).
  static String? validateReceiptFile(String path) {
    final ext = extensionFromPath(path);
    if (!allowedExtensions.contains(ext)) {
      return 'invalidExtension';
    }

    final file = File(path);
    if (!file.existsSync()) {
      return 'fileNotFound';
    }

    final length = file.lengthSync();
    if (length <= 0) {
      return 'fileEmpty';
    }
    if (length > maxBytes) {
      return 'fileTooLarge';
    }

    return null;
  }
}
