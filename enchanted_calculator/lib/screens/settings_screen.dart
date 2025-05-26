import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  const SettingsScreen({super.key, required this.themeModeNotifier});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticsEnabled = true;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', _hapticsEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: SwitchListTile(
                title: const Text("Enable Haptics"),
                value: _hapticsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _hapticsEnabled = value;
                    _saveSettings();
                  });
                },
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Theme Settings"),
                trailing: DropdownButton<ThemeMode>(
                  value: widget.themeModeNotifier.value,
                  icon: const Icon(Icons.arrow_downward),
                  items: const [
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text("Light")),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text("System")),
                  ],
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      widget.themeModeNotifier.value = newValue;
                    }
                  },
                ),
              ),
            ),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "More settings coming soon!",
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}