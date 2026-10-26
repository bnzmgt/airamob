import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../reports/report_detail_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  bool _isLoading = true;
  String _parentName = 'Orang Tua';
  List<dynamic> _children = [];
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await SecureStorage.getUserName();
    final dashRes = await ApiClient.get(ApiEndpoints.parentDashboard);
    final reportRes = await ApiClient.get(ApiEndpoints.parentReports);

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

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card
                    Card(
                      color: AppTheme.accentGreen,
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
                    const SizedBox(height: 20),

                    // Connected children section
                    const Text('Ananda yang Terhubung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ..._children.map((child) {
                      final isSubmitted = child['is_submitted_today'] == true;
                      final latestReport = child['latest_report'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: latestReport != null
                              ? () => _navigateToReportDetail(latestReport['id'])
                              : null,
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
                                    if (latestReport != null) ...[
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Lihat Laporan ›',
                                        style: TextStyle(fontSize: 11, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Reports feed section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Feed Laporan Belajar Anak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${_reports.length} Laporan', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_reports.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textMuted),
                                SizedBox(height: 8),
                                Text('Belum ada laporan belajar masuk.', style: TextStyle(color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._reports.map((report) {
                        final studentName = report['student']?['name'] ?? 'Ananda';
                        final myAppreciation = report['my_appreciation'];
                        final hasPhoto = report['photo_url'] != null;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
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
                                    style: const TextStyle(fontSize: 14, height: 1.4),
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
                                  const Divider(height: 24),
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
                                                Text(myAppreciation['emoji'] ?? '❤️', style: const TextStyle(fontSize: 16)),
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
                                          icon: const Icon(Icons.favorite_border, color: Colors.pink, size: 16),
                                          label: const Text('Beri Apresiasi', style: TextStyle(color: Colors.pink, fontSize: 13)),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            side: const BorderSide(color: Colors.pink),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      TextButton.icon(
                                        onPressed: () => _navigateToReportDetail(report['id']),
                                        icon: const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryGreen),
                                        label: const Text(
                                          'Detail & AI',
                                          style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13),
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
