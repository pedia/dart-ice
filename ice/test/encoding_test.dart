import 'package:test/test.dart';
import 'package:ice/ice.dart';

import 'example.dart';

void main() {
  final d1 = Derived(99, 'Hello', true, "World!", 3.14);
  final d2 = Derived(115, 'Cave', false, "Canem", 6.32);

  test('EncodingTest', () {
    final o = callTwo(d1, d2);
    expect(o.finished().lengthInBytes, 103);
  });

  test('SliceFlagTest', () {
    final f = SliceFlag(flagIsLast);
    expect(f.value, 0x20);
    expect(f.isLast, isTrue);

    f.set(flagHasTypeIdString);
    expect(f.value, 0x21);
    expect(f.hasTypeIdString, isTrue);
    expect(f.isLast, isTrue);

    f.unset(flagIsLast);
    expect(f.value, 0x1);
    expect(f.isLast, isFalse);

    // worked:
    // expect(() => throw AssertionError(), throwsA(isA<AssertionError>()));

    // not work:
    // expect(() => SliceFlag(0xff00), throwsA(isA<AssertionError>()));

    // expect(() {
    //   assert(false);
    //   return AssertionError();
    // }, throwsA(isA<AssertionError>()));
  });
}
