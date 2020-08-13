class EnvironmentConfig {
  static const API_KEY = String.fromEnvironment(
    'API_KEY',
    defaultValue: ''
  );
  static const API_SECRET = String.fromEnvironment(
    'API_SECRET',
    defaultValue: ''
  );
}