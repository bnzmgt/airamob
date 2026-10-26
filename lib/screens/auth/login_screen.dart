import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../parent/parent_home_screen.dart';
import '../safeguarding/track_incident_screen.dart';
import '../student/student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await ApiClient.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password,
        'device_name': 'AiNARA Mobile App',
      },
      withAuth: false,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      final token = response.data['token'];
      final user = response.data['user'];
      final role = user['role'] as String;

      await SecureStorage.saveAuthSession(
        token: token,
        role: role,
        name: user['name'] ?? 'Pengguna',
        email: user['email'] ?? '',
      );

      if (!mounted) return;

      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
        );
      } else if (role == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
        );
      } else {
        setState(() => _errorMessage = 'Peran akun ($role) disarankan login melalui panel admin web.');
      }
    } else {
      setState(() => _errorMessage = response.message ?? 'Login gagal. Periksa kembali data akun Anda.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Logo / Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.school, size: 54, color: AppTheme.primaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AiNARA Mobile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Daily Study Report & Family Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Masuk Aplikasi'),
                ),
                const SizedBox(height: 28),

                // Public Safeguarding Action
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrackIncidentScreen()),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, color: AppTheme.primaryGreen),
                  label: const Text(
                    'Lacak Tiket Aduan LANTANG (Tanpa Login)',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
