part of ice;

class ObjectAdapterFactory {
  final Instance instance;

  /// uuid not in [adapterNamesInUse]
  final Set<String> adapterNamesInUse = <String>{};
  final List<ObjectAdapter> adapters = [];

  State state = State.initialized;

  ObjectAdapterFactory(this.instance);

  final completer = Completer<State>();

  void shutdown() {
    if (isShutdown()) {
      return;
    }

    state = State.deactivating;

    adapters.forEach((o) {
      o.deactivate();
    });

    state = State.deactivated;
    completer.complete(state);
  }

  Future<void> waitForShutdown() async {
    await completer.future;
  }

  bool isShutdown() => state.index >= State.deactivating.index;

  void destory() {
    state = State.destroying;

    adapters.clear();

    state = State.destroyed;
  }

  ObjectAdapter create(String name) {
    late ObjectAdapterI adapter;

    if (name.isEmpty) {
      adapter = ObjectAdapterI(
        instance: instance,
        name: Uuid().v1(),
      );
    } else {
      if (adapterNamesInUse.contains(name)) {
        throw AlreadyRegisteredException();
      }

      adapter = ObjectAdapterI(
        instance: instance,
        name: name,
      );

      adapterNamesInUse.add(name);
    }

    // Must be called outside the synchronization since initialize can make
    // client invocations on the router if it's set.
    // adapter.initialize(router);
    adapter.initialize();

    adapters.add(adapter);
    return adapter;
  }
}
