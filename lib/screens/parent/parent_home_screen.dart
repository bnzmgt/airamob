import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_downloader.dart';
import '../auth/login_screen.dart';
import '../reports/report_detail_screen.dart';
import '../profile/profile_screen.dart';
import 'child_reports_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  bool _isLoading = true;
  bool _isExporting = false;
  String _parentName = 'Orang Tua';
  List<dynamic> _children = [];
  List<dynamic> _reports = [];

  int? _selectedStudentId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await SecureStorage.getUserName();
    final dashRes = await ApiClient.get(ApiEndpoints.parentDashboard);

    final queryParams = <String>[];
    if (_selectedStudentId != null) {
      queryParams.add('student_id=$_selectedStudentId');
    }
    if (_fromDate != null) {
      queryParams.add('from_date=${_formatDate(_fromDate!)}');
    }
    if (_toDate != null) {
      queryParams.add('to_date=${_formatDate(_toDate!)}');
    }

    final reportUrl = queryParams.isNotEmpty
        ? '${ApiEndpoints.parentReports}?${queryParams.join('&')}'
        : ApiEndpoints.parentReports;

    final reportRes = await ApiClient.get(reportUrl);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (name != null) _parentName = name;
      if (dashRes.success && dashRes.data != null) {
        _children = (dashRes.data['children'] as List?) ?? [];
      }
      if (reportRes.success && reportRes.data != null) {
        _reports = (reportRes.data['items'] as List?) ?? [];
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
      _loadData();
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
      _loadData();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStudentId = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadData();
  }

  Future<void> _exportData(bool isPdf) async {
    setState(() => _isExporting = true);

    final queryParams = <String>[];
    if (_selectedStudentId != null) {
      queryParams.add('student_id=$_selectedStudentId');
    }
    if (_fromDate != null) {
      queryParams.add('from_date=${_formatDate(_fromDate!)}');
    }
    if (_toDate != null) {
      queryParams.add('to_date=${_formatDate(_toDate!)}');
    }

    final queryStr = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final url = isPdf
        ? '${ApiEndpoints.parentReportsExportPdf}$queryStr'
        : '${ApiEndpoints.parentReportsExportCsv}$queryStr';

    try {
      final res = await ApiClient.getRaw(url);
      if (!mounted) return;

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final ext = isPdf ? 'pdf' : 'csv';
        final nowStr = _formatDate(DateTime.now());
        final filename = 'rekap_laporan_terpadu_$nowStr.$ext';

        downloadFile(res.bodyBytes, filename);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File ${ext.toUpperCase()} berhasil diunduh: $filename'),
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
                      content: Text('Apresiasi berhasil dikirim dan ternotifikasi ke ananda!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                  _loadData();
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
    ).then((_) => _loadData());
  }

  void _navigateToChildReports(dynamic child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildReportsScreen(
          studentId: child['id'],
          initialStudentName: child['name'],
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = _selectedStudentId != null || _fromDate != null || _toDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AiNARA Parent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar Akun',
            onPressed: () async {
              await ApiClient.post(ApiEndpoints.logout, {});
              await SecureStorage.clearSession();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading && _children.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card
                    Card(
                      color: AppTheme.accentGreen,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          ).then((_) => _loadData());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppTheme.primaryGreen,
                                child: Icon(Icons.family_restroom, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bapak / Ibu,', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                    Text(_parentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Connected children section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ananda yang Terhubung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${_children.length} Siswa', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._children.map((child) {
                      final isSubmitted = child['is_submitted_today'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _navigateToChildReports(child),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(Icons.school, color: AppTheme.primaryGreen),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(child['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Kelas ${child['class_name'] ?? '-'} • ${child['student_code'] ?? ''}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSubmitted ? AppTheme.accentGreen : Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isSubmitted ? '✓ Sudah Lapor' : '⚠ Belum Lapor',
                                        style: TextStyle(
                                          color: isSubmitted ? AppTheme.primaryGreen : Colors.amber.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Riwayat & Rekap',
                                          style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                        ),
                                        Icon(Icons.chevron_right, size: 14, color: AppTheme.primaryGreen),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),

                    // Reports feed header & filter section
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Filter Riwayat & Ekspor Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 10),

                            // Student selector if multiple children
                            if (_children.length > 1) ...[
                              DropdownButtonFormField<int?>(
                                value: _selectedStudentId,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  labelText: 'Pilih Siswa',
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('Semua Ananda', style: TextStyle(fontSize: 13)),
                                  ),
                                  ..._children.map((c) => DropdownMenuItem<int?>(
                                    value: c['id'] as int?,
                                    child: Text(c['name'] ?? '', style: const TextStyle(fontSize: 13)),
                                  )),
                                ],
                                onChanged: (val) {
                                  setState(() => _selectedStudentId = val);
                                  _loadData();
                                },
                              ),
                              const SizedBox(height: 10),
                            ],

                            // Date range pickers
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

                            const Divider(height: 18),

                            // Export buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting ? null : () => _exportData(true),
                                    icon: const Icon(Icons.picture_as_pdf, size: 15, color: Colors.red),
                                    label: const Text('Cetak PDF', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFFECDD3)),
                                      backgroundColor: const Color(0xFFFFF1F2),
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting ? null : () => _exportData(false),
                                    icon: const Icon(Icons.table_chart, size: 15, color: AppTheme.primaryGreen),
                                    label: const Text('Export CSV', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
                                      backgroundColor: AppTheme.accentGreen,
                                      padding: const EdgeInsets.symmetric(vertical: 9),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Feed Laporan Belajar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${_reports.length} Laporan', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 10),

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
                                'Belum ada laporan dari ananda',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Laporan harian yang dikirim oleh ananda akan tampil di sini secara terpadu.',
                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._reports.map((report) {
                        final studentName = report['student']?['name'] ?? 'Ananda';
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
                                      Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Row(
                                        children: [
                                          if (hasPhoto) ...[
                                            const Icon(Icons.photo_camera, size: 14, color: AppTheme.primaryGreen),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            report['report_date'] ?? '',
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                          ),
                                        ],
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
                  ],
                ),
              ),
            ),
    );
  }
}
