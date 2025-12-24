import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/storage_repository.dart';
import '../../../data/file_model.dart';

// Events
abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object?> get props => [];
}

class StorageLoadFiles extends StorageEvent {}

class StorageUploadFile extends StorageEvent {
  final File file;
  final String? folder;

  const StorageUploadFile({required this.file, this.folder});

  @override
  List<Object?> get props => [file, folder];
}

class StorageDeleteFile extends StorageEvent {
  final String filePath;

  const StorageDeleteFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class StorageDownloadFile extends StorageEvent {
  final String filePath;

  const StorageDownloadFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// States
abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object?> get props => [];
}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageUploading extends StorageState {
  final double progress;

  const StorageUploading({this.progress = 0});

  @override
  List<Object?> get props => [progress];
}

class StorageLoaded extends StorageState {
  final List<FileModel> files;
  final int totalSize;

  const StorageLoaded({
    this.files = const [],
    this.totalSize = 0,
  });

  StorageLoaded copyWith({
    List<FileModel>? files,
    int? totalSize,
  }) {
    return StorageLoaded(
      files: files ?? this.files,
      totalSize: totalSize ?? this.totalSize,
    );
  }

  @override
  List<Object?> get props => [files, totalSize];
}

class StorageError extends StorageState {
  final String message;
  const StorageError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageRepository _repository;

  StorageBloc(this._repository) : super(StorageInitial()) {
    on<StorageLoadFiles>(_onLoadFiles);
    on<StorageUploadFile>(_onUploadFile);
    on<StorageDeleteFile>(_onDeleteFile);
    on<StorageDownloadFile>(_onDownloadFile);
  }

  Future<void> _onLoadFiles(
    StorageLoadFiles event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    try {
      final files = await _repository.listFiles();
      final totalSize = files.fold<int>(0, (sum, file) => sum + file.size);
      emit(StorageLoaded(files: files, totalSize: totalSize));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  Future<void> _onUploadFile(
    StorageUploadFile event,
    Emitter<StorageState> emit,
  ) async {
    emit(const StorageUploading(progress: 0));
    try {
      await _repository.uploadFile(
        file: event.file,
        folder: event.folder,
        onProgress: (progress) {
          emit(StorageUploading(progress: progress));
        },
      );
      add(StorageLoadFiles());
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  Future<void> _onDeleteFile(
    StorageDeleteFile event,
    Emitter<StorageState> emit,
  ) async {
    final currentState = state;
    if (currentState is StorageLoaded) {
      try {
        await _repository.deleteFile(event.filePath);
        final updatedFiles = currentState.files
            .where((file) => file.path != event.filePath)
            .toList();
        final totalSize = updatedFiles.fold<int>(0, (sum, file) => sum + file.size);
        emit(currentState.copyWith(files: updatedFiles, totalSize: totalSize));
      } catch (e) {
        emit(StorageError(e.toString()));
      }
    }
  }

  Future<void> _onDownloadFile(
    StorageDownloadFile event,
    Emitter<StorageState> emit,
  ) async {
    try {
      await _repository.getDownloadUrl(event.filePath);
      // The URL can be used to download the file
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }
}