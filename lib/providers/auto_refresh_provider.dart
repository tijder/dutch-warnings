import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'alerts_provider.dart';
import 'settings_provider.dart';

final autoRefreshProvider = Provider<void>((ref) {
  final settings = ref.watch(settingsProvider);
  if (!settings.autoRefreshEnabled) return;

  final timer = Timer.periodic(
    Duration(minutes: settings.autoRefreshIntervalMinutes),
    (_) => ref.read(alertsProvider.notifier).refresh(),
  );

  ref.onDispose(timer.cancel);
});
