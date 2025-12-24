import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/note_model.dart';

abstract class DatabaseRepository {
  Future<List<NoteModel>> getNotes({bool useRealtimeDatabase = false});
  Future<NoteModel> addNote({
    required String title,
    required String content,
    String color = '#6366F1',
    bool useRealtimeDatabase = false,
  });
  Future<void> updateNote(NoteModel note, {bool useRealtimeDatabase = false});
  Future<void> deleteNote(String noteId, {bool useRealtimeDatabase = false});
  Stream<List<NoteModel>> notesStream({bool useRealtimeDatabase = false});
}

class DatabaseRepositoryImpl implements DatabaseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _realtimeDatabase;

  DatabaseRepositoryImpl(this._firestore, this._realtimeDatabase);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference get _notesCollection =>
      _firestore.collection('users').doc(_userId).collection('notes');

  DatabaseReference get _notesRef =>
      _realtimeDatabase.ref('users/$_userId/notes');

  @override
  Future<List<NoteModel>> getNotes({bool useRealtimeDatabase = false}) async {
    if (_userId == null) return [];

    if (useRealtimeDatabase) {
      final snapshot = await _notesRef.orderByChild('createdAt').get();
      if (!snapshot.exists) return [];

      final notes = <NoteModel>[];
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        notes.add(NoteModel.fromRealtimeDatabase(key, value as Map<dynamic, dynamic>));
      });
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notes;
    } else {
      final snapshot = await _notesCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    }
  }

  @override
  Future<NoteModel> addNote({
    required String title,
    required String content,
    String color = '#6366F1',
    bool useRealtimeDatabase = false,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    
    if (useRealtimeDatabase) {
      final newRef = _notesRef.push();
      final note = NoteModel(
        id: newRef.key!,
        title: title,
        content: content,
        color: color,
        createdAt: now,
        updatedAt: now,
        userId: _userId,
      );
      await newRef.set(note.toRealtimeDatabase());
      return note;
    } else {
      final docRef = _notesCollection.doc();
      final note = NoteModel(
        id: docRef.id,
        title: title,
        content: content,
        color: color,
        createdAt: now,
        updatedAt: now,
        userId: _userId,
      );
      await docRef.set(note.toFirestore());
      return note;
    }
  }

  @override
  Future<void> updateNote(NoteModel note, {bool useRealtimeDatabase = false}) async {
    if (_userId == null) throw Exception('User not authenticated');

    final updatedNote = note.copyWith(updatedAt: DateTime.now());

    if (useRealtimeDatabase) {
      await _notesRef.child(note.id).update(updatedNote.toRealtimeDatabase());
    } else {
      await _notesCollection.doc(note.id).update(updatedNote.toFirestore());
    }
  }

  @override
  Future<void> deleteNote(String noteId, {bool useRealtimeDatabase = false}) async {
    if (_userId == null) throw Exception('User not authenticated');

    if (useRealtimeDatabase) {
      await _notesRef.child(noteId).remove();
    } else {
      await _notesCollection.doc(noteId).delete();
    }
  }

  @override
  Stream<List<NoteModel>> notesStream({bool useRealtimeDatabase = false}) {
    if (_userId == null) return Stream.value([]);

    if (useRealtimeDatabase) {
      return _notesRef.onValue.map((event) {
        if (!event.snapshot.exists) return <NoteModel>[];
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final notes = <NoteModel>[];
        data.forEach((key, value) {
          notes.add(NoteModel.fromRealtimeDatabase(key, value as Map<dynamic, dynamic>));
        });
        notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return notes;
      });
    } else {
      return _notesCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
    }
  }
}