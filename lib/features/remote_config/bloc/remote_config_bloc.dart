import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/remote_config_repository.dart';

// Events
abstract class RemoteConfigEvent extends Equatable {
  const RemoteConfigEvent();

  @override
  List<Object?> get props => [];
}

class RemoteConfigFetch extends RemoteConfigEvent {}

class RemoteConfigActivate extends RemoteConfigEvent {}

// States
abstract class RemoteConfigState extends Equatable {
  const RemoteConfigState();

  @override
  List<Object?> get props => [];
}

class RemoteConfigInitial extends RemoteConfigState {}

class RemoteConfigLoading extends RemoteConfigState {}

class RemoteConfigLoaded extends RemoteConfigState {
  final Map<String, dynamic> values;

  const RemoteConfigLoaded({this.values = const {}});

  @override
  List<Object?> get props => [values];
}

class RemoteConfigError extends RemoteConfigState {
  final String message;
  const RemoteConfigError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RemoteConfigBloc extends Bloc<RemoteConfigEvent, RemoteConfigState> {
  final RemoteConfigRepository _repository;

  RemoteConfigBloc(this._repository) : super(RemoteConfigInitial()) {
    on<RemoteConfigFetch>(_onFetch);
    on<RemoteConfigActivate>(_onActivate);
  }

  Future<void> _onFetch(
    RemoteConfigFetch event,
    Emitter<RemoteConfigState> emit,
  ) async {
    emit(RemoteConfigLoading());
    try {
      await _repository.initialize();
      await _repository.fetchAndActivate();
      final values = _repository.getAllValues();
      emit(RemoteConfigLoaded(values: values));
    } catch (e) {
      emit(RemoteConfigError(e.toString()));
    }
  }

  Future<void> _onActivate(
    RemoteConfigActivate event,
    Emitter<RemoteConfigState> emit,
  ) async {
    try {
      await _repository.fetchAndActivate();
      final values = _repository.getAllValues();
      emit(RemoteConfigLoaded(values: values));
    } catch (e) {
      emit(RemoteConfigError(e.toString()));
    }
  }
}