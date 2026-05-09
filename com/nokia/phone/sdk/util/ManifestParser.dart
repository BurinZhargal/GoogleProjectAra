import 'dart:convert';

class ManifestParser {
  final Map<String, String> _attributes = {};

  /// Конструктор принимает сырое текстовое содержимое файла манифеста
  ManifestParser(String manifestContent) {
    try {
      // Разбиваем текст манифеста на строки, учитывая любые разделители (\n или \r\n)
      final lines = const LineSplitter().convert(manifestContent);
      
      for (final line in lines) {
        if (line.contains(':')) {
          final index = line.indexOf(':');
          final key = line.substring(0, index).trim();
          final value = line.substring(index + 1).trim();
          
          if (key.isNotEmpty) {
            _attributes[key] = value;
          }
        }
      }
    } catch (e) {
      print("ManifestParser: exception during parsing: $e");
    }
  }

  /// Возвращает значение атрибута по его имени
  String? getAttribute(String attributeName) {
    return _attributes[attributeName];
  }
}
