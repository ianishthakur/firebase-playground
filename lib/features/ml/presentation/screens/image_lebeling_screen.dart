import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/di/injection.dart';
import '../../bloc/ml_bloc.dart';

class ImageLabelingScreen extends StatelessWidget {
  const ImageLabelingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MLBloc>(),
      child: const ImageLabelingContent(),
    );
  }
}

class ImageLabelingContent extends StatelessWidget {
  const ImageLabelingContent({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      context.read<MLBloc>().add(MLLabelImage(File(image.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Image Labeling'),
      ),
      body: BlocBuilder<MLBloc, MLState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  hasBorder: false,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.tag, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Image Labeling',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Identify objects in images',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                if (state is MLImageLabeled) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Image.file(state.image, width: double.infinity, height: 200, fit: BoxFit.cover),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  PremiumCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.tag, size: 20, color: AppTheme.successColor),
                            const SizedBox(width: 8),
                            Text('${state.labels.length} Labels Found', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (state.labels.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: state.labels.map((label) {
                              final confidence = (label.confidence * 100).toStringAsFixed(0);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      label.label,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$confidence%',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Confidence Scores', style: Theme.of(context).textTheme.labelMedium),
                                const SizedBox(height: 8),
                                ...state.labels.take(5).map((label) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(label.label, style: Theme.of(context).textTheme.bodySmall),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: LinearProgressIndicator(
                                            value: label.confidence,
                                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              label.confidence > 0.8
                                                  ? AppTheme.successColor
                                                  : label.confidence > 0.5
                                                      ? AppTheme.warningColor
                                                      : AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(label.confidence * 100).toStringAsFixed(0)}%',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Text('No labels identified', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextSecondary)),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                ],

                if (state is MLInitial)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.tag, size: 48, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        const SizedBox(height: 16),
                        Text('Select an image to identify objects', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                if (state is MLLoading)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Camera',
                        icon: Iconsax.camera,
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                        onPressed: () => _pickImage(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(context, ImageSource.gallery),
                        icon: const Icon(Iconsax.gallery, size: 20),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: const Color(0xFF8B5CF6),
                          side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }
}