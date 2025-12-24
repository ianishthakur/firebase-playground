import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../bloc/notifications_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Push Notifications'),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
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
                        child: const Icon(Iconsax.notification, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firebase Cloud Messaging',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Unlimited free push notifications',
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

                // FCM Token Section
                Text(
                  'Device Token',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 12),

                PremiumCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Iconsax.key,
                            size: 20,
                            color: state is NotificationsReady && state.fcmToken != null
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'FCM Token',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          if (state is NotificationsReady && state.fcmToken != null)
                            IconButton(
                              icon: const Icon(Iconsax.copy, size: 18),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: state.fcmToken!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Token copied!'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Text(
                          state is NotificationsReady && state.fcmToken != null
                              ? '${state.fcmToken!.substring(0, 50)}...'
                              : 'Token not available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use this token to send targeted notifications from Firebase Console',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.lightTextSecondary),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Topic Subscriptions
                Text(
                  'Topic Subscriptions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 12),

                _buildTopicCard(
                  context,
                  'news',
                  'News Updates',
                  'Receive latest news notifications',
                  Iconsax.document,
                  state is NotificationsReady && state.subscribedTopics.contains('news'),
                  0,
                ),
                _buildTopicCard(
                  context,
                  'promotions',
                  'Promotions',
                  'Special offers and discounts',
                  Iconsax.gift,
                  state is NotificationsReady && state.subscribedTopics.contains('promotions'),
                  1,
                ),
                _buildTopicCard(
                  context,
                  'updates',
                  'App Updates',
                  'New features and improvements',
                  Iconsax.refresh,
                  state is NotificationsReady && state.subscribedTopics.contains('updates'),
                  2,
                ),

                const SizedBox(height: 24),

                // Recent Notifications
                Text(
                  'Recent Notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                const SizedBox(height: 12),

                if (state is NotificationsReady && state.messages.isNotEmpty)
                  ...state.messages.take(5).map((message) {
                    return PremiumCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.notification, size: 18, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.notification?.title ?? 'Notification',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    if (message.notification?.body != null)
                                      Text(
                                        message.notification!.body!,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
                else
                  PremiumCard(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Iconsax.notification_bing,
                            size: 48,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send a test notification from Firebase Console',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    String topic,
    String title,
    String description,
    IconData icon,
    bool subscribed,
    int index,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subscribed ? AppTheme.successColor.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: subscribed ? AppTheme.successColor : AppTheme.lightTextSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: subscribed,
            activeColor: AppTheme.successColor,
            onChanged: (value) {
              if (value) {
                context.read<NotificationsBloc>().add(NotificationsSubscribeToTopic(topic));
              } else {
                context.read<NotificationsBloc>().add(NotificationsUnsubscribeFromTopic(topic));
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 400 + (100 * index)),
          duration: 400.ms,
        ).slideX(begin: 0.1, end: 0);
  }
}