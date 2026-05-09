import 'dart:io';

class Preverifier {
  static String? _preverifier;

  static void main(List<String> args) async {
    final instance = Preverifier();
    if (instance._initialize() != 0) {
      exit(1);
    }

    await instance._preverify(args);
  }

  int _initialize() {
    String? binary;
    String? home;

    try {
      // Ищем в переменных окружения (в Dart аналог System.getProperty/getenv)
      binary = Platform.environment['preverifier.binary'];
    } catch (_) {}

    if (binary == null) {
      binary = 'bin${Platform.pathSeparator}preverify';
    }

    try {
      home = Platform.environment['emulator.home'] ?? Platform.environment['kvem.home'];
    } catch (_) {}

    if (home == null) {
      stderr.writeln('System property emulator.home not set.');
      print(_usage());
      _preverifier = null;
      return 1;
    } else {
      _preverifier = '$home${Platform.pathSeparator}$binary';
      return 0;
    }
  }

  Future<void> _preverify(List<String> args) async {
    if (_preverifier == null) return;

    try {
      // В Dart процесс запускается передачей исполняемого файла отдельно от аргументов
      final process = await Process.start(_preverifier!, args);

      // Аналог StreamCopier: перенаправляем потоки процесса напрямую в консоль
      final stdoutFuture = stdout.addStream(process.stdout);
      final stderrFuture = stderr.addStream(process.stderr);

      // Ждем завершения копирования потоков и самого процесса
      await Future.wait([stdoutFuture, stderrFuture]);
      final exitCode = await process.exitCode;

      if (exitCode != 0) {
        exit(exitCode);
      }
    } catch (_) {
      stderr.writeln('Cannot execute $_preverifier');
      print('');
      print(_usage());
      exit(1);
    }
  }

  String _usage() {
    return 'Usage: dart run preverifier.dart [options] classnames|dirnames ...\n\n'
        'where options include:\n'
        "   -classpath <directories separated by ';'>\n"
        '       Directories in which to look for classes\n'
        '   -d <directory> Directory in which output is written (default is ./output/)\n'
        '   @<filename> Read command line arguments from a text file\n';
  }
}
