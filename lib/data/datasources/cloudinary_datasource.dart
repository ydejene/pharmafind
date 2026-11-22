import 'dart:typed_data';

/// Result returned from a successful Cloudinary upload.
class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });
}

/// Abstract contract for uploading partner verification documents to Cloudinary.
abstract class ICloudinaryDataSource {
  /// Uploads document [bytes] with [filename] and returns the resulting [CloudinaryUploadResult].
  Future<CloudinaryUploadResult> uploadDocument(
    Uint8List bytes,
    String filename,
  );
}

