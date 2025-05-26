// cooking_mode_state.dart
import 'package:equatable/equatable.dart';
import 'package:reci_p/domain/entities/recipe.dart';

abstract class CookingModeState extends Equatable {
  final Recipe recipe;
  final int currentStep;
  final int remainingTime;

  const CookingModeState({required this.recipe, required this.currentStep, this.remainingTime = 0});

  @override
  List<Object> get props => [recipe, currentStep, remainingTime];
}

class CookingModeInitial extends CookingModeState {
  CookingModeInitial({required Recipe recipe, required int currentStep})
      : super(recipe: recipe, currentStep: currentStep);
}

class CookingModeInProgress extends CookingModeState {
  final bool isListening;
  final bool timerJustFinished;

  CookingModeInProgress({
    required Recipe recipe,
    required int currentStep,
    this.isListening = false,
    int remainingTime = 0,
    this.timerJustFinished = false,
  }) : super(recipe: recipe, currentStep: currentStep, remainingTime: remainingTime);

  @override
  List<Object> get props => [recipe, currentStep, isListening, remainingTime, timerJustFinished]; // Include timerJustFinished in props

  CookingModeInProgress copyWith({
    Recipe? recipe,
    int? currentStep,
    bool? isListening,
    int? remainingTime,
    bool? timerJustFinished,
  }) {
    return CookingModeInProgress(
      recipe: recipe ?? this.recipe,
      currentStep: currentStep ?? this.currentStep,
      isListening: isListening ?? this.isListening,
      remainingTime: remainingTime ?? this.remainingTime,
      timerJustFinished: timerJustFinished ?? this.timerJustFinished,
    );
  }
}

class CookingModeCompleted extends CookingModeState {
  CookingModeCompleted({required Recipe recipe}) : super(recipe: recipe, currentStep: recipe.instructions.length);
}

class CookingModeError extends CookingModeState {
  final String error;

  CookingModeError({required Recipe recipe, required this.error}) : super(recipe: recipe, currentStep: 0);

  @override
  List<Object> get props => [recipe, error];
}