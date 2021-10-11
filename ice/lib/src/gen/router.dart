part of ice;

/// The Ice router interface. Routers can be set either globally with
/// {@link Communicator#setDefaultRouter}, or with <code>ice_router</code> on specific
/// proxies.
abstract class Router {
  /// Get the router's client proxy, i.e., the proxy to use for
  /// forwarding requests from the client to the router.
  ///
  /// If a null proxy is returned, the client will forward requests
  /// to the router's endpoints.
  ///
  /// @param hasRoutingTable Indicates whether or not the router supports a routing
  /// table. If it is supported, the Ice runtime will call addProxies to populate the
  /// routing table. This out parameter is only supported starting with Ice 3.7.
  /// The Ice runtime assumes the router has a routing table if the optional is not
  /// set.
  ///
  /// @return The router's client proxy.
  ///
  Object getClientProxy(bool hasRoutingTable); // out optional(1)

  ///
  /// Get the router's server proxy, i.e., the proxy to use for
  /// forwarding requests from the server to the router.
  ///
  /// @return The router's server proxy.
  ///
  Object getServerProxy();

  ///
  /// Add new proxy information to the router's routing table.
  ///
  /// @param proxies The proxies to add.
  ///
  /// @return Proxies discarded by the router.
  ///
  ObjectProxySeq addProxies(ObjectProxySeq proxies);
}

/// This inferface should be implemented by services implementing the
/// Ice::Router interface. It should be advertised through an Ice
/// object with the identity `Ice/RouterFinder'. This allows clients to
/// retrieve the router proxy with just the endpoint information of the
/// service.
abstract class RouterFinder {
  ///
  /// Get the router proxy implemented by the process hosting this
  /// finder object. The proxy might point to several replicas.

  /// @return The router proxy.
  Router getRouter();
}
