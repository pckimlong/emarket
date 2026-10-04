import 'package:emarket_client/emarket_client.dart';
import 'package:media_domain/media_domain.dart';

class MediaMapper {
  const MediaMapper();

  UploadedMedia fromDto(UploadResultDto dto) {
    return UploadedMedia(
      path: dto.path,
      publicUri: Uri.parse(dto.url),
      mimeType: dto.mimeType,
      fileSizeBytes: dto.fileSizeBytes,
    );
  }
}
