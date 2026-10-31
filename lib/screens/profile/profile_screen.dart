import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  // Profile & Contact Form
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _specializationController = TextEditingController();
  final _bioController = TextEditingController();
  XFile? _selectedAvatar;
  bool _isSavingContact = false;

  // Password Form
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSavingPassword = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final response = await ApiClient.get(ApiEndpoints.profile);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _user = response.data;
        _nameController.text = _user!['name'] ?? '';
        final profile = _user!['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          _phoneController.text = profile['phone_number'] ?? '';
          _addressController.text = profile['address'] ?? '';
          _specializationController.text = profile['specialization'] ?? '';
          _bioController.text = profile['bio'] ?? '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal memuat data profil.'),
            backgroundColor: AppTheme.destructive,
          ),
        );
      }
    });
  }

  Future<void> _pickAvatar() async {
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
                'Pilih Sumber Foto Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryBlue),
              title: const Text('Ambil dari Kamera', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 75,
                );
                if (picked != null) {
                  setState(() => _selectedAvatar = picked);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryBlue),
              title: const Text('Pilih dari Galeri', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 75,
                );
                if (picked != null) {
                  setState(() => _selectedAvatar = picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap tidak boleh kosong.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    setState(() => _isSavingContact = true);

    final payload = <String, String>{
      'name': name,
      'phone_number': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    if (_user?['role'] == 'mentor') {
      payload['specialization'] = _specializationController.text.trim();
      payload['bio'] = _bioController.text.trim();
    }

    ApiResponse res;
    if (_selectedAvatar != null) {
      res = await ApiClient.postMultipart(
        ApiEndpoints.updateContact,
        payload,
        file: _selectedAvatar,
        fileField: 'avatar',
      );
    } else {
      res = await ApiClient.post(
        ApiEndpoints.updateContact,
        payload,
      );
    }

    if (!mounted) return;
    setState(() => _isSavingContact = false);

    if (res.success) {
      setState(() {
        _selectedAvatar = null;
        if (res.data != null) {
          _user = res.data;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data profil berhasil disimpan!'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Gagal memperbarui profil.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  Future<void> _savePassword() async {
    final currentPass = _currentPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom kata sandi wajib diisi.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru minimal 6 karakter.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi baru tidak sesuai.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }

    setState(() => _isSavingPassword = true);

    final res = await ApiClient.post(
      ApiEndpoints.updatePassword,
      {
        'current_password': currentPass,
        'password': newPass,
        'password_confirmation': confirmPass,
      },
    );

    if (!mounted) return;
    setState(() => _isSavingPassword = false);

    if (res.success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi berhasil diubah!'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Gagal mengubah kata sandi.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  bool _isSyncingToken = false;

  Future<void> _syncNotificationToken() async {
    setState(() => _isSyncingToken = true);
    final result = await NotificationService.testAndSyncToken();
    if (!mounted) return;
    setState(() => _isSyncingToken = false);

    final success = result['success'] == true;
    final message = result['message'] ?? (success ? 'Notifikasi aktif!' : 'Gagal');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorder),
        ),
        title: const Text('Konfirmasi Keluar', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun AiNARA?', style: TextStyle(color: AppTheme.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await NotificationService.unregisterToken();
      await ApiClient.post(ApiEndpoints.logout, {});
      await SecureStorage.clearSession();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildAvatarWidget() {
    if (_selectedAvatar != null) {
      if (kIsWeb) {
        return ClipOval(
          child: Image.network(
            _selectedAvatar!.path,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipOval(
          child: Image.file(
            File(_selectedAvatar!.path),
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    final rawAvatarUrl = _user?['avatar_url'] as String?;
    final avatarUrl = ApiEndpoints.resolveImageUrl(rawAvatarUrl);
    if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const CircleAvatar(
            radius: 44,
            backgroundColor: Color(0xFFEFF6FF),
            child: Icon(Icons.person, size: 48, color: AppTheme.primaryBlue),
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 44,
      backgroundColor: Color(0xFFEFF6FF),
      child: Icon(Icons.person, size: 48, color: AppTheme.primaryBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _user?['profile'] as Map<String, dynamic>?;
    final role = _user?['role'] ?? 'user';
    final isStudent = role == 'student';
    final isMentor = role == 'mentor';
    final isParent = role == 'parent';

    String roleLabel = 'Pengguna';
    Color roleBadgeBg = const Color(0xFFEFF6FF);
    Color roleBadgeBorder = const Color(0xFFBFDBFE);
    Color roleBadgeText = AppTheme.primaryBlue;

    if (isStudent) {
      roleLabel = 'Siswa';
      roleBadgeBg = const Color(0xFFEFF6FF);
      roleBadgeBorder = const Color(0xFFBFDBFE);
      roleBadgeText = AppTheme.primaryBlue;
    } else if (isMentor) {
      roleLabel = 'Mentor Les Privat';
      roleBadgeBg = const Color(0xFFECFDF5);
      roleBadgeBorder = const Color(0xFFA7F3D0);
      roleBadgeText = const Color(0xFF047857);
    } else if (isParent) {
      roleLabel = 'Orang Tua / Wali';
      roleBadgeBg = const Color(0xFFF5F3FF);
      roleBadgeBorder = const Color(0xFFDDD6FE);
      roleBadgeText = const Color(0xFF6D28D9);
    }

    return Scaffold(
      backgroundColor: AppTheme.canvasColor,
      appBar: AppBar(
        title: const Text('Profil & Akun Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppTheme.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Profile Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                _buildAvatarWidget(),
                                GestureDetector(
                                  onTap: _pickAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _user?['name'] ?? 'Pengguna',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user?['email'] ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: roleBadgeBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: roleBadgeBorder),
                                  ),
                                  child: Text(
                                    roleLabel,
                                    style: TextStyle(
                                      color: roleBadgeText,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: const Text(
                                    '🟢 Aktif',
                                    style: TextStyle(
                                      color: Color(0xFF047857),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isStudent && profile != null) ...[
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: AppTheme.cardBorder),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('NIS / Kode Siswa', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 3),
                                      Text(
                                        profile['student_code'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                  Container(height: 28, width: 1, color: AppTheme.cardBorder),
                                  Column(
                                    children: [
                                      const Text('Kelas Terdaftar', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 3),
                                      Text(
                                        profile['class_name'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ] else if (isMentor && profile != null) ...[
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: AppTheme.cardBorder),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Siswa Bimbingan Aktif', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${profile['active_students_count'] ?? 0} Siswa',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                  Container(height: 28, width: 1, color: AppTheme.cardBorder),
                                  Column(
                                    children: [
                                      const Text('Spesialisasi', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 3),
                                      Text(
                                        (profile['specialization'] != null && profile['specialization'].toString().isNotEmpty)
                                            ? profile['specialization'].toString()
                                            : 'Umum',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact & Profile Update Form Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.badge_outlined, color: AppTheme.primaryBlue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Informasi Profil & Kontak',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                hintText: 'Nama lengkap Anda',
                                prefixIcon: Icon(Icons.person_outline, size: 20),
                              ),
                            ),
                            if (isMentor) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _specializationController,
                                decoration: const InputDecoration(
                                  labelText: 'Spesialisasi Mata Pelajaran',
                                  hintText: 'Contoh: Matematika, Fisika SMA',
                                  prefixIcon: Icon(Icons.menu_book_outlined, size: 20),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _bioController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Bio / Riwayat Singkat Mengajar',
                                  hintText: 'Tuliskan profil singkat atau pendekatan les privat Anda...',
                                  prefixIcon: Icon(Icons.notes_outlined, size: 20),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Nomor WhatsApp / HP',
                                hintText: '0812xxxxxxxx',
                                prefixIcon: Icon(Icons.phone_android, size: 20),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Alamat Domisili',
                                hintText: 'Nama jalan, perumahan, kota...',
                                prefixIcon: Icon(Icons.home_outlined, size: 20),
                              ),
                            ),
                            if (_selectedAvatar != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Foto profil baru terpilih: ${_selectedAvatar!.name}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedAvatar = null),
                                      child: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSavingContact ? null : _saveContact,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                minimumSize: const Size(double.infinity, 48),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSavingContact
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Simpan Perubahan Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Update Form Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lock_outline, color: AppTheme.primaryBlue, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Ganti Kata Sandi',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _currentPasswordController,
                              obscureText: _obscureCurrent,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi Saat Ini',
                                prefixIcon: const Icon(Icons.lock_open, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20),
                                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _newPasswordController,
                              obscureText: _obscureNew,
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi Baru (min. 6 karakter)',
                                prefixIcon: const Icon(Icons.key, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Kata Sandi Baru',
                                prefixIcon: const Icon(Icons.key, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSavingPassword ? null : _savePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.textPrimary, // #0F172A Slate 900
                                minimumSize: const Size(double.infinity, 48),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSavingPassword
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Perbarui Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notification & Device Status Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryBlue, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notifikasi & Perangkat',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                                      ),
                                      Text(
                                        'Status sambungan push notification Firebase',
                                        style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: AppTheme.cardBorder),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _isSyncingToken ? null : _syncNotificationToken,
                              icon: _isSyncingToken
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.sync, size: 18, color: Colors.white),
                              label: Text(
                                _isSyncingToken ? 'Menghubungkan...' : 'Sinkronkan Notifikasi Handphone Ini',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout Button Card
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppTheme.cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                          label: const Text('Keluar dari Akun', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECDD3)),
                            backgroundColor: const Color(0xFFFFF1F2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
