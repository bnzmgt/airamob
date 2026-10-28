import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _showServerConfigDialog() async {
    final controller = TextEditingController(text: ApiEndpoints.baseUrl);
    String? testStatus;
    bool isTesting = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.dns_outlined, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Text('Pengaturan Server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ubah URL endpoint backend AiNARA sesuai lingkungan koneksi (HP Fisik via Wi-Fi/LAN, Emulator, atau VPS):',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Base URL API',
                        hintText: 'http://192.168.1.x:8000/api/v1',
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Preset Lingkungan:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          label: const Text('Valet / Web'),
                          onPressed: () {
                            setDialogState(() {
                              controller.text = 'http://airamod.test/api/v1';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Android Emulator'),
                          onPressed: () {
                            setDialogState(() {
                              controller.text = 'http://10.0.2.2:8000/api/v1';
                            });
                          },
                        ),
                        ActionChip(
                          label: const Text('Localhost:8000'),
                          onPressed: () {
                            setDialogState(() {
                              controller.text = 'http://127.0.0.1:8000/api/v1';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (testStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: testStatus!.startsWith('✓') ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: testStatus!.startsWith('✓') ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          testStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            color: testStatus!.startsWith('✓') ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    OutlinedButton.icon(
                      onPressed: isTesting
                          ? null
                          : () async {
                              setDialogState(() {
                                isTesting = true;
                                testStatus = 'Menguji koneksi ke server...';
                              });
                              final target = ApiEndpoints.sanitizeBaseUrl(controller.text);
                              final pingUrl = '$target/safeguarding/track/PING-CHECK';
                              final sw = Stopwatch()..start();
                              try {
                                final res = await http.get(Uri.parse(pingUrl)).timeout(const Duration(seconds: 5));
                                sw.stop();
                                setDialogState(() {
                                  isTesting = false;
                                  if (res.statusCode == 200 || res.statusCode == 404 || res.statusCode == 422) {
                                    testStatus = '✓ Terhubung! Respon ${res.statusCode} (${sw.elapsedMilliseconds} ms)';
                                  } else {
                                    testStatus = '⚠ Server merespon HTTP ${res.statusCode} (${sw.elapsedMilliseconds} ms)';
                                  }
                                });
                              } catch (e) {
                                sw.stop();
                                setDialogState(() {
                                  isTesting = false;
                                  testStatus = '✕ Gagal terhubung: $e';
                                });
                              }
                            },
                      icon: isTesting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.wifi_tethering, size: 16),
                      label: const Text('Uji Respon Koneksi'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await SecureStorage.clearBaseUrl();
                    ApiEndpoints.setBaseUrl(ApiEndpoints.defaultBaseUrl);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Server URL dikembalikan ke default.')),
                      );
                    }
                  },
                  child: const Text('Reset Default', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newUrl = ApiEndpoints.sanitizeBaseUrl(controller.text);
                    await SecureStorage.saveBaseUrl(newUrl);
                    ApiEndpoints.setBaseUrl(newUrl);
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Server berhasil diatur ke: $newUrl'),
                          backgroundColor: AppTheme.primaryBlue,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dns_outlined, color: AppTheme.textMuted),
            tooltip: 'Pengaturan Server Backend',
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Logo
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 76,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.borderDefault),
                        ),
                        child: const Icon(Icons.school, size: 50, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AiNARA Mobile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Daily Study Report & Family Connection',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
                  icon: const Icon(Icons.shield_outlined, color: AppTheme.primaryBlue),
                  label: const Text(
                    'Lacak Tiket Aduan LANTANG (Tanpa Login)',
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),

                // Active Server Indicator Button
                Center(
                  child: TextButton.icon(
                    onPressed: _showServerConfigDialog,
                    icon: const Icon(Icons.settings_ethernet, size: 14, color: AppTheme.textMuted),
                    label: Text(
                      'Server: ${ApiEndpoints.baseUrl}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
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
