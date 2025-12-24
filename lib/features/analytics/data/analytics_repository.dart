import 'package:firebase_analytics/firebase_analytics.dart';

abstract class AnalyticsRepository {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });
  Future<void> setUserId(String userId);
  Future<void> setUserProperty({required String name, required String value});
  Future<void> logScreenView({required String screenName, String? screenClass});
  Future<void> logLogin({required String loginMethod});
  Future<void> logSignUp({required String signUpMethod});
}

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseAnalytics _analytics;

  AnalyticsRepositoryImpl(this._analytics);

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  @override
  Future<void> logLogin({required String loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  @override
  Future<void> logSignUp({required String signUpMethod}) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }
}