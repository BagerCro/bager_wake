import 'package:flutter/material.dart';

import '../../core/models/diagnostic_item.dart';
import '../../core/services/diagnostics_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/device_header.dart';
import 'widgets/diagnostic_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.diagnostics});

  final DiagnosticsService diagnostics;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DashboardData> _load() async {
    final device = await widget.diagnostics.readDeviceInfo();
    final items = await widget.diagnostics.readAll();
    return _DashboardData(device: device, items: items);
  }

  Future<void> _refresh() async {
    final next = _load();
    // Swap only once the new data is in, so pull-to-refresh doesn't flash a
    // loading spinner over already-visible results.
    final data = await next;
    if (!mounted) return;
    setState(() => _future = Future.value(data));
  }

  Future<void> _openSettings(String id) async {
    await widget.diagnostics.openSettingsFor(id);
  }

  Future<void> _requestNotificationPermission() async {
    await widget.diagnostics.requestNotificationPermission();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: FutureBuilder<_DashboardData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorView(
              message: l10n.dashboardLoadError,
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                DeviceHeader(device: data.device),
                for (final item in data.items)
                  DiagnosticTile(
                    item: item,
                    onOpenSettings: () => _openSettings(item.id),
                    onRequestNotificationPermission:
                        item.id == DiagnosticIds.notificationsEnabled &&
                                item.status != DiagnosticStatus.ok
                            ? _requestNotificationPermission
                            : null,
                  ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({required this.device, required this.items});
  final DeviceInfo device;
  final List<DiagnosticItem> items;
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
