import 'package:domain_primitives/domain_primitives.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:media_domain/media_domain.dart';

part 'media_upload_state.freezed.dart';

@freezed
sealed class MediaUploadState with _$MediaUploadState {
  const factory MediaUploadState.idle() = _MediaUploadIdle;
  const factory MediaUploadState.uploading({double? progress}) =
      _MediaUploadUploading;
  const factory MediaUploadState.success(UploadedMedia media) =
      _MediaUploadSuccess;
  const factory MediaUploadState.failure(Failure failure) = _MediaUploadFailure;
}
