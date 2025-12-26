import 'package:firebase_playground/features/database/data/note_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/database_repository.dart';

// Events
abstract class DatabaseEvent extends Equatable {
  const DatabaseEvent();

  @override
  List<Object?> get props => [];
}

class DatabaseLoadNotes extends DatabaseEvent {}

class DatabaseAddNote extends DatabaseEvent {
  final String title;
  final String content;
  final String color;

  const DatabaseAddNote({
    required this.title,
    required this.content,
    this.color = '#6366F1',
  });

  @override
  List<Object?> get props => [title, content, color];
}

class DatabaseUpdateNote extends DatabaseEvent {
  final NoteModel note;

  const DatabaseUpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

class DatabaseDeleteNote extends DatabaseEvent {
  final String noteId;

  const DatabaseDeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

class DatabaseSwitchSource extends DatabaseEvent {
  final bool useRealtimeDatabase;

  const DatabaseSwitchSource({required this.useRealtimeDatabase});

  @override
  List<Object?> get props => [useRealtimeDatabase];
}

// States
abstract class DatabaseState extends Equatable {
  const DatabaseState();

  @override
  List<Object?> get props => [];
}

class DatabaseInitial extends DatabaseState {}

class DatabaseLoading extends DatabaseState {}

class DatabaseLoaded extends DatabaseState {
  final List<NoteModel> notes;
  final bool useRealtimeDatabase;

  const DatabaseLoaded({
    this.notes = const [],
    this.useRealtimeDatabase = false,
  });

  DatabaseLoaded copyWith({
    List<NoteModel>? notes,
    bool? useRealtimeDatabase,
  }) {
    return DatabaseLoaded(
      notes: notes ?? this.notes,
      useRealtimeDatabase: useRealtimeDatabase ?? this.useRealtimeDatabase,
    );
  }

  @override
  List<Object?> get props => [notes, useRealtimeDatabase];
}

class DatabaseError extends DatabaseState {
  final String message;
  const DatabaseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  final DatabaseRepository _repository;
  bool _useRealtimeDatabase = false;

  DatabaseBloc(this._repository) : super(DatabaseInitial()) {
    on<DatabaseLoadNotes>(_onLoadNotes);
    on<DatabaseAddNote>(_onAddNote);
    on<DatabaseUpdateNote>(_onUpdateNote);
    on<DatabaseDeleteNote>(_onDeleteNote);
    on<DatabaseSwitchSource>(_onSwitchSource);
  }

  Future<void> _onLoadNotes(
    DatabaseLoadNotes event,
    Emitter<DatabaseState> emit,
  ) async {
    emit(DatabaseLoading());
    try {
      final notes = await _repository.getNotes(
        useRealtimeDatabase: _useRealtimeDatabase,
      );
      emit(DatabaseLoaded(
        notes: notes,
        useRealtimeDatabase: _useRealtimeDatabase,
      ));
    } catch (e) {
      emit(DatabaseError(e.toString()));
    }
  }

  Future<void> _onAddNote(
    DatabaseAddNote event,
    Emitter<DatabaseState> emit,
  ) async {
    final currentState = state;
    if (currentState is DatabaseLoaded) {
      try {
        final note = await _repository.addNote(
          title: event.title,
          content: event.content,
          color: event.color,
          useRealtimeDatabase: _useRealtimeDatabase,
        );
        final updatedNotes = [note, ...currentState.notes];
        emit(currentState.copyWith(notes: updatedNotes));
      } catch (e) {
        emit(DatabaseError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateNote(
    DatabaseUpdateNote event,
    Emitter<DatabaseState> emit,
  ) async {
    final currentState = state;
    if (currentState is DatabaseLoaded) {
      try {
        await _repository.updateNote(
          event.note,
          useRealtimeDatabase: _useRealtimeDatabase,
        );
        final updatedNotes = currentState.notes.map((note) {
          return note.id == event.note.id ? event.note : note;
        }).toList();
        emit(currentState.copyWith(notes: updatedNotes));
      } catch (e) {
        emit(DatabaseError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteNote(
    DatabaseDeleteNote event,
    Emitter<DatabaseState> emit,
  ) async {
    final currentState = state;
    if (currentState is DatabaseLoaded) {
      try {
        await _repository.deleteNote(
          event.noteId,
          useRealtimeDatabase: _useRealtimeDatabase,
        );
        final updatedNotes = currentState.notes
            .where((note) => note.id != event.noteId)
            .toList();
        emit(currentState.copyWith(notes: updatedNotes));
      } catch (e) {
        emit(DatabaseError(e.toString()));
      }
    }
  }

  void _onSwitchSource(
    DatabaseSwitchSource event,
    Emitter<DatabaseState> emit,
  ) {
    _useRealtimeDatabase = event.useRealtimeDatabase;
    add(DatabaseLoadNotes());
  }
}