import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../core/models/test_run.dart';
import '../../core/services/test_engine_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../test/widgets/test_run_result_view.dart';
import 'widgets/history_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.testEngine});

  final TestEngineService testEngine;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<TestRun>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.testEngine.history();
  }

  Future<void> _refresh() async {
    final next = widget.testEngine.history();
    final runs = await next;
    if (!mounted) return;
    setState(() => _future = Future.value(runs));
  }

  void _openDetail(TestRun run) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _HistoryDetailScreen(run: run)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: FutureBuilder<List<TestRun>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final runs = [...(snapshot.data ?? const <TestRun>[])]
            ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
          if (runs.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 40,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(l10n.historyEmpty, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                for (final run in runs)
                  HistoryTile(run: run, onTap: () => _openDetail(run)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryDetailScreen extends StatelessWidget {
  const _HistoryDetailScreen({required this.run});

  final TestRun run;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d.M.yyyy. HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(dateFormat.format(run.startedAt))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TestRunResultView(run: run),
      ),
    );
  }
}
