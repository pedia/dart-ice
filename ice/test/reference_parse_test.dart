import 'package:args/args.dart';
import 'package:test/test.dart';

///   tcp -h *|{host} -p {port} -t infinite|{timeout} -z(compress) --sourceAddress {sourceAddress}
///   udp --interface {host} --ttl {} -c(connect) -z(compress)
///   ws -r {resource}
///
ArgParser endpointParser() => ArgParser()
      ..addOption('host', abbr: 'h')
      ..addOption('port', abbr: 'p')
      ..addOption('timeout', abbr: 't')
      ..addOption('sourceAddress')
      ..addOption('ttl')
      ..addOption('interface', abbr: 'i')
      ..addOption('resource', abbr: 'r')
      ..addFlag('compress', abbr: 'z') //, defaultsTo: false);
    ;

ArgParser preferenceParser() => ArgParser()
      ..addOption('facet', abbr: 'f')
      ..addOption('protocol', abbr: 'p')
      ..addOption('encoding', abbr: 'e')
      ..addFlag('secure', abbr: 's') // , defaultsTo: false)
      ..addFlag('twoway', abbr: 't') // , defaultsTo: true)
      ..addFlag('oneway', abbr: 'o') // , defaultsTo: false)
      ..addFlag('batchOneway', abbr: 'O') // , defaultsTo: false)
      ..addFlag('datagram', abbr: 'd') // , defaultsTo: false)
      ..addFlag('batchDatagram', abbr: 'D') // , defaultsTo: false)
    ;

dump(ArgResults rs) {
  print('${rs.arguments.first}: ${List.from(rs.options)}');
}

parseReference(String s) {
  final arr = s.split(':');
  if (arr.isNotEmpty) {
    var r = preferenceParser().parse(arr[0].split(' '));
    dump(r);

    for (int i = 1; i < arr.length; ++i) {
      var e = endpointParser().parse(arr[i].split(' '));
      dump(e);
    }
  } else {
    var r = preferenceParser().parse(arr);
    dump(r);
  }
}

void main() {
  parseReference(
      'identity -f facet -s -d -s:default -p 10000:tcp -h localhost -p 3000:udp -ttl 33:ws -r foo.com');
  parseReference('identity -f facet -O -s -p 1.0 -e 2.0 @adapterId');
}
