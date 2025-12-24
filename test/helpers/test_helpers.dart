// Test helpers and utilities for Firebase Flutter App tests

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/core/theme/app_theme.dart';
import 'package:firebase_flutter_app/features/auth/bloc/auth_bloc.dart';
import 'package:firebase_flutter_app/features/database/bloc/database_bloc.dart';
import 'package:firebase_flutter_app/features/storage/bloc/storage_bloc.dart';
import 'package:firebase_flutter_app/features/ml/bloc/ml_bloc.dart';
import 'package:firebase_flutter_app/features/analytics/bloc/analytics_bloc.dart';
import 'package:firebase_flutter_app/features/notifications/bloc/notifications_bloc.dart';
import 'package:firebase_flutter_app/features/remote_config/bloc/remote_config_bloc.dart';

// Mock BLoCs
class MockAuthBloc extends Mock implements AuthBloc {}

class MockDatabaseBloc extends Mock implements DatabaseBloc {}

class MockStorageBloc extends Mock implements StorageBloc {}

class MockMLBloc extends Mock implements MLBloc {}

class MockAnalyticsBloc extends Mock implements AnalyticsBloc {}

class MockNotificationsBloc extends Mock implements NotificationsBloc {}

class MockRemoteConfigBloc extends Mock implements RemoteConfigBloc {}

// Fake Events for registration
class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeDatabaseEvent extends Fake implements DatabaseEvent {}

class FakeStorageEvent extends Fake implements StorageEvent {}

class FakeMLEvent extends Fake implements MLEvent {}

class FakeAnalyticsEvent extends Fake implements AnalyticsEvent {}

class FakeNotificationsEvent extends Fake implements NotificationsEvent {}

class FakeRemoteConfigEvent extends Fake implements RemoteConfigEvent {}

// Fake States for registration
class FakeAuthState extends Fake implements AuthState {}

class FakeDatabaseState extends Fake implements DatabaseState {}

class FakeStorageState extends Fake implements StorageState {}

class FakeMLState extends Fake implements MLState {}

class FakeAnalyticsState extends Fake implements AnalyticsState {}

class FakeNotificationsState extends Fake implements NotificationsState {}

class FakeRemoteConfigState extends Fake implements RemoteConfigState {}

/// Register all fallback values for mocktail
void registerAllFallbackValues() {
  registerFallbackValue(FakeAuthEvent());
  registerFallbackValue(FakeAuthState());
  registerFallbackValue(FakeDatabaseEvent());
  registerFallbackValue(FakeDatabaseState());
  registerFallbackValue(FakeStorageEvent());
  registerFallbackValue(FakeStorageState());
  registerFallbackValue(FakeMLEvent());
  registerFallbackValue(FakeMLState());
  registerFallbackValue(FakeAnalyticsEvent());
  registerFallbackValue(FakeAnalyticsState());
  registerFallbackValue(FakeNotificationsEvent());
  registerFallbackValue(FakeNotificationsState());
  registerFallbackValue(FakeRemoteConfigEvent());
  registerFallbackValue(FakeRemoteConfigState());
}

/// Creates a test app wrapper with theme
Widget createTestApp({
  required Widget child,
  bool useDarkTheme = false,
}) {
  return MaterialApp(
    theme: useDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme,
    home: child,
  );
}

/// Creates a test app wrapper with multiple BLoC providers
Widget createTestAppWithBlocs({
  required Widget child,
  AuthBloc? authBloc,
  DatabaseBloc? databaseBloc,
  StorageBloc? storageBloc,
  MLBloc? mlBloc,
  AnalyticsBloc? analyticsBloc,
  NotificationsBloc? notificationsBloc,
  RemoteConfigBloc? remoteConfigBloc,
  bool useDarkTheme = false,
}) {
  return MaterialApp(
    theme: useDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme,
    home: MultiBlocProvider(
      providers: [
        if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
        if (databaseBloc != null) BlocProvider<DatabaseBloc>.value(value: databaseBloc),
        if (storageBloc != null) BlocProvider<StorageBloc>.value(value: storageBloc),
        if (mlBloc != null) BlocProvider<MLBloc>.value(value: mlBloc),
        if (analyticsBloc != null) BlocProvider<AnalyticsBloc>.value(value: analyticsBloc),
        if (notificationsBloc != null) BlocProvider<NotificationsBloc>.value(value: notificationsBloc),
        if (remoteConfigBloc != null) BlocProvider<RemoteConfigBloc>.value(value: remoteConfigBloc),
      ],
      child: child,
    ),
  );
}

/// Test data generators
class TestData {
  static DateTime get now => DateTime.now();

  static DateTime get yesterday => now.subtract(const Duration(days: 1));

  static DateTime get lastWeek => now.subtract(const Duration(days: 7));

  static String generateUid([int length = 20]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[index % chars.length]).join();
  }

  static String generateEmail([String? name]) {
    final userName = name ?? 'testuser${DateTime.now().millisecondsSinceEpoch}';
    return '$userName@example.com';
  }
}

/// Custom matchers for tests
class IsValidEmail extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(item);
  }

  @override
  Description describe(Description description) {
    return description.add('a valid email address');
  }
}

Matcher isValidEmail() => IsValidEmail();

class IsValidHexColor extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;
    final hexColorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexColorRegex.hasMatch(item);
  }

  @override
  Description describe(Description description) {
    return description.add('a valid hex color code');
  }
}

Matcher isValidHexColor() => IsValidHexColor();

class IsNonEmptyString extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! String) return false;
    return item.trim().isNotEmpty;
  }

  @override
  Description describe(Description description) {
    return description.add('a non-empty string');
  }
}

Matcher isNonEmptyString() => IsNonEmptyString();

/// Extension for easier widget testing
extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await pumpWidget(createTestApp(child: widget));
    await pumpAndSettle();
  }

  Future<void> pumpAppWithBlocs(
    Widget widget, {
    AuthBloc? authBloc,
    DatabaseBloc? databaseBloc,
  }) async {
    await pumpWidget(createTestAppWithBlocs(
      child: widget,
      authBloc: authBloc,
      databaseBloc: databaseBloc,
    ));
    await pumpAndSettle();
  }
}
