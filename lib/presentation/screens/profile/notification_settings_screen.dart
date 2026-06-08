import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _appointmentReminders = true;
  bool _appointmentConfirmations = true;
  bool _appointmentCancellations = true;
  bool _medicationReminders = true;
  bool _labResults = true;
  bool _prescriptions = true;
  bool _promotions = false;
  bool _healthTips = true;
  bool _systemUpdates = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toutes les notifications
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _allNotifications
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : context.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _allNotifications
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: _allNotifications
                          ? AppColors.primary
                          : context.textMuted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Toutes les notifications',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Activer/désactiver toutes',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _allNotifications,
                    onChanged: (value) {
                      setState(() {
                        _allNotifications = value;
                        if (!value) {
                          _appointmentReminders = false;
                          _appointmentConfirmations = false;
                          _appointmentCancellations = false;
                          _medicationReminders = false;
                          _labResults = false;
                          _prescriptions = false;
                          _promotions = false;
                          _healthTips = false;
                          _systemUpdates = false;
                        }
                      });
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rendez-vous
            Text(
              'Rendez-vous',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _NotificationTile(
              icon: Icons.event_available_rounded,
              title: 'Rappels de rendez-vous',
              subtitle: '24h et 1h avant',
              value: _appointmentReminders,
              onChanged: (v) => setState(() => _appointmentReminders = v),
            ),
            _NotificationTile(
              icon: Icons.check_circle_outline_rounded,
              title: 'Confirmations',
              subtitle: 'Confirmation de réservation',
              value: _appointmentConfirmations,
              onChanged: (v) => setState(() => _appointmentConfirmations = v),
            ),
            _NotificationTile(
              icon: Icons.cancel_outlined,
              title: 'Annulations',
              subtitle: 'Annulation ou modification',
              value: _appointmentCancellations,
              onChanged: (v) => setState(() => _appointmentCancellations = v),
            ),

            const SizedBox(height: 24),

            // Santé
            Text(
              'Santé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _NotificationTile(
              icon: Icons.medication_rounded,
              title: 'Rappels de médicaments',
              subtitle: 'Prise de médicaments',
              value: _medicationReminders,
              onChanged: (v) => setState(() => _medicationReminders = v),
            ),
            _NotificationTile(
              icon: Icons.science_rounded,
              title: 'Résultats de laboratoire',
              subtitle: 'Nouveaux résultats disponibles',
              value: _labResults,
              onChanged: (v) => setState(() => _labResults = v),
            ),
            _NotificationTile(
              icon: Icons.receipt_long_rounded,
              title: 'Ordonnances',
              subtitle: 'Nouvelles ordonnances',
              value: _prescriptions,
              onChanged: (v) => setState(() => _prescriptions = v),
            ),

            const SizedBox(height: 24),

            // Autres
            Text(
              'Autres',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _NotificationTile(
              icon: Icons.local_offer_rounded,
              title: 'Promotions',
              subtitle: 'Offres et réductions',
              value: _promotions,
              onChanged: (v) => setState(() => _promotions = v),
            ),
            _NotificationTile(
              icon: Icons.tips_and_updates_rounded,
              title: 'Conseils santé',
              subtitle: 'Articles et conseils',
              value: _healthTips,
              onChanged: (v) => setState(() => _healthTips = v),
            ),
            _NotificationTile(
              icon: Icons.system_update_rounded,
              title: 'Mises à jour système',
              subtitle: 'Nouvelles fonctionnalités',
              value: _systemUpdates,
              onChanged: (v) => setState(() => _systemUpdates = v),
            ),

            const SizedBox(height: 24),

            // Canaux de notification
            Text(
              'Canaux de notification',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _NotificationTile(
              icon: Icons.notifications_rounded,
              title: 'Notifications push',
              subtitle: 'Sur votre appareil',
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            _NotificationTile(
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: 'Par email',
              value: _emailNotifications,
              onChanged: (v) => setState(() => _emailNotifications = v),
            ),
            _NotificationTile(
              icon: Icons.sms_rounded,
              title: 'SMS',
              subtitle: 'Par message texte',
              value: _smsNotifications,
              onChanged: (v) => setState(() => _smsNotifications = v),
            ),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Les notifications importantes (urgences, sécurité) ne peuvent pas être désactivées.',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : context.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: value ? AppColors.primary : context.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
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
