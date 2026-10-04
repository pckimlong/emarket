import 'dart:typed_data';

import 'package:data_utils/data_utils.dart';
import 'package:emarket_client/emarket_client.dart';
import 'package:media_domain/media_domain.dart';

import '../mappers/media_mapper.dart';

class MediaRepoImpl implements IMediaRepo {
  MediaRepoImpl({
    required this._endpoint,
    this._mapper = const MediaMapper(),
  });

  final EndpointAdminMedia _endpoint;
  final MediaMapper _mapper;

  @override
  Result<UploadedMedia> uploadImage(MediaUploadInput input) {
    return failureHandler(() async {
      final byteData = ByteData.sublistView(input.bytes);
      final dto = await _endpoint.uploadImage(
        folder: input.folder,
        fileName: input.fileName,
        byteData: byteData,
      );
      return _mapper.fromDto(dto);
    });
  }

  @override
  Result<void> deleteFile(String path) {
    return failureHandler(() async {
      await _endpoint.deleteFile(path);
    });
  }
}
