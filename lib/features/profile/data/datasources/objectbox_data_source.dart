import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../objectbox.g.dart';
import 'objectbox_entity_migration.dart';

class MotionOrbitObjectBox {
  MotionOrbitObjectBox._();

  static Store? _store;
  static Admin? _admin;

  static Future<void> initialize() async {
    if (_store != null) return;

    final appSupportDirectory = await getApplicationSupportDirectory();
    final objectBoxDirectory = path.join(appSupportDirectory.path, 'objectbox');
    final openedStore = await openStore(directory: objectBoxDirectory);
    try {
      await ObjectBoxEntityMigration(openedStore).run();
      // Publish the store only after the migration and readback succeed.
      _store = openedStore;
    } catch (_) {
      openedStore.close();
      rethrow;
    }

    if (!kDebugMode) return;

    final adminAvailable = Admin.isAvailable();
    debugPrint('ObjectBox Admin available: $adminAvailable');
    if (!adminAvailable) return;

    _admin ??= Admin(_store!);
    debugPrint('ObjectBox Admin listening on port ${_admin!.port}');
  }

  static Store get store {
    final value = _store;
    if (value == null) {
      throw StateError('ObjectBox has not been initialized');
    }
    return value;
  }
}
