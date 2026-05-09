import 'dart:io';
// Импортируем целевой класс прокси. 
// Когда вы переведете пакет kdp, путь заменится на относительный или пакетный
import 'package:nokia_sdk/kdp/kvm_debug_proxy.dart' as kdp; 

class KVMDebugProxy {
  static Future<void> main(List<String> args) async {
    // Создаем экземпляр основного прокси-класса из пакета kdp
    final proxy = kdp.KVMDebugProxy();
    
    if (!proxy.parseArgs(args)) {
      proxy.help();
      return;
    }

    final exitCode = proxy.go();
    if (exitCode != 0) {
      exit(exitCode);
    }
  }
}
