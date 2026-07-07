import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_page.dart';
import 'stats_page.dart';
import 'alarm_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('theme_mode') ?? 'light';
    if (modeStr == 'dark') {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else if (modeStr == 'system') {
      MyApp.themeNotifier.value = ThemeMode.system;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Hydrated',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0EA5E9),   // Sky Blue
              secondary: Color(0xFF38BDF8), // Light Sky Blue
              surface: Color(0xFFF0F9FF),   // Soft sky blue tint surface
              onSurface: Color(0xFF0F172A), // Dark slate text
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0B132B), // Dark Navy
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0EA5E9),   // Sky Blue
              secondary: Color(0xFF38BDF8), // Light Sky Blue
              surface: Color(0xFF1C2541),   // Dark Midnight Navy
              onSurface: Colors.white,
            ),
          ),
          home: const WaterTrackerPage(),
        );
      },
    );
  }
}

// Log entry model representing one drink action
class WaterLogEntry {
  final DateTime timestamp;
  final int volumeMl;
  final String type; // 'water', 'tea', 'smoothie', 'juice'

  WaterLogEntry({
    required this.timestamp,
    required this.volumeMl,
    this.type = 'water',
  });

  // Serialize to JSON Map
  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'volumeMl': volumeMl,
        'type': type,
      };

  // Deserialize from JSON Map
  factory WaterLogEntry.fromJson(Map<String, dynamic> json) {
    return WaterLogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      volumeMl: json['volumeMl'] as int,
      type: json['type'] as String? ?? 'water',
    );
  }

  // Keep for backward compatibility / migration
  static WaterLogEntry fromSharedPrefString(String str) {
    final parts = str.split('|');
    return WaterLogEntry(
      timestamp: DateTime.parse(parts[0]),
      volumeMl: int.parse(parts[1]),
      type: 'water',
    );
  }
}

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key});

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> with WidgetsBindingObserver {
  final List<WaterLogEntry> _logs = [];
  String _status = 'Initializing...';
  bool _isPolling = false;
  bool _nfcAvailable = false;
  bool _isDisposed = false;
  SharedPreferences? _prefs;
  int _currentIndex = 0;

  // Preset volume settings
  int _defaultVolume = 250;
  String _activePreset = '250'; // '250', '500', '1000', 'Custom'

  // Daily water goal settings
  int _dailyGoal = 2000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initStorageAndNfc();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  // Get local file for JSON storage
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/water_logs.json');
  }

  // Load saved logs from JSON file
  Future<List<WaterLogEntry>> _loadLogsFromFile() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        return jsonList.map((json) => WaterLogEntry.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error reading logs from file: $e');
    }
    return [];
  }

  // Load configuration and logs
  Future<void> _initStorageAndNfc() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Load preset/custom volume settings
      _defaultVolume = _prefs?.getInt('default_volume') ?? 250;
      _activePreset = _prefs?.getString('active_preset') ?? '250';

      // Load daily water goal
      _dailyGoal = _prefs?.getInt('daily_goal') ?? 2000;
      
      // Load/Migrate saved logs
      List<WaterLogEntry> loadedLogs = [];
      final file = await _localFile;
      if (await file.exists()) {
        loadedLogs = await _loadLogsFromFile();
      } else {
        // Migrate legacy logs from SharedPreferences if any exist
        final savedLogStrings = _prefs?.getStringList('water_logs') ?? [];
        if (savedLogStrings.isNotEmpty) {
          loadedLogs = savedLogStrings.map((s) => WaterLogEntry.fromSharedPrefString(s)).toList();
          setState(() {
            _logs.clear();
            _logs.addAll(loadedLogs);
          });
          await _saveLogs(); // Save to new JSON file
          await _prefs?.remove('water_logs'); // Clean up SharedPreferences key
        }
      }

      setState(() {
        _logs.clear();
        _logs.addAll(loadedLogs);
      });

      // Cleanup: Prune logs older than 7 days
      _pruneOldLogs();

      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability == NFCAvailability.available) {
        setState(() {
          _nfcAvailable = true;
          _status = 'NFC antenna initialized.';
        });
        _startPolling();
      } else {
        setState(() {
          _nfcAvailable = false;
          _status = 'NFC hardware is unsupported or disabled.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Initialization error: $e';
      });
    }
  }

  void _pruneOldLogs() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final originalLength = _logs.length;
    _logs.removeWhere((entry) => entry.timestamp.isBefore(cutoff));
    if (_logs.length != originalLength) {
      _saveLogs();
    }
  }

  Future<void> _saveLogs() async {
    try {
      final file = await _localFile;
      final jsonList = _logs.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await file.writeAsString(jsonString);
    } catch (e) {
      debugPrint('Error saving logs to file: $e');
    }
  }

  void _startPolling() {
    if (!_nfcAvailable || _isPolling) return;
    setState(() {
      _isPolling = true;
    });
    _pollLoop();
  }

  Future<void> _stopPolling() async {
    if (!_isDisposed && mounted) {
      setState(() {
        _isPolling = false;
      });
    } else {
      _isPolling = false;
    }
    try {
      await FlutterNfcKit.finish();
    } catch (_) {}
  }

  // Foreground infinite polling loop
  Future<void> _pollLoop() async {
    while (_isPolling) {
      try {
        setState(() {
          _status = 'Tap your NFC cup/bottle sticker...';
        });

        // Wait for an NFC tag to be scanned
        NFCTag tag = await FlutterNfcKit.poll(
          timeout: const Duration(seconds: 30),
          androidPlatformSound: true,
        );

        // Dynamically log the volume configured in the UI
        int loggedVolume = _defaultVolume;
        await _logWater(loggedVolume);

        setState(() {
          _status = 'Logged $loggedVolume ml from NFC tap! Cooling down...';
        });

        // 2-second debounce cooldown
        await Future.delayed(const Duration(seconds: 2));

      } catch (e) {
        debugPrint('NFC scan session closed or timed out: $e');
        await Future.delayed(const Duration(milliseconds: 1000));
      } finally {
        try {
          await FlutterNfcKit.finish();
        } catch (_) {}
      }
    }
  }

  // Write drinking log entry
  Future<void> _logWater(int volumeMl, [String type = 'water']) async {
    final newEntry = WaterLogEntry(
      timestamp: DateTime.now(),
      volumeMl: volumeMl,
      type: type,
    );
    setState(() {
      _logs.add(newEntry);
    });
    await _saveLogs();
  }

  // Delete a specific entry
  Future<void> _deleteEntry(WaterLogEntry entry) async {
    setState(() {
      _logs.remove(entry);
    });
    await _saveLogs();
  }

  // Get total volume drank TODAY
  int get _todayTotalMl {
    final now = DateTime.now();
    return _logs
        .where((entry) =>
            entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month &&
            entry.timestamp.day == now.day)
        .fold(0, (sum, entry) => sum + entry.volumeMl);
  }

  // Get logs filtered only for today
  List<WaterLogEntry> get _todayLogs {
    final now = DateTime.now();
    return _logs
        .where((entry) =>
            entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month &&
            entry.timestamp.day == now.day)
        .toList()
        .reversed
        .toList(); // Newest first
  }

  // Custom clock string formatter (e.g., 2:45 PM)
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = StatsPage(
          logs: _logs,
          dailyGoal: _dailyGoal,
          onLogDrink: (volume, type) => _logWater(volume, type),
          onDeleteEntry: _deleteEntry,
          nfcStatus: _status,
          nfcAvailable: _nfcAvailable,
          isPolling: _isPolling,
        );
        break;
      case 1:
        currentBody = const AlarmPage();
        break;
      case 2:
        currentBody = SettingsPage(
          onSettingsChanged: () {
            _initStorageAndNfc();
          },
        );
        break;
      default:
        currentBody = StatsPage(
          logs: _logs,
          dailyGoal: _dailyGoal,
          onLogDrink: (volume, type) => _logWater(volume, type),
          onDeleteEntry: _deleteEntry,
          nfcStatus: _status,
          nfcAvailable: _nfcAvailable,
          isPolling: _isPolling,
        );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: currentBody),
            Opacity(
              opacity: 0.5,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.nfc_rounded,
                      size: 14,
                      color: _isPolling ? theme.colorScheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.light ? Colors.grey[700] : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey[500],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm_rounded),
              label: 'Alarm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Setting',
            ),
          ],
        ),
    );
  }
}
