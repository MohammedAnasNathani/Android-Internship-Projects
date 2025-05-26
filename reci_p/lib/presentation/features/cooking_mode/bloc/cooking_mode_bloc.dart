// cooking_mode_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_event.dart';
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_state.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class CookingModeBloc extends Bloc<CookingModeEvent, CookingModeState> {
  final Recipe recipe;
  int currentStep = 0;
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  Timer? _timer;
  int _remainingTime = 0;

  CookingModeBloc({required this.recipe})
      : super(CookingModeInitial(recipe: recipe, currentStep: 0)) {
    on<StartCooking>(_onStartCooking);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<RepeatStep>(_onRepeatStep);
    on<SetTimer>(_onSetTimer);
    on<AdjustServings>(_onAdjustServings);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<TimerUpdate>(_onTimerUpdate);
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResetTimer>(_onResetTimer);
    on<TimerUp>(_onTimerUp);
    on<ResetTimerUpFlag>(_onResetTimerUpFlag);
    _initTextToSpeech();
  }

  Future<void> _initTextToSpeech() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  Future<void> _onStartCooking(
      StartCooking event, Emitter<CookingModeState> emit) async {
    if (recipe.instructions.isNotEmpty) {
      _speak(
          'Starting to cook ${recipe.name}. ${recipe.instructions[currentStep]}');
      emit(CookingModeInProgress(
          recipe: recipe, currentStep: currentStep, remainingTime: 0));
    } else {
      _speak('Error: This recipe has no instructions.');
      emit(CookingModeError(
          recipe: recipe, error: 'No instructions available.'));
    }
  }

  Future<void> _onNextStep(
      NextStep event, Emitter<CookingModeState> emit) async {
    final currentState = state;
    if (currentState is CookingModeInProgress) {
      final nextStep = currentState.currentStep + 1;
      if (nextStep < recipe.instructions.length) {
        _speak(recipe.instructions[nextStep]);
        emit(CookingModeInProgress(
            recipe: recipe, currentStep: nextStep, remainingTime: 0));
      } else {
        _speak('You have completed all steps. Enjoy your meal!');
        emit(CookingModeCompleted(recipe: recipe));
      }
    }
  }

  Future<void> _onPreviousStep(
      PreviousStep event, Emitter<CookingModeState> emit) async {
    final currentState = state;
    if (currentState is CookingModeInProgress) {
      final previousStep = currentState.currentStep - 1;
      if (previousStep >= 0) {
        _speak(recipe.instructions[previousStep]);
        emit(CookingModeInProgress(
            recipe: recipe, currentStep: previousStep, remainingTime: 0));
      } else {
        _speak('You are already on the first step.');
        emit(CookingModeInProgress(recipe: recipe, currentStep: 0));
      }
    }
  }

  Future<void> _onRepeatStep(
      RepeatStep event, Emitter<CookingModeState> emit) async {
    final currentState = state;
    if (currentState is CookingModeInProgress) {
      _speak(recipe.instructions[currentState.currentStep]);
      emit(currentState);
    }
  }

  Future<void> _onSetTimer(SetTimer event, Emitter<CookingModeState> emit) async {
    _timer?.cancel();
    _remainingTime = event.duration;
    emit(CookingModeInProgress(
        recipe: recipe,
        currentStep: currentStep,
        isListening: isListening,
        remainingTime: _remainingTime,
        timerJustFinished: false
    ));
  }

  Future<void> _onAdjustServings(
      AdjustServings event, Emitter<CookingModeState> emit) async {
  }

  Future<void> _onStartListening(
      StartListening event, Emitter<CookingModeState> emit) async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) {
          print('onStatus: $status');
          if (status == "listening") {
            emit(CookingModeInProgress(
                recipe: recipe,
                currentStep: currentStep,
                isListening: true,
                remainingTime: state.remainingTime,
                timerJustFinished: false));
          } else if (status == "notListening" || status == "done") {
            emit(CookingModeInProgress(
                recipe: recipe,
                currentStep: currentStep,
                isListening: false,
                remainingTime: state.remainingTime,
                timerJustFinished: false));
          }
        },
        onError: (error) {
          print('onError: $error');
          emit(CookingModeInProgress(
              recipe: recipe,
              currentStep: currentStep,
              isListening: false,
              remainingTime: state.remainingTime,
              timerJustFinished: false));
        },
      );
      if (available) {
        isListening = true;
        emit(CookingModeInProgress(
            recipe: recipe,
            currentStep: currentStep,
            isListening: true,
            remainingTime: state.remainingTime,
            timerJustFinished: false));
        speech.listen(
          onResult: (val) {
            final command = val.recognizedWords.toLowerCase();
            print(command);
            if (command.contains('next')) {
              add(NextStep());
            } else if (command.contains('previous')) {
              add(PreviousStep());
            } else if (command.contains('repeat')) {
              add(RepeatStep());
            } else if (command.contains('set timer for')) {
              _parseTimerCommand(command);
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
        );
      } else {
        print("The user has denied the use of speech recognition.");
      }
    }
  }

  Future<void> _onStopListening(
      StopListening event, Emitter<CookingModeState> emit) async {
    if (isListening) {
      await speech.stop();
      isListening = false;
      emit(CookingModeInProgress(
          recipe: recipe,
          currentStep: currentStep,
          isListening: false,
          remainingTime: state.remainingTime,
          timerJustFinished: false));
    }
  }

  void _onTimerUpdate(TimerUpdate event, Emitter<CookingModeState> emit) {
    if (state is CookingModeInProgress) {
      emit((state as CookingModeInProgress)
          .copyWith(remainingTime: event.remainingTime, timerJustFinished: false));
    }
  }

  void _onStartTimer(StartTimer event, Emitter<CookingModeState> emit) {
    _timer?.cancel();
    const stepTime =
    Duration(seconds: 5);
    _remainingTime = stepTime.inSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        add(TimerUpdate(_remainingTime));
      } else {
        _timer?.cancel();
        add(TimerUp());
      }
    });
  }

  void _onPauseTimer(PauseTimer event, Emitter<CookingModeState> emit) {
    _timer?.cancel();
  }

  void _onResetTimer(ResetTimer event, Emitter<CookingModeState> emit) {
    _timer?.cancel();
    emit(CookingModeInProgress(
        recipe: recipe, currentStep: currentStep, remainingTime: 0, timerJustFinished: false));
  }

  void _onTimerUp(TimerUp event, Emitter<CookingModeState> emit) async {
    _speak("Timer Up!");
    print("Timer Up Event Received in Bloc");
    if (state is CookingModeInProgress) {
      emit((state as CookingModeInProgress).copyWith(timerJustFinished: true, remainingTime: 0));
    }
  }

  void _onResetTimerUpFlag(ResetTimerUpFlag event, Emitter<CookingModeState> emit) {
    print("ResetTimerUpFlag Event Received in Bloc");
    if (state is CookingModeInProgress) {
      emit((state as CookingModeInProgress).copyWith(timerJustFinished: false));
    }
  }


  void _parseTimerCommand(String command) {
    final RegExpMatch? match =
    RegExp(r'set timer for (\d+)\s+(minutes?|seconds?)').firstMatch(command);
    if (match != null) {
      final int? duration = int.tryParse(match.group(1)!);
      final String unit = match.group(2)!;

      if (duration != null) {
        int durationInSeconds =
        unit.startsWith('minute') ? duration * 60 : duration;
        add(SetTimer(durationInSeconds));
      }
    }
  }

  @override
  Future<void> close() {
    flutterTts.stop();
    speech.stop();
    _timer?.cancel();
    return super.close();
  }
}