import 'package:equatable/equatable.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanImageFromCamera extends ScanEvent {}

class ScanImageFromGallery extends ScanEvent {}

class ClearScanResults extends ScanEvent {}

class AppStarted extends ScanEvent {}