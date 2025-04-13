import 'package:status_saver/app/services/local/local_storage.dart';

class AppInitialization {
  static Future<void> initializeDependencies() async {
    await localStorage.initializePref();
  }
}
