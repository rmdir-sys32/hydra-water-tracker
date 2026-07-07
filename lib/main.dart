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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydrated',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B132B), // Deep Ocean Blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),   // Sky/Water Blue
          secondary: Color(0xFF0EA5E9), // Ocean Blue
          surface: Color(0xFF1C2541),   // Midnight Navy
          onSurface: Colors.white,
        ),
      ),
      home: const WaterTrackerPage(),
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

  Widget _buildHomeTab(BuildContext context, ThemeData theme, int todayTotal, List<WaterLogEntry> todayRecords, double progress) {
    return Stack(
      children: [
        // Decorative background blurs
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.06),
                  blurRadius: 120,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hydrated',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Circular Fluid Level Progress Circle (Interactive Tap)
              GestureDetector(
                onTap: () {
                  _logWater(_defaultVolume);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logged $_defaultVolume ml manually'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                  );
                },
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow Radial Progress indicator
                      SizedBox(
                        width: 194,
                        height: 194,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      // Content Card Inside circle
                      Container(
                        width: 174,
                        height: 174,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(_isPolling ? 0.12 : 0.02),
                              blurRadius: 20,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$todayTotal',
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '/ $_dailyGoal ml',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dailyGoal > 0 
                                  ? '${(todayTotal / _dailyGoal * 100).toInt()}% goal'
                                  : '0% goal',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'TAP TO ADD',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Scanning Status Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !_nfcAvailable 
                                ? Colors.red 
                                : (_isPolling ? theme.colorScheme.primary : Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !_nfcAvailable ? 'NFC ERROR' : (_isPolling ? 'NFC SCANNER LIVE' : 'SCANNER IDLE'),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: !_nfcAvailable ? Colors.redAccent : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Today's records header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "TODAY'S RECORDS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Hydration logs history with single entry removal
              Expanded(
                child: todayRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.water_drop_outlined, size: 30, color: Colors.grey[700]),
                            const SizedBox(height: 4),
                            Text(
                              'No drinks logged today yet.',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: todayRecords.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (context, index) {
                          final entry = todayRecords[index];
                          IconData drinkIcon = Icons.local_drink_rounded;
                          Color drinkColor = theme.colorScheme.primary;
                          if (entry.type == 'smoothie') {
                            drinkIcon = Icons.blender_rounded;
                            drinkColor = const Color(0xFFF472B6);
                          } else if (entry.type == 'tea') {
                            drinkIcon = Icons.emoji_food_beverage_rounded;
                            drinkColor = const Color(0xFF34D399);
                          } else if (entry.type == 'juice') {
                            drinkIcon = Icons.breakfast_dining_rounded;
                            drinkColor = const Color(0xFFFB923C);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      drinkIcon,
                                      color: drinkColor.withOpacity(0.8),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${entry.volumeMl} ml',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          _formatTime(entry.timestamp),
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Remove individual log item button
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                  color: Colors.redAccent.withOpacity(0.7),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _deleteEntry(entry),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayTotal = _todayTotalMl;
    final todayRecords = _todayLogs;
    final progress = _dailyGoal > 0 ? (todayTotal / _dailyGoal).clamp(0.0, 1.0) : 0.0;

    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = _buildHomeTab(context, theme, todayTotal, todayRecords, progress);
        break;
      case 1:
        currentBody = const AlarmPage();
        break;
      case 2:
        currentBody = StatsPage(
          logs: _logs,
          dailyGoal: _dailyGoal,
          onLogDrink: (volume, type) => _logWater(volume, type),
        );
        break;
      case 3:
        currentBody = SettingsPage(
          onSettingsChanged: () {
            _initStorageAndNfc();
          },
        );
        break;
      default:
        currentBody = _buildHomeTab(context, theme, todayTotal, todayRecords, progress);
    }

    return Scaffold(
      body: SafeArea(child: currentBody),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B132B),
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
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Statistics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}
