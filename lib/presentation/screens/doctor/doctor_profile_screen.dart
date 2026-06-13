import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  bool _isEditing = false;

  late final TextEditingController _bioCtrl;
  late final TextEditingController _specialtyCtrl;
  late final TextEditingController _experienceCtrl;
  late final TextEditingController _clinicCtrl;
  late final TextEditingController _cityCtrl;

  final _formKey = GlobalKey<FormState>();

  // TODO: charger depuis AppServices.authSessionManager.user et DoctorService

  // Chargement réel depuis l'API
  bool _isLoadingProfile = true;
  late final TextEditingController _licenseCtrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _specialtyCtrl  = TextEditingController();
    _experienceCtrl = TextEditingController();
    _bioCtrl        = TextEditingController();
    _clinicCtrl     = TextEditingController();
    _cityCtrl       = TextEditingController();
    _licenseCtrl    = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doctor = await AppServices.doctorRepository.getMyProfile();
      if (!mounted) return;
      _specialtyCtrl.text  = doctor.specialty;
      _experienceCtrl.text = '${doctor.yearsOfExperience}';
      _bioCtrl.text        = doctor.bio ?? '';
      _clinicCtrl.text     = doctor.hospitalName ?? '';
      _cityCtrl.text       = doctor.city ?? '';
      _licenseCtrl.text    = doctor.licenseNumber;
    } catch (_) {
      // Garder les champs vides — l'utilisateur les remplit manuellement
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _specialtyCtrl.dispose();
    _experienceCtrl.dispose();
    _clinicCtrl.dispose();
    _cityCtrl.dispose();
    _licenseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoadingProfile) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = AppServices.authSessionManager.user;
    final fullName = user?.fullName ?? 'Dr. Médecin';
    final initial = user?.firstName.isNotEmpty == true ? user!.firstName[0] : 'D';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ─── Hero header card ───────────────────────────────────────
              _ProfileHeroCard(
                name: fullName,
                initial: initial,
                specialty: _specialtyCtrl.text,
                email: user?.email ?? '',
                isEditing: _isEditing,
              ),
              const SizedBox(height: 24),
              // ─── Stats ─────────────────────────────────────────────────
              if (!_isEditing)
                _StatsRow(),
              if (!_isEditing) const SizedBox(height: 24),
              // ─── Professional info ────────────────────────────────────
              _SectionCard(
                title: 'Informations professionnelles',
                icon: Icons.work_outline_rounded,
                children: [
                  _ProfileField(
                    label: 'Spécialité',
                    controller: _specialtyCtrl,
                    enabled: _isEditing,
                    icon: Icons.medical_services_outlined,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 14),
                  _ProfileField(
                    label: "Années d'expérience",
                    controller: _experienceCtrl,
                    enabled: _isEditing,
                    icon: Icons.timeline_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 14),
                  _ProfileField(
                    label: 'Biographie',
                    controller: _bioCtrl,
                    enabled: _isEditing,
                    icon: Icons.description_outlined,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ─── Location ─────────────────────────────────────────────
              _SectionCard(
                title: 'Lieu de pratique',
                icon: Icons.location_on_outlined,
                children: [
                  _ProfileField(
                    label: 'Clinique / Hôpital',
                    controller: _clinicCtrl,
                    enabled: _isEditing,
                    icon: Icons.local_hospital_outlined,
                  ),
                  const SizedBox(height: 14),
                  _ProfileField(
                    label: 'Ville',
                    controller: _cityCtrl,
                    enabled: _isEditing,
                    icon: Icons.place_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ─── Static info ───────────────────────────────────────────
              if (!_isEditing)
                _SectionCard(
                  title: 'Informations légales',
                  icon: Icons.verified_outlined,
                  children: [
                    _InfoRow(
                      label: 'Numéro de licence',
                      value: _licenseCtrl.text.isNotEmpty ? _licenseCtrl.text : 'Non renseigné',
                    ),
                  ],
                ),
              if (!_isEditing) const SizedBox(height: 16),
              // ─── Action buttons ───────────────────────────────────────
              _ActionsSection(
                isEditing: _isEditing,
                isLoading: _isLoading,
                onSave: _saveProfile,
                onViewReviews: () {},
                onSupport: () {},
                onLogout: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        'Mon Profil',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: context.textColor,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isEditing
              ? TextButton(
                  key: const ValueKey('cancel'),
                  onPressed: () => setState(() => _isEditing = false),
                  child: Text(
                    'Annuler',
                    style: TextStyle(color: context.mutedText, fontSize: 14),
                  ),
                )
              : IconButton(
                  key: const ValueKey('edit'),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  onPressed: () => setState(() => _isEditing = true),
                ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await AppServices.doctorRepository.updateMyProfile({
        'specialty': _specialtyCtrl.text.trim(),
        'years_of_experience': int.tryParse(_experienceCtrl.text) ?? 0,
        'bio': _bioCtrl.text.trim(),
        'hospital_name': _clinicCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() { _isEditing = false; _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profil mis à jour'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Se déconnecter',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: ctx.textColor,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: ctx.mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annuler',
              style: TextStyle(color: ctx.mutedText),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await AppServices.authSessionManager.logout();
    }
  }
}

// ─── Hero profile card ────────────────────────────────────────────────────────

class _ProfileHeroCard extends StatelessWidget {
  final String name;
  final String initial;
  final String specialty;
  final String email;
  final bool isEditing;

  const _ProfileHeroCard({
    required this.name,
    required this.initial,
    required this.specialty,
    required this.email,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            specialty,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          // Verified badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                const Text(
                  'Médecin certifié',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: '324', label: 'Patients', color: AppColors.primary),
        const SizedBox(width: 10),
        _StatBox(value: '156', label: 'RDV/mois', color: AppColors.accent),
        const SizedBox(width: 10),
        _StatBox(value: '4.8★', label: 'Note', color: AppColors.warning),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: context.mutedText,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textColor,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

// ─── Profile field ────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: context.mutedText),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.mutedText,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontSize: 14,
            color: context.textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled
                ? context.bgColor
                : context.cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: context.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Info row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: context.mutedText,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Actions section ──────────────────────────────────────────────────────────

class _ActionsSection extends StatelessWidget {
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onViewReviews;
  final VoidCallback onSupport;
  final VoidCallback onLogout;

  const _ActionsSection({
    required this.isEditing,
    required this.isLoading,
    required this.onSave,
    required this.onViewReviews,
    required this.onSupport,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onSave,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(isLoading ? 'Enregistrement...' : 'Enregistrer'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _ActionButton(
          icon: Icons.star_outline_rounded,
          label: 'Voir les avis (4.8★ · 234)',
          isPrimary: true,
          onTap: onViewReviews,
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.help_outline_rounded,
          label: 'Aide & Support',
          isPrimary: false,
          onTap: onSupport,
        ),
        const SizedBox(height: 10),
        _ActionButton(
          icon: Icons.logout_rounded,
          label: 'Se déconnecter',
          isPrimary: false,
          isDestructive: true,
          onTap: onLogout,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.danger : AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}


