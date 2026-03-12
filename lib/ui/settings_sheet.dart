import 'package:as_promised_weather/ui/models.dart';
import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final TempUnit unit;
  final ValueChanged<TempUnit> onUnitChanged;

  const SettingsSheet({super.key, required this.unit, required this.onUnitChanged});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999))),
              ),
              const SizedBox(height: 16),
              Text('Settings',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Text('Units',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<TempUnit>(
                segments: const [
                  ButtonSegment(
                      value: TempUnit.c,
                      label: Text('Celsius (°C)'),
                      icon: Icon(Icons.thermostat_rounded)),
                  ButtonSegment(
                      value: TempUnit.f,
                      label: Text('Fahrenheit (°F)'),
                      icon: Icon(Icons.device_thermostat)),
                ],
                selected: {unit},
                onSelectionChanged: (s) => onUnitChanged(s.first),
              ),
              const SizedBox(height: 24),
            ]),
      ),
    );
  }
}

