import 'package:faithlock/config/logger.dart';
import 'package:faithlock/core/errors/supabase_error_handler.dart';
import 'package:faithlock/core/mixins/error_handler_mixin.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDbService extends GetxController with AsyncStateHandlerMixin {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getDataById({
    required String table,
    required String id,
  }) async {
    return await executeWithErrorHandling(() async {
      try {
        final PostgrestMap response =
            await _client.from(table).select().eq('id', id).single();
        return response;
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<List<Map<String, dynamic>>?> getAllData({
    required String table,
  }) async {
    return await executeWithErrorHandling(() async {
      try {
        final PostgrestList result = await _client.from(table).select();
        return List<Map<String, dynamic>>.from(result);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<void> insertData({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await executeWithErrorHandling(() async {
      try {
        await _client.from(table).insert(data);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<void> updateData({
    required String table,
    required Map<String, dynamic> data,
    required String id,
  }) async {
    await executeWithErrorHandling(() async {
      try {
        await _client.from(table).update(data).eq('id', id);
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }

  Future<void> deleteData({
    required String table,
    required String id,
  }) async {
    await executeWithErrorHandling(() async {
      try {
        final response = await _client.from(table).delete().eq('id', id);
        if (response.error != null) {
          throw Exception(
              SupabaseErrorHandler.handleException(response.error!));
        }
      } catch (e) {
        logger.error(e);
        rethrow;
      }
    });
  }
}
