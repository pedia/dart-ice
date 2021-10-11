import 'package:test/test.dart';

import '../lib/ice.dart';
import '../lib/src/util/stringext.dart';
import 'helper.dart';

void main() {
  test('StringFindNotOf', () {
    // >>> re.compile('[^ ]+').findall('b a ')
    // ['b', 'a']
    final delimNot = r'[^ \t\r\n]+';

    expect(' b a'.indexOf(delimNot), -1);
    expect('a'.indexOf(delimNot), -1);
    expect(''.indexOf(delimNot), -1);
    expect(' '.indexOf(delimNot), -1);
    expect(' a'.indexOf(delimNot), -1);

    final pattern = ' \t\r\n';

    expect('a'.indexOfNot(pattern), 0);
    expect(' a'.indexOfNot(pattern), 1);
    expect(''.indexOfNot(pattern), -1);
    expect(' '.indexOfNot(pattern), -1);

    // re.compile(r'[ \t\r\n:@]+').findall('test:a')
    // [':']

    final delim2 = RegExp('[ \t\r\n:@]+');
    expect('test:default -p 12010'.indexOf(delim2), 4);
  });

  test('SplitWithQuote', () {
    expect('a "b b"'.splitWithQuote(' '), ['a', 'b b']);
    expect('"b b" c'.splitWithQuote(' '), ['b b', 'c']);
    expect('aa "bb" cc'.splitWithQuote(' '), ['aa', 'bb', 'cc']);
    expect(' aa "bb" cc '.splitWithQuote(' '), ['aa', 'bb', 'cc']);
    expect(' aa "" cc '.splitWithQuote(' '), ['aa', '', 'cc']);
    expect(' aa  cc '.splitWithQuote(' '), ['aa', 'cc']);
    expect(' aa " " cc '.splitWithQuote(' '), ['aa', ' ', 'cc']);
    expect(() => 'a "'.splitWithQuote(' '), throwsA(isFormatException));
    expect(() => '" a'.splitWithQuote(' '), throwsA(isFormatException));
    expect(() => '" a"b'.splitWithQuote(' '), throwsA(isFormatException));
  });

  test('ProxyTest', () {
    final communicator = initialize();
    expect(communicator, isNotNull);

    String endp = getTestEndpoint(communicator.getProperties());

    String ref = 'test:$endp';
    final base = communicator.stringToProxy(ref);
    expect(base, isNotNull, reason: 'parse `$ref` failed');
    expect(base!.ice_getIdentity.name, 'test');

    // Server
    // final properties = createTestPoroperties(args);
    // properties.setProperty('Ice.Warn.Dispatch', "0");

    // final ich = CommunicatorHolder(args: args, properties: properties);
    // ich.communicator
    //     .getProperties()
    //     .setProperty('TestAdapter.Endpoints', getTestEndpoint());

    // final adapter = ich.communicator.createObjectAdapter("TestAdapter");
    // adapter.add(, stringToIdentity('test'));
    // adapter.activate();
    // // serverReady();
    // ich.communicator.waitForShutdown();
  });
}
