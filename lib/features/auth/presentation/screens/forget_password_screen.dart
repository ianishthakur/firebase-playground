import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/premium_button.dart';
import '../../../../../../core/widgets/premium_text_field.dart';
import '../../../../bloc/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendResetEmail() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthForgotPasswordRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          setState(() => _emailSent = true);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _emailSent ? _buildSuccessState(context) : _buildFormState(context, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState(BuildContext context, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Iconsax.lock_1,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
          
          const SizedBox(height: 24),
          
          // Header
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.headlineLarge,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            "No worries! Enter your email and we'll send you a link to reset your password.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          
          const SizedBox(height: 40),
          
          // Email Field
          PremiumTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email address',
            prefixIcon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onSendResetEmail(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
          
          const SizedBox(height: 32),
          
          // Send Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PremiumButton(
                text: 'Send Reset Link',
                isLoading: state is AuthLoading,
                onPressed: _onSendResetEmail,
              );
            },
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Back to Login
          Center(
            child: TextButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Iconsax.arrow_left_2, size: 18),
              label: const Text('Back to Login'),
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        const SizedBox(height: 60),
        
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.accentGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.successColor.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: const Icon(
            Iconsax.tick_circle,
            color: Colors.white,
            size: 48,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0, 0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(),
        
        const SizedBox(height: 32),
        
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            "We've sent a password reset link to:\n${_emailController.text}",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms),
        
        const SizedBox(height: 48),
        
        PremiumButton(
          text: 'Back to Login',
          onPressed: () => context.go('/login'),
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideY(begin: 0.2, end: 0),
        
        const SizedBox(height: 16),
        
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            "Didn't receive the email? Try again",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryColor,
                ),
          ),
        )
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms),
      ],
    );
  }
}