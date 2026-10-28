import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  // Contact Form
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
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
    _phoneController.dispose();
    _addressController.dispose();
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
        final profile = _user!['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          _phoneController.text = profile['phone_number'] ?? '';
          _addressController.text = profile['address'] ?? '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Gagal memuat data profil.'),
            backgroundColor: Colors.red,
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
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
              title: const Text('Pilih dari Galeri'),
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
    setState(() => _isSavingContact = true);

    ApiResponse res;
    if (_selectedAvatar != null) {
      res = await ApiClient.postMultipart(
        ApiEndpoints.updateContact,
        {
          'phone_number': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        },
        file: _selectedAvatar,
        fileField: 'avatar',
      );
    } else {
      res = await ApiClient.post(
        ApiEndpoints.updateContact,
        {
          'phone_number': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        },
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
          content: Text('Data profil kontak berhasil disimpan!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Gagal memperbarui profil.'),
          backgroundColor: Colors.red,
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
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi baru minimal 6 karakter.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi baru tidak sesuai.'),
          backgroundColor: Colors.red,
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
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'Gagal mengubah kata sandi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun AiNARA?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
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
            backgroundColor: AppTheme.accentGreen,
            child: Icon(Icons.person, size: 48, color: AppTheme.primaryGreen),
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 44,
      backgroundColor: AppTheme.accentGreen,
      child: Icon(Icons.person, size: 48, color: AppTheme.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _user?['profile'] as Map<String, dynamic>?;
    final role = _user?['role'] ?? 'user';
    final isStudent = role == 'student';

    return Scaffold(
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
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Profile Card
                    Card(
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
                                      color: AppTheme.primaryGreen,
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
                            const SizedBox(height: 12),
                            Text(
                              _user?['name'] ?? 'Pengguna',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user?['email'] ?? '',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isStudent ? 'Siswa' : 'Orang Tua / Wali',
                                    style: const TextStyle(
                                      color: AppTheme.primaryGreen,
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
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('NIS / Kode Siswa', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile['student_code'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Kelas Terdaftar', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile['class_name'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                    const SizedBox(height: 20),

                    // Contact Update Form Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.contact_phone, color: AppTheme.primaryGreen, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Informasi Kontak & Alamat',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
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
                                prefixIcon: Icon(Icons.home, size: 20),
                              ),
                            ),
                            if (_selectedAvatar != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Foto profil baru terpilih: ${_selectedAvatar!.name}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _selectedAvatar = null),
                                      child: const Icon(Icons.close, size: 18, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isSavingContact ? null : _saveContact,
                              child: _isSavingContact
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Simpan Perubahan Kontak'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Update Form Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.lock_outline, color: AppTheme.primaryGreen, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Ganti Kata Sandi',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
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
                                backgroundColor: const Color(0xFF1E293B),
                              ),
                              child: _isSavingPassword
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Perbarui Kata Sandi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logout Button Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
