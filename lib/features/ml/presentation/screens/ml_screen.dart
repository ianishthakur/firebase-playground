import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';

class MLScreen extends StatelessWidget {
  const MLScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Iconsax.cpu,
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
                          'ML Kit',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'On-device machine learning',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.info_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All ML features run on-device, no internet required!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // ML Features Grid
              Text(
                'Vision Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildFeatureCard(
                    context,
                    Iconsax.scan,
                    'Text Recognition',
                    'Extract text from images',
                    AppTheme.primaryGradient,
                    () => context.push('/ml/text-recognition'),
                    0,
                  ),
                  _buildFeatureCard(
                    context,
                    Iconsax.user_square,
                    'Face Detection',
                    'Detect faces & features',
                    AppTheme.accentGradient,
                    () => context.push('/ml/face-detection'),
                    1,
                  ),
                  _buildFeatureCard(
                    context,
                    Iconsax.scan_barcode,
                    'Barcode Scanner',
                    'Scan QR & barcodes',
                    AppTheme.warmGradient,
                    () => context.push('/ml/barcode-scanner'),
                    2,
                  ),
                  _buildFeatureCard(
                    context,
                    Iconsax.tag,
                    'Image Labeling',
                    'Identify objects',
                    const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    () => context.push('/ml/image-labeling'),
                    3,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Language Features
              Text(
                'Language Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),

              const SizedBox(height: 16),

              _buildFullWidthFeatureCard(
                context,
                Iconsax.translate,
                'Translation',
                'Translate text between 59+ languages',
                const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                () => context.push('/ml/translation'),
                7,
              ),

              const SizedBox(height: 24),

              // Coming Soon Features
              Text(
                'More Features',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms),

              const SizedBox(height: 16),

              _buildComingSoonCard(
                context,
                [
                  _ComingSoonItem(Iconsax.message_text, 'Smart Reply'),
                  _ComingSoonItem(Iconsax.language_circle, 'Language ID'),
                  _ComingSoonItem(Iconsax.box, 'Object Detection'),
                  _ComingSoonItem(Iconsax.people, 'Pose Detection'),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    LinearGradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return FeatureCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      gradient: gradient,
      onTap: onTap,
      animationIndex: index,
    );
  }

  Widget _buildFullWidthFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    LinearGradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return PremiumCard(
      onTap: onTap,
      hasShadow: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Iconsax.arrow_right_3,
            size: 20,
            color: AppTheme.lightTextSecondary,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: 100 * index),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildComingSoonCard(
    BuildContext context,
    List<_ComingSoonItem> items,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map((item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 16,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms);
  }
}

class _ComingSoonItem {
  final IconData icon;
  final String label;

  _ComingSoonItem(this.icon, this.label);
}