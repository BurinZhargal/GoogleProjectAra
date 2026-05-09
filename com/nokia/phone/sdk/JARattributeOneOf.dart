import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart'; // Требуется добавить archive в pubspec.yaml

// Вспомогательный класс для разбора манифеста в экосистеме Dart
class DartManifestParser {
  final Map<String, String> _attributes = {};

  DartManifestParser(String manifestContent) {
    // Режем манифест на строки и парсим пары Ключ: Значение
    final lines = const LineSplitter().convert(manifestContent);
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final key = parts South.first.trim();
        final value = parts.sublist(1).join(':').trim();
        _attributes[key] = value;
      }
    }
  }

  String? getAttribute(String key) => _attributes[key];
}

class JARattributeOneOf extends JADJARCheck {
  final String attribute;
  final List<String?> values;

  JARattributeOneOf(this.attribute, this.values);

  @override
  int check(JAD jad) {
    try {
      final jarPath = jad.resolveJAR();
      final bytes = File(jarPath).readAsBytesSync();
      
      // Декодируем zip/jar архив
      final archive = ZipDecoder().decodeBytes(bytes);
      
      // Ищем файл манифеста внутри архива (регистронезависимо)
      ArchiveFile? manifestFile;
      for (var file in archive) {
        if (file.name.toUpperCase() == 'META-INF/MANIFEST.MF') {
          manifestFile = file;
          break;
        }
      }

      if (manifestFile == null) {
        print("WARNING: JAR file is missing manifest file.");
        return 4;
      }

      // Читаем контент манифеста
      final manifestContent = utf8.decode(manifestFile.content as List<int>);
      final parser = DartManifestParser(manifestContent);
      final jarValue = parser.getAttribute(attribute);

      // Проверяем совпадение с допустимым списком значений
      for (var allowedValue in values) {
        if (allowedValue == null && jarValue == null) {
          return 0;
        }
        if (allowedValue != null && jarValue != null && jarValue == allowedValue) {
          return 0;
        }
      }

      print("WARNING: Attribute value for $attribute defined in JAR manifest is not supported.");
      return 1;
    } catch (_) {
      return 1;
    }
  }
}
