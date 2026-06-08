import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_session_manager.dart';
import 'screens/home/main_navigation.dart';
import 'screens/doctor/doctor_main_navigation.dart';

/// Widget qui route vers l'interface appropriée selon le rôle
class AuthenticatedContent extends StatelessWidget {
  const AuthenticatedContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authSession = context.watch<AuthSessionManager>();
    final userRole = authSession.user?.role ?? 'patient';

    // Route selon le rôle
    if (userRole == 'doctor') {
      return const DoctorMainNavigation();
    }

    return const MainNavigation();
  }
}
