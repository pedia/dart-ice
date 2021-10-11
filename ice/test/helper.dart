import '../lib/ice.dart';

Properties createTestPoroperties(List<String> args) {
  final p = createProperties(args);
  return p;
}

String getTestEndpoint(Properties properties, {int n = 0, String? protocol}) {
  protocol ??=
      properties.getPropertyWithDefault("Ice.Default.Protocol", "default");

  int basePort = properties.getPropertyAsIntWithDefault("Test.BasePort", 12010);

  return '$protocol -p ${basePort + n}';
}
