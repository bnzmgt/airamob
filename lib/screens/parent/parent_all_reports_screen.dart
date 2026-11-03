import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/file_downloader.dart';
import '../reports/report_detail_screen.dart';

class ParentAllReportsScreen extends StatefulWidget {
  final List<dynamic>? initialChildren;
  final int? initialSelectedStudentId;

  const ParentAllReportsScreen({
    super.key,
    this.initialChildren,
    this.initialSelectedStudentId,
  });

  @override
  State<ParentAllReportsScreen> createState() => _ParentAllReportsScreenState();
}

class _ParentAllReportsScreenState extends State<ParentAllReportsScreen> {
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _children = [];
  int? _selectedStudentId;

  DateTime? _fromDate;
  DateTime? _toDate;

  List<dynamic> _reports = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isExporting = false;

  int _currentPage = 1;
  int _lastPage = 1;
  int _totalReports = 0;

  @override
  void initState() {
    super.initState();
    _children = widget.initialChildren ?? [];
    _selectedStudentId = widget.initialSelectedStudentId;

    _scrollController.addListener(_onScroll);

    _initData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _currentPage < _lastPage) {
        _loadReports(page: _currentPage + 1);
      }
    }
  }

  Future<void> _initData() async {
    if (_children.isEmpty) {
      final res = await ApiClient.get(ApiEndpoints.parentDashboard);
      if (res.success && res.data != null && mounted) {
        setState(() {
          _children = (res.data['children'] as List?) ?? [];
        });
      }
    }
    await _loadReports(page: 1);
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _loadReports({int page = 1, bool isRefresh = false}) async {
    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isLoadingMore = true);
    }

    final queryParams = <String>[
      'page=$page',
      'per_page=15',
    ];

    if (_selectedStudentId != null) {
      queryParams.add('student_id=$_selectedStudentId');
    }
    if (_fromDate != null) {
      queryParams.add('from_date=${_formatDate(_fromDate!)}');
    }
    if (_toDate != null) {
      queryParams.add('to_date=${_formatDate(_toDate!)}');
    }

    final url = '${ApiEndpoints.parentReports}?${queryParams.join('&')}';
    final res = await ApiClient.get(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;

      if (res.success && res.data != null) {
        final items = (res.data['items'] as List?) ?? [];
        final pagination = res.data['pagination'];

        if (page == 1) {
          _reports = items;
        } else {
          _reports.addAll(items);
        }

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
      _selectedStudentId = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadReports(page: 1);
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
        final studentLabel = _selectedStudentId != null
            ? (_children.firstWhere((c) => c['id'] == _selectedStudentId, orElse: () => {'name': 'siswa'})['name'] ?? 'siswa')
            : 'semua_ananda';
        final cleanLabel = studentLabel.toString().replaceAll(' ', '_');
        final filename = 'rekap_laporan_${cleanLabel}_$nowStr.$ext';

        downloadFile(res.bodyBytes, filename);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File ${ext.toUpperCase()} berhasil diunduh: $filename'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh berkas (Status: ${res.statusCode})'),
            backgroundColor: AppTheme.destructive,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat unduh: $e'),
            backgroundColor: AppTheme.destructive,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.cardBorder),
          ),
          title: Text(
            'Apresiasi Belajar $studentName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
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
                        color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(r['emoji']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text(
                            r['label']!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            ),
                          ),
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
                    'reaction': selectedReaction,
                    'note': noteController.text.trim(),
                  },
                );

                if (mounted) {
                  if (res.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apresiasi berhasil dikirimkan ke ananda! ❤️'),
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                    );
                    _loadReports(page: 1);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.message ?? 'Gagal mengirimkan apresiasi'),
                        backgroundColor: AppTheme.destructive,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kirim Apresiasi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = _selectedStudentId != null || _fromDate != null || _toDate != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Seluruh Laporan Belajar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.cardBorder, height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadReports(page: 1, isRefresh: true),
        color: AppTheme.primaryBlue,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Student Switcher Tabs / ChoiceChips
                    if (_children.isNotEmpty) ...[
                      const Text(
                        'Pilih Ananda',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Semua Ananda'),
                              selected: _selectedStudentId == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedStudentId = null);
                                  _loadReports(page: 1);
                                }
                              },
                              selectedColor: const Color(0xFFEFF6FF),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: _selectedStudentId == null ? FontWeight.bold : FontWeight.normal,
                                color: _selectedStudentId == null ? AppTheme.primaryBlue : AppTheme.textPrimary,
                              ),
                              side: BorderSide(
                                color: _selectedStudentId == null ? AppTheme.primaryBlue : AppTheme.cardBorder,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            ..._children.map((child) {
                              final isSelected = _selectedStudentId == child['id'];
                              return Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: ChoiceChip(
                                  label: Text(child['name'] ?? 'Ananda'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() => _selectedStudentId = child['id'] as int?);
                                      _loadReports(page: 1);
                                    }
                                  },
                                  selectedColor: const Color(0xFFEFF6FF),
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Filter Card: Date Range & Export
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Rentang Tanggal & Ekspor Rekap',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickFromDate,
                                    icon: const Icon(Icons.calendar_today, size: 14, color: AppTheme.primaryBlue),
                                    label: Text(
                                      _fromDate != null ? _formatDate(_fromDate!) : 'Dari Tanggal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _fromDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      side: const BorderSide(color: AppTheme.cardBorder),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickToDate,
                                    icon: const Icon(Icons.event, size: 14, color: AppTheme.primaryBlue),
                                    label: Text(
                                      _toDate != null ? _formatDate(_toDate!) : 'Sampai Tanggal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _toDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                      side: const BorderSide(color: AppTheme.cardBorder),
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
                                  icon: const Icon(Icons.clear, size: 14, color: AppTheme.textMuted),
                                  label: const Text('Reset Filter', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                ),
                              ),
                            ],
                            const Divider(height: 20, color: AppTheme.cardBorder),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isExporting ? null : () => _exportData(true),
                                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 15, color: Color(0xFFEF4444)),
                                    label: const Text('Cetak PDF', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
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
                                    icon: const Icon(Icons.table_chart_outlined, size: 15, color: AppTheme.primaryBlue),
                                    label: const Text('Export CSV', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                                      backgroundColor: const Color(0xFFEFF6FF),
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

                    // Results Counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Riwayat',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                        ),
                        Text(
                          '$_totalReports Laporan Ditemukan',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                ),
              )
            else if (_reports.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_outlined, size: 56, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada laporan belajar yang sesuai',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cobalah mengubah filter nama ananda atau rentang tanggal di atas.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        if (hasActiveFilter) ...[
                          const SizedBox(height: 14),
                          ElevatedButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reset Semua Filter'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _reports.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 2),
                          ),
                        );
                      }

                      final report = _reports[index];
                      final studentName = report['student']?['name'] ?? 'Ananda';
                      final myAppreciation = report['my_appreciation'];
                      final hasPhoto = report['photo_url'] != null;

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportDetailScreen(reportId: report['id']),
                              ),
                            ).then((_) => _loadReports(page: 1));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person, size: 14, color: AppTheme.primaryBlue),
                                          const SizedBox(width: 4),
                                          Text(
                                            studentName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (hasPhoto) ...[
                                          const Icon(Icons.photo_camera_outlined, size: 14, color: AppTheme.primaryBlue),
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
                                const SizedBox(height: 10),
                                Text(
                                  report['content'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppTheme.textPrimary),
                                ),
                                if ((report['ai_tags'] as List?)?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: (report['ai_tags'] as List).take(4).map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppTheme.cardBorder),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ],
                                const Divider(height: 22, color: AppTheme.cardBorder),
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
                                        icon: const Icon(Icons.favorite_border, color: AppTheme.secondaryTangerine, size: 15),
                                        label: const Text('Beri Apresiasi', style: TextStyle(color: AppTheme.secondaryTangerine, fontSize: 12, fontWeight: FontWeight.bold)),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          side: const BorderSide(color: AppTheme.secondaryTangerine),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportDetailScreen(reportId: report['id']),
                                          ),
                                        ).then((_) => _loadReports(page: 1));
                                      },
                                      icon: const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
                                      label: const Text('Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _reports.length + (_isLoadingMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
