import 'package:test/test.dart';
import '../lib/ice.dart';

void main() {
  test('Hash', () {
    final a = Identity(name: 'hello');
    final b = Identity(name: 'hello');

    expect(identical(a, b), isFalse);

    expect(a.hashCode, b.hashCode);
    expect(a == b, isTrue);

    final map = <Identity, bool>{a: true};
    expect(map.containsKey(b), isTrue);
  });

  test('Test stringToIdentity and identityToString', () {
    expect(int.parse('42'), 42);

    // 0xBD A single character in ISO Latin 9
    final msg = 'tu me fends le c${String.fromCharCode(0xBD)}ur!';

    final ident = stringToIdentity('cat/$msg');
    expect(ident.category, 'cat');
    expect(ident.name, msg);
  });
}
