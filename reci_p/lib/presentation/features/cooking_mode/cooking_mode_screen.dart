// cooking_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reci_p/domain/entities/recipe.dart';
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_bloc.dart';
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_event.dart';
import 'package:reci_p/presentation/features/cooking_mode/bloc/cooking_mode_state.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _CookingModeScreenState createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  final TextEditingController _timerController = TextEditingController();
  Timer? _timer;
  int _remainingTime = 0;
  bool _timerRunning = false;
  bool _timerPaused = false;

  @override
  void dispose() {
    _timerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startOrPauseResumeTimer(BuildContext context, int duration) {
    if (!_timerRunning && !_timerPaused) {
      _startTimer(context, duration);
    } else if (_timerRunning) {
      _pauseTimer();
    } else if (_timerPaused) {
      _resumeTimer(context);
    } else {
      _startTimer(context, duration);
    }
  }

  void _startTimer(BuildContext context, int duration) {
    _timer?.cancel();
    setState(() {
      _remainingTime = duration;
      _timerRunning = true;
      _timerPaused = false;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        BlocProvider.of<CookingModeBloc>(context).add(TimerUpdate(_remainingTime - 1));
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        _timerRunning = false;
        _timerPaused = false;
        BlocProvider.of<CookingModeBloc>(context).add(TimerUp());
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timerRunning = false;
      _timerPaused = true;
    });
    BlocProvider.of<CookingModeBloc>(context).add(PauseTimer());
  }

  void _resumeTimer(BuildContext context) {
    _startTimer(context, _remainingTime);
  }


  void _resetTimer(BuildContext context) {
    _timer?.cancel();
    setState(() {
      _remainingTime = 0;
      _timerRunning = false;
      _timerPaused = false;
    });
    BlocProvider.of<CookingModeBloc>(context, listen: false).add(ResetTimer());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CookingModeBloc>(
      create: (context) => CookingModeBloc(recipe: widget.recipe)..add(StartCooking()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.recipe.name),
        ),
        body: BlocConsumer<CookingModeBloc, CookingModeState>(
          listener: (context, state) {
            if (state is CookingModeInProgress && state.timerJustFinished) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Timer Up!'),
                  duration: Duration(seconds: 3),
                ),
              );
              BlocProvider.of<CookingModeBloc>(context).add(ResetTimerUpFlag());
            }
          },
          builder: (context, state) {
            if (state is CookingModeInProgress) {
              return _buildInProgress(context, state);
            } else if (state is CookingModeCompleted) {
              return _buildCompleted(context);
            } else if (state is CookingModeError) {
              return Center(child: Text(state.error));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildInProgress(BuildContext context, CookingModeInProgress state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProgressBar(context, state),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${state.currentStep + 1} of ${widget.recipe.instructions.length}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.recipe.instructions[state.currentStep],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildTimerDisplay(context, state),
          _buildNavigationButtons(context, state.isListening),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, CookingModeInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LinearProgressIndicator(
        value: (state.currentStep + 1) / widget.recipe.instructions.length,
        minHeight: 10,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildTimerDisplay(BuildContext context, CookingModeInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _timerController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Set Timer (seconds, default 15s)',
              labelStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          SizedBox(height: 16),
          BlocBuilder<CookingModeBloc, CookingModeState>(
              builder: (timerContext, timerState) {
                return Text(
                  formatDuration(timerState.remainingTime),
                  style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                );
              }
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  final int duration = int.tryParse(_timerController.text) ?? 15;
                  _startOrPauseResumeTimer(context, duration);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _timerRunning
                          ? Icons.pause
                          : _timerPaused ? Icons.play_arrow : Icons.play_arrow,
                      size: 24,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _timerRunning
                          ? 'Pause'
                          : _timerPaused ? 'Resume' : 'Start',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  _resetTimer(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 24, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Reset', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildNavigationButtons(BuildContext context, bool isListening) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavigationButton(
                  context,
                  Icons.arrow_back,
                  'Prev',
                      () {
                    BlocProvider.of<CookingModeBloc>(context).add(PreviousStep());
                  },
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _buildNavigationButton(
                  context,
                  Icons.repeat,
                  'Repeat',
                      () {
                    BlocProvider.of<CookingModeBloc>(context).add(RepeatStep());
                  },
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _buildNavigationButton(
                  context,
                  Icons.arrow_forward,
                  'Next',
                      () {
                    BlocProvider.of<CookingModeBloc>(context).add(NextStep());
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Center(
              child: isListening
                  ? ElevatedButton.icon(
                onPressed: () {
                  BlocProvider.of<CookingModeBloc>(context)
                      .add(StopListening());
                },
                icon: const Icon(Icons.mic_off, color: Colors.white, size: 24),
                label: const Text('Stop Mic',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  minimumSize: Size(double.infinity, 45),
                ),
              )
                  : ElevatedButton.icon(
                onPressed: () {
                  BlocProvider.of<CookingModeBloc>(context)
                      .add(StartListening());
                },
                icon: const Icon(Icons.mic, color: Colors.white, size: 24),
                label: const Text('Start Mic',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  minimumSize: Size(double.infinity, 45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 24),
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: Size(0, 45),
      ),
    );
  }


  Widget _buildCompleted(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'You have completed all steps!',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}