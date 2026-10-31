import 'package:flutter/material.dart';

class MentorStudentSummary {
  final int id;
  final String name;
  final String? studentCode;
  final String? className;
  final String? subjectName;
  final String? avatarUrl;

  MentorStudentSummary({
    required this.id,
    required this.name,
    this.studentCode,
    this.className,
    this.subjectName,
    this.avatarUrl,
  });

  factory MentorStudentSummary.fromJson(Map<String, dynamic> json) {
    return MentorStudentSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Siswa',
      studentCode: json['student_code'] as String?,
      className: json['class_name'] as String?,
      subjectName: json['subject_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class MentorReport {
  final int id;
  final int studentId;
  final String studentName;
  final String? studentCode;
  final String? className;
  final int mentorId;
  final String? mentorName;
  final String sessionDate;
  final String? sessionDateFormatted;
  final String? startTime;
  final String? endTime;
  final int? durationMinutes;
  final String subject;
  final String materialTaught;
  final String studentProgress;
  final String understandingLevel;
  final String understandingLabel;
  final String? homeworkNotes;
  final String? photoUrl;
  final String? submittedAt;
  final String? createdAt;

  MentorReport({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentCode,
    this.className,
    required this.mentorId,
    this.mentorName,
    required this.sessionDate,
    this.sessionDateFormatted,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.subject,
    required this.materialTaught,
    required this.studentProgress,
    required this.understandingLevel,
    required this.understandingLabel,
    this.homeworkNotes,
    this.photoUrl,
    this.submittedAt,
    this.createdAt,
  });

  factory MentorReport.fromJson(Map<String, dynamic> json) {
    return MentorReport(
      id: json['id'] as int,
      studentId: json['student_id'] as int? ?? 0,
      studentName: json['student_name'] as String? ?? 'Siswa',
      studentCode: json['student_code'] as String?,
      className: json['class_name'] as String?,
      mentorId: json['mentor_id'] as int? ?? 0,
      mentorName: json['mentor_name'] as String? ?? 'Mentor',
      sessionDate: json['session_date'] as String? ?? '',
      sessionDateFormatted: json['session_date_formatted'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      subject: json['subject'] as String? ?? '-',
      materialTaught: json['material_taught'] as String? ?? '-',
      studentProgress: json['student_progress'] as String? ?? '-',
      understandingLevel: json['understanding_level'] as String? ?? 'paham',
      understandingLabel: json['understanding_label'] as String? ?? 'Paham Baik',
      homeworkNotes: json['homework_notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      submittedAt: json['submitted_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Color get understandingColor {
    switch (understandingLevel) {
      case 'sangat_paham':
        return const Color(0xFF059669); // Emerald
      case 'paham':
        return const Color(0xFF2563EB); // Blue
      case 'cukup':
        return const Color(0xFFD97706); // Amber
      case 'perlu_bimbingan':
      default:
        return const Color(0xFFE11D48); // Rose
    }
  }

  Color get understandingBgColor {
    switch (understandingLevel) {
      case 'sangat_paham':
        return const Color(0xFFECFDF5);
      case 'paham':
        return const Color(0xFFEFF6FF);
      case 'cukup':
        return const Color(0xFFFFFBEB);
      case 'perlu_bimbingan':
      default:
        return const Color(0xFFFFF1F2);
    }
  }
}
