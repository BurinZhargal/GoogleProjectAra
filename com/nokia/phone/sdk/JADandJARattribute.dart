import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart'; // Требуется archive в pubspec.yaml
import 'package:nokia_sdk/util/jad.dart';

class JADandJARattribute extends JADJARCheck {
  final String attribute;
  final bool jadMandatory;
  final bool jarMandatory;

  // В Dart три Java-конструктора объединяются в один с параметрами по умолчанию
  JADandJARattribute(
    this.attribute, [
    bool genericMandatory = true,
    bool? specificJarMandatory,
  ])  : jadMandatory = genericMandatory,
        jarMandatory = specificJarMandatory ?? genericMandatory;

  @override
  int check(JAD jad) {
    final jadValue = jad.getAttribute(attribute);
    
    if (jadValue == null) {
      if (jadMandatory) {
        print("WARNING: JAD file doesn't define required attribute $attribute");
        return JADJARCheck.fail; // Возвращаем константу 1
      }

      if (!jarMandatory) {
        return JADJARCheck.pass; // Возвращаем константу 0
      }
    }

    try {
      final jarPath = jad.resolveJAR();
      final bytes = File(jarPath).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      ArchiveFile? manifestFile;
      for (var file in archive) {
        if (file.name.toUpperCase() == 'META-INF/MANIFEST.MF') {
          manifestFile = file;
          break;
        }
      }

      if (manifestFile == null) {
        print("WARNING: JAR file is missing manifest file.");
        return JADJARCheck.missingManifest; // Возвращаем константу 4
      }

      final manifestContent = utf8.decode(manifestFile.content as List<int>);
      // Используем написанный нами на шаге 'JARattributeOneOf' парсер манифеста
      final parser = DartManifestParser(manifestContent);
      final jarValue = parser.getAttribute(attribute);

      if (jarMandatory && jarValue == null) {
        print("WARNING: JAR file doesn't define required attribute $attribute");
        return JADJARCheck.fail;
      } else if (jarValue != null && jadValue != null) {
        if (jadValue == jarValue) {
          return JADJARCheck.pass;
        } else {
          print("WARNING: JAD file and JAR manifest have differing values for attribute $attribute");
          return JADJARCheck.fail;
        }
      } else {
        return JADJARCheck.pass;
      }
    } catch (_) {
      return JADJARCheck.fail;
    }
  }
}
