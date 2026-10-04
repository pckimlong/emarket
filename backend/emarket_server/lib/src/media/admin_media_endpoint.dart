import 'dart:typed_data';

import 'package:emarket_server/src/generated/protocol.dart';
import 'package:emarket_server/src/shared/auth/app_scopes.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';

class AdminMediaEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {AppScopes.staff};

  static const _allowedFolders = {
    'brands',
    'products',
    'categories',
    'banners',
  };
  static const _allowedExtensions = {'.png', '.jpg', '.jpeg', '.webp', '.svg'};
  static const _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

  static const _mimeTypes = {
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.webp': 'image/webp',
    '.svg': 'image/svg+xml',
  };

  Future<UploadResultDto> uploadImage(
    Session session, {
    required String folder,
    required String fileName,
    required ByteData byteData,
  }) async {
    final cleanFolder = folder.trim().toLowerCase();
    if (!_allowedFolders.contains(cleanFolder)) {
      throw ValidationException(
        message:
            'Invalid folder: $folder. Allowed: ${_allowedFolders.join(', ')}',
      );
    }

    if (byteData.lengthInBytes == 0) {
      throw ValidationException(message: 'Uploaded file cannot be empty.');
    }

    if (byteData.lengthInBytes > _maxFileSizeBytes) {
      throw ValidationException(
        message:
            'File size exceeds 5 MB limit (${byteData.lengthInBytes} bytes).',
      );
    }

    final extension = p.extension(fileName).toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw ValidationException(
        message:
            'Unsupported file extension: $extension. Allowed: ${_allowedExtensions.join(', ')}',
      );
    }

    final mimeType = _mimeTypes[extension] ?? 'application/octet-stream';
    final uniqueId = const Uuid().v4();
    final storagePath = '$cleanFolder/$uniqueId$extension';

    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: byteData,
    );

    final publicUrl = await session.storage.publicDownloadUrl(
      storageId: 'public',
      path: storagePath,
    );

    return UploadResultDto(
      path: storagePath,
      url: publicUrl.toString(),
      fileName: fileName,
      mimeType: mimeType,
      fileSizeBytes: byteData.lengthInBytes,
    );
  }

  Future<void> deleteFile(Session session, String path) async {
    final cleanPath = path.trim();
    final parts = cleanPath.split('/');
    if (parts.length != 2 ||
        !_allowedFolders.contains(parts[0]) ||
        parts[1].contains('..')) {
      throw ValidationException(message: 'Invalid storage path: $path');
    }

    await session.storage.deleteFile(
      storageId: 'public',
      path: cleanPath,
    );
  }
}
