// calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enchanted_calculator/utils/constants.dart';
import 'package:enchanted_calculator/screens/settings_screen.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const CalculatorScreen({Key? key, required this.themeModeNotifier})
      : super(key: key);

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with WidgetsBindingObserver {
  String _output = '0';
  String _expression = '';
  bool _isOperatorClicked = false;
  String _lastButton = '';
  String _hiddenMessage = '';
  bool _isSecretRevealed = false;
  String? _currentButton;
  final ScrollController _scrollController = ScrollController();
  late TextStyle _displayTextStyle;
  late TextStyle _expressionTextStyle;
  late SharedPreferences prefs;
  String _memoryValue = "0";
  List<String> _memoryHistory = [];
  List<String> _history = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPrefs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _displayTextStyle = TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.12,
        color: Colors.white);
    _expressionTextStyle = TextStyle(
        fontSize: MediaQuery.of(context).size.width * 0.06,
        color: Colors.white70);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _buttonPressed(String buttonText) async {
    final prefs = await SharedPreferences.getInstance();
    final hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;

    setState(() {
      _currentButton = buttonText;
      if (buttonText == "=" || buttonText == "AC" || buttonText == "DEL") {
        if (hapticsEnabled) {
          HapticFeedback.heavyImpact();
        }
      } else {
        if (hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _currentButton = null;
      });
    });

    setState(() {
      if (buttonText == 'AC') {
        _resetCalculator();
      } else if (buttonText == 'DEL') {
        _deleteLast();
      } else if (buttonText == '=') {
        _calculateResult();
      } else if (buttonText == "M+") {
        _addToMemory();
      } else if (buttonText == "M-") {
        _subtractFromMemory();
      } else if (buttonText == "MR") {
        _recallMemory();
      } else if (buttonText == "MC") {
        _clearMemory();
      } else {
        _appendToExpression(buttonText);
      }
      _lastButton = buttonText;
      _scrollToEnd();
    });
  }

  void _clearMemory() {
    setState(() {
      _memoryValue = "0";
      _memoryHistory.clear();
    });
  }

  void _addToMemory() {
    if (_output != "0" && !(_output == "Error")) {
      setState(() {
        _memoryHistory.add(_output);
        _memoryValue = _output;
      });
    }
  }

  void _subtractFromMemory() {
    if (_output != "0" && !(_output == "Error")) {
      double val = double.parse(_memoryValue) - double.parse(_output);
      setState(() {
        _memoryValue = val.toString();
        _memoryHistory.add(_memoryValue);
      });
    }
  }

  void _recallMemory() {
    if (_memoryHistory.isNotEmpty) {
      setState(() {
        _expression = _memoryHistory.last;
        _output = _memoryHistory.last;
      });
    }
  }

  void _resetCalculator() {
    setState(() {
      _output = '0';
      _expression = '';
      _isOperatorClicked = false;
      _lastButton = 'AC';
      _hiddenMessage = '';
      _isSecretRevealed = false;
    });
  }

  void _deleteLast() {
    if (_expression.isNotEmpty) {
      setState(() {
        _expression = _expression.substring(0, _expression.length - 1);
        if (_expression.isEmpty) {
          _output = '0';
        } else {
          _output = _expression.split(RegExp(r'[+\-x/%]')).last;
        }
      });
    } else {
      setState(() {
        _output = '0';
      });
    }
  }


  void _calculateResult() {
    if (_expression.isEmpty) return;

    String expressionForEval = _expression.replaceAll('x', '*');
    if (Constants.operators.contains(expressionForEval.substring(expressionForEval.length - 1))) {
      expressionForEval = expressionForEval.substring(0, expressionForEval.length - 1);
    }
    try {
      Parser p = Parser();
      Expression exp = p.parse(expressionForEval);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      final outputString =
      eval == eval.floor() ? eval.floor().toString() : eval.toString();

      setState(() {
        _output = outputString;
        _history.insert(0, '$_expression = $_output');
        _expression = _expression;
        _isOperatorClicked = false;
      });
    } catch (e) {
      setState(() {
        _output = "Error";
      });
    }

    if (_isSecretCodeEntered()) {
      _showSecretMessage();
    }
  }

  bool _isSecretCodeEntered() {
    final secretCodes = {
      "915": "Team915 is indeed awesome! ✨",
      "919191": "You've unlocked the ancient wisdom!",
      "111111": "Ah, you're a pro at this!",
      "12345": "Wow, you're fast!",
      "911": "Please select this student! lol",
      "7890": "You have activated the secret",
      "54321": "You're on your way to becoming a legend!",
      "01234": "Keep going, you can do it!",
      "121212": "Secrets revealed!",
      "111111": "Master of digits, you are!",
      "12345": "Speedy fingers, secret finder!",
      "7890": "The final enchantment is cast!",
      "54321": "Legendary coder in the making!",
      "01234": "Persistence pays off, keep calculating!",
      "99999": "Internship secured? 😉",
      "13": "You're a secret code wizard!",
      "420": "You speak the language of numbers!",
      "69": "Heh, I see what you did there 🙂",
    };

    if (_output.isEmpty) return false;

    for (var entry in secretCodes.entries) {
      if (_output.contains(entry.key)) {
        _hiddenMessage = entry.value;
        return true;
      }
    }

    return false;
  }

  void _showSecretMessage() {
    setState(() {
      _isSecretRevealed = true;
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _appendToExpression(String text) {
    setState(() {
      if (text == '.') {
        if (_isOperatorClicked || _output == '0' || _lastButton == '=') {
          _expression += (_expression.isEmpty || _lastButton == '=') ? '0.' : '.';
          _isOperatorClicked = false;
        } else {
          int lastOperatorIndex = -1;
          for (int i = _expression.length - 1; i >= 0; i--) {
            if (Constants.operators.contains(_expression[i])) {
              lastOperatorIndex = i;
              break;
            }
          }
          String lastNumber = _expression.substring(lastOperatorIndex + 1);
          if (!lastNumber.contains('.')) {
            _expression += text;
          }
        }
        _output = _expression.split(RegExp(r'[+\-x/%]')).last;
      } else if (Constants.operators.contains(text)) {
        if (_expression.isEmpty && _output != '0' && _lastButton == '=') {
          _expression = _output + text;
        } else if (_expression.isNotEmpty) {
          if (Constants.operators
              .contains(_expression[_expression.length - 1])) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          _expression += text;
          _isOperatorClicked = true;
        } else if (_expression.isEmpty && _output == '0') {
          return;
        }
        _isOperatorClicked = true;

      } else {
        if (_output == '0' && text != '.') {
          _expression = _expression.isEmpty ? text : _expression + text;
          _output = text;
        } else if (_lastButton == '='){
          _expression = text;
          _output = text;
        }
        else {
          _expression += text;
          _output = _expression.split(RegExp(r'[+\-x/%]')).last;
        }
        _isOperatorClicked = false;
      }
    });
  }


  Widget _buildButton(String text,
      {Color? backgroundColor, Color? textColor, double fontSize = 32}) {
    double currentFontSize = MediaQuery.of(context).size.width * 0.06;
    Widget buttonContent;
    if (text == 'DEL') {
      buttonContent = Text(
        '⌫',
        style: TextStyle(
          color: textColor ?? Theme.of(context).scaffoldBackgroundColor,
          fontSize: currentFontSize,
        ),
      );
    } else {
      buttonContent = Text(
        text,
        style: TextStyle(
          color: textColor ?? Theme.of(context).scaffoldBackgroundColor,
          fontSize: currentFontSize,
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedScale(
          scale: _currentButton == text ? 0.95 : 1,
          duration: const Duration(milliseconds: 100),
          child: SizedBox(
            height: MediaQuery.of(context).size.width * 0.18,
            child: ElevatedButton(
              onPressed: () => _buttonPressed(text),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                backgroundColor ?? Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary)),
                padding: const EdgeInsets.all(20.0),
                elevation: 5,
                minimumSize: Size.zero,
              ),
              child: Center(child: buttonContent),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: const DrawerHeader(
                  child: Center(
                      child: Text(
                        'History',
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ))),
            ),
            Expanded(
              child: ListView.builder(
                reverse: false,
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final exp = _history[index];
                  return ListTile(
                    title: SelectableText(
                      exp,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: exp));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Copied To Clipboard!")));
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                      Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  onPressed: () {
                    setState(() {
                      _history.clear();
                    });
                  },
                  child: const Text(
                    "Clear History",
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  )),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Ancient Calculator'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SettingsScreen(
                            themeModeNotifier: widget.themeModeNotifier),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              icon: const Icon(Icons.settings))
        ],
        leading: IconButton(
          icon: Icon(
            Icons.history,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _isSecretRevealed
                  ? Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text("Secret Message : $_hiddenMessage",
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic)))
                  : const SizedBox(height: 20),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.0)),
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: SelectableText(
                            _expression,
                            key: ValueKey(_expression),
                            style: _expressionTextStyle,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: SelectableText(
                            _output,
                            key: ValueKey(_output),
                            style: _displayTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildButton('AC',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
                _buildButton('DEL',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
                _buildButton('%',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
                _buildButton('/',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
                _buildButton('x',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
                _buildButton('-',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
                _buildButton('+',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildButton('0'),
                _buildButton('.'),
                _buildButton('=',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).scaffoldBackgroundColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}