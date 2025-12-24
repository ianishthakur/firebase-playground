import 'package:firebase_playground/features/notifications/bloc/notification_bloc.dart';
import 'package:firebase_playground/features/notifications/data/notification_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/remote_config/bloc/remote_config_bloc.dart';
import '../../features/remote_config/data/remote_config_repository.dart';
import '../../features/analytics/bloc/analytics_bloc.dart';
import '../../features/analytics/data/analytics_repository.dart';
import '../../features/database/bloc/database_bloc.dart';
import '../../features/database/data/database_repository.dart';
import '../../features/storage/bloc/storage_bloc.dart';
import '../../features/storage/data/storage_repository.dart';
import '../../features/ml/bloc/ml_bloc.dart';
import '../../features/ml/data/ml_repository.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Firebase instances
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton(() => FirebaseStorage.instance);
  getIt.registerLazySingleton(() => FirebaseMessaging.instance);
  getIt.registerLazySingleton(() => FirebaseAnalytics.instance);
  getIt.registerLazySingleton(() => FirebaseRemoteConfig.instance);
  getIt.registerLazySingleton(() => FirebaseDatabase.instance);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<FirebaseMessaging>()),
  );
  
  getIt.registerLazySingleton<RemoteConfigRepository>(
    () => RemoteConfigRepositoryImpl(getIt<FirebaseRemoteConfig>()),
  );
  
  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(getIt<FirebaseAnalytics>()),
  );
  
  getIt.registerLazySingleton<DatabaseRepository>(
    () => DatabaseRepositoryImpl(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseDatabase>(),
    ),
  );
  
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(getIt<FirebaseStorage>()),
  );
  
  getIt.registerLazySingleton<MLRepository>(
    () => MLRepositoryImpl(),
  );

  // BLoCs
  getIt.registerFactory(
    () => AuthBloc(getIt<AuthRepository>()),
  );
  
  getIt.registerFactory(
    () => NotificationsBloc(getIt<NotificationsRepository>()),
  );
  
  getIt.registerFactory(
    () => RemoteConfigBloc(getIt<RemoteConfigRepository>()),
  );
  
  getIt.registerFactory(
    () => AnalyticsBloc(getIt<AnalyticsRepository>()),
  );
  
  getIt.registerFactory(
    () => DatabaseBloc(getIt<DatabaseRepository>()),
  );
  
  getIt.registerFactory(
    () => StorageBloc(getIt<StorageRepository>()),
  );
  
  getIt.registerFactory(
    () => MLBloc(getIt<MLRepository>()),
  );
}