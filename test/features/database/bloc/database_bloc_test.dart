import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/database/bloc/database_bloc.dart';
import 'package:firebase_flutter_app/features/database/data/database_repository.dart';
import 'package:firebase_flutter_app/features/database/data/note_model.dart';

// Mocks
class MockDatabaseRepository extends Mock implements DatabaseRepository {}

void main() {
  late DatabaseBloc databaseBloc;
  late MockDatabaseRepository mockDatabaseRepository;

  final testNotes = [
    NoteModel(
      id: '1',
      title: 'Test Note 1',
      content: 'Content 1',
      color: '#6366F1',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      userId: 'user-123',
    ),
    NoteModel(
      id: '2',
      title: 'Test Note 2',
      content: 'Content 2',
      color: '#10B981',
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      userId: 'user-123',
    ),
  ];

  setUp(() {
    mockDatabaseRepository = MockDatabaseRepository();
    databaseBloc = DatabaseBloc(mockDatabaseRepository);
  });

  tearDown(() {
    databaseBloc.close();
  });

  group('DatabaseBloc', () {
    test('initial state is DatabaseInitial', () {
      expect(databaseBloc.state, isA<DatabaseInitial>());
    });

    group('DatabaseLoadNotes', () {
      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when notes are loaded successfully from Firestore',
        build: () {
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => testNotes);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(DatabaseLoadNotes()),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.notes.length,
            'notes count',
            2,
          ),
        ],
        verify: (_) {
          verify(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false)).called(1);
        },
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] with empty list when no notes exist',
        build: () {
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => []);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(DatabaseLoadNotes()),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.notes.isEmpty,
            'notes is empty',
            true,
          ),
        ],
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseError] when loading fails',
        build: () {
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenThrow(Exception('Failed to load notes'));
          return databaseBloc;
        },
        act: (bloc) => bloc.add(DatabaseLoadNotes()),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseError>(),
        ],
      );
    });

    group('DatabaseAddNote', () {
      final newNote = NoteModel(
        id: '3',
        title: 'New Note',
        content: 'New Content',
        color: '#F59E0B',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'user-123',
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when note is added successfully',
        build: () {
          when(() => mockDatabaseRepository.addNote(
                title: 'New Note',
                content: 'New Content',
                color: '#F59E0B',
                useRealtimeDatabase: false,
              )).thenAnswer((_) async => newNote);
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => [...testNotes, newNote]);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(const DatabaseAddNote(
          title: 'New Note',
          content: 'New Content',
          color: '#F59E0B',
        )),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.notes.length,
            'notes count',
            3,
          ),
        ],
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseError] when adding note fails',
        build: () {
          when(() => mockDatabaseRepository.addNote(
                title: any(named: 'title'),
                content: any(named: 'content'),
                color: any(named: 'color'),
                useRealtimeDatabase: false,
              )).thenThrow(Exception('Failed to add note'));
          return databaseBloc;
        },
        act: (bloc) => bloc.add(const DatabaseAddNote(
          title: 'New Note',
          content: 'New Content',
          color: '#F59E0B',
        )),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseError>(),
        ],
      );
    });

    group('DatabaseUpdateNote', () {
      final updatedNote = testNotes[0].copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when note is updated successfully',
        build: () {
          when(() => mockDatabaseRepository.updateNote(updatedNote, useRealtimeDatabase: false))
              .thenAnswer((_) async {});
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => [updatedNote, testNotes[1]]);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(DatabaseUpdateNote(updatedNote)),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.notes.first.title,
            'updated title',
            'Updated Title',
          ),
        ],
      );
    });

    group('DatabaseDeleteNote', () {
      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when note is deleted successfully',
        build: () {
          when(() => mockDatabaseRepository.deleteNote('1', useRealtimeDatabase: false))
              .thenAnswer((_) async {});
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => [testNotes[1]]);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(const DatabaseDeleteNote('1')),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.notes.length,
            'notes count after delete',
            1,
          ),
        ],
      );
    });

    group('DatabaseSwitchSource', () {
      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when switching to Realtime Database',
        build: () {
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: true))
              .thenAnswer((_) async => testNotes);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(const DatabaseSwitchSource(useRealtimeDatabase: true)),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.useRealtimeDatabase,
            'uses realtime database',
            true,
          ),
        ],
      );

      blocTest<DatabaseBloc, DatabaseState>(
        'emits [DatabaseLoading, DatabaseLoaded] when switching to Firestore',
        build: () {
          when(() => mockDatabaseRepository.getNotes(useRealtimeDatabase: false))
              .thenAnswer((_) async => testNotes);
          return databaseBloc;
        },
        act: (bloc) => bloc.add(const DatabaseSwitchSource(useRealtimeDatabase: false)),
        expect: () => [
          isA<DatabaseLoading>(),
          isA<DatabaseLoaded>().having(
            (state) => state.useRealtimeDatabase,
            'uses realtime database',
            false,
          ),
        ],
      );
    });
  });
}
