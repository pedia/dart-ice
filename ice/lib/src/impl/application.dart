part of ice;

abstract class Application {
  Communicator? get communicator => _communicator;
  String get appName => _appName!;

  int run(List<String> args);

  int main({
    List<String>? args,
    InitializationData? initData,
    StringSeq? seq,
    String? configFile,
    int version = iceIntVersion,
  }) {
    _appName = '';

    if (args != null && args.isNotEmpty) {
      _appName = args[0];
    }

    // TODO: set logger
    initData ??= InitializationData(
      properties: createProperties(args, initData?.properties),
    );

    if (configFile != null) {
      // TODO: try-catch
      initData.properties.load(configFile);
    }

    _appName = initData.properties
        .getPropertyWithDefault('Ice.ProgramName', _appName!);

    return _doMain(args ?? [], initData, version);
  }

  int _doMain(List<String> args, InitializationData initData, int version) {
    _communicator = initialize(
      args: args,
      initData: initData,
      version: version,
    );

    // TODO: try-catch
    final status = run(args);

    _communicator?.destroy();
    return status;
  }

  String? _appName;
  Communicator? _communicator;
}
