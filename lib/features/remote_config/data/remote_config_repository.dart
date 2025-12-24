import 'package:firebase_remote_config/firebase_remote_config.dart';

abstract class RemoteConfigRepository {
  Future<void> initialize();
  Future<bool> fetchAndActivate();
  String getString(String key);
  int getInt(String key);
  bool getBool(String key);
  double getDouble(String key);
  Map<String, dynamic> getAllValues();
}

class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigRepositoryImpl(this._remoteConfig);

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // Set default values
    await _remoteConfig.setDefaults({
      'welcome_message': 'Welcome to Firebase Showcase!',
      'feature_ml_enabled': true,
      'feature_storage_enabled': true,
      'max_upload_size_mb': 10,
      'app_theme': 'system',
      'show_premium_features': false,
    });
  }

  @override
  Future<bool> fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      return updated;
    } catch (e) {
      return false;
    }
  }

  @override
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  @override
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  @override
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  @override
  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  @override
  Map<String, dynamic> getAllValues() {
    final all = _remoteConfig.getAll();
    return all.map((key, value) => MapEntry(key, value.asString()));
  }
}