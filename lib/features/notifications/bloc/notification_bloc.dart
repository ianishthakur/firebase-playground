import 'package:firebase_playground/features/notifications/data/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsInitialize extends NotificationsEvent {}

class NotificationsSubscribeToTopic extends NotificationsEvent {
  final String topic;
  const NotificationsSubscribeToTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class NotificationsUnsubscribeFromTopic extends NotificationsEvent {
  final String topic;
  const NotificationsUnsubscribeFromTopic(this.topic);

  @override
  List<Object?> get props => [topic];
}

class NotificationsMessageReceived extends NotificationsEvent {
  final RemoteMessage message;
  const NotificationsMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsReady extends NotificationsState {
  final String? fcmToken;
  final List<String> subscribedTopics;
  final List<RemoteMessage> messages;

  const NotificationsReady({
    this.fcmToken,
    this.subscribedTopics = const [],
    this.messages = const [],
  });

  NotificationsReady copyWith({
    String? fcmToken,
    List<String>? subscribedTopics,
    List<RemoteMessage>? messages,
  }) {
    return NotificationsReady(
      fcmToken: fcmToken ?? this.fcmToken,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [fcmToken, subscribedTopics, messages];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsBloc(this._repository) : super(NotificationsInitial()) {
    on<NotificationsInitialize>(_onInitialize);
    on<NotificationsSubscribeToTopic>(_onSubscribeToTopic);
    on<NotificationsUnsubscribeFromTopic>(_onUnsubscribeFromTopic);
    on<NotificationsMessageReceived>(_onMessageReceived);
  }

  Future<void> _onInitialize(
    NotificationsInitialize event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      await _repository.requestPermission();
      final token = await _repository.getToken();
      
      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        add(NotificationsMessageReceived(message));
      });

      emit(NotificationsReady(fcmToken: token));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onSubscribeToTopic(
    NotificationsSubscribeToTopic event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsReady) {
      try {
        await _repository.subscribeToTopic(event.topic);
        final updatedTopics = [...currentState.subscribedTopics, event.topic];
        emit(currentState.copyWith(subscribedTopics: updatedTopics));
      } catch (e) {
        // Keep current state on error
      }
    }
  }

  Future<void> _onUnsubscribeFromTopic(
    NotificationsUnsubscribeFromTopic event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsReady) {
      try {
        await _repository.unsubscribeFromTopic(event.topic);
        final updatedTopics = currentState.subscribedTopics
            .where((t) => t != event.topic)
            .toList();
        emit(currentState.copyWith(subscribedTopics: updatedTopics));
      } catch (e) {
        // Keep current state on error
      }
    }
  }

  void _onMessageReceived(
    NotificationsMessageReceived event,
    Emitter<NotificationsState> emit,
  ) {
    final currentState = state;
    if (currentState is NotificationsReady) {
      final updatedMessages = [event.message, ...currentState.messages];
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }
}