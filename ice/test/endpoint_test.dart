import 'package:test/test.dart';
import 'dart:typed_data';

import '../lib/ice.dart';

void main() {
  final ich = CommunicatorHolder();
  final instance = (ich.communicator as CommunicatorI).instance;
  test('ParseAndToString', () {
    {
      var ep = parseEndpoint(instance, 'tcp -h foo -p 3000 -z');
      expect(ep.toString(), 'tcp -h foo -p 3000 -z');
      expect(ep!.addressList.isEmpty, isTrue);
    }
    {
      var ep = parseEndpoint(instance, 'tcp -h foo -p 3000 -t infinite -z');

      expect(ep!.addressList.isEmpty, isTrue);
      expect(ep.timeout, -1);
      expect(ep.toString(), 'tcp -h foo -p 3000 -t infinite -z');
    }

    final p = ich.communicator.getProperties();
    expect(p.getProperty('Ice.Default.Host'), '');
    {
      var ep = parseEndpoint(instance, 'tcp -h * -p 3000 -z');
      expect(ep.toString(), 'tcp -h * -p 3000 -z');
      expect(ep!.addressList.isNotEmpty, isTrue);
    }

    {
      var ep = parseEndpoint(instance, 'tcp  -p 3000 -z');
      expect(ep.toString(), 'tcp -p 3000 -z');
      expect(ep!.addressList.isNotEmpty, isTrue);
    }

    p.setProperty('Ice.Default.Host', 'bar');
    {
      var ep = parseEndpoint(instance, 'tcp  -p 3000 -z');
      expect(ep!.addressList.isEmpty, isTrue);
      expect(ep.host, 'bar');

      expect(ep.toString(), 'tcp -h bar -p 3000 -z');
    }
  });

  test('StreamTest', () {
    // a Reply
    final Uint8List data = Uint8List.fromList([
      73, 99, 101, 80, 1, 0, 1, 0, 2, 0, 206, 0, 0, 0, //
      1, 0, 0, 0, // requestId
      0, // status
      187, 0, 0, 0, 1, 1, 36, 55, 56, 70, 52, 70, 55, 48, 57, 45,
      67, 70, 67, 55, 45, 52, 55, 67, 54, 45, 56, 57, 53, 48, 45, 52, 68,
      66, 54, 67, 52, 57, 56, 55, 48, 55, 69, 0, 0, 0, 0, 1, 0, 1, 1, 5,
      1, 0, 25, 0, 0, 0, 1, 1, 9, 108, 111, 99, 97, 108, 104, 111, 115,
      116, 16, 39, 0, 0, 96, 234, 0, 0, 0, 3, 0, 21, 0, 0, 0, 1, 1, 9,
      108, 111, 99, 97, 108, 104, 111, 115, 116, 16, 39, 0, 0, 0, 2, 0,
      25, 0, 0, 0, 1, 1, 9, 108, 111, 99, 97, 108, 104, 111, 115, 116, 17,
      39, 0, 0, 96, 234, 0, 0, 0, 4, 0, 27, 0, 0, 0, 1, 1, 9, 108, 111, 99,
      97, 108, 104, 111, 115, 116, 18, 39, 0, 0, 96, 234, 0, 0, 0, 1, 47, 5,
      0, 27, 0, 0, 0, 1, 1, 9, 108, 111, 99, 97, 108, 104, 111, 115, 116, 19,
      39, 0, 0, 96, 234, 0, 0, 0, 1, 47
    ]);

    final input =
        InputStream(ByteData.view(data.buffer), data.buffer.lengthInBytes);
    Header header = Message.parseHeader(input);

    expect(input.readInt(), 1);
    expect(input.readByte(), 0);
    final encap = input.readEncapsulation();

    final identity = input.readIndentity();

    final ref = instance.referenceFactory.createFromStream(identity, input);
    expect(ref, isNotNull);
  });
}
