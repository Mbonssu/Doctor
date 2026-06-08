import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isLoading = false;
  bool _isEditing = false;

  late TextEditingController _bioCtrl;
  late TextEditingController _specialtyCtrl;
  late TextEditingController _experienceCtrl;

  @override
  void initState() {
    super.initState();
    _bioCtrl = TextEditingController();
    _specialtyCtrl = TextEditingController();
    _experienceCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _specialtyCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.authSessionManager.user;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mon Profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar section
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user?.firstName[0] ?? 'D',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Dr. Docteur',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.mutedText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats row
            if (!_isEditing)
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Patients',
                      value: '324',
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'RDV ce mois',
                      value: '156',
                      context: context,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Note',
                      value: '4.8★',
                      context: context,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 32),

            // Formulaire édition / Information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Informations Professionnelles', context),
                const SizedBox(height: 12),
                _buildEditableField(
                  label: 'Spécialité',
                  controller: _specialtyCtrl,
                  enabled: _isEditing,
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildEditableField(
                  label: 'Années d\'expérience',
                  controller: _experienceCtrl,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  context: context,
                ),
                const SizedBox(height: 12),
                _buildEditableField(
                  label: 'Biographie',
                  controller: _bioCtrl,
                  enabled: _isEditing,
                  maxLines: 3,
                  context: context,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Autres informations
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Autres Informations', context),
                const SizedBox(height: 12),
                _InfoTile(
                  label: 'Numéro de Licence',
                  value: 'LIC123456',
                  context: context,
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  label: 'Hôpital / Clinique',
                  value: 'CHU de Cocody',
                  context: context,
                ),
                const SizedBox(height: 8),
                _InfoTile(
                  label: 'Ville',
                  value: 'Abidjan',
                  context: context,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Boutons action
            Column(
              children: [
                if (_isEditing)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Enregistrer les modifications'),
                  ),
                if (!_isEditing) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      // Voir les avis
                    },
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('Voir les avis (4.8★ • 234)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Aide/Support
                    },
                    icon: const Icon(Icons.help_outline_rounded),
                    label: const Text('Aide & Support'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Se déconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.textColor,
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required BuildContext context,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.mutedText,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: enabled,
            fillColor: enabled
                ? context.bgColor
                : context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Sauvegarder le profil via l'API
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour')),
        );
        setState(() => _isEditing = false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await AppServices.authSessionManager.logout();
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _StatBox({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final BuildContext context;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.mutedText,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
        ],
      ),
    );
  }
}
