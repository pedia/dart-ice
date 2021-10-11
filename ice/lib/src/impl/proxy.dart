part of ice;

const Context noExplicitContext = {};

typedef ObjectCreator = ObjectPrx Function(Reference?);

///
/// Base class of all object proxies.
///
class ObjectPrx {
  final Reference reference;

  ObjectPrx(this.reference);

  String get ice_staticId => '::Ice::Object';

  dynamic ice_invoke(String operation, OperationMode mode,
      [Context? context, WriteParams? writeParams, ReplyHandle? handle]) {
    final o = Outgoing(this, operation, mode, context, writeParams ?? (out) {});

    o.invoke();

    if (this.reference.mode == Mode.modeOneway ||
        this.reference.mode == Mode.modeDatagram ||
        this.reference.mode == Mode.modeBatchDatagram) {
      return;
    }

    return o.handleReply(handle ?? (status, input) {});
  }

  Future<dynamic> ice_invokeAsync(String operation, OperationMode mode,
      [Context? context, WriteParams? writeParams, ReplyHandle? handle]) async {
    final o = Outgoing(this, operation, mode, context, writeParams ?? (out) {});

    await o.invokeAsync();

    return o.handleReply(handle ?? (status, input) {});
  }

  ///
  T? proxyFromStream<T>(InputStream input, ObjectCreator creator) {
    final identity = input.readIndentity();
    final Reference? ref =
        reference.instance.referenceFactory.createFromStream(identity, input);
    return creator(ref) as T;
  }

  void ice_ping([Context? context]) {
    return ice_invoke('ice_ping', OperationMode.nonmutating, context);
  }

  Future<void> ice_pingAsync([Context? context]) async {
    return ice_invokeAsync('ice_ping', OperationMode.nonmutating, context);
  }

  bool ice_isA(String typeId, [Context? context]) {
    checkTwowayOnly('ice_isA', true);
    return ice_invoke('ice_isA', OperationMode.nonmutating, context, (out) {
      out.writeString(typeId);
    }, (status, input) {
      return input.readBool();
    });
  }

  Future<bool> ice_isAAsync(String typeId, [Context? context]) async {
    checkTwowayOnly('ice_isA', false);
    return await ice_invokeAsync(
      'ice_isA',
      OperationMode.nonmutating,
      context,
      (out) {
        out.writeString(typeId);
      },
      (status, input) {
        return input.readBool();
      },
    );
  }

  List<String> ice_ids([Context? context]) {
    checkTwowayOnly('ice_ids', true);
    return ice_invoke('ice_ids', OperationMode.nonmutating, context, (out) {},
        (status, input) {
      return input.readStringList();
    });
  }

  Future<List<String>> ice_idsAsync([Context? context]) async {
    checkTwowayOnly('ice_ids', true);
    return await ice_invokeAsync(
      'ice_ids',
      OperationMode.nonmutating,
      context,
      (out) {},
      (status, input) {
        return input.readStringList();
      },
    );
  }

  Identity get ice_getIdentity => reference.identity;
  ObjectPrx ice_identity(Identity identity) => _apply(
        () => reference.identity == identity,
        () => ObjectPrx(reference.apply(identity: identity)),
      );

  Context get ice_getContext => reference.context;
  ObjectPrx ice_context(Context context) => _apply(
        () => reference.context == context,
        () => ObjectPrx(reference.apply(context: context)),
      );

  String get ice_getFacet => reference.facet;
  ObjectPrx ice_facet(String facet) => _apply(
        () => reference.facet == facet,
        () => ObjectPrx(reference.apply(facet: facet)),
      );

  ObjectPrx ice_twoway() => _apply(
        () => reference.mode == Mode.modeTwoway,
        () => ObjectPrx(reference.apply(mode: Mode.modeTwoway)),
      );

  ObjectPrx ice_oneway() => _apply(
        () => reference.mode == Mode.modeOneway,
        () => ObjectPrx(reference.apply(mode: Mode.modeOneway)),
      );

  ObjectPrx ice_datagram() => _apply(
        () => reference.mode == Mode.modeDatagram,
        () => ObjectPrx(reference.apply(mode: Mode.modeDatagram)),
      );
  // TODO: adapterId, endpoints, secure, preferSecure, router, locator

  ObjectPrx _apply(bool Function() test, ObjectPrx Function() createNew) {
    return test() ? this : createNew();
  }

  bool ice_isTwoway() {
    return reference.mode == Mode.modeTwoway;
  }

  void checkTwowayOnly(String operation, bool sync) {
    if (!ice_isTwoway() && sync) {
      throw TwowayOnlyException();
    }
  }

  Message request(
    String operation,
    int requestId,
    Context? context,
    WriteParams writeParams, {
    OperationMode mode = OperationMode.normal,
    bool sync = true,
  }) =>
      Message(
        header: Header(
          type: MessageType.request,
          protocol: reference.protocol,
          encoding: reference.encoding,
          compress: reference.compress,
        ),
        identity: reference.identity,
        operation: operation,
        operationMode: mode,
        context: context ?? {},
        requestId: requestId,
        writeParams: writeParams,
        sync: sync,
      );

  /// Since dart not support `new T`, pass [ObjectCreator] to create it
  static ObjectPrx? create<T extends ObjectPrx>(
    Reference? reference, [
    ObjectCreator? creator,
  ]) {
    if (reference == null) return null;

    if (creator == null) {
      return ObjectPrx(reference);
    } else {
      return creator(reference) as T;
    }
  }

  static ObjectCreator creator = (ref) => ObjectPrx(ref!);

  // TODO:
  void write(OutputStream output) {}
  static ObjectPrx read(InputStream input) {
    throw Exception();
  }
}

T? checkedCast<T extends ObjectPrx>(ObjectPrx o, ObjectCreator creator,
    [Context? context]) {
  final t = ObjectPrx.create<T>(o.reference, creator) as T;

  if (t.ice_isA(t.ice_staticId, context)) {
    return t;
  }
}

T? uncheckedCast<T extends ObjectPrx>(ObjectPrx o, ObjectCreator creator) {
  return ObjectPrx.create<T>(o.reference, creator) as T;
}
