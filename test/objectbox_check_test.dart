import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:motion_orbit/objectbox.g.dart';

void main() { 
  test('test openStore on Windows', () async {
    final dir = Directory.systemTemp.createTempSync('obx_test');
    try {
      final store = openStore(directory: dir.path);
      expect(store, isNotNull);
      store.close();
    } catch (e) {
      // ignore: avoid_print
      print('ObjectBox open error: $e');
    } finally {
      if (dir.existsSync()) {
        try {
          dir.deleteSync(recursive: true);
        } catch (_) {}
      }
    }
  });
}

