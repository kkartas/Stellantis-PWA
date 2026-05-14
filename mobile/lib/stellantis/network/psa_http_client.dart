import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/stellantis/auth/token_refresh_interceptor.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';

const _log = AppLogger('PsaHttpClient');

/// Default timeout for all PSA API calls.
const _defaultTimeout = Duration(seconds: 30);

/// Application/JSON content type expected by the PSA Connected Car v4 API.
const _acceptHeader = 'application/hal+json';

final psaHttpClientProvider = Provider<Dio>((ref) {
  final interceptor = ref.watch(tokenRefreshInterceptorProvider);
  return buildPsaHttpClient(interceptor);
});

/// Builds a [Dio] instance configured for the PSA Connected Car v4 API.
///
/// - Base URL: [BrandConstants.apiBaseUrl]
/// - Persistent connection via keep-alive headers
/// - [TokenRefreshInterceptor] attached for auth lifecycle
/// - Structured logging via [AppLogger]
Dio buildPsaHttpClient(TokenRefreshInterceptor tokenInterceptor) {
  final dio = Dio(
    BaseOptions(
      baseUrl: BrandConstants.apiBaseUrl,
      connectTimeout: _defaultTimeout,
      receiveTimeout: _defaultTimeout,
      sendTimeout: _defaultTimeout,
      headers: {
        'Accept': _acceptHeader,
        'Connection': 'keep-alive',
        'User-Agent': 'okhttp/4.8.0',
      },
    ),
  );

  dio.interceptors.addAll([
    tokenInterceptor,
    _LoggingInterceptor(),
  ]);

  return dio;
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log.d('${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e(
      '${err.response?.statusCode ?? "ERR"} ${err.requestOptions.uri}',
      err,
      err.stackTrace,
    );
    handler.next(err);
  }
}
