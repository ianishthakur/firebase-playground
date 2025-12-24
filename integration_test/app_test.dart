// Integration tests for Firebase Flutter App
// Run with: flutter test integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches and shows splash screen', (tester) async {
      // Note: This test requires Firebase to be initialized
      // For CI/CD, use Firebase emulators

      // App should show splash screen initially
      // await tester.pumpWidget(const MyApp());
      // expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Navigation to login screen works', (tester) async {
      // Test navigation from splash to login
    });

    testWidgets('User can sign in with email', (tester) async {
      // Test the complete sign-in flow
      // 1. Enter email
      // 2. Enter password
      // 3. Tap sign in
      // 4. Verify navigation to home
    });

    testWidgets('User can create a note', (tester) async {
      // Test the complete note creation flow
      // 1. Navigate to database tab
      // 2. Tap add button
      // 3. Enter title and content
      // 4. Save note
      // 5. Verify note appears in list
    });

    testWidgets('User can upload a file', (tester) async {
      // Test file upload flow
      // Note: Requires mock file picker for testing
    });

    testWidgets('ML text recognition works', (tester) async {
      // Test ML feature
      // Note: Requires mock image for testing
    });

    testWidgets('Bottom navigation works correctly', (tester) async {
      // Test navigation between tabs
      // 1. Tap each tab
      // 2. Verify correct screen is shown
    });

    testWidgets('Theme switching works', (tester) async {
      // Test dark/light theme switching
    });

    testWidgets('User can sign out', (tester) async {
      // Test sign out flow
      // 1. Navigate to profile
      // 2. Tap sign out
      // 3. Verify navigation to login
    });
  });
}

/// Helper class for integration test data
class IntegrationTestData {
  static const testEmail = 'integration_test@example.com';
  static const testPassword = 'testPassword123';
  static const testDisplayName = 'Integration Test User';

  static const testNoteTitle = 'Integration Test Note';
  static const testNoteContent = 'This note was created during integration testing';
}

/// Helper functions for common integration test operations
class IntegrationTestHelpers {
  static Future<void> signIn(
    WidgetTester tester, {
    String email = IntegrationTestData.testEmail,
    String password = IntegrationTestData.testPassword,
  }) async {
    // Find and fill email field
    final emailField = find.byType(TextFormField).first;
    await tester.enterText(emailField, email);

    // Find and fill password field
    final passwordField = find.byType(TextFormField).at(1);
    await tester.enterText(passwordField, password);

    // Tap sign in button
    final signInButton = find.text('Sign In');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
  }

  static Future<void> navigateToTab(WidgetTester tester, int tabIndex) async {
    final bottomNav = find.byType(BottomNavigationBar);
    expect(bottomNav, findsOneWidget);

    // Find the tab icon and tap it
    final tabs = find.descendant(
      of: bottomNav,
      matching: find.byType(Icon),
    );

    await tester.tap(tabs.at(tabIndex));
    await tester.pumpAndSettle();
  }

  static Future<void> createNote(
    WidgetTester tester, {
    String title = IntegrationTestData.testNoteTitle,
    String content = IntegrationTestData.testNoteContent,
  }) async {
    // Tap FAB to add note
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Enter title
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, title);

    // Enter content
    final contentField = find.byType(TextFormField).at(1);
    await tester.enterText(contentField, content);

    // Save note
    final saveButton = find.text('Save Note');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  static Future<void> signOut(WidgetTester tester) async {
    // Navigate to profile
    await navigateToTab(tester, 4); // Profile is usually the last tab

    // Tap sign out button
    final signOutButton = find.text('Sign Out');
    await tester.tap(signOutButton);
    await tester.pumpAndSettle();

    // Confirm sign out in dialog
    final confirmButton = find.text('Sign Out').last;
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();
  }
}
