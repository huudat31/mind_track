import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/personalization/game_personalization_service.dart';
import 'package:mind_track/features/game/security/risk_keyword_scanner.dart';

void main() {
  group('GamePersonalizationService Tests', () {
    test('normalizeContextTag correctly normalizes Vietnamese variations', () {
      expect(GamePersonalizationService.normalizeContextTag('Ôn thi học kỳ'), 'hoc_tap');
      expect(GamePersonalizationService.normalizeContextTag('study'), 'hoc_tap');
      expect(GamePersonalizationService.normalizeContextTag('Bố mẹ kỳ vọng'), 'gia_dinh');
      expect(GamePersonalizationService.normalizeContextTag('Người yêu giận dỗi'), 'tinh_cam');
      expect(GamePersonalizationService.normalizeContextTag('Mạng xã hội áp lực'), 'mang_xa_hoi');
      expect(GamePersonalizationService.normalizeContextTag('ngẫu nhiên'), 'hoc_tap'); // Fallback
    });

    test('findMostFrequentContextTag selects the most frequent tag in history', () {
      final sampleLogs = [
        {'context_tags': ['gia_dinh', 'học tập']},
        {'context_tags': ['gia_dinh']},
        {'context_tags': ['tinh_cam']},
        {'context_tags': ['gia_dinh']},
      ];

      final topTag = GamePersonalizationService.findMostFrequentContextTag(sampleLogs);
      expect(topTag, 'gia_dinh');
    });

    test('findMostFrequentContextTag falls back to hoc_tap on empty or null logs', () {
      expect(GamePersonalizationService.findMostFrequentContextTag([]), 'hoc_tap');
    });
  });

  group('RiskKeywordScanner Safety Tests', () {
    test('Returns safe on normal everyday thoughts', () {
      final result1 = RiskKeywordScanner.scan('Hôm nay mình thấy hơi hồi hộp trước buổi thuyết trình.');
      expect(result1.level, RiskLevel.none);
      expect(result1.requiresImmediateIntervention, isFalse);
      expect(result1.matchedKeywords, isEmpty);

      final result2 = RiskKeywordScanner.scan('');
      expect(result2.level, RiskLevel.none);
    });

    test('Detects critical crisis keywords and requires immediate intervention', () {
      final result = RiskKeywordScanner.scan('Mình cảm thấy muốn chết đi cho xong, không muốn sống nữa.');
      expect(result.level, RiskLevel.critical);
      expect(result.requiresImmediateIntervention, isTrue);
      expect(result.matchedKeywords.contains('muốn chết') || result.matchedKeywords.contains('không muốn sống'), isTrue);
      expect(result.recommendation.contains('111'), isTrue);
    });

    test('Detects warning distress keywords', () {
      final result = RiskKeywordScanner.scan('Mọi thứ dạo này quá bế tắc và mình cảm thấy vô dụng hoàn toàn.');
      expect(result.level, RiskLevel.warning);
      expect(result.requiresImmediateIntervention, isFalse);
      expect(result.matchedKeywords.contains('quá bế tắc'), isTrue);
    });
  });
}
