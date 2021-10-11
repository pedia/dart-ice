part of ice;

class PluginManagerI extends PluginManager {
  @override
  void initializePlugins() {
    assert(!_initialized);

    plugins.forEach((name, plugin) {
      // TODO: catch exception and call destory ...
      plugin.initialize();
    });

    _initialized = true;
  }

  @override
  StringSeq getPlugins() => List.from(plugins.keys);

  @override
  Plugin? getPlugin(String name) => plugins[name];

  @override
  void addPlugin(String name, Plugin pi) {}

  @override
  void destroy() {
    plugins.forEach((name, plugin) => plugin.destroy());
  }

  static void registerPluginFactory(
      String name, PluginFacotry factory, bool loadOnInit) {}

  static final plugins = <String, Plugin>{};
  bool _initialized = false;
}
