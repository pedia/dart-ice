// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library colors;

/// ANSI/xterm termcap for setting default colors. Output from Unix
/// command-line program `tput op`.
const String DEFAULT_COLOR = "\x1b[39;49m";

/// ANSI/xterm termcap for setting black text color. Output from Unix
/// command-line program `tput setaf 0`.
const String BLACK_COLOR = "\x1b[30m";

/// ANSI/xterm termcap for setting red text color. Output from Unix
/// command-line program `tput setaf 1`.
const String RED_COLOR = "\x1b[31m";

/// ANSI/xterm termcap for setting green text color. Output from Unix
/// command-line program `tput setaf 2`.
const String GREEN_COLOR = "\x1b[32m";

/// ANSI/xterm termcap for setting yellow text color. Output from Unix
/// command-line program `tput setaf 3`.
const String YELLOW_COLOR = "\x1b[33m";

/// ANSI/xterm termcap for setting blue text color. Output from Unix
/// command-line program `tput setaf 4`.
const String BLUE_COLOR = "\x1b[34m";

/// ANSI/xterm termcap for setting magenta text color. Output from Unix
/// command-line program `tput setaf 5`.
const String MAGENTA_COLOR = "\x1b[35m";

/// ANSI/xterm termcap for setting cyan text color. Output from Unix
/// command-line program `tput setaf 6`.
const String CYAN_COLOR = "\x1b[36m";

/// ANSI/xterm termcap for setting white text color. Output from Unix
/// command-line program `tput setaf 7`.
const String WHITE_COLOR = "\x1b[37m";

/// All the above codes. This is used to compare the above codes to the
/// terminal's. Printing this string should have the same effect as just
/// printing [DEFAULT_COLOR].
const String ALL_CODES = BLACK_COLOR +
    RED_COLOR +
    GREEN_COLOR +
    YELLOW_COLOR +
    BLUE_COLOR +
    MAGENTA_COLOR +
    CYAN_COLOR +
    WHITE_COLOR +
    DEFAULT_COLOR;

/// Boolean value caching whether or not we should display ANSI colors.
///
/// If `null`, we haven't decided whether we should display ANSI colors or not.
bool _enableColors = false;

/// Finds out whether we are displaying ANSI colors.
///
/// The first time this getter is invoked (either by a client or by an attempt
/// to use a color), it decides whether colors should be used based on the
/// logic in [_computeEnableColors] (unless a value has previously been set).
bool get enableColors => _enableColors;

/// Allows the client to override the decision of whether to disable ANSI
/// colors.
void set enableColors(bool value) {
  // ignore: unnecessary_null_comparison
  assert(value != null);
  _enableColors = value;
}

String wrap(String string, String color) {
  return enableColors ? "${color}$string${DEFAULT_COLOR}" : string;
}

String black(String string) => wrap(string, BLACK_COLOR);
String red(String string) => wrap(string, RED_COLOR);
String green(String string) => wrap(string, GREEN_COLOR);
String yellow(String string) => wrap(string, YELLOW_COLOR);
String blue(String string) => wrap(string, BLUE_COLOR);
String magenta(String string) => wrap(string, MAGENTA_COLOR);
String cyan(String string) => wrap(string, CYAN_COLOR);
String white(String string) => wrap(string, WHITE_COLOR);
