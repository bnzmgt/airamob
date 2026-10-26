import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../reports/report_detail_screen.dart';
import '../safeguarding/track_incident_screen.dart';
import 'submit_incident_screen.dart';
import 'submit_report_screen.dart';
import '../profile/profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _isLoading = true;
  String _studentName = 'Siswa';
  Map<String, dynamic>? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final name = await SecureStorage.getUserName();
    final response = await ApiClient.get(ApiEndpoints.studentDashboard);

    setState(() {
      _isLoading = false;
      if (name != null) _studentName = name;
      if (response.success && response.data != null) {
        _dashboardData = response.data;
      }
    });
  }

  Future<void> _logout() async {
    await ApiClient.post(ApiEndpoints.logout, {});
    await SecureStorage.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmittedToday = _dashboardData?['is_submitted_today'] ?? false;
    final todayReport = _dashboardData?['today_report'];
    final recentReports = (_dashboardData?['recent_reports'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AiNARA Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadDashboard());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Greeting Card
                    Card(
                      color: AppTheme.accentGreen,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          ).then((_) => _loadDashboard());
                        },
                        child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryGreen,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Assalamu’alaikum,',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  ),
                                  Text(
                                    _studentName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Today's Report Status Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Laporan Belajar Hari Ini',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSubmittedToday ? AppTheme.accentGreen : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isSubmittedToday ? '✓ Sudah Kirim' : '⚠ Belum Lapor',
                                    style: TextStyle(
                                      color: isSubmittedToday ? AppTheme.primaryGreen : Colors.amber.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (isSubmittedToday && todayReport != null) ...[
                              Text(
                                todayReport['content'] ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppTheme.textDark, height: 1.4),
                              ),
                              if ((todayReport['appreciations'] as List?)?.isNotEmpty ?? false) ...[
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Text(
                                      (todayReport['appreciations'][0]['emoji'] ?? '❤️') as String,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Apresiasi Ortu: "${todayReport['appreciations'][0]['message'] ?? 'Semangat belajarnya!'}"',
                                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReportDetailScreen(
                                        reportId: todayReport['id'],
                                        isParent: false,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, size: 16),
                                label: const Text('Buka Detail Laporan Hari Ini', style: TextStyle(fontSize: 13)),
                              ),
                            ] else ...[
                              const Text(
                                'Kamu belum mengisi laporan belajar hari ini. Yuk bagikan apa yang sudah kamu pelajari!',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
                                  );
                                  if (result == true) {
                                    _loadDashboard();
                                  }
                                },
                                icon: const Icon(Icons.edit_note),
                                label: const Text('Isi Laporan Hari Ini'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LANTANG Safeguarding Card
                    Card(
                      color: const Color(0xFFEFF6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.shield_outlined, color: Color(0xFF1D4ED8)),
                                SizedBox(width: 8),
                                Text(
                                  'Layanan Perlindungan LANTANG',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Mengalami atau melihat perundungan? Ceritakan secara aman, rahasia, atau anonim total.',
                              style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SubmitIncidentScreen()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                    icon: const Icon(Icons.add_moderator, size: 18),
                                    label: const Text('Buat Pengaduan', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const TrackIncidentScreen()),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1D4ED8),
                                    side: const BorderSide(color: Color(0xFF93C5FD)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  child: const Text('Lacak Tiket', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent History Header
                    const Text(
                      'Riwayat Belajar Terakhir',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (recentReports.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Belum ada riwayat laporan belajar.',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          ),
                        ),
                      )
                    else
                      ...recentReports.map((report) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReportDetailScreen(
                                      reportId: report['id'],
                                      isParent: false,
                                    ),
                                  ),
                                );
                              },
                              leading: const CircleAvatar(
                                backgroundColor: AppTheme.accentGreen,
                                child: Icon(Icons.book, color: AppTheme.primaryGreen),
                              ),
                              title: Text(
                                report['content'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                report['report_date'] ?? '',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if ((report['appreciations'] as List?)?.isNotEmpty ?? false)
                                    Text(
                                      report['appreciations'][0]['emoji'] ?? '❤️',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}
