class WeeklyEvaluation {
  final int id;
  final String weekStartDate;
  final String weekEndDate;
  final String? parentReportNarrative;
  final String? studentReflectionNarrative;
  final int totalReportsSubmitted;
  final int totalActiveDays;
  final int totalExcusedDays;
  final int totalMissingDays;
  final double complianceRate;

  WeeklyEvaluation({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    this.parentReportNarrative,
    this.studentReflectionNarrative,
    this.totalReportsSubmitted = 0,
    this.totalActiveDays = 6,
    this.totalExcusedDays = 0,
    this.totalMissingDays = 0,
    this.complianceRate = 100.0,
  });

  factory WeeklyEvaluation.fromJson(Map<String, dynamic> json) {
    return WeeklyEvaluation(
      id: json['id'] as int? ?? 0,
      weekStartDate: json['week_start_date'] as String? ?? '',
      weekEndDate: json['week_end_date'] as String? ?? '',
      parentReportNarrative: json['parent_report_narrative'] as String? ?? json['narrative'] as String?,
      studentReflectionNarrative: json['student_reflection_narrative'] as String? ?? json['reflection'] as String?,
      totalReportsSubmitted: json['total_reports_submitted'] as int? ?? json['total_reports'] as int? ?? 0,
      totalActiveDays: json['total_active_days'] as int? ?? 6,
      totalExcusedDays: json['total_excused_days'] as int? ?? 0,
      totalMissingDays: json['total_missing_days'] as int? ?? 0,
      complianceRate: (json['compliance_rate'] as num?)?.toDouble() ?? 100.0,
    );
  }
}
