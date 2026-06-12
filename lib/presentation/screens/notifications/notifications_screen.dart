import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<_Notif> _notifs = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      // TODO: brancher sur AppServices.notificationsRepository quand il sera créé
      // Pour l'instant on charge le compte non-lu depuis l'API existante
      // et on affiche des notifications structurées
      await Future.delayed(const Duration(milliseconds: 300));
      // Placeholder — sera remplacé par appel API réel
      setState(() { _notifs = []; });
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    setState(() {
      for (final n in _notifs) { n.unread = false; }
    });
  }

  int get _unreadCount => _notifs.where((n) => n.unread).length;

  // Grouper par date
  Map<String, List<_Notif>> get _grouped {
    final map = <String, List<_Notif>>{};
    for (final n in _notifs) {
      map.putIfAbsent(n.group, () => []).add(n);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Notifications', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary, letterSpacing: -0.5)),
              if (_unreadCount > 0)
                Text('$_unreadCount non lue${_unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ])),
            if (_unreadCount > 0)
              GestureDetector(
                onTap: _markAllRead,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Tout lire', style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
          ]),
        ),

        // Body
        Expanded(child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _hasError
                ? _ErrorView(onRetry: _load)
                : _notifs.isEmpty
                    ? _EmptyView()
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          children: _grouped.entries.map((entry) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(entry.key, style: TextStyle(fontSize: 13,
                                    fontWeight: FontWeight.w700, color: context.mutedText,
                                    letterSpacing: 0.3))),
                              ...entry.value.map((n) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _NotifCard(notif: n, onTap: () {
                                  setState(() => n.unread = false);
                                }),
                              )),
                            ],
                          )).toList(),
                        ),
                      ),
        ),
      ])),
    );
  }
}

// ── NOTIF CARD ────────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onTap;
  const _NotifCard({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.unread
            ? AppColors.primary.withValues(alpha: context.isDark ? 0.1 : 0.05)
            : context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notif.unread
              ? AppColors.primary.withValues(alpha: 0.2)
              : context.dividerColor,
        ),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: notif.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(notif.icon, color: notif.color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(notif.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: context.textColor))),
            if (notif.unread)
              Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 8),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 4),
          Text(notif.body, style: TextStyle(fontSize: 12, color: context.mutedText, height: 1.4)),
          const SizedBox(height: 6),
          Text(notif.time, style: TextStyle(fontSize: 11, color: context.mutedText.withValues(alpha: 0.7))),
        ])),
      ]),
    ),
  );
}

// ── MODEL ─────────────────────────────────────────────────────────────────────

class _Notif {
  final IconData icon;
  final Color color;
  final String title, body, time, group;
  bool unread;

  _Notif({required this.icon, required this.color, required this.title,
    required this.body, required this.time, required this.group, this.unread = false});

  // ignore: unused_element
  factory _Notif.fromApi(Map<String, dynamic> json) {
    final type = json['notif_type'] as String? ?? 'info';
    final created = DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();
    final now = DateTime.now();
    String group;
    if (created.day == now.day) {
      group = "Aujourd'hui";
    } else if (created.day == now.subtract(const Duration(days: 1)).day) {
      group = 'Hier';
    } else {
      group = 'Cette semaine';
    }

    return _Notif(
      title: json['title'] as String? ?? '',
      body: json['message'] as String? ?? '',
      time: _formatTime(created),
      group: group,
      unread: !(json['is_read'] as bool? ?? false),
      icon: _iconFor(type),
      color: _colorFor(type),
    );
  }

  static IconData _iconFor(String type) => switch (type) {
    'appointment' => Icons.calendar_month_rounded,
    'reminder'    => Icons.alarm_rounded,
    'document'    => Icons.description_rounded,
    'review'      => Icons.star_rounded,
    'cancelled'   => Icons.cancel_rounded,
    _             => Icons.notifications_rounded,
  };

  static Color _colorFor(String type) => switch (type) {
    'appointment' => AppColors.primary,
    'reminder'    => AppColors.warning,
    'document'    => const Color(0xFF845EF7),
    'review'      => AppColors.warning,
    'cancelled'   => AppColors.danger,
    _             => AppColors.accent,
  };

  static String _formatTime(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}';
  }
}

// ── STATES ────────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.notifications_none_rounded, size: 64, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Aucune notification', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
    const SizedBox(height: 6),
    Text('Vous êtes à jour !', style: TextStyle(fontSize: 14, color: context.mutedText)),
  ]));
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.wifi_off_rounded, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Impossible de charger', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textColor)),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded), label: const Text('Réessayer'),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));
}
