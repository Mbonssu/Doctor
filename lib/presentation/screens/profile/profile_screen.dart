import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers/auth_session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/routes/navigation_helper.dart';
import '../../../core/utils/modal_utils.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  bool _emailAlerts = false;
  bool _smsReminders = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Header profil ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient haut
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mon Profil',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showEditProfile(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Modifier',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Carte profil flottante
                Positioned(
                  top: 110,
                  left: 24,
                  right: 24,
                  child: _ProfileCard(),
                ),
              ],
            ),
          ),

          // Espace pour la carte flottante
          const SliverToBoxAdapter(child: SizedBox(height: 120)),

          // ── Stats santé ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Informations de santé'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _HealthStat(
                        label: 'Groupe sanguin',
                        value: 'O+',
                        icon: Icons.bloodtype_rounded,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 12),
                      _HealthStat(
                        label: 'Poids',
                        value: '72 kg',
                        icon: Icons.monitor_weight_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _HealthStat(
                        label: 'Taille',
                        value: '1,78 m',
                        icon: Icons.height_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Allergies + maladies chroniques
                  _HealthInfoRow(
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    title: 'Allergies',
                    value: 'Pénicilline, Arachides',
                  ),
                  const SizedBox(height: 10),
                  _HealthInfoRow(
                    icon: Icons.monitor_heart_outlined,
                    color: AppColors.danger,
                    title: 'Maladies chroniques',
                    value: 'Hypertension légère',
                  ),
                  const SizedBox(height: 10),
                  _HealthInfoRow(
                    icon: Icons.medication_outlined,
                    color: const Color(0xFF845EF7),
                    title: 'Traitements en cours',
                    value: 'Amlodipine 5mg / jour',
                  ),
                ],
              ),
            ),
          ),

          // ── Mes médecins favoris ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionHeader(title: 'Médecins favoris'),
                      TextButton(
                        onPressed: () =>
                            NavigationHelper.goToFavoriteDoctors(context),
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 92,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FavoriteDoc(
                          initials: 'AT',
                          name: 'Dr. Toure',
                          specialty: 'Cardio',
                          color: AppColors.cardio,
                        ),
                        _FavoriteDoc(
                          initials: 'NB',
                          name: 'Dr. Bello',
                          specialty: 'Pédiatrie',
                          color: AppColors.pediatrie,
                        ),
                        _FavoriteDoc(
                          initials: 'CF',
                          name: 'Dr. Fon',
                          specialty: 'Ophtalmo',
                          color: AppColors.ophtalmo,
                        ),
                        _FavoriteDoc(
                          initials: '+',
                          name: 'Ajouter',
                          specialty: '',
                          color: context.textMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Paramètres notifications ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Notifications'),
                  const SizedBox(height: 14),
                  _ToggleTile(
                    icon: Icons.notifications_outlined,
                    color: AppColors.primary,
                    title: 'Rappels de RDV',
                    subtitle: 'Notifié 1h avant chaque rendez-vous',
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.email_outlined,
                    color: AppColors.accent,
                    title: 'Alertes email',
                    subtitle: 'Confirmation et annulation par email',
                    value: _emailAlerts,
                    onChanged: (v) => setState(() => _emailAlerts = v),
                  ),
                  const SizedBox(height: 10),
                  _ToggleTile(
                    icon: Icons.sms_outlined,
                    color: const Color(0xFF845EF7),
                    title: 'SMS de rappel',
                    subtitle: 'Rappel SMS 24h avant le RDV',
                    value: _smsReminders,
                    onChanged: (v) => setState(() => _smsReminders = v),
                  ),
                ],
              ),
            ),
          ),

          // ── Paramètres généraux ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Préférences'),
                  const SizedBox(height: 14),
                  // Mode sombre
                  _SettingTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: context.isDark ? const Color(0xFF845EF7) : AppColors.warning,
                    title: context.isDark ? 'Mode sombre activé' : 'Mode clair activé',
                    subtitle: 'Changer le thème de l\'application',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.language_rounded,
                    color: AppColors.accent,
                    title: 'Langue',
                    subtitle: 'Français',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    onTap: () {
                      // TODO: Implement language selection
                    },
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.lock_outline_rounded,
                    color: AppColors.primary,
                    title: 'Confidentialité & Sécurité',
                    subtitle: 'Mot de passe, biométrie, données',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    onTap: () => NavigationHelper.goToChangePassword(context),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.help_outline_rounded,
                    color: context.textMuted,
                    title: 'Aide & Support',
                    subtitle: 'FAQ, contact, signaler un problème',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    onTap: () => NavigationHelper.goToFaq(context),
                  ),
                  const SizedBox(height: 10),
                  _SettingTile(
                    icon: Icons.info_outline_rounded,
                    color: context.textMuted,
                    title: 'À propos de DoctoPing',
                    subtitle: 'Version 1.0.0 · Mentions légales',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: context.textMuted,
                    ),
                    onTap: () {
                      // TODO: Implement about page
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bouton déconnexion ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
              child: Column(
                children: [
                  // Supprimer compte
                  GestureDetector(
                    onTap: () {
                      // TODO: Implement account deletion
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.danger,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Supprimer mon compte',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Déconnexion
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Se déconnecter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    ModalUtils.showBlurredBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditProfileSheet(),
    );
  }

  void _confirmLogout(BuildContext context) {
    ModalUtils.showBlurredDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.surfaceColor,
        title: const Text(
          'Se déconnecter',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          'Voulez-vous vraiment vous déconnecter de DoctoPing ?',
          style: TextStyle(color: context.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AppServices.authRepository.logout();
              } on ApiException {
                // Session is still cleared locally by repository.
              } catch (_) {
                // Continue with local logout navigation.
              }
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Déconnecter',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: context.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionManager>();
    final user = session.currentUser;
    final firstName = (user?.firstName ?? '').trim();
    final lastName = (user?.lastName ?? '').trim();
    final fullName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Mon compte';
    final email = user?.email ?? 'email@doctoping.com';
    final initials = _buildInitials(firstName, lastName);
    final isVerified = user?.isVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.surfaceColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: context.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVerified ? 'Patient vérifié' : 'Patient',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isVerified
                          ? Icons.verified_rounded
                          : Icons.verified_user_outlined,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // RDV badge
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryLightColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '12',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'RDV',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: context.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildInitials(String firstName, String lastName) {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final initials = '$first$last'.toUpperCase();
    return initials.isNotEmpty ? initials : 'DP';
  }
}

class _HealthStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _HealthStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor, width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, value;

  const _HealthInfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.edit_outlined, size: 14, color: context.textMuted),
        ],
      ),
    );
  }
}

class _FavoriteDoc extends StatelessWidget {
  final String initials, name, specialty;
  final Color color;

  const _FavoriteDoc({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          if (specialty.isNotEmpty)
            Text(
              specialty,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: context.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ── Modal Édition du profil ────────────────────────────────────

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet();

  @override
  Widget build(BuildContext context) {

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Modifier le profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar éditable
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          'JD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.surfaceColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _EditField(
                label: 'Prénom',
                initial: 'Jean',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _EditField(
                label: 'Nom',
                initial: 'Dupont',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _EditField(
                label: 'Email',
                initial: 'jean.dupont@email.com',
                icon: Icons.mail_outline_rounded,
              ),
              const SizedBox(height: 16),
              _EditField(
                label: 'Téléphone',
                initial: '+237 6XX XXX XXX',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              _EditField(
                label: 'Date de naissance',
                initial: '15 / 03 / 1990',
                icon: Icons.cake_outlined,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sauvegarder les modifications',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label, initial;
  final IconData icon;

  const _EditField({
    required this.label,
    required this.initial,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initial,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: context.textMuted),
          ),
        ),
      ],
    );
  }
}
