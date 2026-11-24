import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitFormApp());
}

class FitFormApp extends StatelessWidget {
  const FitFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitForm Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.charcoalBg,
        primaryColor: AppColors.spinachGreen,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.spinachGreen,
          secondary: AppColors.spinachGreenLight,
          surface: AppColors.charcoalSurface,
          error: AppColors.warningRed,
        ),
        useMaterial3: true,
      ),
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
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _authService.checkAndHandleWebCallback();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.charcoalBg,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.spinachGreen,
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return MainNavigationScreen(user: snapshot.data!);
        }

        return const LoginScreen();
      },
    );
  }
}
