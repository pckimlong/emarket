import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_admin_presentation/media_admin_presentation.dart';
import 'package:media_domain/media_domain.dart';

class _FakeMediaRepo implements IMediaRepo {
  UploadedMedia? returnedMedia;
  Failure? returnedFailure;

  @override
  Result<UploadedMedia> uploadImage(MediaUploadInput input) {
    if (returnedFailure != null) {
      return TaskEither.left(returnedFailure!);
    }
    return TaskEither.right(returnedMedia!);
  }

  @override
  Result<void> deleteFile(String path) => TaskEither.right(null);
}

class _FakeMediaFilePicker implements IMediaFilePicker {
  MediaUploadInput? returnedInput;

  @override
  Future<MediaUploadInput?> pickImage({required String folder}) async {
    return returnedInput;
  }
}

void main() {
  group('MediaUploadCubit', () {
    late _FakeMediaRepo repo;
    late _FakeMediaFilePicker picker;

    final testMedia = UploadedMedia(
      path: 'brands/uuid.png',
      publicUri: Uri.parse('https://example.com/brands/uuid.png'),
      mimeType: 'image/png',
      fileSizeBytes: 256,
    );

    final testInput = MediaUploadInput(
      folder: 'brands',
      fileName: 'nike.png',
      bytes: Uint8List.fromList([1, 2, 3]),
    );

    setUp(() {
      repo = _FakeMediaRepo()..returnedMedia = testMedia;
      picker = _FakeMediaFilePicker()..returnedInput = testInput;
    });

    test('initial state is idle', () {
      final cubit = MediaUploadCubit(mediaRepo: repo, filePicker: picker);
      expect(cubit.state, const MediaUploadState.idle());
      cubit.close();
    });

    blocTest<MediaUploadCubit, MediaUploadState>(
      'emits [uploading, success] when upload succeeds',
      build: () => MediaUploadCubit(mediaRepo: repo, filePicker: picker),
      act: (cubit) => cubit.uploadInput(testInput),
      expect: () => [
        const MediaUploadState.uploading(),
        MediaUploadState.success(testMedia),
      ],
    );

    blocTest<MediaUploadCubit, MediaUploadState>(
      'emits [uploading, failure] when upload fails',
      setUp: () {
        repo.returnedFailure = Failure(
          error: 'Network error',
          stackTrace: StackTrace.empty,
          message: 'Upload failed',
        );
      },
      build: () => MediaUploadCubit(mediaRepo: repo, filePicker: picker),
      act: (cubit) => cubit.uploadInput(testInput),
      expect: () => [
        const MediaUploadState.uploading(),
        isA<MediaUploadState>().having(
          (s) => s.maybeWhen(failure: (f) => f.message, orElse: () => null),
          'failure.message',
          'Upload failed',
        ),
      ],
    );

    blocTest<MediaUploadCubit, MediaUploadState>(
      'pickAndUpload does nothing if user cancels file picking',
      setUp: () {
        picker.returnedInput = null;
      },
      build: () => MediaUploadCubit(mediaRepo: repo, filePicker: picker),
      act: (cubit) => cubit.pickAndUpload(folder: 'brands'),
      expect: () => [],
    );

    blocTest<MediaUploadCubit, MediaUploadState>(
      'reset returns state to idle',
      build: () => MediaUploadCubit(mediaRepo: repo, filePicker: picker),
      seed: () => MediaUploadState.success(testMedia),
      act: (cubit) => cubit.reset(),
      expect: () => [const MediaUploadState.idle()],
    );
  });
}
