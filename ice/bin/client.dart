import '../lib/ice.dart';
import 'hello.dart' as demo;
import '../test/example.dart';

void main(List<String> args) async {
  final ich = CommunicatorHolder(args: args, configFile: 'bin/config.client');

  final o = ich.communicator.propertyToProxy("Hello.Proxy");
  assert(o.runtimeType == ObjectPrx);

  if (o != null) {
    final prx = uncheckedCast<demo.HelloPrx>(o, demo.HelloPrx.creator);
    if (prx != null) {
      assert(prx.runtimeType == demo.HelloPrx);
      // print('reference: ${prx.reference}');

      // print(prx.ice_ids());
      // print(await prx.ice_idsAsync());

      // prx.ice_ping();
      // await prx.ice_pingAsync();

      // final typeId = '::Demo::Hello';
      // prx.ice_isA(typeId);

      // await prx.ice_isAAsync(typeId);
      // await prx.ice_isAAsync('::Ice::Object');
      // await prx.ice_isAAsync('typeId2');

      // prx.say(0);

      // final d1 = Derived(99, 'Hello', true, "World!", 3.14);
      // final d2 = Derived(115, 'Cave', false, "Canem", 6.32);
      // prx.encodeTest(d1, d2);

      final talk = prx.createTalk('hello');
      talk.ice_ids();
      assert(talk.getName() == 'hello');

      // try {
      //   prx.sayHello(3); // server throw std::exception
      // } catch (ex) {
      //   print(ex);
      // }
      // try {
      //   prx.sayHello(4); // server throw Ice::TimeoutException
      // } catch (ex) {
      //   print(ex);
      // }

      // await prx.sayHelloAsync(0);

      // oneway
      // final oprx = prx.ice_oneway();
      // assert(!oprx.ice_isTwoway());
      // oprx.ice_ping();

      // final dprx = prx.ice_datagram();
      // dprx.ice_ping();

      // try {
      //   dprx.ice_isA('::Demo::Hello');
      // } catch (ex) {
      //   print(ex);
      // }
    }
  }

  ich.communicator.shutdown();
}
