part of ice;

class CommunicatorI implements Communicator {
  final Instance instance;

  CommunicatorI._(this.instance);

  factory CommunicatorI.create(InitializationData initData) {
    var c = CommunicatorI._(Instance(initData));
    c.instance.communicator = c;

    c.instance.finishSetup();
    return c;
  }

  @override
  void destroy() {
    instance.destroy();
  }

  final completer = Completer<State>();

  @override
  void shutdown() {
    instance.objectAdapterFactory.shutdown();

    instance.referenceFactory.destory();
    completer.complete(State.deactivated);
  }

  @override
  Future<void> waitForShutdown() async {
    await completer.future;
  }

  @override
  bool isShutdown() {
    return instance.objectAdapterFactory.isShutdown();
  }

  @override
  ObjectPrx? stringToProxy(String s) {
    return instance.stringToProxy(s);
  }

  @override
  String proxyToString(ObjectPrx obj) {
    return '';
  }

  @override
  ObjectPrx? propertyToProxy(String prefix) {
    return instance.propertyToProxy(prefix);
  }

  @override
  PropertyDict proxyToProperty(Object proxy, String property) {
    return PropertyDict();
  }

  @override
  Identity stringToIdentity(String str) {
    return Identity(name: '', category: '');
  }

  @override
  String identityToString(Identity ident) {
    return '';
  }

  @override
  ObjectAdapter createObjectAdapter(String name) {
    return instance.objectAdapterFactory.create(name);
  }

  // ObjectAdapter createObjectAdapterWithEndpoints(
  //     String name, String endpoints) {}

  // ObjectAdapter createObjectAdapterWithRouter(String name, Router rtr) {}

  // TODO: void addObjectFactory(ObjectFactory factory, String id) {}

  // TODO: ObjectFactory findObjectFactory(String id) {}

  // ImplicitContext getImplicitContext() {}

  @override
  Properties getProperties() {
    return instance.initData.properties;
  }

  // Logger getLogger() {}

  // // TODO: Instrumentation::CommunicatorObserver getObserver() {}

  // Router getDefaultRouter() {}

  // void setDefaultRouter(Router rtr) {}

  // Locator getDefaultLocator() {}

  // void setDefaultLocator(Locator loc) {}

  // // TODO: PluginManager getPluginManager() {}

  // // TODO:ValueFactoryManager getValueFactoryManager() {}

  // void flushBatchRequests(CompressBatch compress) {}

  // Object createAdmin(ObjectAdapter adminAdapter, Identity adminId) {}

  // void addAdminFacet(Object servant, String facet) {}

  // Object removeAdminFacet(String facet) {}

  // Object findAdminFacet(String facet) {}

  // FacetMap findAllAdminFacets() {}

  // Object getClientDispatchQueue() {}

  // Object getServerDispatchQueue() {}
}
