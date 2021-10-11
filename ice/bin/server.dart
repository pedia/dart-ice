import '../lib/ice.dart';
import 'hello.dart';

class HelloI extends Hello {
  @override
  void sayHello(int delay, [Current? current]) {
    print('hello');
  }

  @override
  void shutdown([Current? current]) {
    print('Shutting down...');
    current?.adapter?.communicator.shutdown();
  }
}

void main(List<String> args) async {
  final ich = CommunicatorHolder(args: args, configFile: 'bin/config.server');
  final adapter = ich.communicator.createObjectAdapter('Hello');
  adapter.add(HelloI(), stringToIdentity('hello'));
  adapter.activate();

  await ich.communicator.waitForShutdown();
}
