import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mentor_report.dart';
import '../../services/mentor_service.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import 'attach_student_screen.dart';
import 'mentor_report_detail_screen.dart';
import 'submit_mentor_report_screen.dart';

class MentorHomeScreen extends StatefulWidget {
  const MentorHomeScreen({super.key});

  @override
  State<MentorHomeScreen> createState() => _MentorHomeScreenState();
}

class _MentorHomeScreenState extends State<MentorHomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  String _mentorName = 'Mentor';
  String? _specialization;
  String? _avatarUrl;
  String _todayDate = '';
  int _todaySessionsCount = 0;

  List<MentorStudentSummary> _activeStudents = [];
  List<MentorReport> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await MentorService.getDashboard();

    if (!mounted) return;

    if (response.success && response.data is Map) {
      final data = response.data as Map<String, dynamic>;
      final mentorData = data['mentor'] as Map<String, dynamic>? ?? {};

      final studentsJson = data['active_students'] as List? ?? [];
      final reportsJson = data['recent_reports'] as List? ?? [];

      setState(() {
        _isLoading = false;
        _mentorName = mentorData['name'] ?? 'Mentor';
        _specialization = mentorData['specialization'];
        _avatarUrl = mentorData['avatar_url'];
        _todayDate = data['today_date'] ?? '';
        _todaySessionsCount = data['today_sessions_count'] ?? 0;

        _activeStudents = studentsJson
            .map((s) => MentorStudentSummary.fromJson(s as Map<String, dynamic>))
            .toList();

        _recentReports = reportsJson
            .map((r) => MentorReport.fromJson(r as Map<String, dynamic>))
            .toList();
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Gagal memuat dashboard mentor.';
      });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Mentor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
  }

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (mounted) {
      _loadDashboard();
    }
  }

  Future<void> _confirmDetachStudent(MentorStudentSummary student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lepaskan Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin melepaskan ${student.name} dari daftar siswa bimbingan Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lepaskan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await MentorService.detachStudent(student.id);
      if (!mounted) return;
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.name} berhasil dilepaskan dari bimbingan.'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        _loadDashboard();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal melepaskan siswa.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7E22CE),
          onRefresh: _loadDashboard,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF7E22CE)))
              : _errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.errorRed),
                            const SizedBox(height: 12),
                            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.errorRed)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDashboard,
                              child: const Text('Muat Ulang'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Profile & Logout
                          _buildHeaderCard(),

                          const SizedBox(height: 20),

                          // Quick Stats Cards
                          _buildStatsRow(),

                          const SizedBox(height: 24),

                          // Assigned Students Section
                          _buildStudentsSection(),

                          const SizedBox(height: 24),

                          // Recent Tutoring Sessions Section
                          _buildRecentReportsSection(),

                          const SizedBox(height: 80), // Padding for FAB
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7E22CE),
        foregroundColor: Colors.white,
        elevation: 3,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmitMentorReportScreen(),
            ),
          );
          if (result == true) {
            _loadDashboard();
          }
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text(
          'Tulis Laporan Les',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B21A8), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E22CE).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Portal Mentor Les Privat',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                tooltip: 'Profil Saya',
                onPressed: _openProfile,
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                tooltip: 'Keluar',
                onPressed: _logout,
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: _openProfile,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? Image.network(
                          ApiEndpoints.resolveImageUrl(_avatarUrl),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                        )
                      : _buildAvatarPlaceholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $_mentorName! 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _specialization != null && _specialization!.isNotEmpty
                            ? _specialization!
                            : 'Ketuk untuk melengkapi profil mentor.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.people_alt_outlined,
            title: 'Siswa Bimbingan',
            value: '${_activeStudents.length}',
            color: const Color(0xFF7E22CE),
            bg: const Color(0xFFF3E8FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.event_available_outlined,
            title: _todayDate.isNotEmpty ? 'Sesi Hari Ini ($_todayDate)' : 'Sesi Hari Ini',
            value: '$_todaySessionsCount',
            color: const Color(0xFF059669),
            bg: const Color(0xFFECFDF5),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Siswa Bimbingan Aktif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                  SizedBox(height: 2),
                  Text('Pilih siswa untuk langsung mengisi laporan', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E22CE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                  elevation: 0,
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AttachStudentScreen()),
                  );
                  if (result == true) {
                    _loadDashboard();
                  }
                },
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Tambah Siswa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_activeStudents.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderDefault),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_search_outlined, size: 40, color: Color(0xFF7E22CE)),
                  const SizedBox(height: 10),
                  const Text(
                    'Belum ada siswa yang Anda bimbing',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hubungkan siswa les privat Anda agar bisa langsung membuat laporan sesi les.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E22CE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AttachStudentScreen()),
                      );
                      if (result == true) {
                        _loadDashboard();
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+ Hubungkan Siswa Pertama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeStudents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = _activeStudents[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderDefault),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                            ? Image.network(
                                ApiEndpoints.resolveImageUrl(student.avatarUrl),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildStudentAvatar(student.name),
                              )
                            : _buildStudentAvatar(student.name),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kode: ${student.studentCode ?? '-'} • ${student.className ?? 'Kelas -'}',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            if (student.subjectName != null && student.subjectName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '📚 ${student.subjectName}',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick Action Buttons
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7E22CE),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: Size.zero,
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubmitMentorReportScreen(
                                    initialStudentId: student.id,
                                    initialStudentName: student.name,
                                    initialSubject: student.subjectName,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadDashboard();
                              }
                            },
                            child: const Text('Input Sesi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _confirmDetachStudent(student),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.delete_outline, size: 16, color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStudentAvatar(String name) {
    final initials = name.trim().isNotEmpty
        ? (name.trim().length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase())
        : 'S';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
      ),
    );
  }

  Widget _buildRecentReportsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Riwayat Bimbingan Terkini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          const Text('Laporan sesi les privat yang baru saja selesai diisi', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 14),

          if (_recentReports.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: const Text('Belum ada riwayat laporan sesi les.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final report = _recentReports[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MentorReportDetailScreen(
                          reportId: report.id,
                          initialReport: report,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.studentName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: report.understandingBgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: report.understandingColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                report.understandingLabel,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: report.understandingColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.book_outlined, size: 14, color: Color(0xFF7E22CE)),
                            const SizedBox(width: 4),
                            Text(
                              report.subject,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
                            ),
                            const Spacer(),
                            Text(
                              report.sessionDateFormatted ?? report.sessionDate,
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          report.materialTaught,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
