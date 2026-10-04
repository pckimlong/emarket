enum IntegrationMode {
  develop,
  prod,
  stage,
  unitTest,
  integrationTest;

  bool get isTest => isUnitTest || isIntegrationTest;
  bool get isUnitTest => this == .unitTest;
  bool get isIntegrationTest => this == .integrationTest;
  bool get isProd => this == .prod;
  bool get isStage => this == .stage;
  bool get isDevelop => this == .develop;
}
