import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/environment_config.dart';
import 'core/di/app_services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/providers/theme_provider.dart';
import 'core/routes/app_routes.dart';
import 'core/providers/auth_session_manager.dart';
import 'presentation/authenticated_content.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  EnvironmentConfig.initialize();
  await AppServices.initialize();
  runApp(const DoctoPingApp());
}

class DoctoPingApp extends StatelessWidget {
  const DoctoPingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider.value(value: AppServices.authSessionManager),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final authSession = context.watch<AuthSessionManager>();

          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeProvider.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: themeProvider.isDarkMode
                  ? AppColors.surfaceDark
                  : AppColors.surface,
              systemNavigationBarIconBrightness: themeProvider.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );
          return MaterialApp(
            title: 'DoctoPing',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: authSession.isInitialized
                ? (authSession.isAuthenticated
                    ? const AuthenticatedContent()
                    : const SplashScreen())
                : const SplashScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
