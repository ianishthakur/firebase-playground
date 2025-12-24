import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import '../data/ml_repository.dart';

// Events
abstract class MLEvent extends Equatable {
  const MLEvent();

  @override
  List<Object?> get props => [];
}

class MLRecognizeText extends MLEvent {
  final File image;
  const MLRecognizeText(this.image);

  @override
  List<Object?> get props => [image];
}

class MLDetectFaces extends MLEvent {
  final File image;
  const MLDetectFaces(this.image);

  @override
  List<Object?> get props => [image];
}

class MLScanBarcode extends MLEvent {
  final File image;
  const MLScanBarcode(this.image);

  @override
  List<Object?> get props => [image];
}

class MLLabelImage extends MLEvent {
  final File image;
  const MLLabelImage(this.image);

  @override
  List<Object?> get props => [image];
}

class MLTranslateText extends MLEvent {
  final String text;
  final String sourceLanguage;
  final String targetLanguage;

  const MLTranslateText({
    required this.text,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [text, sourceLanguage, targetLanguage];
}

class MLReset extends MLEvent {}

// States
abstract class MLState extends Equatable {
  const MLState();

  @override
  List<Object?> get props => [];
}

class MLInitial extends MLState {}

class MLLoading extends MLState {}

class MLTextRecognized extends MLState {
  final RecognizedText result;
  final File image;

  const MLTextRecognized({required this.result, required this.image});

  @override
  List<Object?> get props => [result, image];
}

class MLFacesDetected extends MLState {
  final List<Face> faces;
  final File image;

  const MLFacesDetected({required this.faces, required this.image});

  @override
  List<Object?> get props => [faces, image];
}

class MLBarcodeScanned extends MLState {
  final List<Barcode> barcodes;
  final File image;

  const MLBarcodeScanned({required this.barcodes, required this.image});

  @override
  List<Object?> get props => [barcodes, image];
}

class MLImageLabeled extends MLState {
  final List<ImageLabel> labels;
  final File image;

  const MLImageLabeled({required this.labels, required this.image});

  @override
  List<Object?> get props => [labels, image];
}

class MLTextTranslated extends MLState {
  final String originalText;
  final String translatedText;

  const MLTextTranslated({
    required this.originalText,
    required this.translatedText,
  });

  @override
  List<Object?> get props => [originalText, translatedText];
}

class MLError extends MLState {
  final String message;
  const MLError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MLBloc extends Bloc<MLEvent, MLState> {
  final MLRepository _repository;

  MLBloc(this._repository) : super(MLInitial()) {
    on<MLRecognizeText>(_onRecognizeText);
    on<MLDetectFaces>(_onDetectFaces);
    on<MLScanBarcode>(_onScanBarcode);
    on<MLLabelImage>(_onLabelImage);
    on<MLTranslateText>(_onTranslateText);
    on<MLReset>(_onReset);
  }

  Future<void> _onRecognizeText(
    MLRecognizeText event,
    Emitter<MLState> emit,
  ) async {
    emit(MLLoading());
    try {
      final result = await _repository.recognizeText(event.image);
      emit(MLTextRecognized(result: result, image: event.image));
    } catch (e) {
      emit(MLError(e.toString()));
    }
  }

  Future<void> _onDetectFaces(
    MLDetectFaces event,
    Emitter<MLState> emit,
  ) async {
    emit(MLLoading());
    try {
      final faces = await _repository.detectFaces(event.image);
      emit(MLFacesDetected(faces: faces, image: event.image));
    } catch (e) {
      emit(MLError(e.toString()));
    }
  }

  Future<void> _onScanBarcode(
    MLScanBarcode event,
    Emitter<MLState> emit,
  ) async {
    emit(MLLoading());
    try {
      final barcodes = await _repository.scanBarcodes(event.image);
      emit(MLBarcodeScanned(barcodes: barcodes, image: event.image));
    } catch (e) {
      emit(MLError(e.toString()));
    }
  }

  Future<void> _onLabelImage(
    MLLabelImage event,
    Emitter<MLState> emit,
  ) async {
    emit(MLLoading());
    try {
      final labels = await _repository.labelImage(event.image);
      emit(MLImageLabeled(labels: labels, image: event.image));
    } catch (e) {
      emit(MLError(e.toString()));
    }
  }

  Future<void> _onTranslateText(
    MLTranslateText event,
    Emitter<MLState> emit,
  ) async {
    emit(MLLoading());
    try {
      final translated = await _repository.translateText(
        text: event.text,
        sourceLanguage: event.sourceLanguage,
        targetLanguage: event.targetLanguage,
      );
      emit(MLTextTranslated(
        originalText: event.text,
        translatedText: translated,
      ));
    } catch (e) {
      emit(MLError(e.toString()));
    }
  }

  void _onReset(MLReset event, Emitter<MLState> emit) {
    emit(MLInitial());
  }
}