import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;

import '../../../data/file_model.dart';

abstract class StorageRepository {
  Future<List<FileModel>> listFiles({String? folder});
  Future<FileModel> uploadFile({
    required File file,
    String? folder,
    void Function(double)? onProgress,
  });
  Future<void> deleteFile(String filePath);
  Future<String> getDownloadUrl(String filePath);
}

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorage _storage;

  StorageRepositoryImpl(this._storage);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Reference get _userRef => _storage.ref('users/$_userId');

  @override
  Future<List<FileModel>> listFiles({String? folder}) async {
    if (_userId == null) return [];

    try {
      final ref = folder != null ? _userRef.child(folder) : _userRef;
      final result = await ref.listAll();

      final files = <FileModel>[];
      for (final item in result.items) {
        try {
          final metadata = await item.getMetadata();
          final downloadUrl = await item.getDownloadURL();
          files.add(FileModel.fromReference(item, metadata).copyWith(
            downloadUrl: downloadUrl,
          ));
        } catch (e) {
          // Skip files that can't be accessed
        }
      }

      // Sort by creation date, newest first
      files.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));

      return files;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FileModel> uploadFile({
    required File file,
    String? folder,
    void Function(double)? onProgress,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');

    final fileName = path.basename(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = folder != null
        ? '$folder/${timestamp}_$fileName'
        : '${timestamp}_$fileName';

    final ref = _userRef.child(storagePath);
    final uploadTask = ref.putFile(file);

    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress?.call(progress);
    });

    await uploadTask;

    final metadata = await ref.getMetadata();
    final downloadUrl = await ref.getDownloadURL();

    return FileModel.fromReference(ref, metadata).copyWith(
      downloadUrl: downloadUrl,
    );
  }

  @override
  Future<void> deleteFile(String filePath) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _storage.ref(filePath).delete();
  }

  @override
  Future<String> getDownloadUrl(String filePath) async {
    if (_userId == null) throw Exception('User not authenticated');

    return await _storage.ref(filePath).getDownloadURL();
  }
}