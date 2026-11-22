import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';
import 'cloudinary_datasource.dart';

class CloudinaryDataSourceImpl implements ICloudinaryDataSource {
  final http.Client _client;

  CloudinaryDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<CloudinaryUploadResult> uploadDocument(
    Uint8List bytes,
    String filename,
  ) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/auto/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..fields['folder'] = AppConfig.cloudinaryUploadFolder
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;
      final publicId = data['public_id'] as String?;

      if (secureUrl == null || publicId == null) {
        throw Exception(
          'Cloudinary upload response missing secure_url or public_id',
        );
      }

      return CloudinaryUploadResult(
        secureUrl: secureUrl,
        publicId: publicId,
      );
    } else {
      String errorMessage = 'Upload failed with status ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        if (errorData['error'] != null &&
            errorData['error']['message'] != null) {
          errorMessage = errorData['error']['message'] as String;
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}

