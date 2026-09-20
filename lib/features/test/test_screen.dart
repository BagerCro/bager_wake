import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/models/test_run.dart';
import '../../core/services/test_engine_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'widgets/lane_result_card.dart';
import 'widgets/test_run_result_view.dart';
import 'widgets/window_picker.dart';

enum _Phase { setup, running, results }

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.testEngine, required this.onNeedPermissions});

  final TestEngineService testEngine;

  /// Called when [TestEngineService.canRun] is false so the shell can switch
  /// the user to the Dashboard tab to fix permissions first.
  final VoidCallback onNeedPermissions;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Duration _window = const Duration(minutes: 15);
  _Phase _phase = _Phase.setup;
  TestRun? _run;
  Timer? _ticker;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _resumeIfInFlight();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _resumeIfInFlight() async {
    final run = await widget.testEngine.currentRun();
    if (!mounted || run == null) return;
    setState(() {
      _run = run;
      _window = run.window;
      _phase = _Phase.running;
    });
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    final run = _run;
    if (run == null) return;
    final remaining = run.startedAt.add(run.window).difference(DateTime.now());
    if (remaining <= Duration.zero) {
      final result = await widget.testEngine.collectResults();
      if (!mounted) return;
      _ticker?.cancel();
      setState(() {
        _run = result ?? run;
        _phase = _Phase.results;
      });
    } else if (mounted) {
      setState(() {}); // countdown repaint
    }
  }

  Future<void> _start() async {
    setState(() => _starting = true);
    final canRun = await widget.testEngine.canRun();
    if (!mounted) return;
    if (!canRun) {
      setState(() => _starting = false);
      _showPermissionDialog();
      return;
    }
    final run = await widget.testEngine.start(_window);
    if (!mounted) return;
    setState(() {
      _run = run;
      _phase = _Phase.running;
      _starting = false;
    });
    _startTicker();
  }

  Future<void> _cancel() async {
    await widget.testEngine.cancel();
    _ticker?.cancel();
    if (!mounted) return;
    setState(() {
      _run = null;
      _phase = _Phase.setup;
    });
  }

  void _startOver() {
    setState(() {
      _run = null;
      _phase = _Phase.setup;
    });
  }

  void _showPermissionDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.testNeedPermissions),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onNeedPermissions();
            },
            child: Text(l10n.testGoToDashboard),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.testTitle)),
      body: switch (_phase) {
        _Phase.setup => _SetupView(
            window: _window,
            starting: _starting,
            onWindowChanged: (w) => setState(() => _window = w),
            onStart: _start,
          ),
        _Phase.running => _RunningView(run: _run!, onCancel: _cancel),
        _Phase.results => _ResultsView(run: _run!, onNewTest: _startOver),
      },
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({
    required this.window,
    required this.starting,
    required this.onWindowChanged,
    required this.onStart,
  });

  final Duration window;
  final bool starting;
  final ValueChanged<Duration> onWindowChanged;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.testWindowLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          WindowPicker(value: window, onChanged: onWindowChanged),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        l10n.testPreflightTitle,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.testPreflightBody,
                    style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: starting ? null : onStart,
            icon: starting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(l10n.testStartButton),
          ),
        ],
      ),
    );
  }
}

class _RunningView extends StatelessWidget {
  const _RunningView({required this.run, required this.onCancel});

  final TestRun run;
  final VoidCallback onCancel;

  String _formatRemaining(Duration d) {
    final clamped = d.isNegative ? Duration.zero : d;
    final m = clamped.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = clamped.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remaining = run.startedAt.add(run.window).difference(DateTime.now());
    final progress = 1 -
        (remaining.inMilliseconds.clamp(0, run.window.inMilliseconds) /
            run.window.inMilliseconds);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(l10n.testRunningTitle, style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0, 1).toDouble(),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        _formatRemaining(remaining),
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.testTimeRemaining(_formatRemaining(remaining))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          for (final lane in run.lanes) LaneResultCard(result: lane),
          Center(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.testCancelButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.run, required this.onNewTest});

  final TestRun run;
  final VoidCallback onNewTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.testResultsTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TestRunResultView(run: run),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.icon(
              onPressed: onNewTest,
              icon: const Icon(Icons.replay),
              label: Text(l10n.testNewTest),
            ),
          ),
        ],
      ),
    );
  }
}
