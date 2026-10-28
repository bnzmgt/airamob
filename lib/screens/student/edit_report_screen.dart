import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';

class EditReportScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const EditReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late final TextEditingController _contentController;
  late final TextEditingController _happyController;
  late final TextEditingController _frustratedController;
  XFile? _selectedPhoto;
  bool _removeExistingPhoto = false;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.report['content'] ?? '');
    _happyController = TextEditingController(text: widget.report['happy_moment'] ?? '');
    _frustratedController = TextEditingController(text: widget.report['frustrated_moment'] ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _happyController.dispose();
    _frustratedController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );

    if (picked != null) {
      setState(() {
        _selectedPhoto = picked;
        _removeExistingPhoto = false;
      });
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Sumber Foto Belajar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              title: const Text('Ambil Foto dari Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateReport() async {
    final content = _contentController.text.trim();
    if (content.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi laporan belajar minimal 5 karakter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fields = <String, String>{
      'content': content,
      'happy_moment': _happyController.text.trim(),
      'frustrated_moment': _frustratedController.text.trim(),
      if (_removeExistingPhoto) 'remove_photo': '1',
    };

    final reportId = widget.report['id'];
    final url = ApiEndpoints.studentReportUpdate(reportId);

    final response = await ApiClient.postMultipart(
      url,
      fields,
      file: _selectedPhoto,
      fileField: 'photo',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan belajar berhasil diperbarui!'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal memperbarui laporan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawPhotoUrl = widget.report['photo_url'] as String?;
    final existingPhotoUrl = ApiEndpoints.resolveImageUrl(rawPhotoUrl);
    final reportDate = widget.report['report_date'] ?? 'Hari ini';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Laporan Belajar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderDefault),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'Tanggal Laporan: $reportDate',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Content Field
            const Text(
              'Apa yang kamu pelajari hari ini? *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tuliskan mata pelajaran, topik materi, atau hafalan yang kamu selesaikan...',
              ),
            ),
            const SizedBox(height: 20),

            // Photo Evidence Section
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.photo_camera_outlined, color: AppTheme.primaryBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Foto Bukti Belajar (Opsional)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Existing photo preview
                    if (existingPhotoUrl.isNotEmpty && !_removeExistingPhoto && _selectedPhoto == null) ...[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            existingPhotoUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showImagePickerSheet,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Ganti Foto', style: TextStyle(fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(color: AppTheme.borderDefault),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _removeExistingPhoto = true),
                              icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.destructive),
                              label: const Text('Hapus Foto', style: TextStyle(color: AppTheme.destructive, fontSize: 13)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.destructive),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_selectedPhoto != null) ...[
                      // New selected photo preview
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedPhoto!.path,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedPhoto!.path),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Foto baru siap diunggah',
                              style: TextStyle(color: AppTheme.success, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _selectedPhoto = null),
                            child: const Text('Batal Ganti', style: TextStyle(color: AppTheme.destructive, fontSize: 12)),
                          ),
                        ],
                      ),
                    ] else ...[
                      // No photo state or photo marked removed
                      if (_removeExistingPhoto)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: AppTheme.destructive),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text('Foto lama akan dihapus saat disimpan.', style: TextStyle(color: AppTheme.destructive, fontSize: 12)),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _removeExistingPhoto = false),
                                child: const Text('Batal Hapus', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      InkWell(
                        onTap: _showImagePickerSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.5), width: 1.2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryBlue, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Unggah Foto Bukti Belajar',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
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
            ),
            const SizedBox(height: 20),

            // Emotional Reflection: Happy Moment
            const Text(
              '😊 Apa yang membuatmu senang hari ini?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _happyController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Berhasil paham rumus trigonometri, dapat nilai 100...',
              ),
            ),
            const SizedBox(height: 20),

            // Emotional Reflection: Frustrated Moment
            Row(
              children: [
                const Text(
                  '😤 Apa kendala atau hal yang membuat jengkel?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryTangerine,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '(Opsional)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _frustratedController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Masih bingung di soal nomor 5, internet lambat...',
              ),
            ),
            const SizedBox(height: 30),

            // Save Changes Button
            ElevatedButton(
              onPressed: _isLoading ? null : _updateReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Simpan Perubahan Laporan'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
