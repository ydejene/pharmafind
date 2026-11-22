import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pharmafind/data/datasources/cloudinary_datasource_impl.dart';
import 'package:pharmafind/data/datasources/mock_cloudinary_datasource.dart';

void main() {
  group('MockCloudinaryDataSource', () {
    late MockCloudinaryDataSource dataSource;

    setUp(() {
      dataSource = MockCloudinaryDataSource();
    });

    test('returns upload result with fake URLs and publicId', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = await dataSource.uploadDocument(bytes, 'license.pdf');

      expect(result.secureUrl, contains('license.pdf'));
      expect(result.publicId, contains('license.pdf'));
    });

    test('throws exception when shouldThrow is true', () async {
      dataSource.shouldThrow = true;
      dataSource.errorMessage = 'Custom failure';

      expect(
        () => dataSource.uploadDocument(Uint8List(0), 'file.png'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Custom failure'),
          ),
        ),
      );
    });
  });

  group('CloudinaryDataSourceImpl', () {
    test('successfully uploads and parses response', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          contains('https://api.cloudinary.com/v1_1/'),
        );
        expect(request.url.toString(), contains('/raw/upload'));

        final responseJson = {
          'secure_url': 'https://res.cloudinary.com/test/raw/upload/v1/license.pdf',
          'public_id': 'pharmafind/partner-verification/license_123',
        };

        return http.Response(jsonEncode(responseJson), 200);
      });

      final dataSource = CloudinaryDataSourceImpl(client: mockClient);
      final result = await dataSource.uploadDocument(
        Uint8List.fromList([10, 20]),
        'license.pdf',
      );

      expect(
        result.secureUrl,
        'https://res.cloudinary.com/test/raw/upload/v1/license.pdf',
      );
      expect(
        result.publicId,
        'pharmafind/partner-verification/license_123',
      );
    });

    test('throws when Cloudinary returns error response', () async {
      final mockClient = MockClient((request) async {
        final errorJson = {
          'error': {'message': 'Upload preset not found'},
        };
        return http.Response(jsonEncode(errorJson), 400);
      });

      final dataSource = CloudinaryDataSourceImpl(client: mockClient);

      expect(
        () => dataSource.uploadDocument(Uint8List(0), 'doc.pdf'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Upload preset not found'),
          ),
        ),
      );
    });

    test('throws when Cloudinary returns missing fields', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'other_field': 'value'}), 200);
      });

      final dataSource = CloudinaryDataSourceImpl(client: mockClient);

      expect(
        () => dataSource.uploadDocument(Uint8List(0), 'doc.pdf'),
        throwsA(isA<Exception>()),
      );
    });
  });
}

