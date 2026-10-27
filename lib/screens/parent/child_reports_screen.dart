import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_downloader.dart';
import '../reports/report_detail_screen.dart';

class ChildReportsScreen extends StatefulWidget {
  final int studentId;
  final String? initialStudentName;

  const ChildReportsScreen({
    super.key,
    required this.studentId,
    this.initialStudentName,
  });

  @override
  State<ChildReportsScreen> createState() => _ChildReportsScreenState();
}

class _ChildReportsScreenState extends State<ChildReportsScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  Map<String, dynamic>? _student;
  List<dynamic> _reports = [];

  int _currentPage = 1;
  int _lastPage = 1;
  int _totalReports = 0;

  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatReadableDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _loadReports({int page = 1}) async {
    setState(() => _isLoading = true);

    final queryParams = <String>[
      'page=$page',
      'per_page=10',
    ];

    if (_fromDate != null) {
      queryParams.add('from_date=${_formatDate(_fromDate!)}');
    }
    if (_toDate != null) {
      queryParams.add('to_date=${_formatDate(_toDate!)}');
    }

    final url = '${ApiEndpoints.parentChildReports(widget.studentId)}?${queryParams.join('&')}';
    final res = await ApiClient.get(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (res.success && res.data != null) {
        _student = res.data['student'];
        _reports = (res.data['items'] as List?) ?? [];
        final pagination = res.data['pagination'];
        if (pagination != null) {
          _currentPage = pagination['current_page'] ?? 1;
          _lastPage = pagination['last_page'] ?? 1;
          _totalReports = pagination['total'] ?? 0;
        }
      }
    });
  }

  Future<void> _pickFromDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: DateTime(2020),
      lastDate: _toDate ?? now,
    );
    if (picked != null && mounted) {
      setState(() => _fromDate = picked);
      _loadReports(page: 1);
    }
  }

  Future<void> _pickToDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? now,
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: now,
    );
    if (picked != null && mounted) {
      setState(() => _toDate = picked);
      _loadReports(page: 1);
    }
  }

  void _resetFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _loadReports(page: 1);
  }

  Future<void> _exportData(bool isPdf) async {
    setState(() => _isExporting = true);

    final queryParams = <String>[];
    if (_fromDate != null) {
      queryParams.add('from_date=${_formatDate(_fromDate!)}');
    }
    if (_toDate != null) {
      queryParams.add('to_date=${_formatDate(_toDate!)}');
    }

    final queryStr = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final url = isPdf
        ? '${ApiEndpoints.parentChildExportPdf(widget.studentId)}$queryStr'
        : '${ApiEndpoints.parentChildExportCsv(widget.studentId)}$queryStr';

    try {
      final res = await ApiClient.getRaw(url);
      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final ext = isPdf ? 'pdf' : 'csv';
        final nowStr = _formatDate(DateTime.now());
        final studentName = _student?['name']?.toString().replaceAll(' ', '_') ?? 'siswa';
        final filename = 'rekap_laporan_${studentName}_$nowStr.$ext';

        downloadFile(res.bodyBytes, filename);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File $ext.toUpperCase() berhasil diunduh: $filename'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh berkas (Status: ${res.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat unduh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _showAppreciationDialog(int reportId, String studentName) async {
    String selectedReaction = 'proud';
    final noteController = TextEditingController();

    final reactions = [
      {'key': 'barakallah', 'emoji': '🤲', 'label': 'Barakallah'},
      {'key': 'proud', 'emoji': '❤️', 'label': 'Bangga'},
      {'key': 'thumbs_up', 'emoji': '👍', 'label': 'Keren'},
      {'key': 'keep_spirit', 'emoji': '💪', 'label': 'Semangat'},
    ];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Apresiasi Belajar $studentName', style: const TextStyle(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Pilih Reaksi Emoji:', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: reactions.map((r) {
                  final isSelected = selectedReaction == r['key'];
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedReaction = r['key']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accentGreen : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(r['emoji']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text(r['label']!, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLength: 250,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan pesan doa atau penyemangat singkat...',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await ApiClient.post(
                  ApiEndpoints.parentAppreciate(reportId),
                  {
                    'reaction_type': selectedReaction,
                    'message': noteController.text.trim(),
                  },
                );

                if (!mounted) return;

                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apresiasi berhasil dikirim ke ananda!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                  _loadReports(page: _currentPage);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message ?? 'Gagal mengirim apresiasi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReportDetail(int reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailScreen(
          reportId: reportId,
          isParent: true,
        ),
      ),
    ).then((_) => _loadReports(page: _currentPage));
  }

  @override
  Widget build(BuildContext context) {
    final studentName = _student?['name'] ?? widget.initialStudentName ?? 'Ananda';
    final hasActiveFilter = _fromDate != null || _toDate != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Laporan $studentName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: () => _loadReports(page: _currentPage),
          ),
        ],
      ),
      body: _isLoading && _student == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: () => _loadReports(page: 1),
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Student Banner Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                              child: Text(
                                studentName.isNotEmpty ? studentName.substring(0, studentName.length >= 2 ? 2 : 1).toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kelas ${_student?['class_name'] ?? '-'} • Kode: ${_student?['student_code'] ?? '-'}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGreen,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total Terarsip', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen)),
                                  Text(
                                    '${_student?['total_reports'] ?? _totalReports} Laporan',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filter & Export Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Filter Rentang Tanggal & Ekspor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickFromDate,
                                    icon: const Icon(Icons.calendar_today, size: 14),
                                    label: Text(
                                      _fromDate != null ? _formatDate(_fromDate!) : 'Dari Tanggal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _fromDate != null ? Colors.black87 : AppTheme.textMuted,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickToDate,
                                    icon: const Icon(Icons.event, size: 14),
                                    label: Text(
                                      _toDate != null ? _formatDate(_toDate!) : 'Sampai Tanggal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _toDate != null ? Colors.black87 : AppTheme.textMuted,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (hasActiveFilter) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _resetFilters,
                                  icon: const Icon(Icons.clear, size: 14, color: Colors.grey),
                                  label: const Text('Reset Filter', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                              ),
                            ],
                            const Divider(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting ? null : () => _exportData(true),
                                    icon: const Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                                    label: const Text('Cetak PDF', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFFECDD3)),
                                      backgroundColor: const Color(0xFFFFF1F2),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting ? null : () => _exportData(false),
                                    icon: const Icon(Icons.table_chart, size: 16, color: AppTheme.primaryGreen),
                                    label: const Text('Export CSV', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
                                      backgroundColor: AppTheme.accentGreen,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Laporan ($_totalReports)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Reports List or Empty state
                    if (_reports.isEmpty && !_isLoading)
                      Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          child: Column(
                            children: [
                              Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 10),
                              Text(
                                'Tidak ada laporan yang ditemukan',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Coba sesuaikan filter rentang tanggal di atas.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._reports.map((report) {
                        final myAppreciation = report['my_appreciation'];
                        final hasPhoto = report['photo_url'] != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _navigateToReportDetail(report['id']),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatReadableDate(report['report_date']),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      if (hasPhoto)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentGreen,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.photo_camera, size: 12, color: AppTheme.primaryGreen),
                                              SizedBox(width: 4),
                                              Text('Foto', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    report['content'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13.5, height: 1.4),
                                  ),
                                  if ((report['ai_tags'] as List?)?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: (report['ai_tags'] as List).take(4).map((tag) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE1FBF2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                            color: Color(0xFF047857),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ],
                                  const Divider(height: 22),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (myAppreciation != null)
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF1F2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFFECDD3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(myAppreciation['emoji'] ?? '❤️', style: const TextStyle(fontSize: 15)),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    '${myAppreciation['label'] ?? 'Diapresiasi'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF9F1239),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        OutlinedButton.icon(
                                          onPressed: () => _showAppreciationDialog(report['id'], studentName),
                                          icon: const Icon(Icons.favorite_border, color: Colors.pink, size: 15),
                                          label: const Text('Beri Apresiasi', style: TextStyle(color: Colors.pink, fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            side: const BorderSide(color: Colors.pink),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _navigateToReportDetail(report['id']),
                                        icon: const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryGreen),
                                        label: const Text(
                                          'Detail & AI',
                                          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                    // Pagination row
                    if (_lastPage > 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 1
                                ? () => _loadReports(page: _currentPage - 1)
                                : null,
                          ),
                          Text(
                            'Halaman $_currentPage dari $_lastPage',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < _lastPage
                                ? () => _loadReports(page: _currentPage + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
