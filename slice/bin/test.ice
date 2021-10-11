// TODO: Put public facing types in this file.

#pragma once

#include <Ice/Version.ice>

/// Checks if you are awesome. Spoiler: you are.
[["cpp:header-ext:h"]]
[["ice-prefix"]]
module Demo {

local class EndpointInfo;
local interface Endpoint;
["swift:nonnull"] local sequence<Endpoint> EndpointSeq;
const short TCPEndpointType = 1;

interface Empty1 {
  int get0(int disabledViews);
  Ice::StringSeq get1(out Ice::StringSeq disabledViews);
  idempotent Ice::StringSeq get2(out optional(1) Ice::StringSeq disabledViews);
  idempotent Ice::StringSeq* get3(out optional(1) Ice::StringSeq* disabledViews);
  Ice::StringSeq* get4(out int disabledViews);
  Ice::StringSeq get5(int disabledViews);
}

struct Empty2 {
}

enum Empty3 {
}



local struct Address {
  int type;
}

enum foo {
  // first is a
  a,
  b
}

/** A sequence of floats. **/
sequence<float> FloatSeq;

module inner {
class Remote {
  int f;
}
}

local class Current {
  /**
  * The object adapter.
  **/
  string name;
}

local class Context extends Current {
  int id;
}

["deprecate:ObjectFactory has been deprecated, use ValueFactory instead."]
interface Awesome {
  /// comment
  ["foo"] bool isAwesome();

  ["cpp:const"] Object* foo(string str, int \value);

  void bar1(["swift:nonnull"] int a, out int b);
  ["nonmutating", "cpp:const"] void bar2(int a, out optional(1) int b);
  ["nonmutating", "cpp:const"] void bar3(int a, optional(1) int b);
}

module Contact {

["cpp:comparable", "js:comparable"]
local interface Hello {
  void foo1();
  double foo2(int a);
  void foo3(int a, int b);
  void foo4(int a, int b, int c);
  /**/
  ["swift:noexcept"] void sayNormal1(int delay);
  ["swift:noexcept"]void sayNormal2(int delay);
  ["swift:noexcept"] void sayNormal3(int delay);
  void sayOut1(int a,  int b);
  void sayOut2(int a, out int b);
  ["swift:noexcept"] void sayExceptionSafe();
  void sayMeta1(["swift:notnull"] Object entrust);
  void sayMeta2(["swift:notnull"]Object entrust);
  // foo
  Object* sayStar1(int entrust);
  Object* sayStar2(int entrust);
  ["swift:noexcept"] Object* sayAll(["swift:notnull"]Object* entrust, int delay, out int three);
}

/** A sequence of longs. **/
sequence<long> LongSeq;
} // module Contact

} // module Demo
