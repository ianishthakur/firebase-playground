import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_flutter_app/features/ml/bloc/ml_bloc.dart';
import 'package:firebase_flutter_app/features/ml/data/ml_repository.dart';

// Mocks
class MockMLRepository extends Mock implements MLRepository {}

class MockFile extends Mock implements File {}

class MockRecognizedText extends Mock implements RecognizedText {}

class MockFace extends Mock implements Face {}

class MockBarcode extends Mock implements Barcode {}

class MockImageLabel extends Mock implements ImageLabel {}

void main() {
  late MLBloc mlBloc;
  late MockMLRepository mockMLRepository;
  late MockFile mockFile;

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockMLRepository = MockMLRepository();
    mockFile = MockFile();
    mlBloc = MLBloc(mockMLRepository);

    when(() => mockFile.path).thenReturn('/tmp/test_image.jpg');
  });

  tearDown(() {
    mlBloc.close();
  });

  group('MLBloc', () {
    test('initial state is MLInitial', () {
      expect(mlBloc.state, isA<MLInitial>());
    });

    group('MLRecognizeText', () {
      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLTextRecognized] when text recognition succeeds',
        build: () {
          final mockResult = MockRecognizedText();
          when(() => mockResult.text).thenReturn('Recognized text content');
          when(() => mockResult.blocks).thenReturn([]);
          when(() => mockMLRepository.recognizeText(any()))
              .thenAnswer((_) async => mockResult);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLRecognizeText(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLTextRecognized>(),
        ],
        verify: (_) {
          verify(() => mockMLRepository.recognizeText(any())).called(1);
        },
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLError] when text recognition fails',
        build: () {
          when(() => mockMLRepository.recognizeText(any()))
              .thenThrow(Exception('Text recognition failed'));
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLRecognizeText(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLError>(),
        ],
      );
    });

    group('MLDetectFaces', () {
      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLFacesDetected] when face detection succeeds',
        build: () {
          final mockFace = MockFace();
          when(() => mockFace.smilingProbability).thenReturn(0.8);
          when(() => mockFace.leftEyeOpenProbability).thenReturn(0.9);
          when(() => mockFace.rightEyeOpenProbability).thenReturn(0.9);
          when(() => mockMLRepository.detectFaces(any()))
              .thenAnswer((_) async => [mockFace]);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLDetectFaces(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLFacesDetected>().having(
            (state) => state.faces.length,
            'faces count',
            1,
          ),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLFacesDetected] with empty list when no faces found',
        build: () {
          when(() => mockMLRepository.detectFaces(any()))
              .thenAnswer((_) async => []);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLDetectFaces(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLFacesDetected>().having(
            (state) => state.faces.isEmpty,
            'no faces',
            true,
          ),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLError] when face detection fails',
        build: () {
          when(() => mockMLRepository.detectFaces(any()))
              .thenThrow(Exception('Face detection failed'));
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLDetectFaces(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLError>(),
        ],
      );
    });

    group('MLScanBarcode', () {
      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLBarcodeScanned] when barcode scanning succeeds',
        build: () {
          final mockBarcode = MockBarcode();
          when(() => mockBarcode.rawValue).thenReturn('https://example.com');
          when(() => mockBarcode.format).thenReturn(BarcodeFormat.qrCode);
          when(() => mockBarcode.type).thenReturn(BarcodeType.url);
          when(() => mockMLRepository.scanBarcodes(any()))
              .thenAnswer((_) async => [mockBarcode]);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLScanBarcode(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLBarcodeScanned>().having(
            (state) => state.barcodes.length,
            'barcodes count',
            1,
          ),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLBarcodeScanned] with empty list when no barcodes found',
        build: () {
          when(() => mockMLRepository.scanBarcodes(any()))
              .thenAnswer((_) async => []);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLScanBarcode(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLBarcodeScanned>().having(
            (state) => state.barcodes.isEmpty,
            'no barcodes',
            true,
          ),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLError] when barcode scanning fails',
        build: () {
          when(() => mockMLRepository.scanBarcodes(any()))
              .thenThrow(Exception('Barcode scanning failed'));
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLScanBarcode(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLError>(),
        ],
      );
    });

    group('MLLabelImage', () {
      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLImageLabeled] when image labeling succeeds',
        build: () {
          final mockLabel = MockImageLabel();
          when(() => mockLabel.label).thenReturn('Cat');
          when(() => mockLabel.confidence).thenReturn(0.95);
          when(() => mockMLRepository.labelImage(any()))
              .thenAnswer((_) async => [mockLabel]);
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLLabelImage(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLImageLabeled>().having(
            (state) => state.labels.length,
            'labels count',
            1,
          ),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLError] when image labeling fails',
        build: () {
          when(() => mockMLRepository.labelImage(any()))
              .thenThrow(Exception('Image labeling failed'));
          return mlBloc;
        },
        act: (bloc) => bloc.add(MLLabelImage(mockFile)),
        expect: () => [
          isA<MLLoading>(),
          isA<MLError>(),
        ],
      );
    });

    group('MLTranslateText', () {
      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLTextTranslated] when translation succeeds',
        build: () {
          when(() => mockMLRepository.translateText(
                text: 'Hello',
                sourceLanguage: 'en',
                targetLanguage: 'es',
              )).thenAnswer((_) async => 'Hola');
          return mlBloc;
        },
        act: (bloc) => bloc.add(const MLTranslateText(
          text: 'Hello',
          sourceLanguage: 'en',
          targetLanguage: 'es',
        )),
        expect: () => [
          isA<MLLoading>(),
          isA<MLTextTranslated>()
              .having((state) => state.originalText, 'original', 'Hello')
              .having((state) => state.translatedText, 'translated', 'Hola'),
        ],
      );

      blocTest<MLBloc, MLState>(
        'emits [MLLoading, MLError] when translation fails',
        build: () {
          when(() => mockMLRepository.translateText(
                text: any(named: 'text'),
                sourceLanguage: any(named: 'sourceLanguage'),
                targetLanguage: any(named: 'targetLanguage'),
              )).thenThrow(Exception('Translation model not downloaded'));
          return mlBloc;
        },
        act: (bloc) => bloc.add(const MLTranslateText(
          text: 'Hello',
          sourceLanguage: 'en',
          targetLanguage: 'es',
        )),
        expect: () => [
          isA<MLLoading>(),
          isA<MLError>(),
        ],
      );
    });

    group('MLReset', () {
      blocTest<MLBloc, MLState>(
        'emits [MLInitial] when reset is called',
        seed: () {
          final mockResult = MockRecognizedText();
          when(() => mockResult.text).thenReturn('Some text');
          when(() => mockResult.blocks).thenReturn([]);
          return MLTextRecognized(result: mockResult, image: mockFile);
        },
        build: () => mlBloc,
        act: (bloc) => bloc.add(MLReset()),
        expect: () => [
          isA<MLInitial>(),
        ],
      );
    });
  });
}
