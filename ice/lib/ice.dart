library ice;

import 'dart:async';
import 'dart:cli'; // waitFor
import 'dart:typed_data';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:meta/meta.dart';
import 'package:args/args.dart';

import 'src/util/stringext.dart';
import 'protocol.dart';

export 'protocol.dart';

// path: gen
// slice2dart target folder

// path: impl
// handwritten code
part 'src/config.dart';
part 'src/gen/builtin_sequences.dart';

part 'src/impl/incoming.dart';
part 'src/impl/outgoing.dart';
part 'src/impl/object.dart';
part 'src/gen/plugin.dart';
part 'src/gen/response_handler.dart';
part 'src/gen/properties_admin.dart';
part 'src/gen/properties.dart';
part 'src/gen/logger.dart';

part 'src/gen/current.dart';
part 'src/gen/implicit_context.dart';

part 'src/gen/endpoint_types.dart';
part 'src/gen/endpoint.dart';
part 'src/gen/connection.dart';

part 'src/gen/facet_map.dart';
part 'src/gen/process.dart';

part 'src/gen/communicator.dart';
part 'src/gen/object_adapter.dart';
part 'src/gen/locator.dart';
part 'src/gen/servant_locator.dart';
part 'src/gen/router.dart';
part 'src/impl/proxy.dart';

part 'src/impl/state.dart';
part 'src/impl/initialize.dart';
part 'src/impl/format.dart';
part 'src/impl/communicator.dart';
part 'src/impl/connection.dart';
part 'src/impl/instance.dart';
part 'src/impl/property_names.dart';
part 'src/impl/properties.dart';
part 'src/impl/proxy_factory.dart';
part 'src/impl/reference.dart';
part 'src/impl/reference_factory.dart';
part 'src/impl/object_adapter.dart';
part 'src/impl/object_adapter_factory.dart';
part 'src/impl/application.dart';
part 'src/impl/plugin.dart';
part 'src/impl/endpoint_factory.dart';
part 'src/impl/tcp_endpoint.dart';
part 'src/impl/udp_endpoint.dart';
part 'src/impl/tcp_connection.dart';
part 'src/impl/udp_connection.dart';

part 'src/mx/metrics.dart';
part 'src/mx/metrics_admin.dart';

/// TODO:
class LocalObject {}

class Value {}
