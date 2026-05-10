import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'logger_service.dart';
import 'supabase_service.dart';

/// The Supabase Storage bucket used for quest completion media.
const _kBucket = 'completions';

/// Maximum file size accepted (50 MB).
const _kMaxBytes = 50 * 1024 * 1024;

/// Result returned by [MediaUploadService.pickAndUpload].
class MediaUploadResult {
  /// The public URL of the uploaded file.
  final String publicUrl;

  /// The storage path inside the bucket (useful for deletion later).
  final String storagePath;

  /// Whether the media is a video (false = photo).
  final bool isVideo;

  const MediaUploadResult({
    required this.publicUrl,
    required this.storagePath,
    required this.isVideo,
  });
}

/// Thrown when the user picks a file that exceeds [_kMaxBytes].
class MediaFileTooLargeException implements Exception {
  final int bytes;
  const MediaFileTooLargeException(this.bytes);

  @override
  String toString() =>
      'MediaFileTooLargeException: file is ${(bytes / 1024 / 1024).toStringAsFixed(1)} MB '
      '(max ${_kMaxBytes ~/ 1024 ~/ 1024} MB)';
}

/// Thrown when the user cancels the picker without selecting a file.
class MediaPickCancelledException implements Exception {
  const MediaPickCancelledException();

  @override
  String toString() => 'MediaPickCancelledException: no file selected';
}

class MediaUploadService {
  final _picker = ImagePicker();

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Shows a source-selection dialog (camera vs. gallery), picks a photo,
  /// uploads it, and returns a [MediaUploadResult].
  ///
  /// [userId] and [completionId] are used to build the storage path:
  ///   `completions/{userId}/{completionId}/{filename}`
  ///
  /// Throws [MediaPickCancelledException] if the user cancels.
  /// Throws [MediaFileTooLargeException] if the file exceeds the size limit.
  /// Rethrows Supabase errors for the caller to handle.
  Future<MediaUploadResult> pickAndUpload({
    required String userId,
    required String completionId,
    ImageSource source = ImageSource.gallery,
    bool allowVideo = false,
  }) async {
    XFile? picked;

    if (allowVideo) {
      picked = await _picker.pickMedia(imageQuality: 85);
    } else {
      picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
        maxHeight: 2048,
      );
    }

    if (picked == null) {
      AppLogger.i('MediaUploadService: user cancelled picker');
      throw const MediaPickCancelledException();
    }

    return _upload(
      file: File(picked.path),
      userId: userId,
      completionId: completionId,
    );
  }

  /// Picks a photo and uploads it as an avatar.
  Future<MediaUploadResult> pickAndUploadAvatar({
    required String userId,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) {
      throw const MediaPickCancelledException();
    }

    // Use a special completionId 'avatar' or upload directly
    return _upload(
      file: File(picked.path),
      userId: userId,
      completionId: 'avatar',
    );
  }

  /// Picks a video from the gallery or camera and uploads it.
  Future<MediaUploadResult> pickAndUploadVideo({
    required String userId,
    required String completionId,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picked = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 3),
    );

    if (picked == null) {
      AppLogger.i('MediaUploadService: user cancelled video picker');
      throw const MediaPickCancelledException();
    }

    return _upload(
      file: File(picked.path),
      userId: userId,
      completionId: completionId,
      isVideo: true,
    );
  }

  /// Deletes a previously uploaded file by its [storagePath].
  Future<void> delete(String storagePath) async {
    try {
      await SupabaseService.client.storage.from(_kBucket).remove([storagePath]);
      AppLogger.i('MediaUploadService: deleted $storagePath');
    } catch (e, st) {
      AppLogger.e(
        'MediaUploadService: failed to delete $storagePath',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<MediaUploadResult> _upload({
    required File file,
    required String userId,
    required String completionId,
    bool isVideo = false,
  }) async {
    // Size guard
    final bytes = await file.length();
    if (bytes > _kMaxBytes) {
      throw MediaFileTooLargeException(bytes);
    }

    // Detect MIME type
    final mimeType =
        lookupMimeType(file.path) ?? (isVideo ? 'video/mp4' : 'image/jpeg');
    final ext = _extensionFromMime(mimeType);
    final filename = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final storagePath = '$userId/$completionId/$filename';

    AppLogger.i(
      'MediaUploadService: uploading $storagePath ($mimeType, '
      '${(bytes / 1024).toStringAsFixed(0)} KB)',
    );

    try {
      final Uint8List data = await file.readAsBytes();

      await SupabaseService.client.storage
          .from(_kBucket)
          .uploadBinary(
            storagePath,
            data,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      final publicUrl = SupabaseService.client.storage
          .from(_kBucket)
          .getPublicUrl(storagePath);

      AppLogger.i('MediaUploadService: upload complete → $publicUrl');

      return MediaUploadResult(
        publicUrl: publicUrl,
        storagePath: storagePath,
        isVideo: isVideo,
      );
    } catch (e, st) {
      AppLogger.e(
        'MediaUploadService: upload failed for $storagePath',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  /// Uploads an already picked [File] to storage.
  Future<MediaUploadResult> uploadFile({
    required File file,
    required String userId,
    required String completionId,
    bool isVideo = false,
  }) async {
    return _upload(
      file: file,
      userId: userId,
      completionId: completionId,
      isVideo: isVideo,
    );
  }

  /// Maps common MIME types to file extensions.
  String _extensionFromMime(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/heic':
      case 'image/heif':
        return '.heic';
      case 'video/mp4':
        return '.mp4';
      case 'video/quicktime':
        return '.mov';
      case 'video/x-matroska':
        return '.mkv';
      default:
        return '';
    }
  }
}
