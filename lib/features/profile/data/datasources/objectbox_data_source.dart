import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../objectbox.g.dart';

class MotionOrbitObjectBox {
  MotionOrbitObjectBox._();

  static Store? _store;

  static Future<void> initialize() async {
    if (_store != null) return;

    final appSupportDirectory = await getApplicationSupportDirectory();
    final objectBoxDirectory = path.join(appSupportDirectory.path, 'objectbox');
    _store ??= openStore(directory: objectBoxDirectory);
  }

  static Store get store {
    final value = _store;
    if (value == null) {
      throw StateError('ObjectBox has not been initialized');
    }
    return value;
  }
}
