import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_card.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header
                  PremiumCard(
                    gradient: AppTheme.primaryGradient,
                    hasBorder: false,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                          ),
                          child: user.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(user.photoUrl!, fit: BoxFit.cover),
                                )
                              : Center(
                                  child: Text(
                                    user.initials,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName ?? (user.isAnonymous ? 'Anonymous User' : 'User'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No email',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user.isAnonymous ? Iconsax.user : Iconsax.verify,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.isAnonymous
                                    ? 'Guest Account'
                                    : (user.emailVerified ? 'Verified' : 'Not Verified'),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

                  const SizedBox(height: 24),

                  // Account Info
                  Text(
                    'Account Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  _buildInfoCard(
                    context,
                    Iconsax.user,
                    'User ID',
                    user.uid.substring(0, 20) + '...',
                    0,
                  ),
                  _buildInfoCard(
                    context,
                    Iconsax.sms,
                    'Email',
                    user.email ?? 'Not provided',
                    1,
                  ),
                  _buildInfoCard(
                    context,
                    Iconsax.call,
                    'Phone',
                    user.phoneNumber ?? 'Not provided',
                    2,
                  ),
                  _buildInfoCard(
                    context,
                    Iconsax.calendar,
                    'Created',
                    user.createdAt != null
                        ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                        : 'Unknown',
                    3,
                  ),
                  _buildInfoCard(
                    context,
                    Iconsax.login,
                    'Last Sign In',
                    user.lastSignInAt != null
                        ? '${user.lastSignInAt!.day}/${user.lastSignInAt!.month}/${user.lastSignInAt!.year}'
                        : 'Unknown',
                    4,
                  ),

                  const SizedBox(height: 24),

                  // Auth Providers
                  Text(
                    'Sign-in Methods',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  PremiumCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (user.isAnonymous)
                          _buildProviderRow(context, Iconsax.user, 'Anonymous', true)
                        else if (user.providers.isEmpty)
                          _buildProviderRow(context, Iconsax.key, 'Email/Password', true)
                        else
                          ...user.providers.map((provider) {
                            IconData icon;
                            String name;
                            switch (provider) {
                              case 'google.com':
                                icon = Iconsax.google;
                                name = 'Google';
                                break;
                              case 'password':
                                icon = Iconsax.key;
                                name = 'Email/Password';
                                break;
                              case 'phone':
                                icon = Iconsax.call;
                                name = 'Phone';
                                break;
                              default:
                                icon = Iconsax.security;
                                name = provider;
                            }
                            return _buildProviderRow(context, icon, name, true);
                          }),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 32),

                  // Sign Out Button
                  PremiumButton(
                    text: 'Sign Out',
                    icon: Iconsax.logout,
                    gradient: const LinearGradient(
                      colors: [AppTheme.errorColor, Color(0xFFDC2626)],
                    ),
                    onPressed: () {
                      _showSignOutDialog(context);
                    },
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => _showDeleteAccountDialog(context),
                    child: Text(
                      'Delete Account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.errorColor,
                          ),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label, String value, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: 200 + (100 * index)),
          duration: 400.ms,
        ).slideX(begin: 0.1, end: 0);
  }

  Widget _buildProviderRow(BuildContext context, IconData icon, String name, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: enabled ? AppTheme.successColor : AppTheme.lightTextSecondary),
          const SizedBox(width: 12),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: enabled ? AppTheme.successColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              enabled ? 'Active' : 'Inactive',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: enabled ? AppTheme.successColor : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthDeleteAccountRequested());
              context.go('/login');
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}