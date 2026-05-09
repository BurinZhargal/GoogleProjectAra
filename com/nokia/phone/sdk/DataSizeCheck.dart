import 'package:nokia_sdk/util/jad.dart';
import 'package:nokia_sdk/jad_jar_check.dart';

class DataSizeCheck extends JADJARCheck {
  final int dataMax;

  DataSizeCheck(this.dataMax);

  @override
  int check(JAD jad) {
    try {
      final dataSizeAttr = jad.getAttribute('MIDlet-Data-Size');
      if (dataSizeAttr == null) {
        return JADJARCheck.pass; // Атрибута нет — проверка пройдена (0)
      }

      final currentDataSize = int.parse(dataSizeAttr);
      if (currentDataSize > dataMax) {
        print("WARNING: Midlet-Data-Size is too large for actual device");
        return JADJARCheck.dataTooLarge; // Ошибка лимита памяти девайса (5)
      }

      return JADJARCheck.pass;
    } on FormatException {
      return JADJARCheck.fail; // Неверный формат числа (1)
    } catch (_) {
      return JADJARCheck.fail; // Любая другая системная ошибка (1)
    }
  }
}
