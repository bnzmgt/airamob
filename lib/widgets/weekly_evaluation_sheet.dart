import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/weekly_evaluation.dart';

class WeeklyEvaluationSheet extends StatelessWidget {
  final WeeklyEvaluation evaluation;
  final String studentName;
  final bool isParent;

  const WeeklyEvaluationSheet({
    super.key,
    required this.evaluation,
    required this.studentName,
    this.isParent = true,
  });

  static Future<void> show(
    BuildContext context, {
    required WeeklyEvaluation evaluation,
    required String studentName,
    bool isParent = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeeklyEvaluationSheet(
        evaluation: evaluation,
        studentName: studentName,
        isParent: isParent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF7C3AED),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rangkuman Belajar Mingguan AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$studentName • Pekan Berakhir ${evaluation.weekEndDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metric Badges Row
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol(
                          label: 'Kepatuhan',
                          value: '${evaluation.complianceRate.toStringAsFixed(0)}%',
                          color: evaluation.complianceRate >= 80
                              ? const Color(0xFF10B981)
                              : (evaluation.complianceRate >= 50
                                  ? AppTheme.secondaryTangerine
                                  : AppTheme.errorRed),
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildMetricCol(
                          label: 'Laporan Masuk',
                          value: '${evaluation.totalReportsSubmitted}/${evaluation.totalActiveDays} Hari',
                          color: AppTheme.primaryBlue,
                        ),
                        Container(width: 1, height: 30, color: Colors.grey.shade300),
                        _buildMetricCol(
                          label: 'Hari Kosong',
                          value: '${evaluation.totalMissingDays} Hari',
                          color: evaluation.totalMissingDays > 0
                              ? AppTheme.errorRed
                              : const Color(0xFF10B981),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Parent Narrative (if available and parent mode)
                  if (isParent && evaluation.parentReportNarrative != null && evaluation.parentReportNarrative!.isNotEmpty) ...[
                    const Text(
                      'Pesan Khusus untuk Orang Tua / Wali',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.family_restroom, color: Color(0xFF059669), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              evaluation.parentReportNarrative!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Student Reflection Narrative
                  if (evaluation.studentReflectionNarrative != null && evaluation.studentReflectionNarrative!.isNotEmpty) ...[
                    Text(
                      isParent ? 'Refleksi Belajar untuk Siswa' : 'Refleksi Pekan Ini untuk Kamu',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.emoji_objects_outlined, color: AppTheme.primaryBlue, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              evaluation.studentReflectionNarrative!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF1E40AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Close button
          SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
