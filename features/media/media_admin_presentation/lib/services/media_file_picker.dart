import 'package:image_picker/image_picker.dart';
import 'package:media_domain/media_domain.dart';

abstract interface class IMediaFilePicker {
  Future<MediaUploadInput?> pickImage({required String folder});
}

class DefaultMediaFilePicker implements IMediaFilePicker {
  const DefaultMediaFilePicker({this._picker});

  final ImagePicker? _picker;

  ImagePicker get picker => _picker ?? ImagePicker();

  @override
  Future<MediaUploadInput?> pickImage({required String folder}) async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return MediaUploadInput(
      folder: folder,
      fileName: file.name,
      bytes: bytes,
    );
  }
}
