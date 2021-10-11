import 'dart:io';
import 'package:test/test.dart';

import '../lib/ice.dart';

late String configPath;

class TestApplication extends Application {
  @override
  int run(List<String> args) {
    final properties = communicator!.getProperties();

    expect(properties.getProperty('Ice.Trace.Network'), '1');
    expect(properties.getProperty('Ice.Trace.Protocol'), '1');
    expect(properties.getProperty('Config.Path'), configPath);
    expect(properties.getProperty('Ice.ProgramName'), 'PropertiesClient');
    return 0;
  }
}

void main() {
  // trim for end of '\n'
  configPath = File('test/config/configPath').readAsStringSync().trim();

  test('testing load properties from UTF-8 path...', () {
    final properties = createProperties();
    properties.load(configPath);
    expect(properties.getProperty('Ice.Trace.Network'), '1');
    expect(properties.getProperty('Ice.Trace.Protocol'), '1');
    expect(properties.getProperty('Config.Path'), configPath);
    expect(properties.getProperty('Ice.ProgramName'), 'PropertiesClient');
  });

  test('testing load properties from UTF-8 path using Ice::Application...', () {
    final app = TestApplication();
    expect(app.main(args: [], configFile: configPath), 0);
  });

  test('testing using Ice.Config with multiple config files...', () {
    final properties = createProperties([
      '--Ice.Config=test/config/config.1, test/config/config.2, test/config/config.3'
    ]);
    expect(properties.getProperty('Config1'), 'Config1');
    expect(properties.getProperty('Config2'), 'Config2');
    expect(properties.getProperty('Config3'), 'Config3');
  });

  test('testing configuration file escapes...', () {
    final args = ['--Ice.Config=test/config/escapes.cfg'];
    final properties = createProperties(args);

    final props = [
      'Foo\tBar', '3', //
      'Foo\\tBar', '4',
      'Escape\\ Space', '2',
      'Prop1', '1',
      'Prop2', '2',
      'Prop3', '3',
      'My Prop1', '1',
      'My Prop2', '2',
      'My.Prop1', 'a property',
      'My.Prop2', 'a     property',
      'My.Prop3', '  a     property  ',
      'My.Prop4', '  a     property  ',
      'My.Prop5', 'a \\ property',
      'foo=bar', '1',
      'foo#bar', '2',
      'foo bar', '3',
      'A', '1',
      'B', '2 3 4',
      'C', '5=#6',
      'AServer', '\\\\server\\dir',
      'BServer', '\\server\\dir',
      ''
    ];

    for (var i = 0; props[i] != ''; i += 2) {
      expect(properties.getProperty(props[i]), props[i + 1]);
    }
  });
}
