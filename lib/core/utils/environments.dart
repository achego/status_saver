class Environments {
  static const String email = String.fromEnvironment(
    'DEVELOPER_EMAIL',
    defaultValue: 'belemaachego@gmail.com',
  );

  static const String appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=dev.belema.status_saver',
  );

  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://belema.dev/status-saver/privacy-policy',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
}
