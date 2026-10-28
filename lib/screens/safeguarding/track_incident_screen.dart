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
                    const Text(
                      'Cek Progres Tindak Lanjut',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
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
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1.0,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: '#SA-XXXX',
                              prefixIcon: Icon(Icons.confirmation_number_outlined, color: AppTheme.primaryBlue),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _trackTicket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
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
                elevation: 0,
                color: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_ticketData != null) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppTheme.cardBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                              _ticketData!['ticket_code'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.primaryBlue,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Text(
                              _ticketData!['status_label'] ?? '',
                              style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: AppTheme.cardBorder),
                      const Text(
                        'Tahapan Penanganan:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildStepper(
                        _ticketData!['current_step_index'] ?? 0,
                        isResolved: _ticketData!['status'] == 'resolved',
                      ),
                      const Divider(height: 28, color: AppTheme.cardBorder),
                      const Text(
                        'Catatan dari Tim Guru BK / TPPK:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.canvasColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Text(
                          _ticketData!['resolution_notes'] ?? 'Laporan baru masuk, tim sedang memverifikasi kronologi.',
                          style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textPrimary),
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

  Widget _buildStepper(int currentStep, {bool isResolved = false}) {
    final steps = ['Laporan Masuk', 'Investigasi', 'Tindakan', 'Selesai'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isCompleted = index < currentStep || (isResolved && index <= currentStep);
        final isActive = index == currentStep && !isResolved;

        Color circleBg;
        Widget iconOrNum;

        if (isCompleted) {
          circleBg = isResolved && index == steps.length - 1 ? const Color(0xFF10B981) : AppTheme.primaryBlue;
          iconOrNum = const Icon(Icons.check, size: 14, color: Colors.white);
        } else if (isActive) {
          circleBg = AppTheme.secondaryTangerine;
          iconOrNum = Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          );
        } else {
          circleBg = const Color(0xFFE2E8F0);
          iconOrNum = Text(
            '${index + 1}',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
          );
        }

        Color textColor;
        FontWeight fontWeight;

        if (isActive) {
          textColor = AppTheme.secondaryTangerine;
          fontWeight = FontWeight.bold;
        } else if (isCompleted) {
          textColor = AppTheme.primaryBlue;
          fontWeight = FontWeight.bold;
        } else {
          textColor = AppTheme.textMuted;
          fontWeight = FontWeight.normal;
        }

        return Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left connector line
                    if (index > 0)
                      Positioned(
                        left: 0,
                        right: 14,
                        child: Container(
                          height: 2,
                          color: (index <= currentStep) ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                        ),
                      ),
                    // Right connector line
                    if (index < steps.length - 1)
                      Positioned(
                        left: 14,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: (index < currentStep) ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                        ),
                      ),
                    // Step circle
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: iconOrNum,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
