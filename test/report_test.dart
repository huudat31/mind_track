import 'package:flutter_test/flutter_test.dart';
import 'package:mind_track/features/report/models/report_config_model.dart';
import 'package:mind_track/features/report/services/pre_therapy_pdf_builder.dart';
import 'package:mind_track/features/report/data/sample_journals_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Module 4: Pre-Therapy PDF Report Builder Tests', () {
    test('ReportPrivacyConfig default settings respect privacy', () {
      const config = ReportPrivacyConfig();

      expect(config.isAnonymous, isTrue);
      expect(config.clientDisplayName, contains('MT-89421'));
      expect(config.includeDass21, isTrue);
      expect(config.includeSymptomFrequency, isTrue);
      expect(config.includeCoOccurrence, isTrue);
      expect(config.selectedJournalIds.isNotEmpty, isTrue);
    });

    test('SampleJournalsData contains structured CBT 3-step entries', () {
      final entries = SampleJournalsData.allEntries;

      expect(entries.length, greaterThanOrEqualTo(3));
      for (final entry in entries) {
        expect(entry.situation.isNotEmpty, isTrue);
        expect(entry.automaticThought.isNotEmpty, isTrue);
        expect(entry.balancedResponse.isNotEmpty, isTrue);
        expect(entry.contextTag.isNotEmpty, isTrue);
      }
    });

    test('PreTherapyPdfBuilder generates valid non-empty PDF document bytes', () async {
      const config = ReportPrivacyConfig();
      final pdfBytes = await PreTherapyPdfBuilder.buildPdf(config);

      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF documents begin with the '%PDF-' magic header
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });
  });
}
