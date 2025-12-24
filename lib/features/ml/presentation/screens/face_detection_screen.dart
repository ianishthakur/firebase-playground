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

class FaceDetectionScreen extends StatelessWidget {
  const FaceDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MLBloc>(),
      child: const FaceDetectionContent(),
    );
  }
}

class FaceDetectionContent extends StatelessWidget {
  const FaceDetectionContent({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      context.read<MLBloc>().add(MLDetectFaces(File(image.path)));
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
        title: const Text('Face Detection'),
      ),
      body: BlocBuilder<MLBloc, MLState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumCard(
                  gradient: AppTheme.accentGradient,
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
                        child: const Icon(Iconsax.user_square, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Face Detection',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Detect faces & facial features',
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

                if (state is MLFacesDetected) ...[
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
                            const Icon(Iconsax.user_tick, size: 20, color: AppTheme.successColor),
                            const SizedBox(width: 8),
                            Text('${state.faces.length} Face(s) Detected', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        if (state.faces.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ...state.faces.asMap().entries.map((entry) {
                            final index = entry.key;
                            final face = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Face ${index + 1}', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  if (face.smilingProbability != null)
                                    _buildFeatureRow(context, 'Smiling', '${(face.smilingProbability! * 100).toStringAsFixed(1)}%', face.smilingProbability! > 0.5 ? AppTheme.successColor : AppTheme.warningColor),
                                  if (face.leftEyeOpenProbability != null)
                                    _buildFeatureRow(context, 'Left Eye Open', '${(face.leftEyeOpenProbability! * 100).toStringAsFixed(1)}%', face.leftEyeOpenProbability! > 0.5 ? AppTheme.successColor : AppTheme.warningColor),
                                  if (face.rightEyeOpenProbability != null)
                                    _buildFeatureRow(context, 'Right Eye Open', '${(face.rightEyeOpenProbability! * 100).toStringAsFixed(1)}%', face.rightEyeOpenProbability! > 0.5 ? AppTheme.successColor : AppTheme.warningColor),
                                  if (face.headEulerAngleY != null)
                                    _buildFeatureRow(context, 'Head Rotation Y', '${face.headEulerAngleY!.toStringAsFixed(1)}°', AppTheme.accentColor),
                                  if (face.headEulerAngleZ != null)
                                    _buildFeatureRow(context, 'Head Rotation Z', '${face.headEulerAngleZ!.toStringAsFixed(1)}°', AppTheme.accentColor),
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          const SizedBox(height: 16),
                          Text('No faces found in this image', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.lightTextSecondary)),
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
                        Icon(Iconsax.user_square, size: 48, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        const SizedBox(height: 16),
                        Text('Select an image to detect faces', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
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
                        gradient: AppTheme.accentGradient,
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
                          side: const BorderSide(color: AppTheme.accentColor, width: 1.5),
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

  Widget _buildFeatureRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}