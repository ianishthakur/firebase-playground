import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/storage/bloc/storage_bloc.dart';
import 'package:firebase_flutter_app/features/storage/data/storage_repository.dart';
import 'package:firebase_flutter_app/features/storage/data/file_model.dart';

// Mocks
class MockStorageRepository extends Mock implements StorageRepository {}

class MockFile extends Mock implements File {}

void main() {
  late StorageBloc storageBloc;
  late MockStorageRepository mockStorageRepository;
  late MockFile mockFile;

  final testFiles = [
    FileModel(
      name: 'image1.jpg',
      path: 'users/user-123/image1.jpg',
      fullPath: 'users/user-123/image1.jpg',
      size: 1024 * 100, // 100 KB
      contentType: 'image/jpeg',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      downloadUrl: 'https://storage.example.com/image1.jpg',
    ),
    FileModel(
      name: 'document.pdf',
      path: 'users/user-123/document.pdf',
      fullPath: 'users/user-123/document.pdf',
      size: 1024 * 500, // 500 KB
      contentType: 'application/pdf',
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
      downloadUrl: 'https://storage.example.com/document.pdf',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    mockFile = MockFile();
    storageBloc = StorageBloc(mockStorageRepository);

    when(() => mockFile.path).thenReturn('/tmp/test_image.jpg');
  });

  tearDown(() {
    storageBloc.close();
  });

  group('StorageBloc', () {
    test('initial state is StorageInitial', () {
      expect(storageBloc.state, isA<StorageInitial>());
    });

    group('StorageLoadFiles', () {
      blocTest<StorageBloc, StorageState>(
        'emits [StorageLoading, StorageLoaded] when files are loaded successfully',
        build: () {
          when(() => mockStorageRepository.listFiles())
              .thenAnswer((_) async => testFiles);
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageLoadFiles()),
        expect: () => [
          isA<StorageLoading>(),
          isA<StorageLoaded>()
              .having((state) => state.files.length, 'files count', 2)
              .having((state) => state.totalSize, 'total size', 1024 * 600),
        ],
        verify: (_) {
          verify(() => mockStorageRepository.listFiles()).called(1);
        },
      );

      blocTest<StorageBloc, StorageState>(
        'emits [StorageLoading, StorageLoaded] with empty list when no files exist',
        build: () {
          when(() => mockStorageRepository.listFiles())
              .thenAnswer((_) async => []);
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageLoadFiles()),
        expect: () => [
          isA<StorageLoading>(),
          isA<StorageLoaded>()
              .having((state) => state.files.isEmpty, 'files is empty', true)
              .having((state) => state.totalSize, 'total size', 0),
        ],
      );

      blocTest<StorageBloc, StorageState>(
        'emits [StorageLoading, StorageError] when loading fails',
        build: () {
          when(() => mockStorageRepository.listFiles())
              .thenThrow(Exception('Failed to load files'));
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageLoadFiles()),
        expect: () => [
          isA<StorageLoading>(),
          isA<StorageError>(),
        ],
      );
    });

    group('StorageUploadFile', () {
      final uploadedFile = FileModel(
        name: 'new_image.jpg',
        path: 'users/user-123/new_image.jpg',
        fullPath: 'users/user-123/new_image.jpg',
        size: 1024 * 200,
        contentType: 'image/jpeg',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        downloadUrl: 'https://storage.example.com/new_image.jpg',
      );

      blocTest<StorageBloc, StorageState>(
        'emits [StorageUploading, StorageLoading, StorageLoaded] when file is uploaded successfully',
        build: () {
          when(() => mockStorageRepository.uploadFile(
                file: any(named: 'file'),
                folder: any(named: 'folder'),
                onProgress: any(named: 'onProgress'),
              )).thenAnswer((_) async => uploadedFile);
          when(() => mockStorageRepository.listFiles())
              .thenAnswer((_) async => [...testFiles, uploadedFile]);
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageUploadFile(file: mockFile)),
        expect: () => [
          isA<StorageUploading>().having((state) => state.progress, 'initial progress', 0),
          isA<StorageLoading>(),
          isA<StorageLoaded>().having((state) => state.files.length, 'files count', 3),
        ],
      );

      blocTest<StorageBloc, StorageState>(
        'emits [StorageUploading, StorageError] when upload fails',
        build: () {
          when(() => mockStorageRepository.uploadFile(
                file: any(named: 'file'),
                folder: any(named: 'folder'),
                onProgress: any(named: 'onProgress'),
              )).thenThrow(Exception('Upload failed'));
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageUploadFile(file: mockFile)),
        expect: () => [
          isA<StorageUploading>(),
          isA<StorageError>(),
        ],
      );
    });

    group('StorageDeleteFile', () {
      blocTest<StorageBloc, StorageState>(
        'emits updated StorageLoaded when file is deleted successfully',
        seed: () => StorageLoaded(files: testFiles, totalSize: 1024 * 600),
        build: () {
          when(() => mockStorageRepository.deleteFile(testFiles[0].fullPath))
              .thenAnswer((_) async {});
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageDeleteFile(testFiles[0].fullPath)),
        expect: () => [
          isA<StorageLoaded>()
              .having((state) => state.files.length, 'files count after delete', 1)
              .having((state) => state.totalSize, 'updated total size', 1024 * 500),
        ],
      );

      blocTest<StorageBloc, StorageState>(
        'emits StorageError when delete fails',
        seed: () => StorageLoaded(files: testFiles, totalSize: 1024 * 600),
        build: () {
          when(() => mockStorageRepository.deleteFile(any()))
              .thenThrow(Exception('Delete failed'));
          return storageBloc;
        },
        act: (bloc) => bloc.add(StorageDeleteFile(testFiles[0].fullPath)),
        expect: () => [
          isA<StorageError>(),
        ],
      );
    });
  });

  group('FileModel', () {
    test('formattedSize returns correct format for bytes', () {
      const file = FileModel(
        name: 'small.txt',
        path: 'path',
        fullPath: 'path',
        size: 500,
      );
      expect(file.formattedSize, '500 B');
    });

    test('formattedSize returns correct format for KB', () {
      const file = FileModel(
        name: 'medium.txt',
        path: 'path',
        fullPath: 'path',
        size: 1024 * 50,
      );
      expect(file.formattedSize, '50.0 KB');
    });

    test('formattedSize returns correct format for MB', () {
      const file = FileModel(
        name: 'large.txt',
        path: 'path',
        fullPath: 'path',
        size: 1024 * 1024 * 5,
      );
      expect(file.formattedSize, '5.0 MB');
    });

    test('isImage returns true for image extensions', () {
      const jpgFile = FileModel(name: 'photo.jpg', path: 'p', fullPath: 'p');
      const pngFile = FileModel(name: 'image.png', path: 'p', fullPath: 'p');
      const gifFile = FileModel(name: 'anim.gif', path: 'p', fullPath: 'p');

      expect(jpgFile.isImage, true);
      expect(pngFile.isImage, true);
      expect(gifFile.isImage, true);
    });

    test('isDocument returns true for document extensions', () {
      const pdfFile = FileModel(name: 'doc.pdf', path: 'p', fullPath: 'p');
      const docxFile = FileModel(name: 'file.docx', path: 'p', fullPath: 'p');

      expect(pdfFile.isDocument, true);
      expect(docxFile.isDocument, true);
    });

    test('isVideo returns true for video extensions', () {
      const mp4File = FileModel(name: 'video.mp4', path: 'p', fullPath: 'p');
      const movFile = FileModel(name: 'clip.mov', path: 'p', fullPath: 'p');

      expect(mp4File.isVideo, true);
      expect(movFile.isVideo, true);
    });

    test('isAudio returns true for audio extensions', () {
      const mp3File = FileModel(name: 'song.mp3', path: 'p', fullPath: 'p');
      const wavFile = FileModel(name: 'audio.wav', path: 'p', fullPath: 'p');

      expect(mp3File.isAudio, true);
      expect(wavFile.isAudio, true);
    });
  });
}
