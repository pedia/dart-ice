import 'package:ice/ice.dart';

// Copy from ice manual
// slice definie:
//
// class Base {
//   int baseInt;
//   string baseString;
// }

// class Derived extends Base {
//   bool derivedBool;
//   string derivedString;
//   double derivedDouble;
// }

class Base extends Object {
  static String _ice_id = "::Demo::Base";
  String ice_id([Current? current]) => _ice_id;

  int baseInt;
  String baseString;
  Base(this.baseInt, this.baseString);

  void write(OutputStream out, SliceFlag flag, [int? typeIdIndex]) {
    out.writeFlag(flag);

    if (flag.hasTypeIdString)
      out.writeString(_ice_id);
    else if (flag.hasTypeIdIndex) out.writeSize(typeIdIndex!);

    if (flag.hasSize) {
      out.writeInt(4 + 4 + 1 + baseString.length);
    }
    out.writeInt(baseInt);
    out.writeString(baseString);
  }
}

class Derived extends Base {
  static String _ice_id = "::Demo::Derived";
  String ice_id([Current? current]) => _ice_id;

  bool derivedBool;
  String derivedString;
  double derivedDouble;
  Derived(int baseInt, String baseString, this.derivedBool, this.derivedString,
      this.derivedDouble)
      : super(baseInt, baseString);

  void write(OutputStream out, SliceFlag flag, [int? typeIdIndex]) {
    out.writeFlag(flag);

    if (flag.hasTypeIdString)
      out.writeString(_ice_id);
    else if (flag.hasTypeIdIndex) out.writeSize(typeIdIndex!);

    if (flag.hasSize) {
      out.writeInt(4 + 1 + 1 + derivedString.length + 8);
    }
    out.writeBool(derivedBool);
    out.writeString(derivedString);
    out.writeDouble(derivedDouble);

    super.write(out, flag..set(flagIsLast), 1);
  }
}

OutputStream callTwo(Derived d1, Derived d2) {
  final out = OutputStream();

  const int marker = 1; // instance marker

  out.writeByte(marker);
  d1.write(
    out,
    SliceFlag(flagHasTypeIdString | flagHasSize),
  );

  out.writeByte(marker);
  d2.write(
    out,
    SliceFlag(flagHasTypeIdIndex | flagHasSize),
    1,
  );

  return out;
}

OutputStream callTwoNoSize(Derived d1, Derived d2) {
  final out = OutputStream();

  const int marker = 1; // instance marker

  out.writeByte(marker);
  d1.write(
    out,
    SliceFlag(flagHasTypeIdString),
  );

  out.writeByte(marker);
  d2.write(
    out,
    SliceFlag(flagHasTypeIdIndex),
    1,
  );

  return out;
}
