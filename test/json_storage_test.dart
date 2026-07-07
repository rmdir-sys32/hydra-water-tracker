import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_counter/main.dart';

void main() {
  group('WaterLogEntry Serialization', () {
    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final entry = WaterLogEntry(timestamp: now, volumeMl: 250, type: 'tea');

      final jsonMap = entry.toJson();
      expect(jsonMap['timestamp'], now.toIso8601String());
      expect(jsonMap['volumeMl'], 250);
      expect(jsonMap['type'], 'tea');

      final decodedEntry = WaterLogEntry.fromJson(jsonMap);
      expect(decodedEntry.timestamp, now);
      expect(decodedEntry.volumeMl, 250);
      expect(decodedEntry.type, 'tea');
    });

    test('backward compatibility fromSharedPrefString works correctly', () {
      final now = DateTime.now();
      final str = '${now.toIso8601String()}|500';

      final decodedEntry = WaterLogEntry.fromSharedPrefString(str);
      expect(decodedEntry.timestamp, now);
      expect(decodedEntry.volumeMl, 500);
    });
  });

  group('JSON File Storage Simulation', () {
    late Directory tempDir;
    late File tempFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('water_tracker_test');
      tempFile = File('${tempDir.path}/water_logs.json');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('Write and read logs to/from JSON file', () async {
      final entries = [
        WaterLogEntry(timestamp: DateTime.now().subtract(const Duration(minutes: 10)), volumeMl: 250),
        WaterLogEntry(timestamp: DateTime.now(), volumeMl: 500),
      ];

      // Write logs to temp JSON file
      final jsonList = entries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await tempFile.writeAsString(jsonString);

      // Verify file exists
      expect(await tempFile.exists(), isTrue);

      // Read back from file
      final contents = await tempFile.readAsString();
      final List<dynamic> decodedJsonList = jsonDecode(contents);
      final readEntries = decodedJsonList.map((json) => WaterLogEntry.fromJson(json)).toList();

      expect(readEntries.length, 2);
      expect(readEntries[0].volumeMl, 250);
      expect(readEntries[1].volumeMl, 500);
      expect(readEntries[0].timestamp.toIso8601String(), entries[0].timestamp.toIso8601String());
      expect(readEntries[1].timestamp.toIso8601String(), entries[1].timestamp.toIso8601String());
    });
  });
}
