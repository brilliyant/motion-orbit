import 'package:flutter/services.dart';

abstract class ProfileLocalDataSource {
  Future<String?> read();
  Future<void> write(String snapshot);
  Future<void> recover();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl();

  static const _channel = MethodChannel('motion_orbit/local_profile');

  @override
  Future<String?> read() => _channel.invokeMethod<String>('read');

  @override
  Future<void> write(String snapshot) =>
      _channel.invokeMethod<void>('write', snapshot);

  @override
  Future<void> recover() => _channel.invokeMethod<void>('recover');
}

