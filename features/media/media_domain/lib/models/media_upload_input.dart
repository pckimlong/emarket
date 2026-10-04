import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_upload_input.freezed.dart';

@freezed
abstract class MediaUploadInput with _$MediaUploadInput {
  const factory MediaUploadInput({
    required String folder,
    required String fileName,
    required Uint8List bytes,
  }) = _MediaUploadInput;
}
