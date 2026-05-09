import 'dart:convert';
import 'io_fallback.dart' if (dart.library.io) 'dart:io';
import 'package:archive/archive.dart';
import 'package:nokia_sdk/util/jad.dart';

class MIDletInfo {
  final int index;
  final String name;
  final String icon;
  final String className;

  const MIDletInfo({
    required this.index,
    required this.name,
    required this.icon,
    required this.className,
  });
}

class MIDletSelector {
  /// Парсит все доступные мидлеты из .jad или .jar манифеста.
  /// Результат передается во Flutter UI для отрисовки кастомного ListView/Dialog.
  List<MIDletInfo> getAvailableMIDlets(String jadPath, String? jarPath) {
    final List<MIDletInfo> midlets = [];
    final jad = JAD(jadPath);
    
    // Ищем записи вида MIDlet-1, MIDlet-2 в JAD-файле
    int i = 1;
    while (true) {
      final value = jad.getAttribute('MIDlet-$i');
      if (value == null) break;
      
      final parsed = _parseMIDletValue(i, value);
      if (parsed != null) midlets.add(parsed);
      i++;
    }

    // Если в JAD ничего не нашли, а JAR передан — парсим его внутренний манифест
    if (midlets.isEmpty && jarPath != null) {
      try {
        final bytes = File(jarPath).readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);
        
        for (final file in archive) {
          if (file.name.toUpperCase() == 'META-INF/MANIFEST.MF') {
            final content = utf8.decode(file.content as List<int>);
            final lines = const LineSplitter().convert(content);
            
            int jarIdx = 1;
            for (final line in lines) {
              if (line.startsWith('MIDlet-')) {
                final parts = line.split(':');
                if (parts.length >= 2 && !parts[0].contains('Jar')) {
                  final parsed = _parseMIDletValue(jarIdx, parts.sublist(1).join(':'));
                  if (parsed != null) {
                    midlets.add(parsed);
                    jarIdx++;
                  }
                }
              }
            }
            break;
          }
        }
      } catch (_) {}
    }

    return midlets;
  }

  /// Парсит стандартную строку J2ME: "Name, /icon.png, com.package.MainClass"
  MIDletInfo? _parseMIDletValue(int index, String value) {
    final parts = value.split(',');
    if (parts.length < 3) return null;
    return MIDletInfo(
      index: index,
      name: parts[0].trim(),
      icon: parts[1].trim(),
      className: parts[2].trim(),
    );
  }
}
