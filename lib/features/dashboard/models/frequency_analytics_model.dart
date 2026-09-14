import 'package:flutter/material.dart';
import '../../logging/models/daily_log_model.dart';
import '../../assessment/models/dass21_model.dart';

enum TimeframeOption {
  sevenDays('7 ngày qua', 7),
  fourteenDays('14 ngày qua', 14),
  twentyEightDays('28 ngày (Toàn kỳ)', 28);

  final String label;
  final int days;
  const TimeframeOption(this.label, this.days);
}

class DassHistoryPoint {
  final DateTime date;
  final String label; // e.g. "T0 (Bắt đầu)", "Ngày 7", "Ngày 14", "Ngày 28"
  final int depression;
  final int anxiety;
  final int stress;

  const DassHistoryPoint({
    required this.date,
    required this.label,
    required this.depression,
    required this.anxiety,
    required this.stress,
  });

  int getScore(DassCategory category) {
    switch (category) {
      case DassCategory.depression:
        return depression;
      case DassCategory.anxiety:
        return anxiety;
      case DassCategory.stress:
        return stress;
    }
  }

  String getSeverity(DassCategory category) {
    return Dass21Data.getSeverity(category, getScore(category));
  }
}

class FlagFrequencyStat {
  final ClinicalFlagItem flag;
  final int count;
  final int totalDays;
  final String trend; // 'up', 'down', 'stable'

  const FlagFrequencyStat({
    required this.flag,
    required this.count,
    required this.totalDays,
    this.trend = 'stable',
  });

  double get percentage => totalDays > 0 ? (count / totalDays) * 100 : 0.0;
  double get fraction => totalDays > 0 ? (count / totalDays) : 0.0;
}

class CoOccurrenceInsight {
  final String title;
  final String observation;
  final String factorA;
  final String factorB;
  final int percentage;
  final IconData icon;
  final Color accentColor;

  const CoOccurrenceInsight({
    required this.title,
    required this.observation,
    required this.factorA,
    required this.factorB,
    required this.percentage,
    required this.icon,
    required this.accentColor,
  });
}

class DailyMoodEnergyPoint {
  final DateTime date;
  final String dayLabel; // "T2", "T3", etc.
  final int moodScore; // 1 - 5
  final int energyLevel; // 1 - 5
  final List<String> flagIds;

  const DailyMoodEnergyPoint({
    required this.date,
    required this.dayLabel,
    required this.moodScore,
    required this.energyLevel,
    this.flagIds = const [],
  });
}
