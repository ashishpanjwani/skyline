import 'package:as_promised_weather/ui/mock_data.dart';
import 'package:as_promised_weather/ui/models.dart';
import 'package:as_promised_weather/ui/settings_sheet.dart';
import 'package:as_promised_weather/ui/weather_screen.dart';
import 'package:flutter/material.dart';

class WeatherShowcasePage extends StatefulWidget {
  const WeatherShowcasePage({super.key});

  @override
  State<WeatherShowcasePage> createState() => _WeatherShowcasePageState();
}

class _WeatherShowcasePageState extends State<WeatherShowcasePage> {
  int currentIndex = 0;
  TempUnit unit = TempUnit.c;

  void _next() =>
      setState(() => currentIndex = (currentIndex + 1) % weatherConditions.length);
  void _prev() => setState(() =>
      currentIndex = (currentIndex - 1 + weatherConditions.length) % weatherConditions.length);

  @override
  Widget build(BuildContext context) {
    final current = weatherConditions[currentIndex];
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.tonal(
                    onPressed: _prev,
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)))),
                    child: const Text('← Prev'),
                  ),
                  const SizedBox(width: 16),
                  WeatherScreen(
                    onRefresh: () async {},
                    weather: current,
                    unit: unit == TempUnit.c ? 'C' : 'F',
                    location: 'San Francisco, CA',
                    onOpenSettings: () async {
                      await showModalBottomSheet(
                        context: context,
                        useSafeArea: true,
                        showDragHandle: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        builder: (_) => SettingsSheet(
                          unit: unit,
                          onUnitChanged: (u) => setState(() => unit = u),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  FilledButton.tonal(
                    onPressed: _next,
                    style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)))),
                    child: const Text('Next →'),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

