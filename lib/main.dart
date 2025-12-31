import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_playground/core/widgets/error_app.dart';
import 'package:firebase_playground/core/widgets/loading_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/bloc/analytics_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/notifications/bloc/notification_bloc.dart';
import 'features/remote_config/bloc/remote_config_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Log background message to a service or console
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. App Configuration (UI & Orientation)
    await _configureAppSystemUI();

    // 2. Immediate UI (Optional: Only if initialization is very slow)
    runApp(const LoadingApp());

    try {
      // 3. Service Initializations
      await Firebase.initializeApp();
      await configureDependencies();
      
      _setupFirebaseServices();

      // 4. Start the Real App
      runApp(const FirebaseShowcaseApp());
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      runApp(ErrorApp(error: e.toString()));
    }
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Moves heavy system configuration out of main()
Future<void> _configureAppSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// Groups all Firebase setup logic together
void _setupFirebaseServices() {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

class FirebaseShowcaseApp extends StatelessWidget {
  const FirebaseShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => getIt<NotificationsBloc>()..add(NotificationsInitialize())),
        BlocProvider(create: (_) => getIt<RemoteConfigBloc>()..add(RemoteConfigFetch())),
        BlocProvider(create: (_) => getIt<AnalyticsBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Firebase Showcase',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}