import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/widgets/premium_text_field.dart';
import '../../../../../../core/di/injection.dart';
import '../../bloc/ml_bloc.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MLBloc>(),
      child: const TranslationContent(),
    );
  }
}

class TranslationContent extends StatefulWidget {
  const TranslationContent({super.key});

  @override
  State<TranslationContent> createState() => _TranslationContentState();
}

class _TranslationContentState extends State<TranslationContent> {
  final _textController = TextEditingController();
  String _sourceLanguage = 'en';
  String _targetLanguage = 'es';

  final _languages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'zh': 'Chinese',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ar': 'Arabic',
    'hi': 'Hindi',
  };

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _translate() {
    if (_textController.text.trim().isEmpty) return;
    context.read<MLBloc>().add(MLTranslateText(
          text: _textController.text.trim(),
          sourceLanguage: _sourceLanguage,
          targetLanguage: _targetLanguage,
        ));
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
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
        title: const Text('Translation'),
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                        child: const Icon(Iconsax.translate, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'On-Device Translation',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Translate text between 59+ languages',
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

                // Language Selector
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildLanguageDropdown(
                          context,
                          'From',
                          _sourceLanguage,
                          (value) => setState(() => _sourceLanguage = value!),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: IconButton(
                          onPressed: _swapLanguages,
                          icon: const Icon(Iconsax.arrow_swap_horizontal, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildLanguageDropdown(
                          context,
                          'To',
                          _targetLanguage,
                          (value) => setState(() => _targetLanguage = value!),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // Input Text Field
                PremiumTextField(
                  controller: _textController,
                  label: 'Text to Translate',
                  hint: 'Enter text here...',
                  maxLines: 4,
                  prefixIcon: Iconsax.edit,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // Translate Button
                PremiumButton(
                  text: 'Translate',
                  icon: Iconsax.translate,
                  gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                  isLoading: state is MLLoading,
                  onPressed: _translate,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Result
                if (state is MLTextTranslated) ...[
                  PremiumCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.tick_circle, size: 20, color: AppTheme.successColor),
                            const SizedBox(width: 8),
                            Text('Translation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Iconsax.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.translatedText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Translation copied!'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Original (${_languages[_sourceLanguage]})', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.lightTextSecondary)),
                              const SizedBox(height: 4),
                              Text(state.originalText, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Translation (${_languages[_targetLanguage]})', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.successColor)),
                              const SizedBox(height: 4),
                              SelectableText(state.translatedText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                ],

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
                        Text(
                          'Translation model may need to be downloaded.\nPlease try again.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Supported Languages Info
                PremiumCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Iconsax.info_circle, color: AppTheme.primaryColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('On-Device Processing', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            Text('Translation models download automatically', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.lightTextSecondary)),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Iconsax.arrow_down_1, size: 16),
          items: _languages.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}