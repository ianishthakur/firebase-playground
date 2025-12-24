import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileModel extends Equatable {
  final String name;
  final String path;
  final String fullPath;
  final int size;
  final String? contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? downloadUrl;

  const FileModel({
    required this.name,
    required this.path,
    required this.fullPath,
    this.size = 0,
    this.contentType,
    this.createdAt,
    this.updatedAt,
    this.downloadUrl,
  });

  factory FileModel.fromReference(Reference ref, FullMetadata metadata) {
    return FileModel(
      name: ref.name,
      path: ref.fullPath,
      fullPath: ref.fullPath,
      size: metadata.size ?? 0,
      contentType: metadata.contentType,
      createdAt: metadata.timeCreated,
      updatedAt: metadata.updated,
    );
  }

  FileModel copyWith({
    String? name,
    String? path,
    String? fullPath,
    int? size,
    String? contentType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? downloadUrl,
  }) {
    return FileModel(
      name: name ?? this.name,
      path: path ?? this.path,
      fullPath: fullPath ?? this.fullPath,
      size: size ?? this.size,
      contentType: contentType ?? this.contentType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  bool get isImage {
    final ext = fileExtension;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  bool get isVideo {
    final ext = fileExtension;
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  bool get isAudio {
    final ext = fileExtension;
    return ['mp3', 'wav', 'aac', 'flac', 'ogg'].contains(ext);
  }

  bool get isDocument {
    final ext = fileExtension;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'].contains(ext);
  }

  @override
  List<Object?> get props => [
        name,
        path,
        fullPath,
        size,
        contentType,
        createdAt,
        updatedAt,
        downloadUrl,
      ];
}