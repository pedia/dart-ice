part of ice;

abstract class Plugin {
  void initialize();
  void destroy();
}

abstract class PluginManager {
  void initializePlugins();
  StringSeq getPlugins();
  Plugin? getPlugin(String name);
  void addPlugin(String name, Plugin pi);
  void destroy();
}
