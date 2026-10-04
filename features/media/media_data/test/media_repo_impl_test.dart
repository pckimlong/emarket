import 'dart:typed_data';

import 'package:emarket_client/emarket_client.dart';
import 'package:media_data/media_data.dart';
import 'package:media_domain/media_domain.dart';
import 'package:test/test.dart';

class _FakeEndpointAdminMedia implements EndpointAdminMedia {
  UploadResultDto? returnedDto;
  Exception? thrownException;
  String? lastFolder;
  String? lastFileName;
  ByteData? lastByteData;
  String? lastDeletedPath;

  @override
  String get name => 'adminMedia';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UploadResultDto> uploadImage({
    required String folder,
    required String fileName,
    required ByteData byteData,
  }) async {
    lastFolder = folder;
    lastFileName = fileName;
    lastByteData = byteData;
    if (thrownException != null) throw thrownException!;
    return returnedDto!;
  }

  @override
  Future<void> deleteFile(String path) async {
    lastDeletedPath = path;
    if (thrownException != null) throw thrownException!;
  }
}

void main() {
  group('MediaMapper', () {
    test('maps UploadResultDto to UploadedMedia', () {
      final dto = UploadResultDto(
        path: 'brands/test.webp',
        url: 'http://localhost:8080/serverpod_cloud_storage?method=file&path=brands/test.webp',
        fileName: 'logo.png',
        mimeType: 'image/webp',
        fileSizeBytes: 2048,
      );
      const mapper = MediaMapper();
      final media = mapper.fromDto(dto);

      expect(media.path, 'brands/test.webp');
      expect(
        media.publicUri,
        Uri.parse(
          'http://localhost:8080/serverpod_cloud_storage?method=file&path=brands/test.webp',
        ),
      );
      expect(media.mimeType, 'image/webp');
      expect(media.fileSizeBytes, 2048);
    });
  });

  group('MediaRepoImpl', () {
    late _FakeEndpointAdminMedia endpoint;
    late MediaRepoImpl repo;

    setUp(() {
      endpoint = _FakeEndpointAdminMedia();
      repo = MediaRepoImpl(endpoint: endpoint);
    });

    test(
      'uploadImage passes bytes and returns UploadedMedia on success',
      () async {
        endpoint.returnedDto = UploadResultDto(
          path: 'brands/uuid.png',
          url: 'https://cdn.example.com/brands/uuid.png',
          fileName: 'nike.png',
          mimeType: 'image/png',
          fileSizeBytes: 128,
        );

        final input = MediaUploadInput(
          folder: 'brands',
          fileName: 'nike.png',
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        final result = await repo.uploadImage(input).run();

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Expected Right'),
          (media) {
            expect(media.path, 'brands/uuid.png');
            expect(
              media.publicUri,
              Uri.parse('https://cdn.example.com/brands/uuid.png'),
            );
            expect(media.mimeType, 'image/png');
          },
        );
        expect(endpoint.lastFolder, 'brands');
        expect(endpoint.lastFileName, 'nike.png');
        expect(endpoint.lastByteData?.lengthInBytes, 3);
      },
    );

    test('uploadImage captures failures as domain Failure', () async {
      endpoint.thrownException = ValidationException(message: 'File too large');

      final input = MediaUploadInput(
        folder: 'brands',
        fileName: 'large.png',
        bytes: Uint8List.fromList([1]),
      );

      final result = await repo.uploadImage(input).run();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'File too large'),
        (_) => fail('Expected Left'),
      );
    });

    test('deleteFile delegates to endpoint and completes on success', () async {
      final result = await repo.deleteFile('brands/uuid.png').run();

      expect(result.isRight(), isTrue);
      expect(endpoint.lastDeletedPath, 'brands/uuid.png');
    });
  });
}
