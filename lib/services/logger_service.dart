import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class _FileAndConsoleOutput extends LogOutput {
  final String filePath;
  final ConsoleOutput _console = ConsoleOutput();

  _FileAndConsoleOutput(this.filePath);

  @override
  void output(OutputEvent event) {
    _console.output(event);

    final level = event.level.name.toUpperCase();
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final lines = event.lines.join('\n');
    final entry = '[$timestamp] [$level] $lines\n';

    try {
      File(filePath).writeAsStringSync(entry, mode: FileMode.append);
    } catch (_) {}
  }
}

class AppLogger {
  AppLogger._();

  static Logger? _logger;
  static String _logFilePath = '';

  static String get logFilePath => _logFilePath;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _logFilePath = '${dir.path}/trailblazer_logs.txt';

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: _FileAndConsoleOutput(_logFilePath),
    );
  }

  static Logger get _log {
    assert(_logger != null, 'AppLogger.init() must be called before use');
    return _logger!;
  }

  static void d(String message) => _log.d(message);
  static void i(String message) => _log.i(message);
  static void w(String message) => _log.w(message);
  static void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) =>
      _log.e(message, error: error, stackTrace: stackTrace);
}
