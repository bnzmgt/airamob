import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../student/edit_report_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final int reportId;
  final bool isParent;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
    this.isParent = false,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _report;
  String? _errorMessage;

  // Appreciation state
  String _selectedReaction = 'barakallah';
  final TextEditingController _appreciationMsgController = TextEditingController();
  bool _isSendingAppreciation = false;

  final List<Map<String, String>> _reactionOptions = [
    {'type': 'barakallah', 'label': 'Barakallah', 'emoji': '🤲'},
    {'type': 'proud', 'label': 'Bangga', 'emoji': '❤️'},
    {'type': 'thumbs_up', 'label': 'Keren', 'emoji': '👍'},
    {'type': 'keep_spirit', 'label': 'Semangat', 'emoji': '💪'},
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  @override
  void dispose() {
    _appreciationMsgController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = widget.isParent
        ? '${ApiEndpoints.parentReports}/${widget.reportId}'
        : '${ApiEndpoints.studentReports}/${widget.reportId}';

    final response = await ApiClient.get(url);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _report = response.data;
        if (widget.isParent && _report?['my_appreciation'] != null) {
          _selectedReaction = _report!['my_appreciation']['reaction_type'] ?? 'barakallah';
          _appreciationMsgController.text = _report!['my_appreciation']['message'] ?? '';
        }
      } else {
        _errorMessage = response.message ?? 'Gagal memuat detail laporan.';
      }
    });
  }

  void _showImageZoom(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Gagal memuat foto dokumen.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppreciationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Apresiasi Laporan Anak',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih reaksi dan berikan kata penyemangat untuk ananda.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 20),

                  // Emoji Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _reactionOptions.map((opt) {
                      final isSelected = _selectedReaction == opt['type'];
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            _selectedReaction = opt['type']!;
                          });
                          setState(() {
                            _selectedReaction = opt['type']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(opt['emoji']!, style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 4),
                              Text(
                                opt['label']!,
                                style: TextStyle(
                                  fontSize: 12,
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
                  const SizedBox(height: 20),

                  // Message TextField
                  TextField(
                    controller: _appreciationMsgController,
                    maxLength: 250,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tuliskan pesan apresiasi singkat (opsional)...',
                      helperText: 'Pesan akan muncul di notifikasi dan portal siswa',
                      filled: true,
                      fillColor: Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isSendingAppreciation
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            setSheetState(() => _isSendingAppreciation = true);
                            setState(() => _isSendingAppreciation = true);

                            final url = '${ApiEndpoints.parentReports}/${widget.reportId}/appreciate';
                            final res = await ApiClient.post(url, {
                              'reaction_type': _selectedReaction,
                              'message': _appreciationMsgController.text.trim(),
                            });

                            if (!mounted) return;
                            setSheetState(() => _isSendingAppreciation = false);
                            setState(() => _isSendingAppreciation = false);

                            if (res.success) {
                              if (bottomSheetContext.mounted) {
                                Navigator.pop(bottomSheetContext);
                              }
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Apresiasi berhasil dikirim! Notifikasi diteruskan ke anak.'),
                                  backgroundColor: AppTheme.primaryBlue,
                                ),
                              );
                              _loadReport();
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(res.message ?? 'Gagal mengirim apresiasi.'),
                                  backgroundColor: AppTheme.destructive,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isSendingAppreciation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Kirim Apresiasi'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getSentimentColor(String? sentiment) {
    switch (sentiment) {
      case 'positive':
        return const Color(0xFF10B981);
      case 'neutral':
        return AppTheme.primaryBlue;
      case 'negative':
        return AppTheme.secondaryTangerine;
      default:
        return AppTheme.textMuted;
    }
  }

  String _getSentimentLabel(String? sentiment) {
    switch (sentiment) {
      case 'positive':
        return '● Kondisi Positif';
      case 'neutral':
        return '● Kondisi Stabil';
      case 'negative':
        return '● Perlu Perhatian';
      default:
        return '● Evaluasi Rutin';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan Belajar'),
        actions: [
          if (!widget.isParent && _report != null)
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: 'Edit Laporan',
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditReportScreen(report: _report!),
                  ),
                );
                if (res == true) {
                  _loadReport();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
        ],
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
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReport,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildReportContent(),
      bottomNavigationBar: widget.isParent && _report != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.cardBorder)),
              ),
              child: ElevatedButton.icon(
                onPressed: _showAppreciationBottomSheet,
                icon: const Icon(Icons.favorite_outline, color: Colors.white),
                label: Text(
                  _report!['my_appreciation'] != null ? 'Ubah Apresiasi' : 'Beri Apresiasi ke Anak',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryTangerine,
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildReportContent() {
    if (_report == null) return const SizedBox.shrink();

    final List<dynamic> aiTags = _report!['ai_tags'] ?? [];
    final List<dynamic> appreciations = _report!['all_appreciations'] ?? _report!['appreciations'] ?? [];
    final studentData = _report!['student'];
    final parentGuidance = _report!['ai_parent_guidance'];

    return RefreshIndicator(
      onRefresh: _loadReport,
      color: AppTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student & Date Header
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppTheme.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFFEFF6FF),
                          radius: 24,
                          child: Icon(Icons.school_outlined, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentData != null
                                    ? (studentData['name'] ?? 'Siswa')
                                    : 'Laporan Mandiri',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                studentData != null && studentData['class_name'] != null
                                    ? 'Kelas: ${studentData['class_name']} • Tanggal: ${_report!['report_date']}'
                                    : 'Tanggal: ${_report!['report_date']}',
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppTheme.cardBorder),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: Text(
                            _getSentimentLabel(_report!['sentiment_level']),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getSentimentColor(_report!['sentiment_level']),
                            ),
                          ),
                        ),
                        if (_report!['submitted_at'] != null)
                          Text(
                            'Terkirim: ${_report!['submitted_at'].toString().split('T').first}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Auto-Tags Chips
            if (aiTags.isNotEmpty) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 18, color: AppTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text(
                            'Topik / Tag Belajar Terdeteksi (AI):',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: aiTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Content / Reflection Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppTheme.cardBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book_outlined, size: 18, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Materi & Catatan Belajar:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _report!['content'] ?? '-',
                      style: const TextStyle(fontSize: 14.5, height: 1.5, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Happy Moment Card
            if (_report!['happy_moment'] != null && (_report!['happy_moment'] as String).isNotEmpty) ...[
              Card(
                elevation: 0,
                color: const Color(0xFFF0FDF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('😊', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Hal yang Membuat Senang:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _report!['happy_moment'],
                        style: const TextStyle(fontSize: 14, color: Color(0xFF166534), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Frustrated Moment Card
            if (_report!['frustrated_moment'] != null && (_report!['frustrated_moment'] as String).isNotEmpty) ...[
              Card(
                elevation: 0,
                color: AppTheme.amberSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFFDE68A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('😤', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Kendala Belajar / Hal yang Mengganjal:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.amberText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _report!['frustrated_moment'],
                        style: const TextStyle(fontSize: 14, color: AppTheme.amberText, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Photo Evidence Card with Zoom Lightbox
            if (ApiEndpoints.resolveImageUrl(_report!['photo_url'] as String?).isNotEmpty) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.photo_library_outlined, size: 18, color: AppTheme.primaryBlue),
                          SizedBox(width: 8),
                          Text('Dokumentasi Foto Belajar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showImageZoom(ApiEndpoints.resolveImageUrl(_report!['photo_url'] as String?)),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                ApiEndpoints.resolveImageUrl(_report!['photo_url'] as String?),
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    height: 220,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: AppTheme.primaryBlue),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 120,
                                    color: const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: Text('Foto tidak dapat dimuat.', style: TextStyle(color: AppTheme.textMuted)),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Sentuh untuk Zoom',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // AI Parent Guidance Card
            if (parentGuidance != null && parentGuidance.toString().isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: const Border(
                    left: BorderSide(color: AppTheme.primaryBlue, width: 3),
                    top: BorderSide(color: AppTheme.cardBorder, width: 1),
                    right: BorderSide(color: AppTheme.cardBorder, width: 1),
                    bottom: BorderSide(color: AppTheme.cardBorder, width: 1),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology_outlined, color: AppTheme.primaryBlue, size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '💡 Panduan Apresiasi Orang Tua (AI)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      parentGuidance.toString(),
                      style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Appreciations Section
            if (appreciations.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: const Color(0xFFFFF1F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('💖', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'Apresiasi Orang Tua Diterima:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF9F1239)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...appreciations.map((appr) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFE4E6)),
                            ),
                            child: Row(
                              children: [
                                Text(appr['emoji'] ?? '👍', style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${appr['label'] ?? 'Apresiasi'} dari ${appr['parent_name'] ?? 'Orang Tua'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                                      ),
                                      if (appr['message'] != null && appr['message'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '"${appr['message']}"',
                                          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
