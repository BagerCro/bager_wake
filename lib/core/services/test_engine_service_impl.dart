import 'package:flutter/services.dart';

import '../models/test_run.dart';
import 'test_engine_service.dart';

class NativeTestEngineService implements TestEngineService {
  static const _channel = MethodChannel('com.tesic.bager_wake/test_engine');

  const NativeTestEngineService();

  @override
  Future<bool> canRun() async {
    return await _channel.invokeMethod<bool>('canRun') ?? false;
  }

  @override
  Future<TestRun> start(Duration window) async {
    final raw = await _channel.invokeMethod<Object?>('start', {
      'windowSeconds': window.inSeconds,
    });
    final map = _asJsonMap(raw);
    if (map == null) {
      throw StateError('Test engine returned no run');
    }
    return TestRun.fromJson(map);
  }

  @override
  Future<TestRun?> currentRun() => _runFrom('currentRun');

  @override
  Future<TestRun?> collectResults() => _runFrom('collectResults');

  @override
  Future<void> cancel() async {
    await _channel.invokeMethod<void>('cancel');
  }

  @override
  Future<void> armRebootProbe() async {
    await _channel.invokeMethod<void>('armRebootProbe');
  }

  @override
  Future<RebootProbe?> rebootProbe() async {
    final map = _asJsonMap(await _channel.invokeMethod<Object?>('rebootProbe'));
    return map == null ? null : RebootProbe.fromJson(map);
  }

  @override
  Future<List<TestRun>> history() async {
    final raw = await _channel.invokeMethod<Object?>('history');
    if (raw is! List) return const [];
    return raw
        .map(_asJsonMap)
        .whereType<Map<String, Object?>>()
        .map(TestRun.fromJson)
        .toList();
  }

  Future<TestRun?> _runFrom(String method) async {
    final map = _asJsonMap(await _channel.invokeMethod<Object?>(method));
    return map == null ? null : TestRun.fromJson(map);
  }

  /// Platform channels hand back `Map<Object?, Object?>` at every level, including
  /// inside lists, so the nested lane maps need converting too before the model
  /// parsers can read them.
  static Map<String, Object?>? _asJsonMap(Object? raw) {
    if (raw is! Map) return null;
    return raw.map(
      (key, value) => MapEntry(key.toString(), _convert(value)),
    );
  }

  static Object? _convert(Object? value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _convert(v)));
    }
    if (value is List) {
      return value.map(_convert).toList();
    }
    return value;
  }
}
