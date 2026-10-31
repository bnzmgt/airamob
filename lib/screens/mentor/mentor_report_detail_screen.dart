import 'package:flutter/material.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mentor_report.dart';
import '../../services/mentor_service.dart';

class MentorReportDetailScreen extends StatefulWidget {
  final int reportId;
  final MentorReport? initialReport;

  const MentorReportDetailScreen({
    super.key,
    required this.reportId,
    this.initialReport,
  });

  @override
  State<MentorReportDetailScreen> createState() => _MentorReportDetailScreenState();
}

class _MentorReportDetailScreenState extends State<MentorReportDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  MentorReport? _report;

  @override
  void initState() {
    super.initState();
    _report = widget.initialReport;
    if (_report == null) {
      _loadReportDetail();
    }
  }

  Future<void> _loadReportDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await MentorService.getReportDetail(widget.reportId);

    if (!mounted) return;

    if (response.success && response.data is Map) {
      setState(() {
        _isLoading = false;
        _report = MentorReport.fromJson(response.data as Map<String, dynamic>);
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Gagal memuat detail laporan les.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Laporan Sesi Les', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF7E22CE)))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.errorRed)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadReportDetail,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _report == null
                    ? const Center(child: Text('Data tidak ditemukan.'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Student Header Card
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.borderDefault),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3E8FF),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.menu_book, color: Color(0xFF7E22CE), size: 24),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _report!.studentName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Kode: ${_report!.studentCode ?? '-'} • ${_report!.className ?? 'Kelas -'}',
                                              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, color: AppTheme.borderDefault),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Mata Pelajaran', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                            const SizedBox(height: 2),
                                            Text(
                                              _report!.subject,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Tanggal Les', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                            const SizedBox(height: 2),
                                            Text(
                                              _report!.sessionDateFormatted ?? _report!.sessionDate,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_report!.startTime != null) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: AppTheme.textMuted),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_report!.startTime} - ${_report!.endTime ?? 'selesai'} (${_report!.durationMinutes ?? 0} menit)',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Understanding Level Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _report!.understandingBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _report!.understandingColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.stars_rounded, color: _report!.understandingColor, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Evaluasi Pemahaman Siswa', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                        const SizedBox(height: 2),
                                        Text(
                                          _report!.understandingLabel,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _report!.understandingColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Material Taught
                            _buildSectionCard(
                              title: 'Topik & Materi yang Diajarkan',
                              icon: Icons.lightbulb_outline,
                              content: _report!.materialTaught,
                            ),

                            const SizedBox(height: 16),

                            // Student Progress
                            _buildSectionCard(
                              title: 'Perkembangan & Keaktifan Belajar',
                              icon: Icons.trending_up,
                              content: _report!.studentProgress,
                            ),

                            // Homework Notes (If any)
                            if (_report!.homeworkNotes != null && _report!.homeworkNotes!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildSectionCard(
                                title: 'Catatan Tugas & PR Mandiri',
                                icon: Icons.assignment_outlined,
                                content: _report!.homeworkNotes!,
                                isHighlight: true,
                              ),
                            ],

                            // Photo Documentation (If any)
                            if (_report!.photoUrl != null && _report!.photoUrl!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.borderDefault),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.photo_camera_outlined, size: 18, color: Color(0xFF7E22CE)),
                                        SizedBox(width: 8),
                                        Text('Dokumentasi Sesi Les', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        ApiEndpoints.resolveImageUrl(_report!.photoUrl),
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 200,
                                            color: AppTheme.backgroundLight,
                                            child: const Center(child: CircularProgressIndicator(color: Color(0xFF7E22CE))),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          height: 150,
                                          color: AppTheme.backgroundLight,
                                          alignment: Alignment.center,
                                          child: const Text('Foto dokumentasi tidak dapat dimuat.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String content,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isHighlight ? const Color(0xFFFDE68A) : AppTheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isHighlight ? const Color(0xFFD97706) : const Color(0xFF7E22CE)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? const Color(0xFF92400E) : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
