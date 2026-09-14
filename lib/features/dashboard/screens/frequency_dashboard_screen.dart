import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FrequencyDashboardScreen extends StatelessWidget {
  const FrequencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê & Tần suất'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: 48,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Module 3: Frequency Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bao gồm: Biểu đồ đường DASS-21, Bảng đếm tần suất cờ đỏ và Thống kê xuất hiện cùng nhau (không suy diễn nhân quả).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
