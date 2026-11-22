import 'dart:typed_data';

import 'cloudinary_datasource.dart';

class MockCloudinaryDataSource implements ICloudinaryDataSource {
  bool shouldThrow = false;
  String errorMessage = 'Mock upload failed';

  @override
  Future<CloudinaryUploadResult> uploadDocument(
    Uint8List bytes,
    String filename,
  ) async {
    if (shouldThrow) {
      throw Exception(errorMessage);
    }
    return CloudinaryUploadResult(
      secureUrl: 'https://res.cloudinary.com/mock/$filename',
      publicId: 'mock-public-id-$filename',
    );
  }
}

