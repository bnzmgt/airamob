import 'package:image_picker/image_picker.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class MentorService {
  static Future<ApiResponse> getDashboard() async {
    return await ApiClient.get(ApiEndpoints.mentorDashboard);
  }

  static Future<ApiResponse> getStudents() async {
    return await ApiClient.get(ApiEndpoints.mentorStudents);
  }

  static Future<ApiResponse> getAvailableStudents({String? search}) async {
    var url = ApiEndpoints.mentorAvailableStudents;
    if (search != null && search.trim().isNotEmpty) {
      url = '$url?search=${Uri.encodeComponent(search.trim())}';
    }
    return await ApiClient.get(url);
  }

  static Future<ApiResponse> attachStudent({
    required int studentId,
    required String subjectName,
  }) async {
    return await ApiClient.post(
      ApiEndpoints.mentorAttachStudent,
      {
        'student_id': studentId,
        'subject_name': subjectName,
      },
    );
  }

  static Future<ApiResponse> detachStudent(int studentId) async {
    return await ApiClient.delete(
      ApiEndpoints.mentorDetachStudent(studentId),
      null,
    );
  }

  static Future<ApiResponse> getReports({int? studentId, int page = 1}) async {
    var url = '${ApiEndpoints.mentorReports}?page=$page';
    if (studentId != null) {
      url += '&student_id=$studentId';
    }
    return await ApiClient.get(url);
  }

  static Future<ApiResponse> getReportDetail(int id) async {
    return await ApiClient.get(ApiEndpoints.mentorReportDetail(id));
  }

  static Future<ApiResponse> submitReport({
    required int studentId,
    required String sessionDate,
    String? startTime,
    String? endTime,
    required String subject,
    required String materialTaught,
    required String studentProgress,
    required String understandingLevel,
    String? homeworkNotes,
    XFile? photo,
  }) async {
    final fields = <String, String>{
      'student_id': studentId.toString(),
      'session_date': sessionDate,
      'subject': subject,
      'material_taught': materialTaught,
      'student_progress': studentProgress,
      'understanding_level': understandingLevel,
    };

    if (startTime != null && startTime.isNotEmpty) {
      fields['start_time'] = startTime;
    }
    if (endTime != null && endTime.isNotEmpty) {
      fields['end_time'] = endTime;
    }
    if (homeworkNotes != null && homeworkNotes.isNotEmpty) {
      fields['homework_notes'] = homeworkNotes;
    }

    return await ApiClient.postMultipart(
      ApiEndpoints.mentorReports,
      fields,
      file: photo,
      fileField: 'photo',
    );
  }

  static Future<ApiResponse> getParentChildMentorReports(int studentId) async {
    return await ApiClient.get(ApiEndpoints.parentChildMentorReports(studentId));
  }

  static Future<ApiResponse> getStudentMentorReports() async {
    return await ApiClient.get(ApiEndpoints.studentMentorReports);
  }
}
