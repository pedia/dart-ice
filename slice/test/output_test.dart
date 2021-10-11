import 'package:test/test.dart';

import '../lib/src/output/dart.dart';

void main() {
  test('Ice type to Dart type Test', () {
    expect('sequence<int>'.split(RegExp(r'[<>]')), ['sequence', 'int', '']);

    expect(DartType.of('int').type, 'int');
    expect(DartType.of('sequence<int>').type, 'List<int>');
    expect(DartType.of('sequence<Object*>').type, 'List<ObjectPrx>');
    expect(DartType.of('dictionary<int, string>').type, 'Map<int, String>');
    expect(DartType.of('dictionary<int, Object*>').type, 'Map<int, ObjectPrx>');
    expect(DartType.of('LocatorRegistryPrx').type, 'LocatorRegistryPrx');
  });

  test('DartMethod', () {
    expect(DartMethod.preadOf('string'), 'input.readString()');
    expect(DartMethod.preadOf('LocatorRegistryPrx'),
        'LocatorRegistryPrx.read(input)');
  });
}
