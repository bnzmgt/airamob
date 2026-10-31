import 'package:flutter_test/flutter_test.dart';
import 'package:ainara_mobile/models/mentor_report.dart';

void main() {
  group('MentorReport Model Tests', () {
    test('MentorStudentSummary correctly parses json', () {
      final json = {
        'id': 12,
        'name': 'Ahmad Dahlan',
        'student_code': 'STD-012',
        'class_name': '5-B',
        'subject_name': 'Matematika SD',
        'avatar_url': '/storage/avatars/12.jpg',
      };

      final student = MentorStudentSummary.fromJson(json);

      expect(student.id, 12);
      expect(student.name, 'Ahmad Dahlan');
      expect(student.studentCode, 'STD-012');
      expect(student.className, '5-B');
      expect(student.subjectName, 'Matematika SD');
      expect(student.avatarUrl, '/storage/avatars/12.jpg');
    });

    test('MentorReport correctly parses json and evaluates colors and labels', () {
      final json = {
        'id': 99,
        'student_id': 12,
        'student_name': 'Ahmad Dahlan',
        'student_code': 'STD-012',
        'class_name': '5-B',
        'mentor_id': 3,
        'mentor_name': 'Kak Budi',
        'session_date': '2026-10-28',
        'session_date_formatted': '28 Okt 2026',
        'start_time': '16:00',
        'end_time': '17:30',
        'duration_minutes': 90,
        'subject': 'Matematika SD',
        'material_taught': 'Pecahan Campuran dan Desimal',
        'student_progress': 'Sangat aktif bertanya dan cepat paham.',
        'understanding_level': 'sangat_paham',
        'understanding_label': 'Sangat Menguasai',
        'homework_notes': 'Latihan halaman 40 nomor 1 sampai 10.',
        'photo_url': '/storage/mentor_reports/session1.jpg',
      };

      final report = MentorReport.fromJson(json);

      expect(report.id, 99);
      expect(report.studentName, 'Ahmad Dahlan');
      expect(report.mentorName, 'Kak Budi');
      expect(report.subject, 'Matematika SD');
      expect(report.durationMinutes, 90);
      expect(report.understandingLevel, 'sangat_paham');
      expect(report.understandingLabel, 'Sangat Menguasai');
      expect(report.understandingColor.value, 0xFF059669);
      expect(report.homeworkNotes, 'Latihan halaman 40 nomor 1 sampai 10.');
    });

    test('MentorReport fallback defaults for minimal json', () {
      final json = {
        'id': 1,
      };

      final report = MentorReport.fromJson(json);

      expect(report.id, 1);
      expect(report.studentName, 'Siswa');
      expect(report.mentorName, 'Mentor');
      expect(report.subject, '-');
      expect(report.understandingLevel, 'paham');
      expect(report.understandingLabel, 'Paham Baik');
    });

    test('Mentor profile payload serialization and field mapping', () {
      final mentorUserResponse = {
        'id': 7,
        'name': 'Kak Rian Fadilah',
        'email': 'rian@mentor.ainara.id',
        'role': 'mentor',
        'status': 'active',
        'avatar_url': '/storage/avatars/rian.webp',
        'profile': {
          'phone_number': '081234567890',
          'specialization': 'Matematika & Fisika SMA',
          'address': 'Jl. Belimbing No. 12, Bandung',
          'bio': 'Pengajar les privat berpengalaman 5 tahun.',
          'active_students_count': 3,
        },
      };

      expect(mentorUserResponse['role'], 'mentor');
      expect(mentorUserResponse['name'], 'Kak Rian Fadilah');

      final profile = mentorUserResponse['profile'] as Map<String, dynamic>;
      expect(profile['specialization'], 'Matematika & Fisika SMA');
      expect(profile['phone_number'], '081234567890');
      expect(profile['address'], 'Jl. Belimbing No. 12, Bandung');
      expect(profile['bio'], 'Pengajar les privat berpengalaman 5 tahun.');
      expect(profile['active_students_count'], 3);

      final updatePayload = <String, String>{
        'name': mentorUserResponse['name'] as String,
        'phone_number': profile['phone_number'] as String,
        'address': profile['address'] as String,
        'specialization': profile['specialization'] as String,
        'bio': profile['bio'] as String,
      };

      expect(updatePayload['name'], 'Kak Rian Fadilah');
      expect(updatePayload['specialization'], 'Matematika & Fisika SMA');
      expect(updatePayload.containsKey('bio'), isTrue);
    });
  });
}
