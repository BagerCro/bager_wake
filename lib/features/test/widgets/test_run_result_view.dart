import 'package:flutter/material.dart';

import '../../../core/models/test_run.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'lane_result_card.dart';

/// The three-lane breakdown plus the "this reading isn't clean" banner.
/// Shared by the Test screen's own results and History's past-run detail so
/// they always read identically.
class TestRunResultView extends StatelessWidget {
  const TestRunResultView({super.key, required this.run});

  final TestRun run;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // screenUnlockedDuringTest is bool? — null means "couldn't be determined"
    // (needs Usage Access), not "clean". It gets its own honest state instead
    // of being folded into either the dirty banner or a silent pass.
    final screenUnlocked = run.screenUnlockedDuringTest;
    final isDirty = screenUnlocked == true || run.rebootedDuringTest;
    final isUnknownClean = screenUnlocked == null && !run.rebootedDuringTest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDirty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.report_problem_outlined, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.testDirtyResultBanner,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (screenUnlocked == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(l10n.testScreenUnlocked,
                              style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                        ),
                      if (run.rebootedDuringTest)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(l10n.testRebooted,
                              style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (isUnknownClean)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline, color: theme.colorScheme.onTertiaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.testScreenUnlockedUnknown,
                    style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
          ),
        for (final lane in run.lanes) LaneResultCard(result: lane),
      ],
    );
  }
}
