import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

abstract class MLRepository {
  Future<RecognizedText> recognizeText(File image);
  Future<List<Face>> detectFaces(File image);
  Future<List<Barcode>> scanBarcodes(File image);
  Future<List<ImageLabel>> labelImage(File image);
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });
  Future<String> identifyLanguage(String text);
  void dispose();
}

class MLRepositoryImpl implements MLRepository {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.5),
  );
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(
    confidenceThreshold: 0.5,
  );

  final Map<String, OnDeviceTranslator> _translators = {};

  MLRepositoryImpl();

  @override
  Future<RecognizedText> recognizeText(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _textRecognizer.processImage(inputImage);
  }

  @override
  Future<List<Face>> detectFaces(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _faceDetector.processImage(inputImage);
  }

  @override
  Future<List<Barcode>> scanBarcodes(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _barcodeScanner.processImage(inputImage);
  }

  @override
  Future<List<ImageLabel>> labelImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    return await _imageLabeler.processImage(inputImage);
  }

  @override
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final key = '${sourceLanguage}_$targetLanguage';

    if (!_translators.containsKey(key)) {
      _translators[key] = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == sourceLanguage,
          orElse: () => TranslateLanguage.english,
        ),
        targetLanguage: TranslateLanguage.values.firstWhere(
          (lang) => lang.bcpCode == targetLanguage,
          orElse: () => TranslateLanguage.spanish,
        ),
      );
    }

    return await _translators[key]!.translateText(text);
  }

  @override
  Future<String> identifyLanguage(String text) async {
    return await _languageIdentifier.identifyLanguage(text);
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _faceDetector.close();
    _barcodeScanner.close();
    _imageLabeler.close();
    _languageIdentifier.close();
    for (final translator in _translators.values) {
      translator.close();
    }
  }
}