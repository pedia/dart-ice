part of ice;

abstract class Request {
  Current getCurrent();
}

/// The base class for servants.
abstract class Object {
  static const _object_ids = ['::Ice::Object'];

  void ice_ping([Current? current]) {} // Nothing to do.
  bool ice_isA(String s, [Current? current]) => _object_ids.contains(s);
  List<String> ice_ids([Current? current]) => _object_ids;
  String ice_id([Current? current]) => _object_ids[0];
  static String ice_staticId() => _object_ids[0];

  bool iceDispatch(Incoming incoming, Current current) {
    switch (current.operation) {
      case 'ice_id':
        return iceD_ice_id(incoming, current);
      case 'ice_ids':
        return iceD_ice_ids(incoming, current);
      case 'ice_isA':
        return iceD_ice_isA(incoming, current);
      case 'ice_ping':
        return iceD_ice_ping(incoming, current);
      default:
        throw OperationNotExistException(
            current.id, current.facet, current.operation);
    }
    return false;
  }

  bool iceD_ice_isA(Incoming incoming, Current current) {
    final typeId = incoming.stream.readString();

    bool res = ice_isA(typeId, current);

    incoming.createReply((output) {
      output.writeBool(res);
    });
    return true;
  }

  bool iceD_ice_id(Incoming incoming, Current current) {
    String id = ice_id(current);

    incoming.createReply((output) {
      output.writeString(id);
    });
    return true;
  }

  bool iceD_ice_ids(Incoming incoming, Current current) {
    List<String> ids = ice_ids(current);

    incoming.createReply((output) {
      output.writeStringList(ids);
    });
    return true;
  }

  bool iceD_ice_ping(Incoming incoming, Current current) {
    ice_ping(current);

    incoming.createReply((output) {});
    return true;
  }

  // iceWrite(OutputStream output);
  // iceRead(InputStream input);
}
