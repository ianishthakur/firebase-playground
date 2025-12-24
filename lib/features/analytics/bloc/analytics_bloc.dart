import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/analytics_repository.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsLogEvent extends AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;

  const AnalyticsLogEvent({
    required this.name,
    this.parameters,
  });

  @override
  List<Object?> get props => [name, parameters];
}

class AnalyticsSetUserId extends AnalyticsEvent {
  final String userId;

  const AnalyticsSetUserId(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AnalyticsSetUserProperty extends AnalyticsEvent {
  final String name;
  final String value;

  const AnalyticsSetUserProperty({
    required this.name,
    required this.value,
  });

  @override
  List<Object?> get props => [name, value];
}

class AnalyticsLogScreenView extends AnalyticsEvent {
  final String screenName;
  final String? screenClass;

  const AnalyticsLogScreenView({
    required this.screenName,
    this.screenClass,
  });

  @override
  List<Object?> get props => [screenName, screenClass];
}

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsReady extends AnalyticsState {}

// BLoC
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<AnalyticsLogEvent>(_onLogEvent);
    on<AnalyticsSetUserId>(_onSetUserId);
    on<AnalyticsSetUserProperty>(_onSetUserProperty);
    on<AnalyticsLogScreenView>(_onLogScreenView);
  }

  Future<void> _onLogEvent(
    AnalyticsLogEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _repository.logEvent(
      name: event.name,
      parameters: event.parameters,
    );
    emit(AnalyticsReady());
  }

  Future<void> _onSetUserId(
    AnalyticsSetUserId event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _repository.setUserId(event.userId);
    emit(AnalyticsReady());
  }

  Future<void> _onSetUserProperty(
    AnalyticsSetUserProperty event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _repository.setUserProperty(
      name: event.name,
      value: event.value,
    );
    emit(AnalyticsReady());
  }

  Future<void> _onLogScreenView(
    AnalyticsLogScreenView event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _repository.logScreenView(
      screenName: event.screenName,
      screenClass: event.screenClass,
    );
    emit(AnalyticsReady());
  }
}