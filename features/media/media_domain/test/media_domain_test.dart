import 'dart:typed_data';

import 'package:media_domain/media_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Media domain models', () {
    test('instantiates UploadedMedia', () {
      final media = UploadedMedia(
        path: 'brands/test.webp',
        publicUri: Uri.parse(
          'http://localhost:8080/serverpod_cloud_storage?method=file&path=brands/test.webp',
        ),
        mimeType: 'image/webp',
        fileSizeBytes: 1024,
      );

      expect(media.path, 'brands/test.webp');
      expect(media.mimeType, 'image/webp');
      expect(media.fileSizeBytes, 1024);
      expect(media.publicUri.toString(), contains('brands/test.webp'));
    });

    test('instantiates MediaUploadInput', () {
      final input = MediaUploadInput(
        folder: 'brands',
        fileName: 'logo.png',
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );

      expect(input.folder, 'brands');
      expect(input.fileName, 'logo.png');
      expect(input.bytes.length, 4);
    });
  });
}
