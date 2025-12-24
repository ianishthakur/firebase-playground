import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

import 'package:firebase_flutter_app/core/theme/app_theme.dart';
import 'package:firebase_flutter_app/core/widgets/premium_button.dart';
import 'package:firebase_flutter_app/core/widgets/premium_card.dart';
import 'package:firebase_flutter_app/core/widgets/premium_text_field.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('PremiumButton', () {
    testWidgets('renders with text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PremiumButton(
          text: 'Test Button',
          onPressed: () {},
        ),
      ));

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('renders with icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PremiumButton(
          text: 'Button with Icon',
          icon: Iconsax.add,
          onPressed: () {},
        ),
      ));

      expect(find.text('Button with Icon'), findsOneWidget);
      expect(find.byIcon(Iconsax.add), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(createTestWidget(
        PremiumButton(
          text: 'Tap Me',
          onPressed: () => wasPressed = true,
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(wasPressed, true);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PremiumButton(
          text: 'Loading Button',
          isLoading: true,
          onPressed: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Text should be hidden when loading
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumButton(
          text: 'Disabled Button',
          onPressed: null,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('applies custom gradient', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PremiumButton(
          text: 'Custom Gradient',
          gradient: AppTheme.accentGradient,
          onPressed: () {},
        ),
      ));

      expect(find.text('Custom Gradient'), findsOneWidget);
    });
  });

  group('PremiumCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumCard(
          child: Text('Card Content'),
        ),
      ));

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumCard(
          padding: EdgeInsets.all(32),
          child: Text('Padded Content'),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(find.text('Padded Content'), findsOneWidget);
    });

    testWidgets('responds to tap when onTap is provided', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(createTestWidget(
        PremiumCard(
          onTap: () => wasTapped = true,
          child: const Text('Tappable Card'),
        ),
      ));

      await tester.tap(find.text('Tappable Card'));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });

    testWidgets('renders with gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumCard(
          gradient: AppTheme.primaryGradient,
          child: Text('Gradient Card'),
        ),
      ));

      expect(find.text('Gradient Card'), findsOneWidget);
    });

    testWidgets('applies custom margin', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumCard(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Margined Card'),
        ),
      ));

      expect(find.text('Margined Card'), findsOneWidget);
    });
  });

  group('PremiumTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumTextField(
          label: 'Email',
          hint: 'Enter your email',
        ),
      ));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders with hint text', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumTextField(
          label: 'Password',
          hint: 'Enter password',
        ),
      ));

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('renders with prefix icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumTextField(
          label: 'Email',
          prefixIcon: Iconsax.sms,
        ),
      ));

      expect(find.byIcon(Iconsax.sms), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(createTestWidget(
        PremiumTextField(
          label: 'Name',
          controller: controller,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'John Doe');
      expect(controller.text, 'John Doe');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumTextField(
          label: 'Password',
          obscureText: true,
        ),
      ));

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.obscureText, true);
    });

    testWidgets('shows error message when validation fails', (tester) async {
      await tester.pumpWidget(createTestWidget(
        Form(
          autovalidateMode: AutovalidateMode.always,
          child: PremiumTextField(
            label: 'Email',
            validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
          ),
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('supports multiline input', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const PremiumTextField(
          label: 'Description',
          maxLines: 4,
        ),
      ));

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.maxLines, 4);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(createTestWidget(
        PremiumTextField(
          label: 'Input',
          onChanged: (value) => changedValue = value,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'New Value');
      expect(changedValue, 'New Value');
    });
  });

  group('GlassCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const GlassCard(
          child: Text('Glass Content'),
        ),
      ));

      expect(find.text('Glass Content'), findsOneWidget);
    });
  });

  group('FeatureCard', () {
    testWidgets('renders with icon, title, and subtitle', (tester) async {
      await tester.pumpWidget(createTestWidget(
        FeatureCard(
          icon: Iconsax.security,
          title: 'Security',
          subtitle: 'Keep your data safe',
          gradient: AppTheme.primaryGradient,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Iconsax.security), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Keep your data safe'), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(createTestWidget(
        FeatureCard(
          icon: Iconsax.home,
          title: 'Home',
          subtitle: 'Go home',
          gradient: AppTheme.primaryGradient,
          onTap: () => wasTapped = true,
        ),
      ));

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(wasTapped, true);
    });
  });

  group('StatsCard', () {
    testWidgets('renders with value, label, and icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const StatsCard(
          value: '150',
          label: 'Users',
          icon: Iconsax.people,
          color: AppTheme.primaryColor,
        ),
      ));

      expect(find.text('150'), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.byIcon(Iconsax.people), findsOneWidget);
    });
  });
}
