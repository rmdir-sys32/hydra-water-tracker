import 'package:flutter/material.dart';
import 'main.dart'; // To access WaterLogEntry

class StatsPage extends StatefulWidget {
  final List<WaterLogEntry> logs;
  final int dailyGoal;
  final Function(int volume, String type) onLogDrink;

  const StatsPage({
    super.key,
    required this.logs,
    required this.dailyGoal,
    required this.onLogDrink,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Top Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Drink",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's see how things\nare going",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_rounded, size: 20, color: Colors.grey[300]),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Time Selector Toggle (Day, Week, Month)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: ['Day', 'Week', 'Month'].map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected ? Colors.black87 : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Glass Preview Card (middle screen design)
            _buildGlassPreviewCard(theme),
            const SizedBox(height: 24),

            // Hydration Stats Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Hydration Stats",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "This $_selectedTab",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: theme.colorScheme.primary),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatsChart(theme),
              ],
            ),
            const SizedBox(height: 24),

            // Drink Options Cards (third screen grid)
            const Text(
              "Quick Logs By Drink Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: _drinkCategories.length,
              itemBuilder: (context, index) {
                final drink = _drinkCategories[index];
                return _buildDrinkCard(drink, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Interactive Glass display matching middle mockup
  Widget _buildGlassPreviewCard(ThemeData theme) {
    // Total today
    final now = DateTime.now();
    final todayTotal = widget.logs
        .where((entry) =>
            entry.timestamp.year == now.year &&
            entry.timestamp.month == now.month &&
            entry.timestamp.day == now.day)
        .fold(0, (sum, entry) => sum + entry.volumeMl);
    
    final progress = widget.dailyGoal > 0 ? (todayTotal / widget.dailyGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minimized profile heads / drink category icons overlay
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                    child: Icon(Icons.local_drink_rounded, size: 14, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Today's Hydration",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[300]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${widget.logs.where((e) => e.timestamp.day == now.day).length} Logs",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Beautiful fluid visual representations
          Stack(
            alignment: Alignment.center,
            children: [
              // Background glass representation
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.2),
                      theme.colorScheme.secondary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$todayTotal/${widget.dailyGoal}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      "ml",
                      style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Floating action to quickly add
              Positioned(
                bottom: 0,
                right: 20,
                child: FloatingActionButton.small(
                  heroTag: 'stats_add_fab',
                  onPressed: () => widget.onLogDrink(250, 'water'),
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Vertical Bar/Cylinder chart
  Widget _buildStatsChart(ThemeData theme) {
    if (_selectedTab == 'Day') {
      return _buildDayChart(theme);
    } else if (_selectedTab == 'Month') {
      return _buildMonthChart(theme);
    } else {
      return _buildWeekChart(theme);
    }
  }

  Widget _buildDayChart(ThemeData theme) {
    // Hourly buckets (6am, 10am, 2pm, 6pm, 10pm)
    final hours = [6, 10, 14, 18, 22];
    final hourLabels = ['6 AM', '10 AM', '2 PM', '6 PM', '10 PM'];
    final now = DateTime.now();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(hours.length, (index) {
          final hr = hours[index];
          // Sum logs within +/- 2 hours of this bucket today
          final totalInBucket = widget.logs
              .where((entry) =>
                  entry.timestamp.year == now.year &&
                  entry.timestamp.month == now.month &&
                  entry.timestamp.day == now.day &&
                  entry.timestamp.hour >= hr - 2 &&
                  entry.timestamp.hour < hr + 2)
              .fold(0, (sum, entry) => sum + entry.volumeMl);

          final maxBucketCap = 1000.0;
          final pct = (totalInBucket / maxBucketCap).clamp(0.0, 1.0);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  totalInBucket > 0 ? '${totalInBucket}ml' : '',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hourLabels[index],
                  style: TextStyle(fontSize: 9, color: Colors.grey[400], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekChart(ThemeData theme) {
    final now = DateTime.now();
    // Monday to Sunday of the current week
    final weekdayOfNow = now.weekday;
    final monday = now.subtract(Duration(days: weekdayOfNow - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
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
                    width: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isToday 
                                ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                                : [theme.colorScheme.secondary.withOpacity(0.6), theme.colorScheme.secondary.withOpacity(0.3)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
    // 4 weeks leading up to today
    final now = DateTime.now();
    final weekRanges = List.generate(4, (i) {
      final start = now.subtract(Duration(days: (3 - i) * 7 + 6));
      final end = now.subtract(Duration(days: (3 - i) * 7));
      return {'start': start, 'end': end, 'label': 'W${i + 1}'};
    });

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
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

          // Weekly goal is daily goal * 7
          final weeklyGoal = widget.dailyGoal * 7;
          final pct = weeklyGoal > 0 ? (totalForWeek / weeklyGoal).clamp(0.0, 1.0) : 0.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  totalForWeek > 0 ? '${(totalForWeek / 1000).toStringAsFixed(1)}L' : '',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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

  // Quick drink category card (third mockup design)
  Widget _buildDrinkCard(Map<String, dynamic> drink, ThemeData theme) {
    final type = drink['type'] as String;
    final color = drink['color'] as Color;
    final icon = drink['icon'] as IconData;
    final label = drink['label'] as String;
    final volume = drink['volume'] as int;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
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
    );
  }
}
