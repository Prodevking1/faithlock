import 'dart:typed_data';

import 'package:faithlock/config/logger.dart';
import 'package:faithlock/core/mixins/error_handler_mixin.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService extends GetxController
    with AsyncStateHandlerMixin {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadFile(
      String bucketName, Uint8List fileBytes, String fileName) async {
    return await executeWithErrorHandling(() async {
      try {
        final String path = '${_client.auth.currentUser!.id}/$fileName';

        final String response =
            await _client.storage.from(bucketName).uploadBinary(
                  path,
                  fileBytes,
                );

        if (response.isEmpty) {
          throw Exception('File upload failed');
        }

        return _client.storage.from(bucketName).getPublicUrl(path);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<Uint8List?> downloadFile(String bucketName, String filePath) async {
    return await executeWithErrorHandling(() async {
      try {
        return await _client.storage.from(bucketName).download(filePath);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<void> deleteFile(String bucketName, String filePath) async {
    await executeWithErrorHandling(() async {
      try {
        await _client.storage.from(bucketName).remove(<String>[filePath]);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<List<FileObject>?> listFiles(String bucketName, String path) async {
    return await executeWithErrorHandling(() async {
      try {
        return await _client.storage.from(bucketName).list(path: path);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  String getPublicUrl(String bucketName, String filePath) {
    try {
      return _client.storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
      logger.error(e);
      rethrow;
    }
  }
}
