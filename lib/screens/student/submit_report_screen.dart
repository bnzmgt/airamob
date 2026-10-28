import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _contentController = TextEditingController();
  final _happyController = TextEditingController();
  final _frustratedController = TextEditingController();
  XFile? _selectedPhoto;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickPhoto() async {
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
                'Pilih Sumber Foto Bukti Belajar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryBlue),
              title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 75,
                );
                if (picked != null) {
                  setState(() => _selectedPhoto = picked);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryBlue),
              title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 75,
                );
                if (picked != null) {
                  setState(() => _selectedPhoto = picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final content = _contentController.text.trim();
    if (content.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi laporan belajar minimal 5 karakter.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fields = <String, String>{
      'content': content,
      if (_happyController.text.trim().isNotEmpty) 'happy_moment': _happyController.text.trim(),
      if (_frustratedController.text.trim().isNotEmpty) 'frustrated_moment': _frustratedController.text.trim(),
    };

    final response = await ApiClient.postMultipart(
      ApiEndpoints.studentReports,
      fields,
      file: _selectedPhoto,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alhamdulillah, laporan belajar hari ini berhasil dikirim!'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal mengirim laporan.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isi Laporan Belajar Hari Ini'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Catatan Materi Belajar *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Tuliskan topik, materi, atau tugas yang dipelajari hari ini...',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hal yang Membuat Senang 😊 (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _happyController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Contoh: Berhasil paham rumus matematika, dipuji ustadz/guru...',
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Kendala / Hal yang Membuat Jengkel 😤',
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
                hintText: 'Contoh: Masih bingung di soal nomor 5, mengantuk di kelas...',
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Foto Bukti Belajar / Catatan 📷 (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            if (_selectedPhoto != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDefault),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: AppTheme.primaryBlue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedPhoto!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.destructive),
                      onPressed: () => setState(() => _selectedPhoto = null),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        'Lampirkan Foto Catatan / Tugas',
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
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Kirim Laporan Belajar'),
            ),
          ],
        ),
      ),
    );
  }
}
