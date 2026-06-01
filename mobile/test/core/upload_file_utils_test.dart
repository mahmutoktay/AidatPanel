import 'dart:io';

import 'package:aidatpanel/core/utils/upload_file_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadFileUtils', () {
    test('extensionFromPath', () {
      expect(UploadFileUtils.extensionFromPath(r'C:\foo\bar.PDF'), 'pdf');
      expect(UploadFileUtils.extensionFromPath('/tmp/a.jpeg'), 'jpeg');
    });

    test('safeFileName strips unsafe chars', () {
      expect(
        UploadFileUtils.safeFileName(r'..\evil\dekont (1).pdf'),
        'dekont__1_.pdf',
      );
    });

    test('validateReceiptFile rejects unknown extension', () {
      final dir = Directory.systemTemp.createTempSync('aidat_upload_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/note.txt')..writeAsStringSync('x');
      expect(UploadFileUtils.validateReceiptFile(file.path), 'invalidExtension');
    });

    test('validateReceiptFile accepts small pdf', () {
      final dir = Directory.systemTemp.createTempSync('aidat_upload_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/dekont.pdf')..writeAsBytesSync([1, 2, 3]);
      expect(UploadFileUtils.validateReceiptFile(file.path), isNull);
    });
  });
}
