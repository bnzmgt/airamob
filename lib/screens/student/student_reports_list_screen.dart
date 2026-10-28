import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../reports/report_detail_screen.dart';
import 'submit_report_screen.dart';

class StudentReportsListScreen extends StatefulWidget {
  const StudentReportsListScreen({super.key});

  @override
  State<StudentReportsListScreen> createState() => _StudentReportsListScreenState();
}

class _StudentReportsListScreenState extends State<StudentReportsListScreen> {
  final List<dynamic> _reports = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalReports = 0;
  String? _errorMessage;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadReports(page: 1);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _lastPage) {
        _loadReports(page: _currentPage + 1, isLoadMore: true);
      }
    }
  }

  Future<void> _loadReports({required int page, bool isLoadMore = false}) async {
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final url = '${ApiEndpoints.studentReports}?page=$page';
    final response = await ApiClient.get(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isLoadingMore = false;

      if (response.success && response.data != null) {
        final items = (response.data['items'] as List?) ?? [];
        final pagination = response.data['pagination'] as Map<String, dynamic>?;

        if (page == 1) {
          _reports.clear();
        }
        _reports.addAll(items);

        if (pagination != null) {
          _currentPage = pagination['current_page'] ?? 1;
          _lastPage = pagination['last_page'] ?? 1;
          _totalReports = pagination['total'] ?? _reports.length;
        }
      } else {
        _errorMessage = response.message ?? 'Gagal memuat riwayat laporan.';
      }
    });
  }

  Widget _buildSentimentBadge(String? sentiment) {
    Color dotColor;
    Color bg = const Color(0xFFF1F5F9);
    Color fg = AppTheme.textPrimary;
    Color borderColor = AppTheme.cardBorder;
    String label;

    switch (sentiment) {
      case 'positive':
        dotColor = const Color(0xFF10B981);
        label = 'Positif';
        break;
      case 'neutral':
        dotColor = AppTheme.primaryBlue;
        label = 'Stabil';
        break;
      case 'negative':
        dotColor = AppTheme.secondaryTangerine;
        bg = AppTheme.amberSurface;
        borderColor = const Color(0xFFFDE68A);
        fg = AppTheme.amberText;
        label = 'Evaluasi';
        break;
      default:
        dotColor = AppTheme.textMuted;
        label = 'Rutin';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Riwayat Belajar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: () => _loadReports(page: 1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
          );
          if (res == true) {
            _loadReports(page: 1);
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderBlueActive),
        ),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text('Lapor Hari Ini', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.destructive),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textPrimary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadReports(page: 1),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadReports(page: 1),
                  color: AppTheme.primaryBlue,
                  child: _reports.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.menu_book_outlined, size: 64, color: AppTheme.primaryBlue),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada riwayat laporan belajar.',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Mulai catat aktivitas belajarmu hari ini!',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _reports.length + (_isLoadingMore ? 1 : 0) + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Laporan Terarsip: $_totalReports',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                                    ),
                                    Text(
                                      'Halaman $_currentPage dari $_lastPage',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final reportIndex = index - 1;
                            if (reportIndex >= _reports.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 2),
                                ),
                              );
                            }

                            final report = _reports[reportIndex];
                            final hasPhoto = report['photo_url'] != null;
                            final appreciations = (report['appreciations'] as List?) ?? [];

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: AppTheme.cardBorder),
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportDetailScreen(
                                        reportId: report['id'],
                                        isParent: false,
                                      ),
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
                                          Row(
                                            children: [
                                              const Icon(Icons.event_note, size: 16, color: AppTheme.primaryBlue),
                                              const SizedBox(width: 6),
                                              Text(
                                                report['report_date'] ?? '-',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                              ),
                                            ],
                                          ),
                                          _buildSentimentBadge(report['sentiment_level']),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        report['content'] ?? '-',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              if (hasPhoto) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: AppTheme.cardBorder),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.photo_camera_outlined, size: 12, color: AppTheme.primaryBlue),
                                                      SizedBox(width: 4),
                                                      Text('Foto', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                              ],
                                              if (appreciations.isNotEmpty) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFDF2F8),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFFBCFE8)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(appreciations.first['emoji'] ?? '❤️', style: const TextStyle(fontSize: 13)),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${appreciations.length} Apresiasi',
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDB2777)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const Row(
                                            children: [
                                              Text('Detail', style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 2),
                                              Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
