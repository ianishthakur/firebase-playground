import 'package:firebase_playground/features/analytics/bloc/analytics_bloc.dart';
import 'package:firebase_playground/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Log screen view
    context.read<AnalyticsBloc>().add(
      const AnalyticsLogEvent(
        name: 'screen_view',
        parameters: {'screen_name': 'home'},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child:
                    Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? AppTheme.darkTextSecondary
                                              : AppTheme.lightTextSecondary,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      String name = 'User';
                                      if (state is AuthAuthenticated) {
                                        name =
                                            state.user.displayName ??
                                            state.user.email
                                                ?.split('@')
                                                .first ??
                                            (state.user.isAnonymous
                                                ? 'Guest'
                                                : 'User');
                                      }
                                      return Text(
                                        name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/notifications'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkCard
                                      : AppTheme.lightCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Iconsax.notification,
                                        color: isDark
                                            ? AppTheme.darkText
                                            : AppTheme.lightText,
                                        size: 22,
                                      ),
                                    ),
                                    Positioned(
                                      right: 12,
                                      top: 12,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.errorColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.push('/settings'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.darkCard
                                      : AppTheme.lightCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? AppTheme.darkBorder
                                        : AppTheme.lightBorder,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.setting_2,
                                  color: isDark
                                      ? AppTheme.darkText
                                      : AppTheme.lightText,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0),
              ),
            ),

            // Welcome Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusXl,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Firebase Showcase',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Explore all free Firebase features in one app',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Stats',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            value: '12',
                            label: 'Features',
                            icon: Iconsax.element_3,
                            color: AppTheme.primaryColor,
                            animationIndex: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            value: 'Free',
                            label: 'Tier',
                            icon: Iconsax.medal_star,
                            color: AppTheme.successColor,
                            animationIndex: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Firebase Features Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Features',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  FeatureCard(
                    icon: Iconsax.security_user,
                    title: 'Authentication',
                    subtitle: 'Email, Google, Anonymous',
                    gradient: AppTheme.primaryGradient,
                    animationIndex: 0,
                    onTap: () => context.go('/profile'),
                  ),
                  FeatureCard(
                    icon: Iconsax.document_cloud,
                    title: 'Firestore',
                    subtitle: 'NoSQL Database',
                    gradient: AppTheme.accentGradient,
                    animationIndex: 1,
                    onTap: () => context.go('/database'),
                  ),
                  FeatureCard(
                    icon: Iconsax.cloud,
                    title: 'Storage',
                    subtitle: 'File Upload & Download',
                    gradient: AppTheme.warmGradient,
                    animationIndex: 2,
                    onTap: () => context.go('/storage'),
                  ),
                  FeatureCard(
                    icon: Iconsax.notification,
                    title: 'Messaging',
                    subtitle: 'Push Notifications',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    animationIndex: 3,
                    onTap: () => context.push('/notifications'),
                  ),
                  FeatureCard(
                    icon: Iconsax.chart,
                    title: 'Analytics',
                    subtitle: 'User Behavior Tracking',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    animationIndex: 4,
                    onTap: () {
                      context.read<AnalyticsBloc>().add(
                        const AnalyticsLogEvent(
                          name: 'feature_tap',
                          parameters: {'feature': 'analytics'},
                        ),
                      );
                      _showInfoSheet(
                        context,
                        'Analytics',
                        'Analytics is automatically tracking your app usage. Events are being logged in the background.',
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Iconsax.cpu,
                    title: 'ML Kit',
                    subtitle: 'On-device AI',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    animationIndex: 5,
                    onTap: () => context.go('/ml'),
                  ),
                  FeatureCard(
                    icon: Iconsax.setting_4,
                    title: 'Remote Config',
                    subtitle: 'Dynamic Settings',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    ),
                    animationIndex: 6,
                    onTap: () {
                      _showInfoSheet(
                        context,
                        'Remote Config',
                        'Remote Config allows you to change app behavior without publishing an update.',
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Iconsax.warning_2,
                    title: 'Crashlytics',
                    subtitle: 'Crash Reporting',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    animationIndex: 7,
                    onTap: () {
                      _showInfoSheet(
                        context,
                        'Crashlytics',
                        'Crashlytics is actively monitoring your app for crashes and errors.',
                      );
                    },
                  ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  void _showInfoSheet(BuildContext context, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This feature is active and working!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
