import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PdfReportScreen extends StatelessWidget {
  const PdfReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo trước trị liệu'),
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
                  color: AppColors.accentLavender.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 48,
                  color: AppColors.accentLavender,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Module 4: Pre-Therapy PDF Builder',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bao gồm: Privacy Selector (tự chọn nhật ký & ẩn danh), Bảng tổng hợp triệu chứng, Biểu đồ DASS-21 và Gợi ý chủ đề mở đầu buổi gặp chuyên gia.',
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
