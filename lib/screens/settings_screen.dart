import 'package:flutter/material.dart';
import '../theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, ThemeData> themes = {
    'Light': ThemeData.light(),
    'Dark': ThemeData.dark(),
    'Custom Blue': ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.blue.shade50,
      cardColor: Colors.blue.shade100,
    ),
    'Custom Green': ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: Colors.green.shade50,
      cardColor: Colors.green.shade100,
    ),
  };

  String selectedTheme = 'Light';

  void updateTheme(String themeName, BuildContext context) {
    final theme = themes[themeName]!;
    ThemeNotifier.of(context).updateTheme(theme);
    setState(() {
      selectedTheme = themeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext parentContext) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: themes.keys.length,
                    itemBuilder: (context, index) {
                      final themeName = themes.keys.elementAt(index);
                      final themeData = themes[themeName]!;

                      return Builder(
                        builder: (BuildContext itemContext) {
                          return GestureDetector(
                            onTap: () => updateTheme(themeName, parentContext),
                            child: Card(
                              color: themeData.cardColor,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        themeName,
                                        style: themeData.textTheme.bodyLarge,
                                      ),
                                    ),
                                    if (selectedTheme == themeName)
                                      Icon(Icons.check,
                                          color: themeData.primaryColor),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
