import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/auth/data/user_model.dart';

class MockUser extends Mock implements User {}

class MockUserMetadata extends Mock implements UserMetadata {}

class MockUserInfo extends Mock implements UserInfo {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('UserModel', () {
    group('constructor', () {
      test('creates UserModel with required fields', () {
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
        );

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, isNull);
        expect(user.isAnonymous, false);
        expect(user.emailVerified, false);
      });

      test('creates UserModel with all fields', () {
        final now = DateTime.now();
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          phoneNumber: '+1234567890',
          isAnonymous: false,
          emailVerified: true,
          createdAt: now,
          lastSignInAt: now,
          providers: ['google.com', 'password'],
        );

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.phoneNumber, '+1234567890');
        expect(user.isAnonymous, false);
        expect(user.emailVerified, true);
        expect(user.createdAt, now);
        expect(user.lastSignInAt, now);
        expect(user.providers, ['google.com', 'password']);
      });
    });

    group('initials', () {
      test('returns first two letters of display name', () {
        final user = UserModel(
          uid: 'uid',
          displayName: 'John Doe',
        );
        expect(user.initials, 'JO');
      });

      test('returns first two letters of email when no display name', () {
        final user = UserModel(
          uid: 'uid',
          email: 'john@example.com',
        );
        expect(user.initials, 'JO');
      });

      test('returns ?? when no display name or email', () {
        final user = UserModel(uid: 'uid');
        expect(user.initials, '??');
      });

      test('handles single character names', () {
        final user = UserModel(
          uid: 'uid',
          displayName: 'A',
        );
        expect(user.initials, 'A');
      });
    });

    group('fromFirebaseUser', () {
      test('creates UserModel from Firebase User', () {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final mockProviderInfo = MockUserInfo();
        final creationTime = DateTime(2024, 1, 1);
        final signInTime = DateTime(2024, 1, 15);

        when(() => mockUser.uid).thenReturn('firebase-uid');
        when(() => mockUser.email).thenReturn('firebase@example.com');
        when(() => mockUser.displayName).thenReturn('Firebase User');
        when(() => mockUser.photoURL).thenReturn('https://photo.url');
        when(() => mockUser.phoneNumber).thenReturn('+1234567890');
        when(() => mockUser.isAnonymous).thenReturn(false);
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(creationTime);
        when(() => mockMetadata.lastSignInTime).thenReturn(signInTime);
        when(() => mockUser.providerData).thenReturn([mockProviderInfo]);
        when(() => mockProviderInfo.providerId).thenReturn('google.com');

        final user = UserModel.fromFirebaseUser(mockUser);

        expect(user.uid, 'firebase-uid');
        expect(user.email, 'firebase@example.com');
        expect(user.displayName, 'Firebase User');
        expect(user.photoUrl, 'https://photo.url');
        expect(user.phoneNumber, '+1234567890');
        expect(user.isAnonymous, false);
        expect(user.emailVerified, true);
        expect(user.createdAt, creationTime);
        expect(user.lastSignInAt, signInTime);
        expect(user.providers, ['google.com']);
      });

      test('handles anonymous user', () {
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();

        when(() => mockUser.uid).thenReturn('anon-uid');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.displayName).thenReturn(null);
        when(() => mockUser.photoURL).thenReturn(null);
        when(() => mockUser.phoneNumber).thenReturn(null);
        when(() => mockUser.isAnonymous).thenReturn(true);
        when(() => mockUser.emailVerified).thenReturn(false);
        when(() => mockUser.metadata).thenReturn(mockMetadata);
        when(() => mockMetadata.creationTime).thenReturn(null);
        when(() => mockMetadata.lastSignInTime).thenReturn(null);
        when(() => mockUser.providerData).thenReturn([]);

        final user = UserModel.fromFirebaseUser(mockUser);

        expect(user.uid, 'anon-uid');
        expect(user.email, isNull);
        expect(user.isAnonymous, true);
        expect(user.providers, isEmpty);
      });
    });

    group('toFirestore / fromFirestore', () {
      test('converts UserModel to Firestore map', () {
        final now = DateTime(2024, 1, 1);
        final user = UserModel(
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://photo.url',
          phoneNumber: '+1234567890',
          isAnonymous: false,
          emailVerified: true,
          createdAt: now,
          lastSignInAt: now,
          providers: ['google.com'],
        );

        final map = user.toFirestore();

        expect(map['uid'], 'test-uid');
        expect(map['email'], 'test@example.com');
        expect(map['displayName'], 'Test User');
        expect(map['photoUrl'], 'https://photo.url');
        expect(map['phoneNumber'], '+1234567890');
        expect(map['isAnonymous'], false);
        expect(map['emailVerified'], true);
        expect(map['providers'], ['google.com']);
      });

      test('fromFirestore creates UserModel from document data', () {
        final now = DateTime(2024, 1, 1);
        final data = {
          'uid': 'firestore-uid',
          'email': 'firestore@example.com',
          'displayName': 'Firestore User',
          'photoUrl': 'https://photo.url',
          'phoneNumber': '+1234567890',
          'isAnonymous': false,
          'emailVerified': true,
          'createdAt': Timestamp.fromDate(now),
          'lastSignInAt': Timestamp.fromDate(now),
          'providers': ['password'],
        };

        final user = UserModel.fromFirestore(data);

        expect(user.uid, 'firestore-uid');
        expect(user.email, 'firestore@example.com');
        expect(user.displayName, 'Firestore User');
        expect(user.photoUrl, 'https://photo.url');
        expect(user.isAnonymous, false);
        expect(user.emailVerified, true);
        expect(user.providers, ['password']);
      });

      test('fromFirestore handles missing optional fields', () {
        final data = {
          'uid': 'minimal-uid',
        };

        final user = UserModel.fromFirestore(data);

        expect(user.uid, 'minimal-uid');
        expect(user.email, isNull);
        expect(user.displayName, isNull);
        expect(user.isAnonymous, false);
        expect(user.providers, isEmpty);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = UserModel(
          uid: 'uid',
          email: 'original@example.com',
          displayName: 'Original Name',
        );

        final copy = original.copyWith(
          displayName: 'New Name',
          emailVerified: true,
        );

        expect(copy.uid, 'uid');
        expect(copy.email, 'original@example.com');
        expect(copy.displayName, 'New Name');
        expect(copy.emailVerified, true);
      });

      test('keeps original values when not overridden', () {
        final original = UserModel(
          uid: 'uid',
          email: 'test@example.com',
          displayName: 'Test User',
          isAnonymous: false,
          emailVerified: true,
        );

        final copy = original.copyWith();

        expect(copy.uid, original.uid);
        expect(copy.email, original.email);
        expect(copy.displayName, original.displayName);
        expect(copy.isAnonymous, original.isAnonymous);
        expect(copy.emailVerified, original.emailVerified);
      });
    });

    group('equality', () {
      test('two UserModels with same values are equal', () {
        final user1 = UserModel(uid: 'uid', email: 'test@example.com');
        final user2 = UserModel(uid: 'uid', email: 'test@example.com');

        expect(user1, equals(user2));
      });

      test('two UserModels with different values are not equal', () {
        final user1 = UserModel(uid: 'uid1', email: 'test1@example.com');
        final user2 = UserModel(uid: 'uid2', email: 'test2@example.com');

        expect(user1, isNot(equals(user2)));
      });
    });
  });
}
