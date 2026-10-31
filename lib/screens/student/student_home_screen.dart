import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../auth/login_screen.dart';
import '../reports/report_detail_screen.dart';
import '../safeguarding/track_incident_screen.dart';
import 'submit_incident_screen.dart';
import 'submit_report_screen.dart';
import 'edit_report_screen.dart';
import 'student_incident_history_screen.dart';
import 'student_reports_list_screen.dart';
import '../../services/notification_service.dart';

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
    await NotificationService.unregisterToken();
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
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            : RefreshIndicator(
                onRefresh: _loadDashboard,
                color: AppTheme.primaryBlue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Modern Minimalist Top Bar (Replacing bulky AppBar)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Assalamu’alaikum,',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _dashboardData?['today_date'] ?? 'Portal Siswa',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ProfileScreen()),
                              ).then((_) => _loadDashboard());
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryBlue, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFEFF6FF),
                                child: Icon(Icons.person, color: AppTheme.primaryBlue, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
                            tooltip: 'Keluar',
                            onPressed: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Today's Report Status Card
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Laporan Belajar Hari Ini',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSubmittedToday ? AppTheme.surfaceTint : AppTheme.amberSurface,
                                    borderRadius: BorderRadius.circular(9999),
                                    border: Border.all(
                                      color: isSubmittedToday ? AppTheme.borderDefault : AppTheme.borderAmber,
                                    ),
                                  ),
                                  child: Text(
                                    isSubmittedToday ? '● Sudah Kirim' : '● Belum Lapor',
                                    style: TextStyle(
                                      color: isSubmittedToday ? AppTheme.success : AppTheme.secondaryTangerine,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.2,
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
                                style: const TextStyle(color: AppTheme.textPrimary, height: 1.45, fontSize: 13),
                              ),
                              if ((todayReport['appreciations'] as List?)?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceTint,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderDefault),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        (todayReport['appreciations'][0]['emoji'] ?? '❤️') as String,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Apresiasi: "${todayReport['appreciations'][0]['message'] ?? 'Semangat belajarnya!'}"',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportDetailScreen(
                                              reportId: todayReport['id'],
                                              isParent: false,
                                            ),
                                          ),
                                        ).then((_) => _loadDashboard());
                                      },
                                      icon: const Icon(Icons.visibility_outlined, size: 16),
                                      label: const Text('Detail', style: TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditReportScreen(report: todayReport),
                                          ),
                                        );
                                        if (res == true) {
                                          _loadDashboard();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue,
                                      ),
                                      icon: const Icon(Icons.edit_note, size: 16),
                                      label: const Text('Edit Laporan', style: TextStyle(fontSize: 13)),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              const Text(
                                'Kamu belum mengisi laporan belajar hari ini. Yuk bagikan apa yang sudah kamu pelajari!',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.secondaryTangerine,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.edit_note),
                                label: const Text('Isi Laporan Hari Ini'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LANTANG Safeguarding Quick Card (with 3px left accent border)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderDefault),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: AppTheme.primaryBlue, width: 3),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: AppTheme.primaryBlue, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Layanan Perlindungan LANTANG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Mengalami atau melihat perundungan? Ceritakan secara aman, rahasia, atau anonim total.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                              ),
                              const SizedBox(height: 14),
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
                                        backgroundColor: AppTheme.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      icon: const Icon(Icons.add_moderator, size: 16),
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
                                      foregroundColor: AppTheme.primaryBlue,
                                      side: const BorderSide(color: AppTheme.borderDefault),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    ),
                                    child: const Text('Lacak Tiket', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const StudentIncidentHistoryScreen()),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.history, size: 14, color: AppTheme.primaryBlue),
                                      SizedBox(width: 6),
                                      Text(
                                        'Lihat Riwayat Kasus Saya ›',
                                        style: TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent History Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Belajar Terakhir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const StudentReportsListScreen()),
                            ).then((_) => _loadDashboard());
                          },
                          child: const Text(
                            'Lihat Semua ›',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
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
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.book_outlined, color: AppTheme.primaryBlue, size: 20),
                              ),
                              title: Text(
                                report['content'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentReportsListScreen()),
            ).then((_) => _loadDashboard());
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentIncidentHistoryScreen()),
            ).then((_) => _loadDashboard());
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ).then((_) => _loadDashboard());
          }
        },
        items: const [
          FloatingNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '',
          ),
          FloatingNavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book,
            label: 'Laporan',
          ),
          FloatingNavItem(
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield,
            label: 'LANTANG',
          ),
          FloatingNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
