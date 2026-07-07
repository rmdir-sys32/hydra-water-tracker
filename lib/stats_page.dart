import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'main.dart'; // To access WaterLogEntry

class StatsPage extends StatefulWidget {
  final List<WaterLogEntry> logs;
  final int dailyGoal;
  final Function(int volume, String type) onLogDrink;
  final Function(WaterLogEntry entry)? onDeleteEntry;
  final String nfcStatus;
  final bool nfcAvailable;
  final bool isPolling;

  const StatsPage({
    super.key,
    required this.logs,
    required this.dailyGoal,
    required this.onLogDrink,
    this.onDeleteEntry,
    required this.nfcStatus,
    required this.nfcAvailable,
    required this.isPolling,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTab = 'Week'; // 'Day', 'Week', 'Month'

  // Drink type categories with configurations
  final List<Map<String, dynamic>> _drinkCategories = [
    {
      'type': 'water',
      'label': 'Water',
      'volume': 250,
      'icon': Icons.local_drink_rounded,
      'color': Color(0xFF38BDF8),
    },
    {
      'type': 'smoothie',
      'label': 'Smoothie',
      'volume': 500,
      'icon': Icons.blender_rounded,
      'color': Color(0xFFF472B6),
    },
    {
      'type': 'tea',
      'label': 'Tea',
      'volume': 200,
      'icon': Icons.emoji_food_beverage_rounded,
      'color': Color(0xFF34D399),
    },
    {
      'type': 'juice',
      'label': 'Juice',
      'volume': 300,
      'icon': Icons.breakfast_dining_rounded,
      'color': Color(0xFFFB923C),
    },
  ];

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // Calculate Today's logs
    final now = DateTime.now();
    final todayLogs = widget.logs.where((entry) =>
        entry.timestamp.year == now.year &&
        entry.timestamp.month == now.month &&
        entry.timestamp.day == now.day).toList();
    
    final todayTotal = todayLogs.fold(0, (sum, entry) => sum + entry.volumeMl);
    final progress = widget.dailyGoal > 0 ? (todayTotal / widget.dailyGoal).clamp(0.0, 1.0) : 0.0;

    // Get last drink logged description
    String lastDrinkText = "No drinks logged today yet";
    if (todayLogs.isNotEmpty) {
      final last = todayLogs.last;
      lastDrinkText = "Last: ${last.volumeMl}ml of ${last.type} at ${_formatTime(last.timestamp)}";
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hydrated',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),


            // STAT 1: Today's Hydration Progress Card (Wave glass theme)
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 24),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.light ? 0.6 : 0.45),
                blur: 15,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.today_rounded, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        const Text(
                          "Today's Hydration",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Large outer wheel
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            ),
                          ),
                          // Content inside the wheel
                          SizedBox(
                            width: 170,
                            height: 170,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$todayTotal ml",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${(progress * 100).toInt()}% of ${widget.dailyGoal} ml",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: theme.brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    lastDrinkText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: Icon(
                                          Icons.nfc_rounded,
                                          size: 11,
                                          color: (theme.brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400])!.withOpacity(0.5),
                                        ),
                                      ),
                                      const TextSpan(text: ' '),
                                      TextSpan(
                                        text: 'Tap NFC to log',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: (theme.brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400])!.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // STAT 2: Weekly / Monthly Hydration Stats Chart Card
            LiquidGlass.withOwnLayer(
              shape: const LiquidRoundedRectangle(borderRadius: 24),
              settings: LiquidGlassSettings(
                glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.5 : 0.35),
                blur: 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Intake Overview",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Mini selector chip toggle
                        Row(
                          children: ['Week', 'Month'].map((tab) {
                            final isSel = _selectedTab == tab;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTab = tab),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tab,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? theme.colorScheme.primary : Colors.grey[400],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatsChart(theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // STAT 3: Today's Drink History
            if (todayLogs.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.history_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  const Text(
                    "Today's History",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LiquidGlass.withOwnLayer(
                shape: const LiquidRoundedRectangle(borderRadius: 20),
                settings: LiquidGlassSettings(
                  glassColor: theme.colorScheme.surface.withOpacity(isLight ? 0.5 : 0.35),
                  blur: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayLogs.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = todayLogs[todayLogs.length - 1 - index];
                      return ListTile(
                        dense: true,
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.water_drop_rounded,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          "${entry.volumeMl} ml",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _formatTime(entry.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: isLight ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                          onPressed: () {
                            widget.onDeleteEntry?.call(entry);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  // Vertical Cylinder Charts
  Widget _buildStatsChart(ThemeData theme) {
    if (_selectedTab == 'Month') {
      return _buildMonthChart(theme);
    } else {
      return _buildWeekChart(theme);
    }
  }

  Widget _buildWeekChart(ThemeData theme) {
    final now = DateTime.now();
    final weekdayOfNow = now.weekday;
    final monday = now.subtract(Duration(days: weekdayOfNow - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SizedBox(
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final date = weekDays[index];
          final totalForDay = widget.logs
              .where((entry) =>
                  entry.timestamp.year == date.year &&
                  entry.timestamp.month == date.month &&
                  entry.timestamp.day == date.day)
              .fold(0, (sum, entry) => sum + entry.volumeMl);

          final pct = widget.dailyGoal > 0 ? (totalForDay / widget.dailyGoal).clamp(0.0, 1.0) : 0.0;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  totalForDay > 0 ? '${(pct * 100).toInt()}%' : '',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isToday ? theme.colorScheme.primary : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 14,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isToday 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.primary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dayLabels[index],
                  style: TextStyle(
                    fontSize: 10, 
                    color: isToday ? theme.colorScheme.primary : Colors.grey[400], 
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthChart(ThemeData theme) {
    final now = DateTime.now();
    final weekRanges = List.generate(4, (i) {
      final start = now.subtract(Duration(days: (3 - i) * 7 + 6));
      final end = now.subtract(Duration(days: (3 - i) * 7));
      return {'start': start, 'end': end, 'label': 'W${i + 1}'};
    });

    return SizedBox(
      height: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (index) {
          final range = weekRanges[index];
          final start = range['start'] as DateTime;
          final end = range['end'] as DateTime;

          final totalForWeek = widget.logs
              .where((entry) =>
                  entry.timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
                  entry.timestamp.isBefore(end.add(const Duration(days: 1))))
              .fold(0, (sum, entry) => sum + entry.volumeMl);

          final weeklyGoal = widget.dailyGoal * 7;
          final pct = weeklyGoal > 0 ? (totalForWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  totalForWeek > 0 ? '${(totalForWeek / 1000).toStringAsFixed(1)}L' : '',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  range['label'] as String,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDrinkCard(Map<String, dynamic> drink, ThemeData theme) {
    final type = drink['type'] as String;
    final color = drink['color'] as Color;
    final icon = drink['icon'] as IconData;
    final label = drink['label'] as String;
    final volume = drink['volume'] as int;

    return LiquidGlass.withOwnLayer(
      shape: const LiquidRoundedRectangle(borderRadius: 20),
      settings: LiquidGlassSettings(
        glassColor: theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.light ? 0.55 : 0.35),
        blur: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              widget.onLogDrink(volume, type);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged $volume ml of $label!'),
                  backgroundColor: color,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      Icon(Icons.arrow_outward_rounded, color: Colors.grey[600], size: 16),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$volume ml",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
