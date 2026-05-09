import 'dart:io';

// Класс-заглушка. Ожидает перевода JAD.dart
abstract class JAD {
  String? getAttribute(String key);
  String resolveJAR();
}

// Базовый класс для проверок
abstract class JADJARCheck {
  int check(JAD jad);
}

class JARSizeCheck extends JADJARCheck {
  final int max;

  JARSizeCheck(this.max);

  @override
  int check(JAD jad) {
    try {
      final sizeAttr = jad.getAttribute('MIDlet-Jar-Size');
      if (sizeAttr == null) return 2;

      final jadJarSize = int.parse(sizeAttr);
      final jarPath = jad.resolveJAR();
      final jarFile = File(jarPath);

      if (!jarFile.existsSync() || jarFile.lengthSync() != jadJarSize) {
        print("WARNING: Jar size defined in JAD file doesn't match actual jar filesize.");
        return 2;
      } else if (jadJarSize > max) {
        print("WARNING: Jar file is too large to run on actual device.");
        return 3;
      } else {
        return 0;
      }
    } on FormatException {
      return 2;
    } catch (_) {
      return 1;
    }
  }
}
