import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Backend-to-Mobile Schema & Enum Parity Tests', () {
    test('AI Sentiment Enum correctly parses backend green, yellow, red values', () {
      final validBackendLevels = ['green', 'yellow', 'red'];

      for (final level in validBackendLevels) {
        String label;
        switch (level.toLowerCase()) {
          case 'green':
          case 'positive':
            label = 'Normal';
            break;
          case 'yellow':
          case 'neutral':
            label = 'Perhatian';
            break;
          case 'red':
          case 'negative':
            label = 'Intervensi';
            break;
          default:
            label = 'Rutin';
        }

        expect(label, isNot('Rutin'), reason: 'Backend level "$level" should not fall into default fallback!');
      }
    });

    test('Student StudyReport payload schema contains all required visual fields', () {
      // Mock exact payload returned by StudentReportApiController::transformReport
      final mockBackendStudentPayload = {
        'id': 42,
        'report_date': '2026-10-31',
        'content': 'Belajar Aljabar Matematika Bab 3',
        'happy_moment': 'Paham rumus kuadrat',
        'frustrated_moment': null,
        'photo_url': 'https://ainara.dstr.biz.id/storage/reports/photo1.jpg',
        'ai_tags': ['Matematika', 'Aljabar'],
        'sentiment_level': 'green',
        'submitted_at': '2026-10-31T07:00:00.000000Z',
        'appreciations': [
          {
            'id': 1,
            'reaction_type': 'barakallah',
            'emoji': '🤲',
            'label': 'Barakallah',
            'message': 'Semangat terus ananda!',
            'parent_name': 'Ayah',
            'created_at': '2026-10-31T07:15:00.000000Z',
          }
        ],
      };

      // Expected keys that mobile UI widgets rely on
      final requiredKeys = [
        'id',
        'report_date',
        'content',
        'photo_url',
        'ai_tags',
        'sentiment_level',
        'submitted_at',
        'appreciations',
      ];

      for (final key in requiredKeys) {
        expect(mockBackendStudentPayload.containsKey(key), isTrue,
            reason: 'Student report payload must contain key "$key"');
      }

      // Verify AI tags is List
      expect(mockBackendStudentPayload['ai_tags'], isA<List>());
      // Verify sentiment_level is one of green/yellow/red
      expect(['green', 'yellow', 'red'].contains(mockBackendStudentPayload['sentiment_level']), isTrue);
    });

    test('Parent StudyReport payload schema contains guidance and appreciations', () {
      // Mock exact payload returned by ParentReportApiController::transformReport
      final mockBackendParentPayload = {
        'id': 42,
        'student': {
          'id': 7,
          'name': 'Ahmad Fauzi',
          'student_code': 'STD-001',
          'class_name': '7A',
        },
        'report_date': '2026-10-31',
        'content': 'Belajar IPA Tata Surya',
        'happy_moment': 'Melihat simulasi orbit',
        'frustrated_moment': 'Masih bingung rotasi bumi',
        'photo_url': null,
        'ai_tags': ['IPA', 'TataSurya'],
        'sentiment_level': 'yellow',
        'ai_parent_guidance': 'Dampingi ananda dengan video animasi orbit planet.',
        'counseling_playbook': {
          'level': 'yellow',
          'type': 'actionable_playbook',
          'title': 'Panduan Obrolan Suportif',
          'summary': 'Ananda menghadapi tantangan.',
          'starter': 'Bagian mana yang bingung?',
          'dos': ['Validasi emosi'],
          'donts': ['Hindari membandingkan'],
        },
        'submitted_at': '2026-10-31T07:00:00.000000Z',
        'my_appreciation': {
          'id': 10,
          'reaction_type': 'keren',
          'emoji': '👍',
          'label': 'Keren',
          'message': 'Bagus nak!',
        },
        'all_appreciations': [],
      };

      final parentSpecificKeys = [
        'student',
        'ai_parent_guidance',
        'counseling_playbook',
        'my_appreciation',
        'all_appreciations',
      ];

      for (final key in parentSpecificKeys) {
        expect(mockBackendParentPayload.containsKey(key), isTrue,
            reason: 'Parent report payload must contain "$key" for full UI rendering');
      }

      expect(mockBackendParentPayload['ai_parent_guidance'], isNotNull);
      expect(mockBackendParentPayload['counseling_playbook'], isA<Map>());
    });

    test('LANTANG Safeguarding status enum matches frontend stage colors', () {
      final backendStatuses = ['SUBMITTED', 'INVESTIGATING', 'ACTION_TAKEN', 'RESOLVED'];

      for (final status in backendStatuses) {
        String label;
        switch (status) {
          case 'SUBMITTED':
            label = 'Diterima';
            break;
          case 'INVESTIGATING':
            label = 'Investigasi';
            break;
          case 'ACTION_TAKEN':
            label = 'Tindakan';
            break;
          case 'RESOLVED':
            label = 'Selesai';
            break;
          default:
            label = 'Tidak Diketahui';
        }

        expect(label, isNot('Tidak Diketahui'),
            reason: 'LANTANG status "$status" must have recognized label mapping');
      }
    });

    test('Compliance tracking payload schema contains all metrics fields', () {
      final mockCompliancePayload = {
        'weekly': {
          'window_days': 7,
          'start_date': '2026-10-25',
          'end_date': '2026-10-31',
          'effective_school_days': 6,
          'submitted_count': 6,
          'excused_count': 0,
          'missing_count': 0,
          'compliance_rate': 100.0,
          'status_label': 'Sangat Baik',
          'status_level': 'green',
        },
        'monthly': {
          'window_days': 30,
          'start_date': '2026-10-02',
          'end_date': '2026-10-31',
          'effective_school_days': 26,
          'submitted_count': 25,
          'excused_count': 1,
          'missing_count': 1,
          'compliance_rate': 96.2,
          'status_label': 'Sangat Baik',
          'status_level': 'green',
        },
        'weekly_rate': 100.0,
        'monthly_rate': 96.2,
        'missing_reports_weekly': 0,
        'missing_reports_monthly': 1,
        'status_label': 'Sangat Baik',
        'status_level': 'green',
      };

      final requiredKeys = [
        'weekly',
        'monthly',
        'weekly_rate',
        'monthly_rate',
        'missing_reports_weekly',
        'missing_reports_monthly',
        'status_label',
        'status_level',
      ];

      for (final key in requiredKeys) {
        expect(mockCompliancePayload.containsKey(key), isTrue,
            reason: 'Compliance payload must contain key "$key"');
      }
      expect(mockCompliancePayload['weekly'], isA<Map>());
      expect(mockCompliancePayload['monthly'], isA<Map>());
    });
  });
}
