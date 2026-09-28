import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/game/models/companion_tone.dart';
import 'package:mind_track/features/game/models/distortion_scenario.dart';

void main() {
  group('Kiểm thử tính toàn vẹn của Scenario JSON Data', () {
    test('Mỗi tình huống phải thỏa mãn 5 tiêu chuẩn kỹ thuật nghiêm ngặt', () {
      final file = File('assets/game/distortion_questions.json');
      expect(file.existsSync(), isTrue, reason: 'File distortion_questions.json không tồn tại');

      final rawJsonString = file.readAsStringSync();
      final List<dynamic> jsonList = jsonDecode(rawJsonString);
      final Set<String> scenarioIds = {};

      expect(jsonList.length, greaterThanOrEqualTo(12));

      for (final item in jsonList) {
        final map = item as Map<String, dynamic>;
        final id = map['id'] as String;

        // 1. ID không được trùng lặp
        expect(scenarioIds.contains(id), isFalse, reason: 'ID bị trùng lặp: $id');
        scenarioIds.add(id);

        // 2. distortion_type bắt buộc phải nằm trong choices
        final correctDistortion = map['distortion_type'] as String;
        final choices = List<String>.from(map['choices'] as List);
        expect(choices.contains(correctDistortion), isTrue,
            reason: 'Tình huống $id: choices không chứa đáp án đúng!');

        // 3. choices phải có đúng 4 phần tử phân biệt (không bị lặp lựa chọn)
        expect(choices.length, equals(4), reason: 'Tình huống $id: choices không đủ 4 phần tử');
        expect(choices.toSet().length, equals(4),
            reason: 'Tình huống $id: choices có lựa chọn bị trùng nhau!');

        // 4. companion_intro phải có đủ 3 tone: chill, friendly, calm
        final intro = map['companion_intro'] as Map<String, dynamic>?;
        expect(intro, isNotNull, reason: 'Tình huống $id: thiếu companion_intro');
        expect(intro!.containsKey('chill'), isTrue, reason: 'Tình huống $id: thiếu tone chill');
        expect(intro.containsKey('friendly'), isTrue, reason: 'Tình huống $id: thiếu tone friendly');
        expect(intro.containsKey('calm'), isTrue, reason: 'Tình huống $id: thiếu tone calm');

        // 5. hint_key và reframe không được để trống
        expect((map['hint_key'] as String).trim().isNotEmpty, isTrue,
            reason: 'Tình huống $id: hint_key rỗng');
        expect((map['reframe'] as String).trim().isNotEmpty, isTrue,
            reason: 'Tình huống $id: reframe rỗng');

        // 6. Parse thành công sang DistortionScenario model mà không ném exception
        final scenario = DistortionScenario.fromJson(map);
        expect(scenario.id, id);
        expect(scenario.choices.length, 4);
        expect(scenario.choices.contains(scenario.distortionType), isTrue);

        // 7. Kiểm tra fallback tone của companion intro
        expect(scenario.companionIntro.getIntro(ToneType.chill).isNotEmpty, isTrue);
        expect(scenario.companionIntro.getIntro(ToneType.friendly).isNotEmpty, isTrue);
        expect(scenario.companionIntro.getIntro(ToneType.calm).isNotEmpty, isTrue);
      }
    });
  });
}
