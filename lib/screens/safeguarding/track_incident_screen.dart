import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';

class TrackIncidentScreen extends StatefulWidget {
  final String? initialTicketCode;

  const TrackIncidentScreen({super.key, this.initialTicketCode});

  @override
  State<TrackIncidentScreen> createState() => _TrackIncidentScreenState();
}

class _TrackIncidentScreenState extends State<TrackIncidentScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _ticketData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialTicketCode != null && widget.initialTicketCode!.isNotEmpty) {
      _codeController.text = widget.initialTicketCode!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trackTicket();
      });
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _trackTicket() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ticketData = null;
    });

    final formattedCode = code.startsWith('#') ? code.substring(1) : code;
    final response = await ApiClient.get(
      ApiEndpoints.trackSafeguarding(formattedCode),
      withAuth: false,
    );

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _ticketData = response.data;
      } else {
        _errorMessage = response.message ?? 'Tiket tidak ditemukan.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Kasus LANTANG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cek Progres Tindak Lanjut',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Masukkan kode tiket rahasia (contoh: #SA-1234) untuk memantau perkembangan tanpa perlu login.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: '#SA-XXXX',
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _trackTicket,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Lacak'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_ticketData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _ticketData!['ticket_code'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _ticketData!['status_label'] ?? '',
                              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Tahapan Penanganan:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      _buildStepper(_ticketData!['current_step_index'] ?? 0),
                      const Divider(height: 24),
                      const Text(
                        'Catatan dari Tim Guru BK / TPPK:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          _ticketData!['resolution_notes'] ?? 'Laporan baru masuk, tim sedang memverifikasi kronologi.',
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepper(int currentStep) {
    final steps = ['Laporan Masuk', 'Investigasi', 'Tindakan', 'Selesai'];

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isCompleted ? AppTheme.primaryGreen : Colors.grey.shade300,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? AppTheme.primaryGreen : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
