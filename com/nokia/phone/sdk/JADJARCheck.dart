import 'package:nokia_sdk/util/jad.dart'; // Путь к вашему будущему JAD.dart

abstract class JADJARCheck {
  static const int pass = 0;
  static const int fail = 1;
  static const int jarSizeInvalid = 2;
  static const int jarTooLarge = 3;
  static const int dataTooLarge = 5;
  static const int missingManifest = 4;

  int check(JAD jad);

  static int performChecks(JAD jad, List<JADJARCheck>? checks) {
    if (checks == null) {
      return pass;
    }

    int result = pass;

    try {
      for (final checkItem in checks) {
        result = checkItem.check(jad);
        if (result != pass) {
          break; // Прерываем цикл при первой ошибке, как в Java (var2 == 0)
        }
      }
      return result;
    } catch (_) {
      return fail;
    }
  }
}
