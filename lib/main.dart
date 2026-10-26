import 'package:flutter/material.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/parent/parent_home_screen.dart';
import 'screens/student/student_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AinaraApp());
}

class AinaraApp extends StatelessWidget {
  const AinaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AiNARA Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Widget _targetScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getRole();

    setState(() {
      _isLoading = false;
      if (token != null && role != null) {
        if (role == 'student') {
          _targetScreen = const StudentHomeScreen();
        } else if (role == 'parent') {
          _targetScreen = const ParentHomeScreen();
        } else {
          _targetScreen = const LoginScreen();
        }
      } else {
        _targetScreen = const LoginScreen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return _targetScreen;
  }
}
