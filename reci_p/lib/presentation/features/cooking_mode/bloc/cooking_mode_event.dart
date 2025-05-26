// cooking_mode_event.dart
import 'package:equatable/equatable.dart';

abstract class CookingModeEvent extends Equatable {
  const CookingModeEvent();

  @override
  List<Object> get props => [];
}

class StartCooking extends CookingModeEvent {}

class NextStep extends CookingModeEvent {}

class PreviousStep extends CookingModeEvent {}

class RepeatStep extends CookingModeEvent {}

class SetTimer extends CookingModeEvent {
  final int duration; // in seconds

  const SetTimer(this.duration);

  @override
  List<Object> get props => [duration];
}

class AdjustServings extends CookingModeEvent {
  final int servings;

  const AdjustServings(this.servings);

  @override
  List<Object> get props => [servings];
}

class StartListening extends CookingModeEvent {}

class StopListening extends CookingModeEvent {}

class TimerUpdate extends CookingModeEvent {
  final int remainingTime;

  const TimerUpdate(this.remainingTime);

  @override
  List<Object> get props => [remainingTime];
}

class StartTimer extends CookingModeEvent {}

class PauseTimer extends CookingModeEvent {}

class ResetTimer extends CookingModeEvent {}

class TimerUp extends CookingModeEvent {}
class ResetTimerUpFlag extends CookingModeEvent {}