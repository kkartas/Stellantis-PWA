import 'dart:developer' as dev;

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger(this._tag);

  final String _tag;

  void d(String msg, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.debug, msg, error, stack);

  void i(String msg, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.info, msg, error, stack);

  void w(String msg, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.warning, msg, error, stack);

  void e(String msg, [Object? error, StackTrace? stack]) =>
      _log(LogLevel.error, msg, error, stack);

  void _log(
    LogLevel level,
    String msg,
    Object? error,
    StackTrace? stack,
  ) {
    final prefix = '[${level.name.toUpperCase()}][$_tag]';
    dev.log('$prefix $msg', error: error, stackTrace: stack, name: _tag);
  }
}
