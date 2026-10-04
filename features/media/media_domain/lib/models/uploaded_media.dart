import 'package:freezed_annotation/freezed_annotation.dart';

part 'uploaded_media.freezed.dart';

@freezed
abstract class UploadedMedia with _$UploadedMedia {
  const factory UploadedMedia({
    required String path,
    required Uri publicUri,
    required String mimeType,
    required int fileSizeBytes,
  }) = _UploadedMedia;
}
