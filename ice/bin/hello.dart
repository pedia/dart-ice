import '../lib/ice.dart' as ice;

import '../test/example.dart';

abstract class Hello extends ice.Object {
  static const _ids = ['::Demo::Hello', '::Ice::Object'];

  @override
  bool ice_isA(String s, [ice.Current? current]) => _ids.contains(s);
  @override
  List<String> ice_ids([ice.Current? current]) => _ids;
  @override
  String ice_id([ice.Current? current]) => ice_staticId();

  static String ice_staticId() => _ids[0];

  void sayHello(int delay, [ice.Current? current]);
  void shutdown([ice.Current? current]);

  bool iceD_sayHello(ice.Incoming incoming, ice.Current current) {
    // checkMode
    int delay = incoming.stream.readInt();

    sayHello(delay, current);

    incoming.createReply((output) {});
    return true;
  }

  bool iceD_shutdown(ice.Incoming incoming, ice.Current current) {
    shutdown(current);

    incoming.createReply((output) {});
    return true;
  }

  bool iceDispatch(ice.Incoming incoming, ice.Current current) {
    switch (current.operation) {
      case 'ice_id':
        return iceD_ice_id(incoming, current);
      case 'ice_ids':
        return iceD_ice_ids(incoming, current);
      case 'ice_isA':
        return iceD_ice_isA(incoming, current);
      case 'ice_ping':
        return iceD_ice_ping(incoming, current);
      case 'sayHello':
        return iceD_sayHello(incoming, current);
      case 'shutdown':
        return iceD_shutdown(incoming, current);
      default:
        throw ice.OperationNotExistException(
            current.id, current.facet, current.operation);
    }
    return false;
  }
}

class B extends ice.Object {
  int b;
  B(this.b);

  static void write(ice.OutputStream out, B v) => out.writeInt(v.b);
  static B read(ice.InputStream input) => B(input.readInt());
}

class C extends B {
  int c;
  C(int b, this.c) : super(b);

  static void write(ice.OutputStream out, C v) {
    out.writeByte(0);
    out.writeInt(v.b);
    out.writeByte(0x20);
    out.writeInt(v.c);
  }

  static C read(ice.InputStream input) => C(
        input.readInt(),
        input.readInt(),
      );
}

class TalkPrx extends ice.ObjectPrx {
  String get ice_staticId => '::Demo::Talk';
  TalkPrx(reference) : super(reference);

  String getName([ice.Context? context = ice.noExplicitContext]) {
    return ice_invoke('getName', ice.OperationMode.normal, context, null,
        (status, input) => input.readString());
  }

  static ice.ObjectCreator creator = (reference) => TalkPrx(reference);
}

class HelloPrx extends ice.ObjectPrx {
  HelloPrx(reference) : super(reference);

  void sayHello(int delay, [ice.Context? context]) {
    return ice_invoke(
      'sayHello',
      ice.OperationMode.idempotent,
      context,
      (out) => out.writeInt(delay),
    );
  }

  Future<void> sayHelloAsync(int delay, [ice.Context? context]) async {
    return ice_invokeAsync(
      'sayHello',
      ice.OperationMode.idempotent,
      context,
      (out) => out.writeInt(delay),
    );
  }

  void say(int delay, [ice.Context? context]) {
    return ice_invoke(
      'say',
      ice.OperationMode.normal,
      context,
      (out) => out.writeInt(delay),
    );
  }

  void encodeTest(Derived d1, Derived d2, [ice.Context? context]) {
    return ice_invoke('encodeTest', ice.OperationMode.normal, context, (out) {
      // TODO:
      final inner = callTwoNoSize(d1, d2);
      out.writeBlob(inner.finished());
    });
  }

  TalkPrx createTalk(String name, [ice.Context? context]) {
    return ice_invoke(
      'createTalk',
      ice.OperationMode.normal,
      context,
      (out) => out.writeString(name),
      (status, input) => proxyFromStream<TalkPrx>(input, TalkPrx.creator),
    );
  }

  void shutdown([ice.Context? context]) {
    return ice_invoke('shutdown', ice.OperationMode.idempotent, context);
  }

  Future<void> shutdownAsync({ice.Context? context}) async {
    return ice_invokeAsync('shutdown', ice.OperationMode.idempotent, context);
  }

  static ice.ObjectCreator creator = (reference) => HelloPrx(reference);
}
