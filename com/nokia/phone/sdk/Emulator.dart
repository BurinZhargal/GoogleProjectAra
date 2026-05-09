import 'dart:io';
import 'package:nokia_sdk/util/jad.dart';
import 'package:nokia_sdk/jad_jar_check.dart';
import 'package:nokia_sdk/invocation_parameters.dart';

// Импорты ваших классов эмуляторов
import 'package:nokia_sdk/generic_emulator.dart';
import 'package:nokia_sdk/nokia_6310i_emulator.dart';
import 'package:nokia_sdk/nokia_9210_emulator.dart';
import 'package:nokia_sdk/nokia_s60_emulator.dart';

abstract class Emulator {
  /// Реестр фабрик для замены Java-рефлексии (Class.forName).
  /// Позволяет Flutter динамически выбирать нужный инстанс эмулятора по строковому имени.
  static final Map<String, Emulator Function()> _emulatorRegistry = {
    'com.nokia.phone.sdk.GenericEmulator': () => GenericEmulator(),
    'com.nokia.phone.sdk.Nokia6310iEmulator': () => Nokia6310iEmulator(),
    'com.nokia.phone.sdk.Nokia9210Emulator': () => Nokia9210Emulator(),
    'com.nokia.phone.sdk.NokiaS60Emulator': () => NokiaS60Emulator(),
  };

  /// Точка входа для вызова из Flutter. Принимает иммутабельный контекст параметров.
  /// Возвращает код выполнения (0 - успех).
  Future<int> runEmulator(InvocationParameters params) async {
    if (params.versionText) {
      version();
      return 0;
    }
    if (params.helpText) {
      usage();
      return 0;
    }

    // Валидация JAD/JAR
    if (params.jarFileName != null && params.jarFileName!.isNotEmpty) {
      print("JAR file used so perform JAD/JAR checking...");
      final jad = JAD(params.jadFileName);
      final checkResult = JADJARCheck.performChecks(jad, getJARJARChecks());
      
      if (checkResult == JADJARCheck.pass) {
        print("JAD / JAR checks all passed!");
      } else {
        print("JAD / JAR checks failed with code: $checkResult");
        return checkResult;
      }
    } else {
      print("No JAR file used, skipping JAD / JAR checking.");
    }

    try {
      // Формируем список аргументов командной строки
      final cmdArgs = formEmulatorCommand(params);
      print("Emulator configured with arguments: ${cmdArgs.join(' ')}");

      // Сюда Flutter-приложение передаст управление графическому движку или мосту
      final exitCode = await executeEmulatorCore(cmdArgs, params);
      
      await doCleanup();
      return exitCode;
    } catch (e) {
      stderr.writeln("Emulator execution error: $e");
      return -1;
    }
  }

  /// Статический метод инициализации конкретного класса эмулятора (Замена Class.forName)
  static Emulator? instantiateEmulator(String? className) {
    if (className == null) return null;
    final factory = _emulatorRegistry[className];
    return factory != null ? factory() : null;
  }

  /// Чтение конфигурационных .properties файлов девайса
  static Map<String, String>? loadDeviceProperties(String emulatorHomePath) {
    try {
      final homeDir = Directory(emulatorHomePath);
      if (!homeDir.existsSync()) {
        stderr.writeln("Invalid system property emulator.home.");
        return null;
      }

      final deviceName = homeDir.path.split(Platform.pathSeparator).last;
      final propsFile = File('${homeDir.path}${Platform.pathSeparator}$deviceName.properties');

      if (!propsFile.existsSync()) {
        stderr.writeln("Cannot read properties from ${propsFile.path}");
        return null;
      }

      final Map<String, String> props = {};
      final lines = propsFile.readAsLinesSync();
      
      for (var line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          props[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
      return props;
    } catch (e) {
      stderr.writeln("Error loading properties: $e");
      return null;
    }
  }

  // Методы, переопределяемые конкретными девайсами (6310, S60 и т.д.)
  List<String> formEmulatorCommand(InvocationParameters params);
  
  List<JADJARCheck> getJARJARChecks() => [];
  
  void usage() => print("No usage help defined for this device.");
  
  void version() => print("Profile Spec: MIDP-1.0");
  
  Future<void> doCleanup() async {}

  /// Абстрактный хук для связи с нативным кодом / плагином Flutter.
  /// Вместо легаси-запуска внешнего .exe, этот метод может вызывать MethodChannel 
  /// или FFI-функции для отрисовки экрана Nokia прямо внутри виджета Flutter.
  Future<int> executeEmulatorCore(List<String> args, InvocationParameters params) async {
    // Базовое исполнение возвращает успех, переопределяется в UI-слое плагина
    return 0;
  }
}
