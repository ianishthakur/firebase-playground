import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/database/data/note_model.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('NoteModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('constructor', () {
      test('creates NoteModel with all fields', () {
        final note = NoteModel(
          id: 'note-123',
          title: 'Test Note',
          content: 'Test content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        expect(note.id, 'note-123');
        expect(note.title, 'Test Note');
        expect(note.content, 'Test content');
        expect(note.color, '#6366F1');
        expect(note.createdAt, testDate);
        expect(note.updatedAt, testDate);
        expect(note.userId, 'user-123');
      });

      test('creates NoteModel with default color', () {
        final note = NoteModel(
          id: 'note-123',
          title: 'Test Note',
          content: 'Test content',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(note.color, '#6366F1'); // Default primary color
      });
    });

    group('copyWith', () {
      test('creates copy with updated title', () {
        final original = NoteModel(
          id: 'note-123',
          title: 'Original Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(title: 'New Title');

        expect(copy.id, 'note-123');
        expect(copy.title, 'New Title');
        expect(copy.content, 'Content');
        expect(copy.color, '#6366F1');
      });

      test('creates copy with updated content', () {
        final original = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Original Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(content: 'New Content');

        expect(copy.title, 'Title');
        expect(copy.content, 'New Content');
      });

      test('creates copy with updated color', () {
        final original = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final copy = original.copyWith(color: '#10B981');

        expect(copy.color, '#10B981');
      });

      test('creates copy with updated timestamp', () {
        final original = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        final newDate = DateTime(2024, 2, 20);
        final copy = original.copyWith(updatedAt: newDate);

        expect(copy.createdAt, testDate);
        expect(copy.updatedAt, newDate);
      });

      test('keeps original values when not overridden', () {
        final original = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.title, original.title);
        expect(copy.content, original.content);
        expect(copy.color, original.color);
        expect(copy.createdAt, original.createdAt);
        expect(copy.updatedAt, original.updatedAt);
        expect(copy.userId, original.userId);
      });
    });

    group('toFirestore', () {
      test('converts NoteModel to Firestore map', () {
        final note = NoteModel(
          id: 'note-123',
          title: 'Test Note',
          content: 'Test content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        final map = note.toFirestore();

        expect(map['title'], 'Test Note');
        expect(map['content'], 'Test content');
        expect(map['color'], '#6366F1');
        expect(map['userId'], 'user-123');
        expect(map['createdAt'], isA<Timestamp>());
        expect(map['updatedAt'], isA<Timestamp>());
        // ID should not be in the map (it's the document ID)
        expect(map.containsKey('id'), false);
      });
    });

    group('fromFirestore', () {
      test('creates NoteModel from Firestore document', () {
        final mockDoc = MockDocumentSnapshot();
        
        when(() => mockDoc.id).thenReturn('firestore-note-id');
        when(() => mockDoc.data()).thenReturn({
          'title': 'Firestore Note',
          'content': 'Firestore content',
          'color': '#F59E0B',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'userId': 'firestore-user',
        });

        final note = NoteModel.fromFirestore(mockDoc);

        expect(note.id, 'firestore-note-id');
        expect(note.title, 'Firestore Note');
        expect(note.content, 'Firestore content');
        expect(note.color, '#F59E0B');
        expect(note.userId, 'firestore-user');
      });

      test('handles missing optional fields', () {
        final mockDoc = MockDocumentSnapshot();
        
        when(() => mockDoc.id).thenReturn('note-id');
        when(() => mockDoc.data()).thenReturn({
          'title': 'Minimal Note',
          'content': 'Content',
          'createdAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
        });

        final note = NoteModel.fromFirestore(mockDoc);

        expect(note.id, 'note-id');
        expect(note.title, 'Minimal Note');
        expect(note.color, '#6366F1'); // Default color
        expect(note.userId, isNull);
      });
    });

    group('toRealtimeDatabase', () {
      test('converts NoteModel to Realtime Database map', () {
        final note = NoteModel(
          id: 'note-123',
          title: 'RT Note',
          content: 'RT content',
          color: '#EF4444',
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        final map = note.toRealtimeDatabase();

        expect(map['title'], 'RT Note');
        expect(map['content'], 'RT content');
        expect(map['color'], '#EF4444');
        expect(map['userId'], 'user-123');
        expect(map['createdAt'], testDate.millisecondsSinceEpoch);
        expect(map['updatedAt'], testDate.millisecondsSinceEpoch);
      });
    });

    group('fromRealtimeDatabase', () {
      test('creates NoteModel from Realtime Database data', () {
        final data = {
          'title': 'RT Note',
          'content': 'RT content',
          'color': '#8B5CF6',
          'createdAt': testDate.millisecondsSinceEpoch,
          'updatedAt': testDate.millisecondsSinceEpoch,
          'userId': 'rt-user',
        };

        final note = NoteModel.fromRealtimeDatabase('rt-note-id', data);

        expect(note.id, 'rt-note-id');
        expect(note.title, 'RT Note');
        expect(note.content, 'RT content');
        expect(note.color, '#8B5CF6');
        expect(note.userId, 'rt-user');
      });

      test('handles missing optional fields in Realtime Database', () {
        final data = {
          'title': 'Minimal RT Note',
          'content': 'Content',
          'createdAt': testDate.millisecondsSinceEpoch,
          'updatedAt': testDate.millisecondsSinceEpoch,
        };

        final note = NoteModel.fromRealtimeDatabase('rt-note-id', data);

        expect(note.id, 'rt-note-id');
        expect(note.title, 'Minimal RT Note');
        expect(note.color, '#6366F1'); // Default color
      });
    });

    group('equality', () {
      test('two NoteModels with same values are equal', () {
        final note1 = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );
        final note2 = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(note1, equals(note2));
      });

      test('two NoteModels with different IDs are not equal', () {
        final note1 = NoteModel(
          id: 'note-1',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );
        final note2 = NoteModel(
          id: 'note-2',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(note1, isNot(equals(note2)));
      });

      test('two NoteModels with different content are not equal', () {
        final note1 = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content 1',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );
        final note2 = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content 2',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(note1, isNot(equals(note2)));
      });
    });

    group('props', () {
      test('props contains all fields for Equatable', () {
        final note = NoteModel(
          id: 'note-123',
          title: 'Title',
          content: 'Content',
          color: '#6366F1',
          createdAt: testDate,
          updatedAt: testDate,
          userId: 'user-123',
        );

        expect(note.props, [
          'note-123',
          'Title',
          'Content',
          '#6366F1',
          testDate,
          testDate,
          'user-123',
        ]);
      });
    });
  });
}
