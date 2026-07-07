import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  SharedPreferences? _prefs;
  bool _remindersEnabled = true;
  String _interval = '2 Hours'; // '1 Hour', '2 Hours', '3 Hours'
  
  final List<Map<String, dynamic>> _fixedReminders = [
    {'time': '09:00 AM', 'enabled': true},
    {'time': '12:00 PM', 'enabled': true},
    {'time': '03:00 PM', 'enabled': true},
    {'time': '06:00 PM', 'enabled': true},
    {'time': '09:00 PM', 'enabled': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = _prefs?.getBool('reminders_enabled') ?? true;
      _interval = _prefs?.getString('reminders_interval') ?? '2 Hours';
      
      // Load saved states for fixed reminders if any
      for (var reminder in _fixedReminders) {
        final key = 'reminder_${reminder['time']}';
        reminder['enabled'] = _prefs?.getBool(key) ?? reminder['enabled'] as bool;
      }
    });
  }

  Future<void> _toggleReminders(bool value) async {
    setState(() {
      _remindersEnabled = value;
    });
    await _prefs?.setBool('reminders_enabled', value);
  }

  Future<void> _changeInterval(String newInterval) async {
    setState(() {
      _interval = newInterval;
    });
    await _prefs?.setString('reminders_interval', newInterval);
  }

  Future<void> _toggleSingleReminder(int index, bool value) async {
    setState(() {
      _fixedReminders[index]['enabled'] = value;
    });
    final timeKey = 'reminder_${_fixedReminders[index]['time']}';
    await _prefs?.setBool(timeKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Top Section Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ALARM",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Hydration Reminders",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 20),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(0.6),
                blur: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Smart Reminders",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Alert me to drink water",
                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: _remindersEnabled,
                      onChanged: _toggleReminders,
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_remindersEnabled) ...[
              // Interval selector
              const Text(
                "Reminder Interval",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['1 Hour', '2 Hours', '3 Hours'].map((time) {
                  final isSelected = _interval == time;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _changeInterval(time),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary.withOpacity(0.18) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.colorScheme.primary : Colors.white10,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isSelected ? theme.colorScheme.primary : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Fixed schedule list
              const Text(
                "Scheduled Alerts",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              LiquidGlass.withOwnLayer(
                shape: const LiquidRoundedRectangle(borderRadius: 20),
                settings: LiquidGlassSettings(
                  glassColor: theme.colorScheme.surface.withOpacity(0.5),
                  blur: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.7)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _fixedReminders.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withOpacity(0.05)),
                    itemBuilder: (context, index) {
                      final item = _fixedReminders[index];
                      final bool isEnabled = item['enabled'] as bool;
                      final String timeStr = item['time'] as String;
  
                      return ListTile(
                        leading: Icon(
                          Icons.access_time_filled_rounded,
                          color: isEnabled ? theme.colorScheme.primary.withOpacity(0.8) : Colors.grey[400],
                          size: 20,
                        ),
                        title: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isEnabled ? theme.colorScheme.onSurface : Colors.grey[500],
                          ),
                        ),
                        trailing: Switch(
                          value: isEnabled,
                          onChanged: (val) => _toggleSingleReminder(index, val),
                          activeColor: theme.colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_off_rounded, size: 48, color: Colors.grey[700]),
                      const SizedBox(height: 12),
                      Text(
                        "Reminders are disabled.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: _remindersEnabled
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Custom alerts schedule coming soon!"),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.black87),
            )
          : null,
    );
  }
}
