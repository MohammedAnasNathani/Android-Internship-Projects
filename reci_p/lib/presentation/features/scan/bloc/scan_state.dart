import 'package:equatable/equatable.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final String imagePath;

  const ScanSuccess({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ScanFailure extends ScanState {
  final String error;

  const ScanFailure({required this.error});

  @override
  List<Object?> get props => [error];
}