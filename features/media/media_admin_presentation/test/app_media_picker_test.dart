import 'dart:typed_data';

import 'package:admin_ui_kit/admin_ui_kit.dart';
import 'package:domain_primitives/domain_primitives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_admin_presentation/media_admin_presentation.dart';
import 'package:media_domain/media_domain.dart';

class _FakeMediaRepo implements IMediaRepo {
  UploadedMedia? returnedMedia;

  @override
  Result<UploadedMedia> uploadImage(MediaUploadInput input) {
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
  group('AppMediaPicker Widget', () {
    late _FakeMediaRepo repo;
    late _FakeMediaFilePicker picker;

    final testMedia = UploadedMedia(
      path: 'brands/nike.png',
      publicUri: Uri.parse('https://example.com/brands/nike.png'),
      mimeType: 'image/png',
      fileSizeBytes: 1024,
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

    Widget createWidget({
      Uri? initialPreviewUri,
      ValueChanged<UploadedMedia?>? onMediaChanged,
    }) {
      return MaterialApp(
        builder: (context, child) => FTheme(
          data: getAdminLightTheme(),
          child: child!,
        ),
        home: Scaffold(
          body: RepositoryProvider<IMediaRepo>.value(
            value: repo,
            child: AppMediaPicker(
              folder: 'brands',
              initialPreviewUri: initialPreviewUri,
              onMediaChanged: onMediaChanged,
              filePicker: picker,
            ),
          ),
        ),
      );
    }

    testWidgets('renders upload button when initialPreviewUri is null', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Upload image'), findsOneWidget);
      expect(find.text('PNG, WEBP, JPG'), findsOneWidget);
    });

    testWidgets(
      'renders preview with Change and Remove buttons when initial preview provided',
      (tester) async {
        await tester.pumpWidget(
          createWidget(initialPreviewUri: testMedia.publicUri),
        );
        await tester.pumpAndSettle();

        expect(find.text('Change'), findsOneWidget);
        expect(find.text('Remove'), findsOneWidget);
        expect(find.text('Upload image'), findsNothing);
      },
    );

    testWidgets(
      'tapping Remove clears the image and notifies onMediaChanged(null)',
      (tester) async {
        UploadedMedia? changedMedia = testMedia;

        await tester.pumpWidget(
          createWidget(
            initialPreviewUri: testMedia.publicUri,
            onMediaChanged: (media) => changedMedia = media,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Remove'));
        await tester.pumpAndSettle();

        expect(changedMedia, isNull);
        expect(find.text('Upload image'), findsOneWidget);
      },
    );

    testWidgets('tapping upload triggers pick and emits uploaded media', (
      tester,
    ) async {
      UploadedMedia? changedMedia;

      await tester.pumpWidget(
        createWidget(
          onMediaChanged: (media) => changedMedia = media,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload image'));
      await tester.pumpAndSettle();

      expect(changedMedia, equals(testMedia));
      expect(find.text('Change'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });
  });
}
