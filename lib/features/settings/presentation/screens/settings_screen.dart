import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_playground/features/analytics/bloc/analytics_bloc.dart';
import 'package:firebase_playground/features/remote_config/bloc/remote_config_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remote Config',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            BlocBuilder<RemoteConfigBloc, RemoteConfigState>(
              builder: (context, state) {
                return PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Iconsax.setting_4,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Remote Config',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  state is RemoteConfigLoaded
                                      ? 'Loaded'
                                      : 'Loading...',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: state is RemoteConfigLoaded
                                            ? AppTheme.successColor
                                            : AppTheme.warningColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => context
                                .read<RemoteConfigBloc>()
                                .add(RemoteConfigFetch()),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                      if (state is RemoteConfigLoaded &&
                          state.values.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        ...state.values.entries
                            .take(5)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        entry.value.toString().length > 20
                                            ? '${entry.value.toString().substring(0, 20)}...'
                                            : entry.value.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(fontFamily: 'monospace'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
              },
            ),

            const SizedBox(height: 24),

            Text(
              'Analytics & Monitoring',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 12),

            _buildActionCard(
              context,
              Iconsax.chart,
              'Log Analytics Event',
              'Send a test event to Firebase Analytics',
              AppTheme.accentGradient,
              () {
                context.read<AnalyticsBloc>().add(
                  const AnalyticsLogEvent(
                    name: 'test_event',
                    parameters: {'source': 'settings'},
                  ),
                );
                _showSnackBar(context, 'Analytics event logged!');
              },
              0,
            ),

            _buildActionCard(
              context,
              Iconsax.warning_2,
              'Test Crashlytics',
              'Log a non-fatal error to Crashlytics',
              AppTheme.warmGradient,
              () {
                FirebaseCrashlytics.instance.recordError(
                  Exception('Test error from settings'),
                  StackTrace.current,
                  reason: 'Test error for Crashlytics',
                  fatal: false,
                );
                _showSnackBar(context, 'Non-fatal error logged!');
              },
              1,
            ),

            _buildActionCard(
              context,
              Iconsax.activity,
              'Log Screen View',
              'Track this screen in Analytics',
              const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              () {
                context.read<AnalyticsBloc>().add(
                  const AnalyticsLogScreenView(screenName: 'settings_screen'),
                );
                _showSnackBar(context, 'Screen view logged!');
              },
              2,
            ),

            const SizedBox(height: 24),

            Text(
              'Firebase Services Status',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

            const SizedBox(height: 12),

            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusRow(context, 'Authentication', true),
                  _buildStatusRow(context, 'Cloud Firestore', true),
                  _buildStatusRow(context, 'Realtime Database', true),
                  _buildStatusRow(context, 'Cloud Storage', true),
                  _buildStatusRow(context, 'Cloud Messaging', true),
                  _buildStatusRow(context, 'Analytics', true),
                  _buildStatusRow(context, 'Crashlytics', true),
                  _buildStatusRow(context, 'Remote Config', true),
                  _buildStatusRow(context, 'Performance', true),
                  _buildStatusRow(context, 'ML Kit', true),
                  _buildStatusRow(context, 'App Check', true),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

            const SizedBox(height: 12),

            PremiumCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
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
                              'Firebase Showcase',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Version 1.0.0',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'A comprehensive Flutter app showcasing all Firebase free tier features with modern UI/UX and BLoC state management.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(context, 'Flutter'),
                      _buildChip(context, 'Firebase'),
                      _buildChip(context, 'BLoC'),
                      _buildChip(context, 'Material 3'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    LinearGradient gradient,
    VoidCallback onTap,
    int index,
  ) {
    return PremiumCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppTheme.lightTextSecondary,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 200 + (100 * index)),
          duration: 400.ms,
        )
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildStatusRow(BuildContext context, String service, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            active ? Iconsax.tick_circle : Iconsax.close_circle,
            size: 18,
            color: active ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(service, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: active
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              active ? 'Active' : 'Inactive',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: active ? AppTheme.successColor : AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.successColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
