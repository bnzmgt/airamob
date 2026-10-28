import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../safeguarding/track_incident_screen.dart';
import 'submit_incident_screen.dart';

class StudentIncidentHistoryScreen extends StatefulWidget {
  const StudentIncidentHistoryScreen({super.key});

  @override
  State<StudentIncidentHistoryScreen> createState() => _StudentIncidentHistoryScreenState();
}

class _StudentIncidentHistoryScreenState extends State<StudentIncidentHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _incidents = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiClient.get(ApiEndpoints.studentMyIncidents);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _incidents = (response.data['items'] as List?) ?? [];
      } else {
        _errorMessage = response.message ?? 'Gagal memuat riwayat aduan.';
      }
    });
  }

  Widget _buildStatusBadge(String? status, String? label) {
    Color dotColor;
    const bg = Color(0xFFF1F5F9);
    const fg = AppTheme.textPrimary;

    switch (status) {
      case 'submitted':
        dotColor = AppTheme.secondaryTangerine;
        label = label ?? 'Laporan Masuk';
        break;
      case 'investigating':
        dotColor = AppTheme.primaryBlue;
        label = label ?? 'Investigasi';
        break;
      case 'action_taken':
        dotColor = AppTheme.secondaryTangerine;
        label = label ?? 'Tindakan';
        break;
      case 'resolved':
        dotColor = const Color(0xFF10B981);
        label = label ?? 'Selesai';
        break;
      default:
        dotColor = AppTheme.textMuted;
        label = label ?? status ?? 'Diproses';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aduan LANTANG'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIncidents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitIncidentScreen()),
          );
          if (res == true) {
            _loadIncidents();
          }
        },
        backgroundColor: const Color(0xFFEF4444),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.shield, color: Colors.white, size: 18),
        label: const Text('Buat Aduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : RefreshIndicator(
              onRefresh: _loadIncidents,
              color: AppTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Banner about anonymous reports
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.amberSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Catatan Privasi & Laporan Anonim:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.amberText),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Hanya laporan bermode "Kerahasiaan Terjaga" yang terdata di sini. Untuk mengecek status aduan berstatus "Anonim Total", gunakan tombol Lacak Tiket.',
                                  style: TextStyle(fontSize: 12, height: 1.4, color: AppTheme.amberText),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const TrackIncidentScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.search, size: 14),
                                  label: const Text('Lacak Tiket Bebas (#SA)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.secondaryTangerine,
                                    side: const BorderSide(color: AppTheme.secondaryTangerine),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      )
                    else if (_incidents.isEmpty)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFEFF6FF),
                                child: Icon(Icons.verified_user_outlined, size: 32, color: AppTheme.primaryBlue),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum Ada Aduan Terdaftar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Kamu belum pernah membuat aduan bermode Kerahasiaan Terjaga. Jika kamu mengalami atau melihat perundungan, laporkan melalui LANTANG.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._incidents.map((item) {
                        final ticketCode = item['ticket_code'] ?? '';
                        final categoryLabel = item['category_label'] ?? item['category'] ?? '-';
                        final location = item['location'] ?? '-';
                        final incidentDate = item['incident_date'] ?? '-';
                        final status = item['status'];
                        final statusLabel = item['status_label'];
                        final resolutionNotes = item['resolution_notes'];

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
                                  builder: (_) => TrackIncidentScreen(initialTicketCode: ticketCode),
                                ),
                              );
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
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.cardBorder),
                                        ),
                                        child: Text(
                                          ticketCode,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      _buildStatusBadge(status, statusLabel),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Text(
                                          'Kategori: $categoryLabel',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tgl: $incidentDate',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item['description'] ?? '-',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textPrimary),
                                  ),
                                  if (resolutionNotes != null && resolutionNotes.toString().isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.canvasColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.cardBorder),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.assignment_outlined, size: 16, color: AppTheme.primaryBlue),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Catatan Guru BK / TPPK: $resolutionNotes',
                                              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Divider(height: 24, color: AppTheme.cardBorder),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lokasi: $location',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                      const Row(
                                        children: [
                                          Text(
                                            'Lihat Penanganan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryBlue,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
