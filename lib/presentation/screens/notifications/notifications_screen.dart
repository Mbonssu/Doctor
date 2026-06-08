import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../widgets/shared_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifGroup> _groups = [
    _NotifGroup(label: "Aujourd'hui", items: [
      _Notif(icon: Icons.calendar_month_rounded, color: AppColors.primary,
          title: 'Rappel de RDV demain', body: 'Dr. Amine Toure · Cardiologie · 14h30 à l\'Hôpital Central',
          time: 'il y a 5 min', unread: true, type: _NotifType.reminder),
      _Notif(icon: Icons.check_circle_rounded, color: AppColors.accent,
          title: 'RDV confirmé', body: 'Votre rendez-vous avec Dr. Nathalie Bello le Mer 21 Mai est confirmé.',
          time: 'il y a 2h', unread: true, type: _NotifType.confirmation),
    ]),
    _NotifGroup(label: 'Hier', items: [
      _Notif(icon: Icons.description_rounded, color: const Color(0xFF845EF7),
          title: 'Ordonnance disponible', body: 'L\'ordonnance de votre consultation du 15 Avril est disponible.',
          time: 'Hier, 16h22', unread: true, type: _NotifType.document),
      _Notif(icon: Icons.star_rounded, color: AppColors.warning,
          title: 'Donnez votre avis', body: 'Comment s\'est passée votre consultation avec Dr. Paul Mbarga ?',
          time: 'Hier, 10h00', unread: false, type: _NotifType.review),
      _Notif(icon: Icons.cancel_rounded, color: AppColors.danger,
          title: 'RDV annulé', body: 'Votre RDV avec Dr. Marc Ela du 3 Mars a été annulé. Vous pouvez en reprendre un.',
          time: 'Hier, 09h15', unread: false, type: _NotifType.cancelled),
    ]),
    _NotifGroup(label: 'Cette semaine', items: [
      _Notif(icon: Icons.medication_rounded, color: AppColors.danger,
          title: 'Rappel médicament', body: 'N\'oubliez pas votre Amlodipine 5mg ce soir avant le dîner.',
          time: 'Lun, 20h00', unread: false, type: _NotifType.medication),
      _Notif(icon: Icons.local_hospital_rounded, color: AppColors.primary,
          title: 'Nouveau médecin disponible', body: 'Dr. Rose Ateba · Orthopédie accepte maintenant les nouveaux patients.',
          time: 'Dim, 11h30', unread: false, type: _NotifType.info),
      _Notif(icon: Icons.health_and_safety_rounded, color: AppColors.accent,
          title: 'Bilan annuel recommandé', body: 'Il est temps de faire votre bilan de santé annuel. Prenez un RDV dès maintenant.',
          time: 'Sam, 09h00', unread: false, type: _NotifType.info),
    ]),
  ];

  int get _unreadCount => _groups.expand((g) => g.items).where((n) => n.unread).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        Text('Notifications',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                color: context.textPrimary, letterSpacing: -0.5)),
                        if (_unreadCount > 0) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('$_unreadCount',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        for (final g in _groups) {
                          for (final n in g.items) {
                            n.unread = false;
                          }
                        }
                      });
                    },
                    child: const Text('Tout lire',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            // Filtres par type
            SizedBox(
              height: 38,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  _NotifFilter(label: 'Tous', active: true),
                  _NotifFilter(label: '📅 RDV', active: false),
                  _NotifFilter(label: '📄 Documents', active: false),
                  _NotifFilter(label: '💊 Médicaments', active: false),
                  _NotifFilter(label: '⭐ Avis', active: false),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _groups.every((g) => g.items.isEmpty)
                  ? const EmptyState(
                      icon: Icons.notifications_off_outlined,
                      title: 'Aucune notification',
                      subtitle: 'Vous verrez ici vos rappels, confirmations et alertes.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        itemCount: _groups.length,
                        itemBuilder: (_, gi) {
                          final group = _groups[gi];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, top: 6),
                                child: Text(group.label,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                        color: context.textMuted, letterSpacing: 0.3)),
                              ),
                              ...group.items.map((n) => _NotifTile(
                                notif: n,
                                onTap: () => setState(() => n.unread = false),
                                onDismiss: () => setState(() => group.items.remove(n)),
                              )),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifTile({required this.notif, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.title + notif.time),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.unread
                ? context.primaryLightColor
                : (context.surfaceColor),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.unread ? context.primary100Color : (context.borderColor),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: notif.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(notif.icon, color: notif.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(notif.title,
                          style: TextStyle(
                              fontSize: 13, fontWeight: notif.unread ? FontWeight.w700 : FontWeight.w600,
                              color: context.textPrimary))),
                      Text(notif.time,
                          style: TextStyle(fontSize: 10, color: context.textMuted)),
                    ]),
                    const SizedBox(height: 4),
                    Text(notif.body,
                        style: TextStyle(fontSize: 12, color: context.textSecondary, height: 1.4)),
                  ],
                ),
              ),
              if (notif.unread) ...[
                const SizedBox(width: 8),
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifFilter extends StatelessWidget {
  final String label;
  final bool active;
  const _NotifFilter({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : context.surfaceColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
          color: active ? Colors.white : context.textSecondary)),
    );
  }
}

enum _NotifType { reminder, confirmation, document, review, cancelled, medication, info }

class _NotifGroup {
  final String label;
  final List<_Notif> items;
  _NotifGroup({required this.label, required this.items});
}

class _Notif {
  final IconData icon;
  final Color color;
  final String title, body, time;
  bool unread;
  final _NotifType type;

  _Notif({required this.icon, required this.color, required this.title,
      required this.body, required this.time, required this.unread, required this.type});
}
