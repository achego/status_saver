const String baseIconSvgPath = 'assets/svgs/';
const String baseImageSvgPath = 'assets/images/';

extension ImageExtension on String {
  String get svg => '$baseIconSvgPath$this.svg';
  String get png => '$baseImageSvgPath$this.png';
}

class AppSvgs {
  // Navigation
  static String get home => 'home'.svg;
  static String get homeFilled => 'home_filled'.svg;
  static String get fav => 'fav'.svg;
  static String get favFilled => 'fav_filled'.svg;
  static String get settings => 'settings'.svg;
  static String get settingsFilled => 'settings_filled'.svg;

  // Actions
  static String get share => 'share'.svg;
  static String get forward => 'forward'.svg;
  static String get delete => 'delete'.svg;
  static String get download => 'download'.svg;

  static String get image => 'image'.svg;
  static String get video => 'video'.svg;

  // Settings
  static String get star => 'star'.svg;
  static String get info => 'info'.svg;
  static String get folder => 'folder'.svg;
  static String get email => 'email'.svg;
  static String get shield => 'shield'.svg;
}

class AppImages {
  static String get storagePermission => 'storage_permission'.png;
  static String get splashBg => 'splash_bg'.png;
}
