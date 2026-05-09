import 'dart:io';

class GenericEmulator extends Emulator {
  @override
  int run(Map<String, String> var1, List<String> var2) {
    return 0;
  }

  List<String> formEmulatorCommand(InvocationParameters params) {
    final List<String> cmd = [];

    // Извлекаем бинарник (гарантируем fallback, если null)
    cmd.add(params.emulatorBinary ?? 'bin${Platform.pathSeparator}emulator');

    // Отладочный режим и порты
    if (params.debugMode) {
      cmd.addAll(['-debugger', '-port', params.kvmPort.toString()]);
    }

    // Извлекаем сетевой прокси из Record
    if (params.proxy != null) {
      cmd.addAll(['-http_proxy', '${params.proxy!.host}:${params.proxy!.port}']);
    }

    // Лимиты памяти
    if (params.heapSize > 0) {
      cmd.addAll(['-heapsize', params.heapSize.toString()]);
    }

    // Маппинг всех флагов трассировки напрямую из иммутабельного вложенного класса TraceOptions
    final t = params.trace;
    if (t.calls) cmd.add('-tracemethods');
    if (t.networking) cmd.add('-tracenetworking');
    if (t.gcVerbose) cmd.add('-tracegcverbose');
    if (t.exceptions) cmd.add('-traceexceptions');
    if (t.stackChunks) cmd.add('-tracestackchunks');
    if (t.frames) cmd.add('-traceframes');
    if (t.classVerbose) cmd.add('-traceclassloadingverbose');
    if (t.events) cmd.add('-traceevents');
    if (t.allocation) cmd.add('-traceallocation');
    if (t.stackMaps) cmd.add('-tracestackmaps');
    if (t.classLoading) cmd.add('-traceclassloading');
    if (t.all) cmd.add('-traceall');
    if (t.verifier) cmd.add('-traceverifier');
    if (t.monitors) cmd.add('-tracemonitors');
    if (t.gc) cmd.add('-tracegc');
    if (t.callsVerbose) cmd.add('-tracemethodsverbose');
    if (t.threading) cmd.add('-tracethreading');
    if (t.bytecodes) cmd.add('-tracebytecodes');

    // Дополнительные параметры
    if (params.otherParams.isNotEmpty) {
      cmd.addAll(params.otherParams);
    }

    // Сборка classpath
    String cp = params.apiClassPath ?? '';
    if (params.classPath != null && params.classPath!.isNotEmpty) {
      cp += (cp.isEmpty ? '' : Platform.pathSeparator) + params.classPath!;
    }
    if (params.jarFileName != null && params.jarFileName!.isNotEmpty) {
      cp += (cp.isEmpty ? '' : Platform.pathSeparator) + params.jarFileName!;
    }

    if (cp.isNotEmpty) {
      cmd.addAll(['-classpath', cp]);
    }

    // Дескриптор приложения (JAD)
    if (params.jadFileName != null && params.jadFileName!.isNotEmpty) {
      cmd.addAll(['-Xdescriptor', params.jadFileName!]);
    }

    return cmd;
  }
}
