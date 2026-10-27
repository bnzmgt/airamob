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
    Color bg;
    Color fg;

    switch (status) {
      case 'submitted':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        break;
      case 'investigating':
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF3730A3);
        break;
      case 'action_taken':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFF9A3412);
        break;
      case 'resolved':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF065F46);
        break;
      default:
        bg = Colors.grey.shade100;
        fg = AppTheme.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label ?? status ?? 'Diproses',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
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
        backgroundColor: const Color(0xFFE11D48),
        icon: const Icon(Icons.shield, color: Colors.white),
        label: const Text('Buat Aduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadIncidents,
              color: AppTheme.primaryGreen,
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
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
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
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Hanya laporan bermode "Kerahasiaan Terjaga" yang terdata di sini. Untuk mengecek status aduan berstatus "Anonim Total", gunakan tombol Lacak Tiket.',
                                  style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF78350F)),
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const TrackIncidentScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.search, size: 14),
                                  label: const Text('Lacak Tiket Bebas (#SA)', style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF92400E),
                                    side: const BorderSide(color: Color(0xFFFCD34D)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFFFE4E6),
                                child: Icon(Icons.verified_user_outlined, size: 32, color: Color(0xFFE11D48)),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum Ada Aduan Terdaftar',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
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
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Text(
                                          ticketCode,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppTheme.textDark,
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Kategori: $categoryLabel',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tgl: $incidentDate',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['description'] ?? '-',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textDark),
                                  ),
                                  if (resolutionNotes != null && resolutionNotes.toString().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFBBF7D0)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('📋', style: TextStyle(fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Catatan Guru BK: $resolutionNotes',
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  const Divider(height: 20),
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
                                              color: Color(0xFFE11D48),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, size: 14, color: Color(0xFFE11D48)),
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
