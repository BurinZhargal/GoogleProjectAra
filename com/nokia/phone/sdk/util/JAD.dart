import 'dart:io';

class JAD {
  final String? jadFileName;

  JAD(this.jadFileName);

  /// Получает значение атрибута по ключу из JAD-файла.
  String? getAttribute(String key) {
    if (jadFileName == null) return null;

    try {
      final file = File(jadFileName!);
      if (!file.existsSync()) return null;

      final lines = file.readAsLinesSync();
      final prefix = '$key:';

      for (var line in lines) {
        // Ищем строку, которая начинается строго с нужного атрибута
        if (line.startsWith(prefix)) {
          return line.substring(prefix.length).trim();
        }
      }
    } catch (_) {
      // Игнорируем исключения, сохраняя логику оригинального Java-кода
    }
    return null;
  }

  /// Находит абсолютный путь к JAR-файлу приложения.
  String? resolveJAR() {
    final jarUrl = getAttribute('MIDlet-Jar-URL');
    if (jarUrl == null) return null;

    // Сценарий 1: Проверяем, существует ли JAR по абсолютному/прямому пути
    final directFile = File(jarUrl);
    if (directFile.existsSync()) {
      return directFile.absolute.path;
    }

    // Сценарий 2: Если по прямому пути файла нет, ищем его относительно папки JAD-файла
    if (jadFileName != null) {
      try {
        final jadFile = File(jadFileName!);
        final parentDir = jadFile.parent.path;
        
        final relativeFile = File('$parentDir${Platform.pathSeparator}$jarUrl');
        if (relativeFile.existsSync()) {
          return relativeFile.absolute.path;
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }
}
