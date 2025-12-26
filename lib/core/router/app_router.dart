import 'package:firebase_playground/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:firebase_playground/features/ml/presentation/screens/image_lebeling_screen.dart';
import 'package:firebase_playground/features/notifications/presentation/screens/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/auth/presentation/screens/register_screen.dart';
import '../../../features/home/presentation/screens/home_screen.dart';
import '../../../features/home/presentation/screens/main_shell.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../features/database/presentation/screens/database_screen.dart';
import '../../../features/storage/presentation/screens/storage_screen.dart';
import '../../../features/ml/presentation/screens/ml_screen.dart';
import '../../../features/ml/presentation/screens/text_recognition_screen.dart';
import '../../../features/ml/presentation/screens/face_detection_screen.dart';
import '../../../features/ml/presentation/screens/barcode_scanner_screen.dart';
import '../../../features/ml/presentation/screens/translation_screen.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';
import '../widgets/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isLoggedIn = authState is AuthAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/database',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DatabaseScreen(),
            ),
          ),
          GoRoute(
            path: '/storage',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StorageScreen(),
            ),
          ),
          GoRoute(
            path: '/ml',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MLScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // ML Feature Routes
      GoRoute(
        path: '/ml/text-recognition',
        builder: (context, state) => const TextRecognitionScreen(),
      ),
      GoRoute(
        path: '/ml/face-detection',
        builder: (context, state) => const FaceDetectionScreen(),
      ),
      GoRoute(
        path: '/ml/barcode-scanner',
        builder: (context, state) => const BarcodeScannerScreen(),
      ),
      GoRoute(
        path: '/ml/image-labeling',
        builder: (context, state) => const ImageLabelingScreen(),
      ),
      GoRoute(
        path: '/ml/translation',
        builder: (context, state) => const TranslationScreen(),
      ),

      // Other Routes
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}