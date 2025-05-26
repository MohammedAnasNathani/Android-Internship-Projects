import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/birthday_label.dart';
import '../widgets/gif_display.dart';
import '../widgets/base64_button.dart';
import '../utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/birthday.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const BirthdayApp());
}

class BirthdayApp extends StatelessWidget {
  const BirthdayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday Magic',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const BirthdayScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({super.key});

  @override
  _BirthdayScreenState createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen>
    with SingleTickerProviderStateMixin {
  late String _convertedDate = '';
  bool _isBase64 = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ConfettiController _confettiController;
  late String _selectedTheme = 'light';
  late Color _backgroundColor;
  late Color _textColor;
  late String _themeColor = '0xFFF4ACB7';
  late String _timeRemaining = '';
  late List<Birthday> _birthdays = [];
  late int _selectedBirthdayIndex = 0;
  int _selectedCakeIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentMusicAsset = "";
  late List<String> _cakeAssets;
  bool _isLoading = true;

  @override
  void initState() {
    _cakeAssets = [
      'assets/images/birthday_cake.gif',
      'assets/images/birthday_cake1.gif',
      'assets/images/birthday_cake2.gif',
    ];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
    _loadData();
    _updateTheme();
    super.initState();
    Future.delayed(Duration.zero, () {
      _startTimer();
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('selected_theme') ?? 'light';
      _themeColor = prefs.getString('theme_color') ?? '0xFFF4ACB7';
      _birthdays = (prefs.getStringList('birthdays') ?? [])
          .map((e) => Birthday.fromJson(jsonDecode(e)))
          .toList();
      _selectedBirthdayIndex = prefs.getInt('selected_birthday_index') ?? 0;
      if (_birthdays.isNotEmpty) {
        _currentMusicAsset = _birthdays[_selectedBirthdayIndex].musicAsset;
        _setAudioSource();
      }
      if (_cakeAssets.isNotEmpty) {
        final savedIndex = prefs.getInt('selected_cake_index') ?? 0;
        _selectedCakeIndex = savedIndex >= 0 && savedIndex < _cakeAssets.length
            ? savedIndex
            : 0;
      }

      _isLoading = false;
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateTimer();
        _startTimer();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> birthdayStrings =
    _birthdays.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setString('selected_theme', _selectedTheme);
    await prefs.setString('theme_color', _themeColor);
    await prefs.setStringList('birthdays', birthdayStrings);
    await prefs.setInt('selected_birthday_index', _selectedBirthdayIndex);
    await prefs.setInt('selected_cake_index', _selectedCakeIndex);
  }

  void _updateTheme() {
    setState(() {
      if (_selectedTheme == 'dark') {
        _backgroundColor = Colors.black87;
        _textColor = Colors.white;
      } else {
        _backgroundColor = Color(int.parse(_themeColor));
        _textColor = Colors.black;
      }
    });
  }

  void _updateTimer() {
    if (_birthdays.isNotEmpty) {
      try {
        final dateFormat = intl.DateFormat('dd-MM-yyyy');
        DateTime birth =
        dateFormat.parse(_birthdays[_selectedBirthdayIndex].date);
        DateTime now = DateTime.now();
        DateTime nextBirthday = DateTime(now.year, birth.month, birth.day);
        if (now.isAfter(nextBirthday)) {
          nextBirthday = DateTime(now.year + 1, birth.month, birth.day);
        }
        Duration remaining = nextBirthday.difference(now);
        if (remaining.isNegative) {
          setState(() {
            int age = now.year - birth.year;
            if (now.month < birth.month ||
                (now.month == birth.month && now.day < birth.day)) {
              age--;
            }
            _timeRemaining = "Birthday Passed! (Age: $age)";
          });
          return;
        }
        int age = now.year - birth.year;
        if (now.month < birth.month ||
            (now.month == birth.month && now.day < birth.day)) {
          age--;
        }
        int days = remaining.inDays;
        int hours = remaining.inHours % 24;
        int minutes = remaining.inMinutes % 60;
        int seconds = remaining.inSeconds % 60;
        setState(() {
          _timeRemaining =
          "$days days, $hours hours, $minutes minutes, $seconds seconds Remaining (Age: $age)";
        });
      } catch (e) {
        setState(() {
          _timeRemaining = "Invalid Date!";
        });
      }
    } else {
      setState(() {
        _timeRemaining = "";
      });
    }
  }

  Future<void> _showAddBirthdayDialog() async {
    String newDate = _birthdays.isNotEmpty
        ? _birthdays[_selectedBirthdayIndex].date
        : '01-01-2000';
    String newMessage = '';

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Birthday'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Date:'),
                        TextFormField(
                            initialValue: _birthdays.isNotEmpty
                                ? _birthdays[_selectedBirthdayIndex].date
                                : '01-01-2000',
                            keyboardType: TextInputType.datetime,
                            onChanged: (text) {
                              try {
                                intl.DateFormat('dd-MM-yyyy').parse(text);
                                newDate = text;
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Invalid date format. Please use DD-MM-YYYY')));
                              }
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Message:'),
                        TextFormField(
                            initialValue: _birthdays.isNotEmpty
                                ? _birthdays[_selectedBirthdayIndex].message
                                : '',
                            onChanged: (text) {
                              newMessage = text;
                            })
                      ]));
                }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    Map<String, dynamic> newBirthday = {
                      'date': newDate,
                      'cake_asset': _birthdays.isNotEmpty
                          ? _cakeAssets[_selectedCakeIndex]
                          : 'assets/images/birthday_cake.gif',
                      'message': newMessage,
                      'music_asset': _birthdays.isNotEmpty
                          ? _birthdays[_selectedBirthdayIndex].musicAsset
                          : 'assets/audio/birthday.mp3'
                    };
                    setState(() {
                      _birthdays = [
                        ..._birthdays,
                        Birthday.fromJson(newBirthday)
                      ];
                      _selectedBirthdayIndex = _birthdays.length - 1;
                      if (_birthdays.isNotEmpty) {
                        _currentMusicAsset =
                            _birthdays[_selectedBirthdayIndex].musicAsset;
                        _setAudioSource();
                      }
                    });
                    await _saveData();
                    await _loadData();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'))
            ],
          );
        });
  }

  Future<void> _showSelectBirthdayDialog() async {
    if (_birthdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a birthday first!')),
      );
      return;
    }
    int? selectedIndex;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: const Text('Select Birthday'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _birthdays.length,
                    itemBuilder: (context, index) {
                      final birthday = _birthdays[index];
                      return ListTile(
                        title: Text('${birthday.date} - ${birthday.message}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  _editBirthdayDialog(index);
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _birthdays.removeAt(index);
                                    if (_birthdays.isNotEmpty) {
                                      _selectedBirthdayIndex = 0;
                                      _currentMusicAsset =
                                          _birthdays[_selectedBirthdayIndex]
                                              .musicAsset;
                                      _setAudioSource();
                                    }
                                  });
                                  _saveData();
                                  _loadData();
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        selected: selectedIndex == index,
                        selectedColor: Theme.of(context).primaryColor,
                        splashColor: Colors.grey[200],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        if (selectedIndex != null) {
                          setState(() {
                            _selectedBirthdayIndex = selectedIndex!;
                            if (_birthdays.isNotEmpty) {
                              _currentMusicAsset =
                                  _birthdays[_selectedBirthdayIndex].musicAsset;
                              _setAudioSource();
                            }
                          });
                          _saveData();
                          _loadData();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Select'))
                ]);
          },
        );
      },
    );
  }

  Future<void> _editBirthdayDialog(int index) async {
    String newDate = _birthdays[index].date;
    String newMessage = _birthdays[index].message;

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit Birthday'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('Date:'),
                        TextFormField(
                            initialValue: _birthdays[index].date,
                            keyboardType: TextInputType.datetime,
                            onChanged: (text) {
                              try {
                                intl.DateFormat('dd-MM-yyyy').parse(text);
                                newDate = text;
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Invalid date format. Please use DD-MM-YYYY')));
                              }
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Message:'),
                        TextFormField(
                            initialValue: _birthdays[index].message,
                            onChanged: (text) {
                              newMessage = text;
                            })
                      ]));
                }),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      _birthdays[index].date = newDate;
                      _birthdays[index].message = newMessage;
                    });
                    await _saveData();
                    await _loadData();
                    Navigator.pop(context);
                  },
                  child: const Text('Save'))
            ],
          );
        });
  }

  Future<void> _showChangeCakeDialog() async {
    int? selectedIndex = _cakeAssets.indexOf(_birthdays.isNotEmpty
        ? _birthdays[_selectedBirthdayIndex].cakeAsset
        : 'assets/images/birthday_cake.gif');
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: const Text('Select Cake Image'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _cakeAssets.length,
                    itemBuilder: (context, index) {
                      final image = _cakeAssets[index];
                      return RadioListTile<int>(
                        title: Image.asset(
                          image,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) =>
                          const Text(
                            "Unable to load the image",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        value: index,
                        groupValue: selectedIndex,
                        onChanged: (int? value) {
                          setState(() {
                            selectedIndex = value!;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        if (selectedIndex != null) {
                          setState(() {
                            _selectedCakeIndex = selectedIndex!;
                          });
                          _updateBirthdayData(
                              cakeAsset: _cakeAssets[_selectedCakeIndex]);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Select'))
                ]);
          },
        );
      },
    );
  }

  Future<void> _pickMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path;
      _updateBirthdayData(musicAsset: path);
    }
  }

  Future<void> _showChangeMusicDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
                title: const Text('Select Music'),
                content: SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                            title: const Text('Music 1'),
                            onTap: () {
                              _updateBirthdayData(
                                  musicAsset: "assets/audio/birthday.mp3");
                              Navigator.pop(context);
                            }),
                        ListTile(
                            title: const Text('Music 2'),
                            onTap: () {
                              _updateBirthdayData(
                                  musicAsset: "assets/audio/music1.mp3");
                              Navigator.pop(context);
                            }),
                        ListTile(
                            title: const Text('Music 3'),
                            onTap: () {
                              _updateBirthdayData(
                                  musicAsset: "assets/audio/music2.mp3");
                              Navigator.pop(context);
                            }),
                      ],
                    )),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        _pickMusic();
                        Navigator.pop(context);
                      },
                      child: const Text('Select Local'))
                ]);
          },
        );
      },
    );
  }

  Future<void> _showChangeThemeDialog() async {
    String? selectedTheme = _selectedTheme;
    Color selectedColor;
    try {
      selectedColor = Color(int.parse(_themeColor));
    } catch (e) {
      selectedColor = Colors.white;
    }
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Theme'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  RadioListTile<String>(
                      value: 'light',
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value!;
                        });
                      },
                      title: const Text('Light')),
                  RadioListTile<String>(
                      value: 'dark',
                      groupValue: selectedTheme,
                      onChanged: (value) {
                        setState(() {
                          selectedTheme = value!;
                        });
                      },
                      title: const Text('Dark')),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Theme Color:'),
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (color) {
                      selectedColor = color;
                    },
                    pickerAreaHeightPercent: 0.5,
                  ),
                ]),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedTheme = selectedTheme!;
                        _themeColor = selectedColor.value.toString();
                      });
                      _updateTheme();
                      _saveData();
                      Navigator.pop(context);
                    },
                    child: const Text('Select'))
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateBirthdayData(
      {String? cakeAsset, String? musicAsset}) async {
    if (_birthdays.isEmpty) return;
    if (musicAsset != null && musicAsset != _currentMusicAsset) {
      setState(() {
        _birthdays[_selectedBirthdayIndex].musicAsset = musicAsset;
        _currentMusicAsset = musicAsset;
        _setAudioSource();
        _stopMusic();
      });
      Future.delayed(Duration(milliseconds: 50), () {
        _playMusic();
      });
    } else {
      setState(() {
        if (cakeAsset != null) {
          _birthdays[_selectedBirthdayIndex].cakeAsset = cakeAsset;
        }
      });
    }
    await _saveData();
    await _loadData();
  }

  void _togglePlayMusic() {
    if (_isPlaying) {
      _pauseMusic();
    } else {
      _playMusic();
    }
  }

  Future<void> _setAudioSource() async {
    try {
      if (_currentMusicAsset.startsWith('assets/')) {
        await _audioPlayer.setSourceAsset(_currentMusicAsset);
      } else {
        await _audioPlayer.setSource(DeviceFileSource(_currentMusicAsset));
      }
    } catch (e) {
      debugPrint('Error setting audio source: $e');
    }
  }

  Future<void> _playMusic() async {
    try {
      if (_currentMusicAsset.isEmpty) {
        return;
      }
      if (_currentMusicAsset.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(_currentMusicAsset.split('/').last));
      } else {
        await _audioPlayer.play(DeviceFileSource(_currentMusicAsset));
      }
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> _pauseMusic() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error stop music: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleDate() {
    if (_birthdays.isEmpty) return;
    setState(() {
      if (_isBase64) {
        try {
          _convertedDate = utf8.decode(base64.decode(_convertedDate));
        } on FormatException catch (e) {
          _convertedDate = 'Invalid base64 string';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Base64 String')),
          );
        }
      } else {
        final dateFormat = intl.DateFormat('dd-MM-yyyy');
        _convertedDate = base64.encode(utf8.encode(
            dateFormat.format(dateFormat.parse(_birthdays[_selectedBirthdayIndex].date))));
        _playMusic();
        _confettiController.play();
      }
      _isBase64 = !_isBase64;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birthday Magic'), actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showAddBirthdayDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: () => _showSelectBirthdayDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.color_lens),
          onPressed: () => _showChangeThemeDialog(),
        ),
      ]),
      backgroundColor: _backgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _showChangeCakeDialog();
                    },
                    child: _cakeAssets.isNotEmpty &&
                        _selectedCakeIndex < _cakeAssets.length
                        ? GifDisplay(
                      asset: _birthdays.isNotEmpty &&
                          _selectedCakeIndex < _cakeAssets.length
                          ? _cakeAssets[_selectedCakeIndex]
                          : 'assets/images/birthday_cake.gif',
                    )
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      _showChangeMusicDialog();
                    },
                    child: Text(
                      'Tap Here To Change Music',
                      style: TextStyle(fontSize: 16, color: _textColor),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  BirthdayLabel(
                      message: _birthdays.isNotEmpty
                          ? _birthdays[_selectedBirthdayIndex].message
                          : 'Happy Birthday',
                      textColor: _textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Time Remaining: $_timeRemaining',
                    style: TextStyle(color: _textColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimatedScale(
                    scale: _animation.value,
                    duration: _animationController.duration!,
                    child: Text(
                      _isBase64
                          ? '$_convertedDate'
                          : '${_birthdays.isNotEmpty ? _birthdays[_selectedBirthdayIndex].date : ''}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textColor),
                    )
                        .animate()
                        .slideY(
                        duration: const Duration(milliseconds: 500),
                        begin: -0.5)
                        .fade(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Base64Button(
                isBase64: _isBase64,
                onTap: () {
                  _animationController.forward().then((value) {
                    _animationController.reverse();
                  });
                  _toggleDate();
                },
                textColor: _textColor),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.01,
            numberOfParticles: 50,
            gravity: 0.2,
          )
        ],
      ),
    );
  }
}