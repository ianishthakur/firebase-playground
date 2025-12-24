import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/di/injection.dart';
import '../../bloc/ml_bloc.dart';

class TextRecognitionScreen extends StatelessWidget {
  const TextRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MLBloc>(),
      child: const TextRecognitionContent(),
    );
  }
}

class TextRecognitionContent extends StatelessWidget {
  const TextRecognitionContent({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);
    if (image != null && context.mounted) {
      context.read<MLBloc>().add(MLRecognizeText(File(image.path)));
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
        title: const Text('Text Recognition'),
      ),
      body: BlocBuilder<MLBloc, MLState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumCard(
                  gradient: AppTheme.primaryGradient,
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
                        child: const Icon(Iconsax.scan, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OCR Technology',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Extract text from any image',
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

                if (state is MLTextRecognized) ...[
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
                            const Icon(Iconsax.document_text, size: 20, color: AppTheme.successColor),
                            const SizedBox(width: 8),
                            Text('Extracted Text', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Iconsax.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.result.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: const Text('Text copied!'), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd))),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: SelectableText(state.result.text.isEmpty ? 'No text found' : state.result.text, style: Theme.of(context).textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 12),
                        Text('${state.result.blocks.length} blocks detected', style: Theme.of(context).textTheme.bodySmall),
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
                        Icon(Iconsax.image, size: 48, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                        const SizedBox(height: 16),
                        Text('Select an image to extract text', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
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

                if (state is MLError)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: Column(
                      children: [
                        const Icon(Iconsax.warning_2, color: AppTheme.errorColor, size: 32),
                        const SizedBox(height: 12),
                        Text('Error occurred', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor), textAlign: TextAlign.center),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: 'Camera',
                        icon: Iconsax.camera,
                        onPressed: () => _pickImage(context, ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PremiumOutlineButton(
                        text: 'Gallery',
                        icon: Iconsax.gallery,
                        onPressed: () => _pickImage(context, ImageSource.gallery),
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

class PremiumOutlineButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PremiumOutlineButton({super.key, required this.text, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}