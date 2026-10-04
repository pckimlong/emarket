import 'dart:typed_data';

import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/media/admin_media_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

class _FakeSession implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminMediaEndpoint validation', () {
    late AdminMediaEndpoint endpoint;
    late _FakeSession session;

    setUp(() {
      endpoint = AdminMediaEndpoint();
      session = _FakeSession();
    });

    test('uploadImage rejects invalid folder', () async {
      expect(
        () => endpoint.uploadImage(
          session,
          folder: 'unauthorized_folder',
          fileName: 'logo.png',
          byteData: ByteData(10),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Invalid folder'),
          ),
        ),
      );
    });

    test('uploadImage rejects empty byteData', () async {
      expect(
        () => endpoint.uploadImage(
          session,
          folder: 'brands',
          fileName: 'logo.png',
          byteData: ByteData(0),
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('Uploaded file cannot be empty'),
          ),
        ),
      );
    });

    test('uploadImage rejects files larger than 5 MB', () async {
      final oversizedBytes = ByteData(5 * 1024 * 1024 + 1);
      expect(
        () => endpoint.uploadImage(
          session,
          folder: 'brands',
          fileName: 'large.png',
          byteData: oversizedBytes,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('File size exceeds 5 MB limit'),
          ),
        ),
      );
    });

    test('uploadImage rejects unsupported file extensions', () async {
      for (final ext in ['.exe', '.txt', '.pdf', '.sh']) {
        expect(
          () => endpoint.uploadImage(
            session,
            folder: 'brands',
            fileName: 'file$ext',
            byteData: ByteData(100),
          ),
          throwsA(
            isA<ValidationException>().having(
              (e) => e.message,
              'message',
              contains('Unsupported file extension'),
            ),
          ),
        );
      }
    });

    test('deleteFile rejects paths with directory traversal', () async {
      expect(
        () => endpoint.deleteFile(session, 'brands/../secret.txt'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deleteFile rejects paths with unauthorized folders', () async {
      expect(
        () => endpoint.deleteFile(session, 'secrets/key.png'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('deleteFile rejects malformed paths', () async {
      expect(
        () => endpoint.deleteFile(session, 'justafile.png'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => endpoint.deleteFile(session, 'brands/sub/extra/file.png'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
