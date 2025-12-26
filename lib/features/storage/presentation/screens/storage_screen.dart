import 'dart:io';
import 'package:firebase_playground/features/storage/data/file_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/di/injection.dart';
import '../../bloc/storage_bloc.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StorageBloc>()..add(StorageLoadFiles()),
      child: const StorageScreenContent(),
    );
  }
}

class StorageScreenContent extends StatelessWidget {
  const StorageScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.warmGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Iconsax.folder_cloud,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloud Storage',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              'Upload & manage files',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Storage Stats
                  BlocBuilder<StorageBloc, StorageState>(
                    builder: (context, state) {
                      int fileCount = 0;
                      String totalSize = '0 B';

                      if (state is StorageLoaded) {
                        fileCount = state.files.length;
                        totalSize = _formatSize(state.totalSize);
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Iconsax.document,
                                '$fileCount',
                                'Files',
                                AppTheme.primaryColor,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Iconsax.chart,
                                totalSize,
                                'Used',
                                AppTheme.successColor,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Iconsax.cloud,
                                '5 GB',
                                'Free Limit',
                                AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),

            // Upload Progress
            BlocBuilder<StorageBloc, StorageState>(
              builder: (context, state) {
                if (state is StorageUploading) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            value: state.progress,
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploading...',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: state.progress,
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(state.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 8),

            // Files Grid
            Expanded(
              child: BlocBuilder<StorageBloc, StorageState>(
                builder: (context, state) {
                  if (state is StorageLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is StorageError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.warning_2,
                            size: 48,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading files',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              context.read<StorageBloc>().add(StorageLoadFiles());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is StorageLoaded) {
                    if (state.files.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: state.files.length,
                      itemBuilder: (context, index) {
                        final file = state.files[index];
                        return _buildFileCard(context, file, index);
                      },
                    );
                  }

                  return _buildEmptyState(context);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadOptions(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: const Text(
          'Upload',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      )
          .animate()
          .scale(delay: 500.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Iconsax.folder_open,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No files yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first file to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTextSecondary,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildFileCard(BuildContext context, FileModel file, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      onTap: () => _showFileOptions(context, file),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: file.isImage && file.downloadUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: file.downloadUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildFileIcon(file),
                      ),
                    )
                  : _buildFileIcon(file),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  file.formattedSize,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 400.ms,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: Duration(milliseconds: 100 * index),
        );
  }

  Widget _buildFileIcon(FileModel file) {
    IconData icon;
    Color color;

    if (file.isImage) {
      icon = Iconsax.image;
      color = AppTheme.primaryColor;
    } else if (file.isVideo) {
      icon = Iconsax.video;
      color = AppTheme.errorColor;
    } else if (file.isAudio) {
      icon = Iconsax.music;
      color = AppTheme.successColor;
    } else if (file.isDocument) {
      icon = Iconsax.document_text;
      color = AppTheme.warningColor;
    } else {
      icon = Iconsax.document;
      color = AppTheme.accentColor;
    }

    return Center(
      child: Icon(icon, size: 40, color: color),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : AppTheme.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upload File',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadOption(
                      context,
                      Iconsax.camera,
                      'Camera',
                      AppTheme.primaryGradient,
                      () async {
                        Navigator.pop(dialogContext);
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        if (image != null && context.mounted) {
                          context.read<StorageBloc>().add(
                                StorageUploadFile(file: File(image.path)),
                              );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadOption(
                      context,
                      Iconsax.gallery,
                      'Gallery',
                      AppTheme.accentGradient,
                      () async {
                        Navigator.pop(dialogContext);
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null && context.mounted) {
                          context.read<StorageBloc>().add(
                                StorageUploadFile(file: File(image.path)),
                              );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadOption(
                      context,
                      Iconsax.document,
                      'Files',
                      AppTheme.warmGradient,
                      () async {
                        Navigator.pop(dialogContext);
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null &&
                            result.files.single.path != null &&
                            context.mounted) {
                          context.read<StorageBloc>().add(
                                StorageUploadFile(
                                  file: File(result.files.single.path!),
                                ),
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption(
    BuildContext context,
    IconData icon,
    String label,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFileOptions(BuildContext context, FileModel file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCard
              : AppTheme.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                file.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${file.formattedSize} • ${file.fileExtension.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              PremiumButton(
                text: 'Delete File',
                gradient: const LinearGradient(
                  colors: [AppTheme.errorColor, Color(0xFFDC2626)],
                ),
                icon: Iconsax.trash,
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<StorageBloc>().add(StorageDeleteFile(file.fullPath));
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}