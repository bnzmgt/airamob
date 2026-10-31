import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Modal inspeksi data API untuk Vibe Coder & Developer.
/// Menampilkan perbandingan langsung antara payload backend mentah (JSON)
/// dengan field-field yang telah berhasil dirender di UI mobile.
class DataInspectorSheet extends StatelessWidget {
  final String screenName;
  final String endpoint;
  final Map<String, dynamic> payload;
  final List<String> renderedKeys;

  const DataInspectorSheet({
    super.key,
    required this.screenName,
    required this.endpoint,
    required this.payload,
    required this.renderedKeys,
  });

  static void show(
    BuildContext context, {
    required String screenName,
    required String endpoint,
    required Map<String, dynamic> payload,
    required List<String> renderedKeys,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DataInspectorSheet(
        screenName: screenName,
        endpoint: endpoint,
        payload: payload,
        renderedKeys: renderedKeys,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allKeys = payload.keys.toList();
    final renderedCount = allKeys.where((k) => renderedKeys.contains(k)).length;
    final unrenderedKeys = allKeys.where((k) => !renderedKeys.contains(k)).toList();
    final parityScore = allKeys.isEmpty ? 100 : ((renderedCount / allKeys.length) * 100).round();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.troubleshoot, color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API Inspector — $screenName',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        endpoint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Summary Score Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: parityScore == 100 ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: parityScore == 100 ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: parityScore / 100,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          parityScore == 100 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                        strokeWidth: 6,
                      ),
                    ),
                    Text(
                      '$parityScore%',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parityScore == 100 ? '✅ 100% Selaras dengan UI' : '⚠️ $renderedCount dari ${allKeys.length} Field Dirender',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: parityScore == 100 ? const Color(0xFF065F46) : const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unrenderedKeys.isEmpty
                            ? 'Semua data dari backend memiliki representasi visual di layar ini.'
                            : 'Field yang belum dirender: ${unrenderedKeys.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: parityScore == 100 ? const Color(0xFF047857) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Tabs (Fields Checklist vs Raw JSON)
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: AppTheme.textMuted,
                    indicatorColor: AppTheme.primaryBlue,
                    tabs: [
                      Tab(icon: Icon(Icons.checklist, size: 18), text: 'Field Breakdown'),
                      Tab(icon: Icon(Icons.code, size: 18), text: 'Raw JSON Payload'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Breakdown Tab
                        ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: allKeys.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final key = allKeys[index];
                            final val = payload[key];
                            final isRendered = renderedKeys.contains(key);

                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isRendered ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isRendered ? Icons.check : Icons.warning_amber_rounded,
                                  color: isRendered ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                  size: 16,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    key,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isRendered ? const Color(0xFFDEF7EC) : const Color(0xFFFEF08A),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isRendered ? 'DIRENDER' : 'BELUM DIRENDER',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isRendered ? const Color(0xFF03543F) : const Color(0xFF713F12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  val == null ? 'null' : val.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ),
                            );
                          },
                        ),

                        // Raw JSON Tab
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Payload Mentah dari Backend:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  TextButton.icon(
                                    icon: const Icon(Icons.copy, size: 14),
                                    label: const Text('Salin JSON', style: TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      final raw = const JsonEncoder.withIndent('  ').convert(payload);
                                      Clipboard.setData(ClipboardData(text: raw));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('JSON disalin ke clipboard!')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SingleChildScrollView(
                                    child: SelectableText(
                                      const JsonEncoder.withIndent('  ').convert(payload),
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
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
        ],
      ),
    );
  }
}
