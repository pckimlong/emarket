import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_domain/media_domain.dart';

import '../services/media_file_picker.dart';
import 'media_upload_state.dart';

class MediaUploadCubit extends Cubit<MediaUploadState> {
  MediaUploadCubit({
    required this.mediaRepo,
    IMediaFilePicker? filePicker,
  }) : _filePicker = filePicker ?? const DefaultMediaFilePicker(),
       super(const MediaUploadState.idle());

  final IMediaRepo mediaRepo;
  final IMediaFilePicker _filePicker;

  Future<void> pickAndUpload({required String folder}) async {
    final input = await _filePicker.pickImage(folder: folder);
    if (input == null) return;
    await uploadInput(input);
  }

  Future<void> uploadInput(MediaUploadInput input) async {
    emit(const MediaUploadState.uploading());
    final result = await mediaRepo.uploadImage(input).run();
    if (isClosed) return;

    result.fold(
      (failure) => emit(MediaUploadState.failure(failure)),
      (media) => emit(MediaUploadState.success(media)),
    );
  }

  void reset() => emit(const MediaUploadState.idle());
}
