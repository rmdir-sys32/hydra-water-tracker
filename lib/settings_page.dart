import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback? onSettingsChanged;
  const SettingsPage({super.key, this.onSettingsChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? _prefs;
  int _defaultVolume = 250;
  String _activePreset = '250';
  int _dailyGoal = 2000;
  String _themeMode = 'light';

  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  bool _confirmReset = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _goalController.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultVolume = _prefs?.getInt('default_volume') ?? 250;
      _activePreset = _prefs?.getString('active_preset') ?? '250';
      _volumeController.text = _defaultVolume.toString();

      _dailyGoal = _prefs?.getInt('daily_goal') ?? 2000;
      _goalController.text = _dailyGoal.toString();

      _themeMode = _prefs?.getString('theme_mode') ?? 'light';
    });
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/water_logs.json');
  }

  Future<void> _exportLogs() async {
    try {
      final file = await _localFile;
      String jsonString = '[]';
      if (await file.exists()) {
        jsonString = await file.readAsString();
      }
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON data copied to clipboard!'),
            backgroundColor: Color(0xFF0EA5E9),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _importLogs(String jsonString) async {
    try {
      // Validate JSON structure
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw const FormatException('JSON root must be a List');
      }
      
      // Verify items are valid logs
      for (var item in decoded) {
        if (item is! Map<String, dynamic> ||
            !item.containsKey('timestamp') ||
            !item.containsKey('volumeMl')) {
          throw const FormatException('Invalid log entry format');
        }
        DateTime.parse(item['timestamp'] as String);
        if (item['volumeMl'] is! int) {
          throw const FormatException('volumeMl must be an integer');
        }
      }

      // Write to file
      final file = await _localFile;
      await file.writeAsString(jsonString);
      widget.onSettingsChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logs imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Import JSON Logs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste the JSON backup string below. This will overwrite your current logs.',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText: '[{"timestamp": "...", "volumeMl": 250}, ...]',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final jsonString = controller.text.trim();
                if (jsonString.isNotEmpty) {
                  _importLogs(jsonString);
                }
                Navigator.pop(context);
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  void _handleReset() {
    if (_confirmReset) {
      _resetLogs();
      _resetTimer?.cancel();
    } else {
      setState(() {
        _confirmReset = true;
      });
      _resetTimer = Timer(const Duration(seconds: 4), () {
        setState(() {
          _confirmReset = false;
        });
      });
    }
  }

  Future<void> _resetLogs() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
      }
      setState(() {
        _confirmReset = false;
      });
      widget.onSettingsChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All logs cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildPresetChip(String label, String valueKey, int targetMl) {
    final theme = Theme.of(context);
    final isSelected = _activePreset == valueKey;
    final isLight = theme.brightness == Brightness.light;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _activePreset = valueKey;
            if (targetMl > 0) {
              _defaultVolume = targetMl;
              _volumeController.text = targetMl.toString();
            }
          });
          _prefs?.setString('active_preset', valueKey);
          if (targetMl > 0) {
            _prefs?.setInt('default_volume', targetMl);
          }
          widget.onSettingsChanged?.call();
        }
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.18),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : (isLight ? Colors.grey[600] : Colors.grey[400]),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildThemeChip(String label, String valueKey, ThemeMode mode) {
    final theme = Theme.of(context);
    final isSelected = _themeMode == valueKey;
    final isLight = theme.brightness == Brightness.light;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _themeMode = valueKey;
          });
          _prefs?.setString('theme_mode', valueKey);
          MyApp.themeNotifier.value = mode;
          widget.onSettingsChanged?.call();
        }
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.18),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : (isLight ? Colors.grey[600] : Colors.grey[400]),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          children: [
            // App Theme Card
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 14),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.55 : 0.35),
                blur: 10,
                thickness: 0,
                lightIntensity: 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_rounded, size: 18, color: isLight ? Colors.grey[600] : Colors.grey[400]),
                        const SizedBox(width: 8),
                         Text(
                          'App Theme',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildThemeChip('Light Mode', 'light', ThemeMode.light),
                        _buildThemeChip('Dark Mode', 'dark', ThemeMode.dark),
                        _buildThemeChip('System', 'system', ThemeMode.system),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Daily Goal Editor Card
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 14),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.55 : 0.35),
                blur: 10,
                thickness: 0,
                lightIntensity: 0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_rounded, size: 18, color: isLight ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Goal',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adjust Target:',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                              onPressed: () {
                                  if (_dailyGoal > 500) {
                                    setState(() {
                                      _dailyGoal -= 250;
                                      _goalController.text = _dailyGoal.toString();
                                    });
                                    _prefs?.setInt('daily_goal', _dailyGoal);
                                    widget.onSettingsChanged?.call();
                                  }
                              },
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 70,
                              height: 36,
                              child: TextField(
                                controller: _goalController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                                ),
                                onChanged: (text) {
                                  int? val = int.tryParse(text);
                                  if (val != null && val > 0) {
                                    setState(() {
                                      _dailyGoal = val;
                                    });
                                    _prefs?.setInt('daily_goal', val);
                                    widget.onSettingsChanged?.call();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                              onPressed: () {
                                setState(() {
                                  _dailyGoal += 250;
                                  _goalController.text = _dailyGoal.toString();
                                });
                                _prefs?.setInt('daily_goal', _dailyGoal);
                                widget.onSettingsChanged?.call();
                              },
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ml',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tap Volume Presets Card
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 14),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.55 : 0.35),
                blur: 10,
                thickness: 0,
                lightIntensity: 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune_rounded, size: 18, color: isLight ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(width: 8),
                        Text(
                          'Tap Volume',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('250ml', '250', 250),
                        _buildPresetChip('500ml', '500', 500),
                        _buildPresetChip('1L', '1000', 1000),
                        _buildPresetChip('Custom', 'Custom', 0),
                      ],
                    ),
                    if (_activePreset == 'Custom') ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Custom size:',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                onPressed: () {
                                  int val = int.tryParse(_volumeController.text) ?? 250;
                                  if (val > 50) {
                                    val -= 50;
                                    setState(() {
                                      _defaultVolume = val;
                                      _volumeController.text = val.toString();
                                    });
                                    _prefs?.setInt('default_volume', val);
                                    widget.onSettingsChanged?.call();
                                  }
                                },
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 70,
                                height: 36,
                                child: TextField(
                                  controller: _volumeController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
                                    ),
                                    filled: true,
                                    fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                                  ),
                                  onChanged: (text) {
                                    int? val = int.tryParse(text);
                                    if (val != null && val > 0) {
                                      setState(() {
                                        _defaultVolume = val;
                                      });
                                      _prefs?.setInt('default_volume', val);
                                      widget.onSettingsChanged?.call();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                onPressed: () {
                                  int val = int.tryParse(_volumeController.text) ?? 250;
                                  val += 50;
                                  setState(() {
                                    _defaultVolume = val;
                                    _volumeController.text = val.toString();
                                  });
                                  _prefs?.setInt('default_volume', val);
                                  widget.onSettingsChanged?.call();
                                },
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ml',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Backup & Restore Card
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 14),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.55 : 0.35),
                blur: 10,
                thickness: 0,
                lightIntensity: 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.save_rounded, size: 18, color: isLight ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(width: 8),
                        Text(
                          'Data Backup & Restore',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Export your local water logs JSON to your clipboard or import a backup string.',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportLogs,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              foregroundColor: theme.colorScheme.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                              ),
                            ),
                            icon: const Icon(Icons.copy_all_rounded, size: 18),
                            label: const Text('Export JSON'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showImportDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                              foregroundColor: theme.colorScheme.secondary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.2)),
                              ),
                            ),
                            icon: const Icon(Icons.install_mobile_rounded, size: 18),
                            label: const Text('Import JSON'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reset history button
            Center(
              child: TextButton.icon(
                onPressed: _handleReset,
                style: TextButton.styleFrom(
                  foregroundColor: _confirmReset ? Colors.redAccent : (isLight ? Colors.grey[700] : Colors.grey[400]),
                  backgroundColor: _confirmReset
                      ? Colors.redAccent.withOpacity(0.1)
                      : (isLight ? Colors.black.withOpacity(0.03) : Colors.white.withOpacity(0.03)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: Icon(
                  _confirmReset ? Icons.warning_amber_rounded : Icons.delete_outline_rounded,
                  size: 18,
                ),
                label: Text(
                  _confirmReset ? 'Tap to Clear History' : 'Reset History',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
