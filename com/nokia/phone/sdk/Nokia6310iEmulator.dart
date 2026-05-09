import 'dart:io';

// Расширяем интерфейс InvocationParameters методом getHeapSize
abstract class InvocationParameters6310i extends InvocationParameters {
  int getHeapSize();
}

// Базовый класс для проверок JAR/JAD (заглушка для будущих файлов архива)
abstract class JARJARCheck {}

class JARSizeCheck extends JARJARCheck {
  final int size;
  JARSizeCheck(this.size);
}

class DataSizeCheck extends JARJARCheck {
  final int size;
  DataSizeCheck(this.size);
}

class JADandJARattribute extends JARJARCheck {
  final String attribute;
  final bool required;
  JADandJARattribute(this.attribute, [this.required = true]);
}

class JARattributeOneOf extends JARJARCheck {
  final String attribute;
  final List<String?> options;
  JARattributeOneOf(this.attribute, this.options);
}

class Nokia6310iEmulator extends Emulator {
  final String _versionString = 
      'Profile Spec    : MIDP-1.0\n'
      'Emulator Version: Beta 0.1\n'
      'Configuration   : CLDC-1.0';

  final String _usageString = 
      '\nUsage:\n'
      'dart run emulator.dart [options] -Xdescriptor <file>\n\n'
      'where:\n\n'
      '  -help\n'
      '      Shows emulator help text.\n\n'
      '  -version\n'
      '      Shows emulator version.\n\n'
      '  -http_proxy <host>:<port>\n'
      '      Specifies an HTTP proxy to use for networking.\n\n'
      '  -debugger\n'
      '      Runs the application with debugging enabled.\n\n'
      '  -dbg_port <port>\n'
      '      Specifies the TCP/IP port number to be used between\n'
      '      debugger and debug proxy. By default, the emulator\n'
      '      assigns the first unallocated port starting from 2810.\n\n'
      '  -port <port>\n'
      '      TCP/IP port number between VM and debug proxy.\n'
      '      By default, the emulator assigns the first unallocated\n'
      '      port starting from 2810.\n\n'
      '  -classpath <path>\n'
      '      Specifies the directories and JAR files to be searched\n'
      '      for classes. May include both library and application\n'
      '      class directories and JAR packages.\n\n'
      '  -Xdescriptor <file> | -jad <file>\n'
      '      Specifies the name of the JAD file to use for finding\n'
      '      the JAR to execute. The option must always be supplied.\n'
      '      JAR will be searched for using these rules:\n'
      '      (1) If JAD contains the entry for MIDlet-Jar-URL, and\n'
      '          (1.1) If URL is a relative file URL, look for JAR\n'
      '                using location of JAD file as reference.\n'
      '          (1.2) If URL is an absolute file URL, look for JAR\n'
      '                using the absolute path.\n'
      '      (2) If JAD does not contain the entry for MIDlet-Jar-URL,\n'
      '          search from the classpath.\n\n'
      '  -ontop\n'
      '      Keeps the emulator window always on top.\n\n'
      '  -heapsize <size in bytes>\n'
      '      Specifies the Java heap size for the emulator.\n\n'
      '  Tracing options:\n'
      '  -tracememoryallocation\n  -tracegarbagecollection\n'
      '  -tracegarbagecollectionverbose\n  -traceclassloading\n'
      '  -traceclassloadingverbose\n  -traceverifier\n  -tracestackmaps\n'
      '  -tracebytecodes\n  -tracemethodcalls\n  -tracemethodcallsverbose\n'
      '  -tracestackchunks\n  -traceframes\n  -traceexceptions\n'
      '  -traceevents\n  -tracemonitors\n  -tracethreading\n'
      '  -tracenetworking\n';

  @override
  int run(Map<String, String> var1, List<String> var2) {
    return 0;
  }

  List<String> formEmulatorCommand(InvocationParameters6310i params) {
    List<String> cmd = [];
    
    cmd.add(params.getEmulatorBinary());
    cmd.addAll(['-faceplate', '6310i.faceplate']);
    cmd.addAll(['-parent_port', params.getParentPort().toString()]);

    if (params.getDebugMode()) {
      cmd.addAll(['-debugger', '-port', params.getKvmPort().toString()]);
    }

    if (params.getProxyHost() != null) {
      cmd.addAll(['-http_proxy', '${params.getProxyHost()}:${params.getProxyPort()}']);
    }

    if (params.getHeapSize() > 0) {
      cmd.addAll(['-heapsize', params.getHeapSize().toString()]);
    }

    if (params.getTraceCalls()) cmd.add('-tracemethods');
    if (params.getTraceNetworking()) cmd.add('-tracenetworking');
    if (params.getTraceGcVerbose()) cmd.add('-tracegcverbose');
    if (params.getTraceExceptions()) cmd.add('-traceexceptions');
    if (params.getTraceStackchunks()) cmd.add('-tracestackchunks');
    if (params.getTraceFrames()) cmd.add('-traceframes');
    if (params.getTraceClassVerbose()) cmd.add('-traceclassloadingverbose');
    if (params.getTraceEvents()) cmd.add('-traceevents');
    if (params.getTraceAllocation()) cmd.add('-traceallocation');
    if (params.getTraceStackmaps()) cmd.add('-tracestackmaps');
    if (params.getTraceClass()) cmd.add('-traceclassloading');
    if (params.getTraceAll()) cmd.add('-traceall');
    if (params.getTraceVerifier()) cmd.add('-traceverifier');
    if (params.getTraceMonitors()) cmd.add('-tracemonitors');
    if (params.getTraceGc()) cmd.add('-tracegc');
    if (params.getTraceCallsVerbose()) cmd.add('-tracemethodsverbose');
    if (params.getTraceThreading()) cmd.add('-tracethreading');
    if (params.getTraceBytecodes()) cmd.add('-tracebytecodes');

    if (params.getOtherParams().isNotEmpty) {
      for (var param in params.getOtherParams()) {
        // Фильтруем параметры, исключая ключи свойств (-D) и (-d)
        if (!param.startsWith('-D') && !param.startsWith('-d')) {
          cmd.add(param);
        }
      }
    }

    String classPath = params.getApiClassPath();
    if (params.getClassPath() != null && params.getClassPath()!.isNotEmpty) {
      classPath += Platform.pathSeparator + params.getClassPath()!;
    }

    if (params.getJarFileName() != null && params.getJarFileName()!.isNotEmpty) {
      classPath += Platform.pathSeparator + params.getJarFileName()!;
    }

    if (classPath.isNotEmpty) {
      cmd.addAll(['-classpath', classPath]);
    }

    if (params.getJadFileName() != null) {
      cmd.add(params.getJadFileName()!);
    }

    return cmd;
  }

  List<JARJARCheck> getJARJARChecks() {
    return [
      JARSizeCheck(32200),
      DataSizeCheck(32200),
      JADandJARattribute('MIDlet-Name'),
      JADandJARattribute('MIDlet-Vendor'),
      JADandJARattribute('MIDlet-Version', false),
      JARattributeOneOf('MicroEdition-Profile', [null, 'MIDP-1.0']),
      JARattributeOneOf('MicroEdition-Configuration', [null, 'CLDC-1.0']),
    ];
  }

  void usage() {
    stdout.write(_usageString);
  }

  void version() {
    stdout.write(_versionString);
  }
}
