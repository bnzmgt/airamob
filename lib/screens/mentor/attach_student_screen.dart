import 'package:flutter/material.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../models/mentor_report.dart';
import '../../services/mentor_service.dart';

class AttachStudentScreen extends StatefulWidget {
  const AttachStudentScreen({super.key});

  @override
  State<AttachStudentScreen> createState() => _AttachStudentScreenState();
}

class _AttachStudentScreenState extends State<AttachStudentScreen> {
  final _searchController = TextEditingController();
  final _subjectController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<MentorStudentSummary> _students = [];
  MentorStudentSummary? _selectedStudent;

  final List<String> _presets = [
    'Matematika',
    'Bahasa Inggris',
    'IPA / Sains',
    'Mengaji & Tahsin',
    'Calistung',
    'Bahasa Indonesia',
    'Fisika',
    'Bimbingan Umum',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableStudents([String? query]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await MentorService.getAvailableStudents(search: query);

    if (!mounted) return;

    if (response.success && response.data is List) {
      final list = (response.data as List)
          .map((item) => MentorStudentSummary.fromJson(item as Map<String, dynamic>))
          .toList();
      setState(() {
        _isLoading = false;
        _students = list;
        if (_selectedStudent != null && !_students.any((s) => s.id == _selectedStudent!.id)) {
          _selectedStudent = null;
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message ?? 'Gagal memuat daftar siswa.';
      });
    }
  }

  Future<void> _submitAttachment() async {
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih siswa bimbingan terlebih dahulu.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tentukan mata pelajaran yang diajarkan.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await MentorService.attachStudent(
      studentId: _selectedStudent!.id,
      subjectName: subject,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedStudent!.name} berhasil ditambahkan ke siswa bimbingan!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Gagal menghubungkan siswa.'),
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
        title: const Text('Tambah Siswa Bimbingan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderDefault),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama, kelas, atau kode siswa...',
                          hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (val) => _loadAvailableStudents(val),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _loadAvailableStudents();
                        },
                      ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _loadAvailableStudents(_searchController.text),
                      child: const Text('Cari', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 1: Select Student
              const Text(
                '1. Pilih Siswa yang Diajar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pilih anak dari daftar siswa yang terdaftar di sekolah / sistem',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_students.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderDefault, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Text(
                      'Tidak ada siswa yang sesuai pencarian atau semua siswa sudah ada di daftar bimbingan Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    final isSelected = _selectedStudent?.id == student.id;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedStudent = student);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF3E8FF) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF7E22CE) : AppTheme.borderDefault,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: student.id,
                              groupValue: _selectedStudent?.id,
                              activeColor: const Color(0xFF7E22CE),
                              onChanged: (val) {
                                setState(() => _selectedStudent = student);
                              },
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      ApiEndpoints.resolveImageUrl(student.avatarUrl),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(student.name),
                                    )
                                  : _buildAvatarPlaceholder(student.name),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Section 2: Subject Input
              const Text(
                '2. Mata Pelajaran yang Diajarkan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tuliskan fokus mata pelajaran les privat untuk siswa ini',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _subjectController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Contoh: Matematika, Bahasa Inggris, Mengaji...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderDefault),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderDefault),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF7E22CE), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Presets
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _presets.map((preset) {
                  return InkWell(
                    onTap: () {
                      _subjectController.text = preset;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderDefault),
                      ),
                      child: Text(
                        '+ $preset',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7E22CE)),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7E22CE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                ),
                onPressed: _isSubmitting ? null : _submitAttachment,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1, size: 20),
                label: Text(
                  _isSubmitting ? 'Menghubungkan Siswa...' : 'Hubungkan Siswa Bimbingan',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.trim().isNotEmpty
        ? (name.trim().length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase())
        : 'S';
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7E22CE)),
      ),
    );
  }
}
