import 'dart:io';

class TraceOptions {
  final bool calls;
  final bool networking;
  final bool gcVerbose;
  final bool exceptions;
  final bool stackChunks;
  final bool frames;
  final bool classVerbose;
  final bool events;
  final bool allocation;
  final bool stackMaps;
  final bool classLoading;
  final bool all;
  final bool verifier;
  final bool monitors;
  final bool gc;
  final bool callsVerbose;
  final bool threading;
  final bool bytecodes;

  const TraceOptions({
    this.calls = false,
    this.networking = false,
    this.gcVerbose = false,
    this.exceptions = false,
    this.stackChunks = false,
    this.frames = false,
    this.classVerbose = false,
    this.events = false,
    this.allocation = false,
    this.stackMaps = false,
    this.classLoading = false,
    this.all = false,
    this.verifier = false,
    this.monitors = false,
    this.gc = false,
    this.callsVerbose = false,
    this.threading = false,
    this.bytecodes = false,
  });

  factory TraceOptions.fromMap(Map<String, String> props) {
    bool check(String key) => props[key]?.toLowerCase() == 'true';
    return TraceOptions(
      calls: check('trace.calls'),
      networking: check('trace.networking'),
      gcVerbose: check('trace.gc.verbose'),
      exceptions: check('trace.exceptions'),
      stackChunks: check('trace.stackchunks'),
      frames: check('trace.frames'),
      classVerbose: check('trace.classloadingverbose'),
      events: check('trace.events'),
      allocation: check('trace.allocation'),
      stackMaps: check('trace.stackmaps'),
      classLoading: check('trace.classloading'),
      all: check('trace.all'),
      verifier: check('trace.verifier'),
      monitors: check('trace.monitors'),
      gc: check('trace.gc'),
      callsVerbose: check('trace.methodsverbose'),
      threading: check('trace.threading'),
      bytecodes: check('trace.bytecodes'),
    );
  }
}

class InvocationParameters {
  final String? emulatorHome;
  final String? emulatorBinary;
  final String? apiClassPath;
  final bool debugMode;
  final bool helpText;
  final bool versionText;
  final int heapSize;
  final ({String host, int port})? proxy;
  final String? classPath;
  final String? jadFileName;
  final String? jarFileName;
  final int kvmPort;
  final int parentPort;
  final List<String> otherParams;
  final Map<String, String> properties;
  final TraceOptions trace;
  final String? propertiesFile;
  final String? emulatorClass;
  final bool launchKDP;
  final int debugPort;

  const InvocationParameters({
    this.emulatorHome,
    this.emulatorBinary,
    this.apiClassPath,
    this.debugMode = false,
    this.helpText = false,
    this.versionText = false,
    this.heapSize = 0,
    this.proxy,
    this.classPath,
    this.jadFileName,
    this.jarFileName = '',
    this.kvmPort = -1,
    this.parentPort = -1,
    this.otherParams = const [],
    this.properties = const {},
    this.trace = const TraceOptions(),
    this.propertiesFile,
    this.emulatorClass,
    this.launchKDP = false,
    this.debugPort = -1,
  });

  InvocationParameters initializeFromWTK103({
    required Map<String, String> wtkProperties, 
    required List<String> commandLineArgs,
  }) {
    final currentDeviceFile = wtkProperties['kvem.device.file'];

    if (currentDeviceFile != null && currentDeviceFile.isNotEmpty) {
      try {
        final file = File(currentDeviceFile);
        final parentPath = file.parent.path;

        if (parentPath.isEmpty || parentPath == '.' || parentPath == '/') {
          stderr.writeln('Emulator: kvem.device.file not properly set.');
          throw const FormatException('Invalid device file path structure');
        }
      } catch (e) {
        stderr.writeln('Emulator: Exception during path verification: $e');
        throw StateError('Initialization aborted due to path error');
      }
    }

    return InvocationParameters(
      properties: Map<String, String>.unmodifiable(wtkProperties),
      propertiesFile: currentDeviceFile,
      otherParams: List<String>.unmodifiable(commandLineArgs),
      trace: TraceOptions.fromMap(wtkProperties),
      emulatorHome: wtkProperties['emulator.home'] ?? Platform.environment['EMULATOR_HOME'],
      emulatorBinary: wtkProperties['emulator.binary'] ?? 'bin${Platform.pathSeparator}emulator',
      apiClassPath: wtkProperties['api.classpath'] ?? '',
      debugMode: wtkProperties['debug.mode']?.toLowerCase() == 'true',
      heapSize: int.tryParse(wtkProperties['heap.size'] ?? '0') ?? 0,
      kvmPort: int.tryParse(wtkProperties['kvm.port'] ?? '-1') ?? -1,
      parentPort: int.tryParse(wtkProperties['parent.port'] ?? '-1') ?? -1,
      proxy: wtkProperties['proxy.host'] != null 
          ? (
              host: wtkProperties['proxy.host']!, 
              port: int.tryParse(wtkProperties['proxy.port'] ?? '80') ?? 80
            )
          : null,
    );
  }
}
