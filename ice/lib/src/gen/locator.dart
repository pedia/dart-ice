part of ice;

/// This exception is raised if an adapter cannot be found.
class AdapterNotFoundException implements Exception {}

/// This exception is raised if the replica group provided by the
/// server is invalid.
class InvalidReplicaGroupIdException implements Exception {}

/// This exception is raised if a server tries to set endpoints for
/// an adapter that is already active.
class AdapterAlreadyActiveException implements Exception {}

/// This exception is raised if an object cannot be found.
class ObjectNotFoundException implements Exception {}

/// This exception is raised if a server cannot be found.
class ServerNotFoundException implements Exception {}

/// The Ice locator interface. This interface is used by clients to
/// lookup adapters and objects. It is also used by servers to get the
/// locator registry proxy.
///
/// <p class="Note">The {@link Locator} interface is intended to be used by
/// Ice internals and by locator implementations. Regular user code
/// should not attempt to use any functionality of this interface
/// directly.
abstract class Locator {
  /// Find an object by identity and return a proxy that contains
  /// the adapter ID or endpoints which can be used to access the
  /// object.
  /// @param id The identity.
  /// @return The proxy, or null if the object is not active.
  /// @throws ObjectNotFoundException Raised if the object cannot implements
  /// be found.
  Object findObjectById(Identity id);
  // throws ObjectNotFoundException; implements

  /// Find an adapter by id and return a proxy that contains
  /// its endpoints.
  /// @param id The adapter id.
  /// @return The adapter proxy, or null if the adapter is not active.
  /// @throws AdapterNotFoundException Raised if the adapter cannot be implements
  /// found.
  Object findAdapterById(String id);
  // @throws AdapterNotFoundException; implements

  /// Get the locator registry.
  /// @return The locator registry.
  LocatorRegistry getRegistry();
}

/// The Ice locator registry interface. This interface is used by
/// servers to register adapter endpoints with the locator.
///
/// <p class="Note"> The {@link LocatorRegistry} interface is intended to be used
/// by Ice internals and by locator implementations. Regular user
/// code should not attempt to use any functionality of this interface
/// directly.
abstract class LocatorRegistry {
  /// Set the adapter endpoints with the locator registry.
  /// @param id The adapter id.
  /// @param proxy The adapter proxy (a dummy direct proxy created
  /// by the adapter). The direct proxy contains the adapter
  /// endpoints.
  ///
  ///  @throws AdapterNotFoundException Raised if the adapter cannot implements
  /// be found, or if the locator only allows
  /// registered adapters to set their active proxy and the
  /// adapter is not registered with the locator.
  ///
  ///  @throws AdapterAlreadyActiveException Raised if an adapter with the same implements
  /// id is already active.
  void setAdapterDirectProxy(String id, Object proxy);
  //  @throws AdapterNotFoundException, AdapterAlreadyActiveException; implements

  /// Set the adapter endpoints with the locator registry.
  /// @param adapterId The adapter id.
  /// @param replicaGroupId The replica group id.
  /// @param p The adapter proxy (a dummy direct proxy created
  /// by the adapter). The direct proxy contains the adapter
  /// endpoints.
  ///  @throws AdapterNotFoundException Raised if the adapter cannot implements
  /// be found, or if the locator only allows registered adapters to
  /// set their active proxy and the adapter is not registered with
  /// the locator.
  ///
  ///  @throws AdapterAlreadyActiveException Raised if an adapter with the same implements
  /// id is already active.
  ///
  ///  @throws InvalidReplicaGroupIdException Raised if the given implements
  /// replica group doesn't match the one registered with the
  /// locator registry for this object adapter.
  void setReplicatedAdapterDirectProxy(
      String adapterId, String replicaGroupId, Object p);
  //  @throws AdapterNotFoundException, AdapterAlreadyActiveException, InvalidReplicaGroupIdException; implements

  /// Set the process proxy for a server.
  /// @param id The server id.
  /// @param proxy The process proxy.
  ///  @throws ServerNotFoundException Raised if the server cannot implements
  /// be found.
  void setServerProcessProxy(String id, Process proxy);
  //  @throws ServerNotFoundException; implements
}

/// This inferface should be implemented by services implementing the
/// Ice::Locator interface. It should be advertised through an Ice
/// object with the identity `Ice/LocatorFinder'. This allows clients
/// to retrieve the locator proxy with just the endpoint information of
/// the service.
abstract class LocatorFinder {
  /// Get the locator proxy implemented by the process hosting this
  /// finder object. The proxy might point to several replicas.

  /// @return The locator proxy.
  Locator getLocator();
}
