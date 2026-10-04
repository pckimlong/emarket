import 'package:domain_primitives/domain_primitives.dart';

import '../models/media_upload_input.dart';
import '../models/uploaded_media.dart';

abstract interface class IMediaRepo {
  Result<UploadedMedia> uploadImage(MediaUploadInput input);
  Result<void> deleteFile(String path);
}
