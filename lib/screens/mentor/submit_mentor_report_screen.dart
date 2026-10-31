import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mentor_report.dart';
import '../../services/mentor_service.dart';

class SubmitMentorReportScreen extends StatefulWidget {
  final int? initialStudentId;
  final String? initialStudentName;
  final String? initialSubject;

  const SubmitMentorReportScreen({
    super.key,
    this.initialStudentId,
    this.initialStudentName,
    this.initialSubject,
  });

  @override
  State<SubmitMentorReportScreen> createState() => _SubmitMentorReportScreenState();
}

class _SubmitMentorReportScreenState extends State<SubmitMentorReportScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedStudentId;
  List<MentorStudentSummary> _students = [];
  bool _isLoadingStudents = false;

  late DateTime _sessionDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final _subjectController = TextEditingController();
  final _materialController = TextEditingController();
  final _progressController = TextEditingController();
  final _homeworkController = TextEditingController();

  String _understandingLevel = 'paham';
  XFile? _photo;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> _understandingOptions = const [
    {
      'key': 'perlu_bimbingan',
      'label': 'Butuh Bimbingan',
      'desc': 'Masih kesulitan / perlu pengulangan',
      'color': Color(0xFFE11D48),
      'bg': Color(0xFFFFF1F2),
    },
    {
      'key': 'cukup',
      'label': 'Cukup Paham',
      'desc': 'Mengerti konsep dasar dengan panduan',
      'color': Color(0xFFD97706),
      'bg': Color(0xFFFFFBEB),
    },
    {
      'key': 'paham',
      'label': 'Paham Baik',
      'desc': 'Mampu menyelesaikan soal mandiri',
      'color': Color(0xFF2563EB),
      'bg': Color(0xFFEFF6FF),
    },
    {
      'key': 'sangat_paham',
      'label': 'Sangat Menguasai',
      'desc': 'Cepat paham & aktif eksplorasi materi',
      'color': Color(0xFF059669),
      'bg': Color(0xFFECFDF5),
    },
  ];

  @override
  void initState() {
    super.initState();
    _sessionDate = DateTime.now();
    _selectedStudentId = widget.initialStudentId;
    if (widget.initialSubject != null && widget.initialSubject!.isNotEmpty) {
      _subjectController.text = widget.initialSubject!;
    }
    _loadStudents();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _materialController.dispose();
    _progressController.dispose();
    _homeworkController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    final response = await MentorService.getStudents();
    if (!mounted) return;

    if (response.success && response.data is List) {
      final list = (response.data as List)
          .map((item) => MentorStudentSummary.fromJson(item as Map<String, dynamic>))
          .toList();
      setState(() {
        _isLoadingStudents = false;
        _students = list;
        if (_selectedStudentId == null && _students.isNotEmpty) {
          _selectedStudentId = _students.first.id;
          if (_subjectController.text.isEmpty && _students.first.subjectName != null) {
            _subjectController.text = _students.first.subjectName!;
          }
        }
      });
    } else {
      setState(() => _isLoadingStudents = false);
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7E22CE),
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _sessionDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? (_startTime ?? const TimeOfDay(hour: 16, minute: 0)) : (_endTime ?? const TimeOfDay(hour: 17, minute: 30));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7E22CE),
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (file != null) {
        setState(() => _photo = file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih siswa bimbingan terlebih dahulu.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await MentorService.submitReport(
      studentId: _selectedStudentId!,
      sessionDate: _formatDate(_sessionDate),
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      subject: _subjectController.text.trim(),
      materialTaught: _materialController.text.trim(),
      studentProgress: _progressController.text.trim(),
      understandingLevel: _understandingLevel,
      homeworkNotes: _homeworkController.text.trim(),
      photo: _photo,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan sesi les berhasil disimpan dan dapat dipantau oleh orang tua!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal menyimpan laporan sesi les.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Input Laporan Sesi Les', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 1: Student & Date
                _buildCard(
                  title: 'Informasi Siswa & Waktu Sesi',
                  children: [
                    // Student Selector
                    const Text('Siswa Bimbingan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    if (_isLoadingStudents)
                      const LinearProgressIndicator(color: Color(0xFF7E22CE))
                    else if (_students.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: const Text(
                          'Belum ada siswa bimbingan. Tambahkan siswa terlebih dahulu dari halaman dashboard.',
                          style: TextStyle(fontSize: 12, color: AppTheme.errorRed),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedStudentId,
                        decoration: _inputDecoration('Pilih Siswa'),
                        items: _students.map((s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(
                              '${s.name} (${s.className ?? 'Kelas -'})',
                              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedStudentId = val;
                            final s = _students.firstWhere((item) => item.id == val);
                            if (s.subjectName != null && s.subjectName!.isNotEmpty && _subjectController.text.isEmpty) {
                              _subjectController.text = s.subjectName!;
                            }
                          });
                        },
                        validator: (val) => val == null ? 'Pilih siswa bimbingan' : null,
                      ),

                    const SizedBox(height: 16),

                    // Date Picker
                    const Text('Tanggal Sesi *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF7E22CE)),
                            const SizedBox(width: 10),
                            Text(
                              _formatDate(_sessionDate),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                            const Spacer(),
                            const Text('Ganti', style: TextStyle(fontSize: 12, color: Color(0xFF7E22CE), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Start and End Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jam Mulai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _pickTime(isStart: true),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.borderDefault),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: AppTheme.textMuted),
                                      const SizedBox(width: 8),
                                      Text(
                                        _startTime != null ? _formatTimeOfDay(_startTime) : '--:--',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jam Selesai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _pickTime(isStart: false),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.borderDefault),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_filled, size: 16, color: AppTheme.textMuted),
                                      const SizedBox(width: 8),
                                      Text(
                                        _endTime != null ? _formatTimeOfDay(_endTime) : '--:--',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card 2: Subject & Material Taught
                _buildCard(
                  title: 'Materi & Pembelajaran',
                  children: [
                    const Text('Mata Pelajaran *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _subjectController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Contoh: Matematika, Bahasa Inggris, Mengaji...'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Mata pelajaran wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('Topik / Materi yang Diajarkan *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _materialController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Tuliskan ringkasan bab / topik yang dipelajari hari ini...'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Topik materi wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('Catatan Perkembangan & Keaktifan Siswa *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _progressController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Ceritakan antusiasme, respon belajar, dan kendala yang dihadapi...'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Catatan perkembangan wajib diisi' : null,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card 3: Understanding Level
                _buildCard(
                  title: 'Tingkat Pemahaman Siswa',
                  children: [
                    const Text('Evaluasi pemahaman anak terhadap materi hari ini:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _understandingOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final opt = _understandingOptions[index];
                        final isSelected = _understandingLevel == opt['key'];
                        final color = opt['color'] as Color;

                        return InkWell(
                          onTap: () {
                            setState(() => _understandingLevel = opt['key'] as String);
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? (opt['bg'] as Color) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? color : AppTheme.borderDefault,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? color : AppTheme.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        opt['label'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? color : AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt['desc'] as String,
                                        style: TextStyle(fontSize: 11, color: isSelected ? color.withOpacity(0.8) : AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card 4: Homework & Photo
                _buildCard(
                  title: 'Tugas Mandiri & Bukti Foto',
                  children: [
                    const Text('Tugas / PR Mandiri (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _homeworkController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration('Contoh: Kerjakan LKS Matematika halaman 24 no 1-5...'),
                    ),

                    const SizedBox(height: 16),

                    const Text('Foto Dokumentasi Belajar (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 6),

                    if (_photo != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_photo!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black.withOpacity(0.6),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                onPressed: () => setState(() => _photo = null),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: AppTheme.borderDefault),
                            ),
                            onPressed: () => _pickPhoto(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF7E22CE)),
                            label: const Text('Ambil Kamera', style: TextStyle(fontSize: 12, color: Color(0xFF7E22CE), fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: AppTheme.borderDefault),
                            ),
                            onPressed: () => _pickPhoto(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppTheme.textDark),
                            label: const Text('Buka Galeri', style: TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7E22CE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                  ),
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    _isSubmitting ? 'Menyimpan Laporan Sesi...' : 'Simpan & Kirim Laporan Les',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const Divider(height: 24, color: AppTheme.borderDefault),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppTheme.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF7E22CE), width: 1.5),
      ),
    );
  }
}
