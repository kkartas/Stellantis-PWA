import 'dart:io';

import 'package:args/args.dart';
import 'package:extract_secrets/apk_cache.dart';
import 'package:extract_secrets/secrets_writer.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'cache',
      abbr: 'c',
      help: 'Path to the APK setup cache JSON (default: .psacc_cache/apk_setup_cache.json)',
      defaultsTo: '.psacc_cache/apk_setup_cache.json',
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: 'Path to write the generated secrets.dart',
      defaultsTo: 'mobile/lib/stellantis/brands/secrets.dart',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help message');

  final ArgResults results;
  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}');
    stderr.writeln(parser.usage);
    exit(1);
  }

  if (results['help'] as bool) {
    stdout.writeln('extract_secrets — converts APK setup cache to a Dart secrets file\n');
    stdout.writeln(parser.usage);
    exit(0);
  }

  final cachePath = results['cache'] as String;
  final outputPath = results['output'] as String;

  try {
    final entries = loadCache(cachePath);
    writeSecrets(entries, outputPath);
  } on ArgumentError catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('Format error: $e');
    exit(1);
  } catch (e, stack) {
    stderr.writeln('Unexpected error: $e\n$stack');
    exit(2);
  }
}
