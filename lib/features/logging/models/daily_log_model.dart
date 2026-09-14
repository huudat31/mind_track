import 'package:flutter/material.dart';

enum MoodType {
  veryBad(1, 'Kiệt quệ', 'Rất tệ', Icons.sentiment_very_dissatisfied_rounded, Color(0xFFE07A5F)),
  bad(2, 'Lo âu / Buồn', 'Tệ', Icons.sentiment_dissatisfied_rounded, Color(0xFFF4A261)),
  neutral(3, 'Bình thường', 'Tạm ổn', Icons.sentiment_neutral_rounded, Color(0xFF818AA3)),
  good(4, 'Bình an', 'Tốt', Icons.sentiment_satisfied_rounded, Color(0xFF7E9F9B)),
  veryGood(5, 'Nhiều năng lượng', 'Rất tốt', Icons.sentiment_very_satisfied_rounded, Color(0xFF2A9D8F));

  final int score;
  final String label;
  final String quickName;
  final IconData icon;
  final Color color;

  const MoodType(this.score, this.label, this.quickName, this.icon, this.color);
}

class ClinicalFlagItem {
  final String id;
  final String name;
  final String category;
  final IconData icon;

  const ClinicalFlagItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });
}

class ClinicalFlagsCatalog {
  static const List<ClinicalFlagItem> allFlags = [
    // 1. Giấc ngủ
    ClinicalFlagItem(id: 'insomnia', name: 'Khó vào giấc', category: 'Giấc ngủ', icon: Icons.bedtime_outlined),
    ClinicalFlagItem(id: 'mid_wake', name: 'Thức giữa đêm', category: 'Giấc ngủ', icon: Icons.nights_stay_outlined),
    ClinicalFlagItem(id: 'hypersomnia', name: 'Ngủ li bì (>10h)', category: 'Giấc ngủ', icon: Icons.hotel_outlined),

    // 2. Ăn uống
    ClinicalFlagItem(id: 'loss_appetite', name: 'Chán ăn / Bỏ bữa', category: 'Ăn uống', icon: Icons.no_food_outlined),
    ClinicalFlagItem(id: 'stress_eating', name: 'Ăn vô thức khi lo', category: 'Ăn uống', icon: Icons.fastfood_outlined),

    // 3. Nhận thức & Não bộ
    ClinicalFlagItem(id: 'brain_fog', name: 'Mất tập trung (Brain fog)', category: 'Nhận thức', icon: Icons.psychology_outlined),
    ClinicalFlagItem(id: 'overwhelmed', name: 'Cảm giác quá tải', category: 'Nhận thức', icon: Icons.cloud_outlined),

    // 4. Hành vi & Xã hội
    ClinicalFlagItem(id: 'social_withdrawal', name: 'Né tránh tin nhắn/gặp mặt', category: 'Hành vi', icon: Icons.person_off_outlined),
    ClinicalFlagItem(id: 'procrastination', name: 'Trì hoãn mọi việc', category: 'Hành vi', icon: Icons.timer_off_outlined),

    // 5. Thể chất (Somatization)
    ClinicalFlagItem(id: 'headache', name: 'Đau đầu / Choáng váng', category: 'Thể chất', icon: Icons.healing_outlined),
    ClinicalFlagItem(id: 'muscle_tension', name: 'Căng cơ vai gáy', category: 'Thể chất', icon: Icons.accessibility_new_outlined),
    ClinicalFlagItem(id: 'chest_tightness', name: 'Tức ngực / Tim đập nhanh', category: 'Thể chất', icon: Icons.monitor_heart_outlined),
    ClinicalFlagItem(id: 'stomach_ache', name: 'Cồn cào dạ dày', category: 'Thể chất', icon: Icons.spa_outlined),
  ];

  static const List<String> categories = [
    'Giấc ngủ',
    'Ăn uống',
    'Nhận thức',
    'Hành vi',
    'Thể chất',
  ];
}
