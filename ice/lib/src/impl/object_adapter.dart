part of ice;

class ObjectAdapterI extends ObjectAdapter {
  State state = State.uninitialized;

  final Instance instance;
  final endpointList = <IPEndpoint>[];
  // TODO: List<Acceptor>
  ServerSocket? serverSocket; // accept socket

  /// Incoming connections
  final connections = <ConnectionI>[];

  @override
  final String name;
  late String id;

  ObjectAdapterI({required this.instance, required this.name});

  // ServantManager
  final Map<Identity, FacetMap> servantMap = <Identity, FacetMap>{};

  @override
  Communicator get communicator => instance.communicator;

  void initialize() {
    final properties = instance.initData.properties;
    // Ice.Admin.AdapterId
    id = properties.getProperty('$name.AdapterId');

    // Ice.Admin.ReplicaGroupId
    // Ice.Admin.ProxyOptions, "-t"
    // Ice.Admin.ACM
    // Ice.Admin.MessageSizeMax
    // Ice.Admin.ThreadPool.Size
    // Ice.Admin.ThreadPool.SizeMax
    // Ice.Admin.ThreadPool.ThreadPriority
    // Ice.Admin.Router
    // Ice.Admin.Endpoints => publishedEndpoint
    final s = properties.getProperty('$name.Endpoints');

    s.split(':').forEach((s) {
      final ep = parseEndpoint(instance, s);
      if (ep != null) {
        endpointList.add(ep);
      }
    });

    // Ice.Admin.Locator
    state = State.initialized;
  }

  //
  Future<void> bind() async {
    endpointList.forEach((endpoint) async {
      final doBind = (endpoint) {
        ServerSocket.bind(endpoint.addressList[0], endpoint.port)
            .then((socket) {
          assert(this.serverSocket == null);
          this.serverSocket = socket;
          socket.listen(_onServerData,
              onError: _onServerError, onDone: _onServerDone);
        });
      };

      // resolve
      if (endpoint.addressList.isEmpty) {
        endpoint.resolve().then((x) => doBind(endpoint));
      } else {
        doBind(endpoint);
      }
    });
  }

  void _onServerData(Socket socket) {
    connections.add(TcpConnection.attach(socket, this));
    socket.done.then(onConnectionClosed);
  }

  void _onServerError(ex) {
    print('ServerSocket::onError $ex');
  }

  void _onServerDone() {
    print('ServerSocket::onDone');
    serverSocket = null;
  }

  void onConnectionClosed(dynamic socket) {
    // TODO:
    // connections.remove();
  }

  void activate() {
    state = State.activating;

    if (endpointList.isNotEmpty) {
      bind().then((value) {
        print('ObjectAdapter bind to $endpointList');
        state = State.active;
      });
    }
  }

  void hold() {}
  void waitForHold() {}
  void deactivate() {
    state = State.deactivating;

    if (serverSocket != null) {
      serverSocket!.close();
      serverSocket = null;
    }

    // TODO: wait reply...
    connections.forEach((c) {
      c.close(ConnectionClose.gracefullyWithWait);
    });
    connections.clear();

    state = State.deactivated;
  }

  void waitForDeactivate() {}

  @override
  bool get isDeactivated => state == State.deactivated;

  void destroy() {}

  Object? add(Object servant, Identity id) {
    return addFacet(servant, id, '');
  }

  Object? addFacet(Object servant, Identity id, String facet) {
    FacetMap facetMap = servantMap.putIfAbsent(id, () => FacetMap());

    assert(!facetMap.containsKey(facet));
    facetMap[facet] = servant;
  }

  ObjectPrx? addWithUUID(Object servant) {}

  ObjectPrx? addFacetWithUUID(Object servant, String facet) {}

  void addDefaultServant(Object servant, String category) {}
  // Object remove(Identity id);
  // Object removeFacet(Identity id, String facet);
  // FacetMap removeAllFacets(Identity id);
  // Object removeDefaultServant(String category);
  // Object find(Identity id);
  // Object findFacet(Identity id, String facet);
  // FacetMap findAllFacets(Identity id);
  // Object findByProxy(Object proxy);
  // void addServantLocator(ServantLocator locator, String category) {}
  // ServantLocator removeServantLocator(String category);
  // ServantLocator findServantLocator(String category);
  // Object findDefaultServant(String category);
  // Object createProxy(Identity id);
  // Object createDirectProxy(Identity id);
  // Object createIndirectProxy(Identity id);
  // void setLocator(Locator loc) {}
  // Locator getLocator();
  // EndpointSeq getEndpoints();
  // void refreshPublishedEndpoints() {}
  // EndpointSeq getPublishedEndpoints();
  // void setPublishedEndpoints(EndpointSeq newEndpoints) {}
  // Object getDispatchQueue();
}
