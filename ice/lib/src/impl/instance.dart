part of ice;

class Instance {
  State _state = State.uninitialized;

  final InitializationData initData;

  late Communicator communicator;
  late ObjectAdapterFactory objectAdapterFactory;
  late ReferenceFactory referenceFactory;
  ObjectAdapter? adminAdapter;
  EndpointFactory endpointFactory = EndpointFactory();

  Instance(this.initData) {
    objectAdapterFactory = ObjectAdapterFactory(this);
    referenceFactory = ReferenceFactory(this);
  }

  bool get isDestroyed => _state == State.destroyed;

  void destroy() {
    _state = State.destroying;

    objectAdapterFactory.destory();
    referenceFactory.destory();

    _state = State.destroyed;
  }

  ObjectPrx? stringToProxy(String s) {
    final ref = referenceFactory.create(s, '');
    return ObjectPrx.create(ref);
  }

  // Well-Known Objects
  //   Object1:tcp -p 10001
  //   Object2@TheAdapter
  //   Object3

  // Indirect Proxy
  //   category/test@adapter:tcp
  ObjectPrx? propertyToProxy(String prefix) {
    // Hello.Proxy=hello:tcp -p 10000:udp -p 10000:ssl -p 10001
    // -----------
    //   prefix
    String proxy = initData.properties.getProperty(prefix);

    if (proxy.isEmpty) return null;

    final ref = referenceFactory.create(proxy, prefix);

    return ObjectPrx.create(ref);
  }

  void finishSetup() {
    _state = State.activating;
    // plugins ...
    // Initialize the endpoint factories
    // Create Admin facets, if enabled.

    // thread pool
    // print process id

    // plugin init
    // admin
    //  adapter admin@Ice.Admin

    // Ice.Admin.InstanceName/admin
    // server/admin

    final adminIdentity = Identity(
        name: 'admin',
        category: initData.properties.getProperty('Ice.Admin.InstanceName'));

    // adminFacets: Logger->, Metrics->
    // _adminAdapter->addFacet(p->second, _adminIdentity, p->first);
    //                         0,         server/admin,   'Logger'

    // ServantManager::addServant(const ObjectPtr& object, const Identity& ident, const string& facet)

    // ObjectAdapterI::newProxy(const Identity& ident, const string& facet)
    //                                server/admin,              'Logger'

    // _instance->referenceFactory()->create(ident, facet, _reference, _publishedEndpoints);
    // ReferenceFactory::create('server/admin', 'Logger', )

    // _servantManager->addServant(object, ident, facet);

    String ep = initData.properties.getProperty('Ice.Admin.Endpoints');
    if (ep.isNotEmpty) {
      final adminAdapter = objectAdapterFactory.create('Ice.Admin');

      // Properties
      adminAdapter.addFacet(initData.properties, adminIdentity, 'Properties');

      // Metrics
      adminAdapter.addFacet(
          MetricsAdminI(initData.properties), adminIdentity, 'Metrics');

      // TODO: Logger, Process

      adminAdapter.activate();

      this.adminAdapter = adminAdapter;
    }

    _state = State.active;
  }

  int messageSizeMax = 1024;

  String get defaultHost => initData.properties.getProperty('Ice.Default.Host');
}
