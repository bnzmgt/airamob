import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../safeguarding/track_incident_screen.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  bool _isAnonymous = false;
  String _victimType = 'self';
  final _victimNameController = TextEditingController();
  String _category = 'verbal';
  String _location = 'Kantin Sekolah';
  DateTime _incidentDate = DateTime.now();
  final _timeController = TextEditingController(text: 'Jam istirahat');
  bool _perpetratorKnown = false;
  final _perpetratorDescController = TextEditingController();
  final _descriptionController = TextEditingController();

  XFile? _selectedPhoto;
  final _picker = ImagePicker();
  bool _isLoading = false;

  final List<String> _locationPresets = [
    'Kantin Sekolah',
    'Ruang Kelas',
    'Lapangan Olahraga',
    'Lorong / Koridor',
    'Toilet Siswa',
    'Perpustakaan',
    'Media Sosial / Grup Chat',
    'Lainnya',
  ];

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
                'Pilih Sumber Foto Bukti Kejadian',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryGreen),
              title: const Text('Ambil dari Kamera'),
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
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
              title: const Text('Pilih dari Galeri'),
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

  Future<void> _submitIncident() async {
    final desc = _descriptionController.text.trim();
    if (desc.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kronologi kejadian wajib diisi minimal 10 karakter.')),
      );
      return;
    }

    if (_victimType == 'other' && _victimNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama teman yang menjadi korban wajib diisi.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fields = <String, String>{
      'is_anonymous': _isAnonymous ? '1' : '0',
      'victim_type': _victimType,
      if (_victimType == 'other') 'victim_name': _victimNameController.text.trim(),
      'category': _category,
      'location': _location,
      'incident_date': _incidentDate.toIso8601String().split('T')[0],
      'incident_time_approx': _timeController.text.trim(),
      'perpetrator_known': _perpetratorKnown ? '1' : '0',
      if (_perpetratorKnown) 'perpetrator_description': _perpetratorDescController.text.trim(),
      'description': desc,
    };

    final response = await ApiClient.postMultipart(
      ApiEndpoints.studentSafeguarding,
      fields,
      file: _selectedPhoto,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      final ticketCode = response.data['ticket_code'] as String;
      _showSuccessDialog(ticketCode);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal mengirim pengaduan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String ticketCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.accentGreen,
              child: Icon(Icons.check, color: AppTheme.primaryGreen, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Laporan LANTANG Terkirim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terima kasih atas keberanianmu melapor. Tim Guru BK / TPPK akan menindaklanjuti laporanmu secara bijaksana.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KODE TIKET RAHASIA', style: TextStyle(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                      Text(ticketCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppTheme.primaryGreen),
                    tooltip: 'Salin Kode Tiket',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ticketCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kode tiket berhasil disalin!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackIncidentScreen()),
              );
            },
            child: const Text('Lacak Kasus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Pengaduan LANTANG'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Kerahasiaan Card
            Card(
              color: _isAnonymous ? Colors.amber.shade50 : AppTheme.accentGreen,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isAnonymous ? 'Mode: Anonim Total' : 'Mode: Kerahasiaan Terjaga',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isAnonymous ? Colors.amber.shade900 : AppTheme.primaryGreen,
                          ),
                        ),
                        Switch(
                          value: _isAnonymous,
                          activeColor: Colors.amber.shade800,
                          onChanged: (val) => setState(() => _isAnonymous = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isAnonymous
                          ? 'Akun Anda tidak dicatat sama sekali di database. Anda hanya dapat melacak laporan ini menggunakan kode tiket rahasia.'
                          : 'Identitas Anda terlindungi dan hanya dapat dilihat oleh Tim Guru BK / TPPK saat mediasi.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isAnonymous ? Colors.amber.shade900 : AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Peran Pelapor
            const Text('Posisi Anda dalam Insiden *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Saya Korban', style: TextStyle(fontSize: 13)),
                    value: 'self',
                    groupValue: _victimType,
                    onChanged: (val) => setState(() => _victimType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Saya Saksi', style: TextStyle(fontSize: 13)),
                    value: 'other',
                    groupValue: _victimType,
                    onChanged: (val) => setState(() => _victimType = val!),
                  ),
                ),
              ],
            ),
            if (_victimType == 'other') ...[
              const SizedBox(height: 8),
              TextField(
                controller: _victimNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Teman yang Menjadi Korban *',
                  hintText: 'Contoh: Ahmad Kelas 7B',
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Kategori
            const Text('Kategori Insiden *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'verbal', child: Text('Ejekan / Celaan / Verbal')),
                DropdownMenuItem(value: 'fisik', child: Text('Kekerasan Fisik / Pemukulan')),
                DropdownMenuItem(value: 'sosial_relasional', child: Text('Pengucilan / Relasional')),
                DropdownMenuItem(value: 'cyber', child: Text('Perundungan Medsos / Cyber')),
              ],
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),

            // Lokasi
            const Text('Lokasi Kejadian *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _location,
              decoration: const InputDecoration(),
              items: _locationPresets.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
              onChanged: (val) => setState(() => _location = val!),
            ),
            const SizedBox(height: 16),

            // Tanggal Kejadian
            const Text('Tanggal Kejadian *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
              leading: const Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
              title: Text(_incidentDate.toIso8601String().split('T')[0]),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _incidentDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _incidentDate = picked);
              },
            ),
            const SizedBox(height: 16),

            // Terduga Pelaku
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mengetahui Identitas / Ciri Pelaku?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              value: _perpetratorKnown,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) => setState(() => _perpetratorKnown = val ?? false),
            ),
            if (_perpetratorKnown) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _perpetratorDescController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ciri-Ciri atau Nama Terduga Pelaku',
                  hintText: 'Contoh: Kakak kelas tinggi, memakai jaket hitam...',
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Kronologi
            const Text('Ceritakan Kronologi Kejadian *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Jelaskan apa yang terjadi, siapa saja yang ada di lokasi, dan bagaimana situasinya...',
              ),
            ),
            const SizedBox(height: 16),

            // Lampiran Foto Bukti
            const Text('Foto Dokumentasi / Bukti (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            if (_selectedPhoto != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image, color: AppTheme.primaryGreen, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_selectedPhoto!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => setState(() => _selectedPhoto = null),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Pilih Foto Bukti (Maks. 2MB)'),
              ),
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitIncident,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Kirim Pengaduan LANTANG'),
            ),
          ],
        ),
      ),
    );
  }
}
