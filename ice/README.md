# Ice Dart
Implement `ZeroC` `Ice` in pure Dart.

Worked client demo:
```dart
void main(List<String> args) async {
  final ich = CommunicatorHolder(args: args, configFile: 'bin/config.client');

  final o = ich.communicator.propertyToProxy("Hello.Proxy");
  assert(o.runtimeType == ObjectPrx);

  if (o != null) {
    final prx = checkedCast<HelloPrx>(o, HelloPrx.creator);
    if (prx != null) {
      assert(prx.runtimeType == HelloPrx);

      final typeId = '::Demo::Hello';
      prx.ice_isA(typeId);

      assert(true == await prx.ice_isAAsync(typeId));
      assert(true == await prx.ice_isAAsync('::Ice::Object'));
      assert(false == await prx.ice_isAAsync('not-exist'));

      prx.sayHello(0);

      await prx.sayHelloAsync(0);
    }
  }

  ich.communicator.shutdown();
}

```

## TODO List
- [x] Object
- [x] Proxy
- [] Server
- [x] slice
  - [x] slice scanner
  - [x] slice parser
  - [x] slice2dart
  - [] unittest for cpp/test/.../*.ice of ice
- [] Transport
  - [x] Tcp
  - [x] Udp
  - [] SSL
  - [] WebSocket
- [] Features
  - [] Router
  - [] BatchMode
  - [] facet
- [] External
  - [] Oberve and Metrix

## Ice Protocol
Implement of Ice Protocol is split up as a standalone library `ice.protocol`.

## Licence
Maybe later or donate.
