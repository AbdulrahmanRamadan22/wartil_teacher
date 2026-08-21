import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../cache/shared_preferences.dart';
import 'api_constants.dart';

class ApiClient {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 45),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // ── SSL bypass: debug builds only ───────────────────────────
    if (kDebugMode && dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 15);
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    // ── Auth interceptor ─────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['no_auth'] != true) {
            final token = SharedPreferencesService.getToken()?.trim();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (DioException err, handler) async {
          // Retry once on connection errors (transient network issues)
          final isRetry = err.requestOptions.extra['_retried'] == true;
          final isConnError = err.type == DioExceptionType.connectionError ||
              err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.receiveTimeout;
          if (!isRetry && isConnError) {
            err.requestOptions.extra['_retried'] = true;
            try {
              final retryResponse = await dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              // fall through to original error
            }
          }
          handler.next(err);
        },
      ),
    );

    // ── Pretty logger: debug only ────────────────────────────────
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    return dio;
  }
}
