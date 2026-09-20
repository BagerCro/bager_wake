import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class WindowPicker extends StatelessWidget {
  const WindowPicker({super.key, required this.value, required this.onChanged});

  final Duration value;
  final ValueChanged<Duration> onChanged;

  static const _options = [
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(minutes: 60),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      _options[0]: l10n.testWindow15,
      _options[1]: l10n.testWindow30,
      _options[2]: l10n.testWindow60,
    };
    return SegmentedButton<Duration>(
      segments: [
        for (final option in _options)
          ButtonSegment(value: option, label: Text(labels[option]!)),
      ],
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}
