import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

// ─── Modèle ──────────────────────────────────────────────────────────────────

class _AppointmentItem {
  final String patientName;
  final String date;
  final String time;
  final String reason;
  final String status;

  const _AppointmentItem({
    required this.patientName,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
  });

  String get initial => patientName.isNotEmpty ? patientName[0] : '?';
}

// ─── Données mock (TODO: remplacer par API) ───────────────────────────────────

const _mockData = {
  'pending': [
    _AppointmentItem(
      patientName: 'Jean Kouassi',
      date: '26 mai',
      time: '09:30',
      reason: 'Consultation générale',
      status: 'pending',
    ),
    _AppointmentItem(
      patientName: 'Marie Traoré',
      date: '26 mai',
      time: '11:00',
      reason: 'Suivi cardiaque',
      status: 'pending',
    ),
    _AppointmentItem(
      patientName: 'Aminata Coulibaly',
      date: '26 mai',
      time: '15:30',
      reason: 'Bilan de santé',
      status: 'pending',
    ),
  ],
  'confirmed': [
    _AppointmentItem(
      patientName: 'Pierre Yao',
      date: '26 mai',
      time: '14:30',
      reason: 'Visite post-opératoire',
      status: 'confirmed',
    ),
    _AppointmentItem(
      patientName: 'Sophie Dubois',
      date: '27 mai',
      time: '10:00',
      reason: 'Consultation',
      status: 'confirmed',
    ),
  ],
  'completed': [
    _AppointmentItem(
      patientName: 'Antoine Martin',
      date: '25 mai',
      time: '15:00',
      reason: 'Consultation',
      status: 'completed',
    ),
    _AppointmentItem(
      patientName: 'Fatou Diallo',
      date: '24 mai',
      time: '09:00',
      reason: 'Suivi mensuel',
      status: 'completed',
    ),
  ],
  'cancelled': <_AppointmentItem>[],
};

const _tabKeys = ['pending', 'confirmed', 'completed', 'cancelled'];
const _tabLabels = ['En attente', 'Confirmé', 'Complété', 'Annulé'];

// ─── Screen ──────────────────────────────────────────────────────────────────

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Compte les items en attente pour le badge
  int get _pendingCount =>
      (_mockData['pending'] ?? []).length;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(_tabKeys.length, (i) {
          final key = _tabKeys[i];
          return _AppointmentTabView(
            items: (_mockData[key] ?? []).cast<_AppointmentItem>(),
            status: key,
            isLoading: _isLoading,
            onAccept: key == 'pending' ? _confirmAppointment : null,
            onReject: key == 'pending' ? _rejectAppointment : null,
            onAddNote: key == 'completed' ? _addNote : null,
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rendez-vous',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textColor,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '$_pendingCount en attente de confirmation',
            style: TextStyle(
              fontSize: 12,
              color: context.mutedText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list_rounded,
            color: context.mutedText,
            size: 22,
          ),
          onPressed: () {
            // TODO: filtre par date / spécialité
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _CustomTabBar(
          controller: _tabController,
          labels: _tabLabels,
          pendingCount: _pendingCount,
        ),
      ),
    );
  }

  void _confirmAppointment(_AppointmentItem item) {
    // TODO: appel API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RDV de ${item.patientName} confirmé'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _rejectAppointment(_AppointmentItem item) {
    showDialog<String>(
      context: context,
      builder: (ctx) => _RejectDialog(
        patientName: item.patientName,
        onConfirm: (reason) {
          // TODO: appel API avec la raison
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('RDV de ${item.patientName} refusé'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addNote(_AppointmentItem item) {
    // TODO: navigation vers écran notes
  }
}

// ─── Custom tab bar ───────────────────────────────────────────────────────────

class _CustomTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final int pendingCount;

  const _CustomTabBar({
    required this.controller,
    required this.labels,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.dividerColor, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelColor: AppColors.primary,
        unselectedLabelColor: context.mutedText,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(2),
          insets: const EdgeInsets.symmetric(horizontal: 8),
        ),
        tabs: List.generate(labels.length, (i) {
          return Tab(
            child: Row(
              children: [
                Text(labels[i]),
                if (i == 0 && pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Tab view ─────────────────────────────────────────────────────────────────

class _AppointmentTabView extends StatelessWidget {
  final List<_AppointmentItem> items;
  final String status;
  final bool isLoading;
  final void Function(_AppointmentItem)? onAccept;
  final void Function(_AppointmentItem)? onReject;
  final void Function(_AppointmentItem)? onAddNote;

  const _AppointmentTabView({
    required this.items,
    required this.status,
    required this.isLoading,
    this.onAccept,
    this.onReject,
    this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (items.isEmpty) {
      return _EmptyState(status: status);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _AppointmentCard(
        item: items[i],
        onAccept: onAccept != null ? () => onAccept!(items[i]) : null,
        onReject: onReject != null ? () => onReject!(items[i]) : null,
        onAddNote: onAddNote != null ? () => onAddNote!(items[i]) : null,
      ),
    );
  }
}

// ─── Appointment card ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final _AppointmentItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onAddNote;

  const _AppointmentCard({
    required this.item,
    this.onAccept,
    this.onReject,
    this.onAddNote,
  });

  static Color _statusColor(String status) => switch (status) {
        'confirmed' => AppColors.success,
        'pending' => AppColors.warning,
        'completed' => AppColors.primary,
        'cancelled' => AppColors.danger,
        _ => AppColors.primary,
      };

  static String _statusLabel(String status) => switch (status) {
        'confirmed' => 'Confirmé',
        'pending' => 'En attente',
        'completed' => 'Complété',
        'cancelled' => 'Annulé',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.status);

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.6),
                        statusColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      item.initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.patientName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _statusLabel(item.status),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.mutedText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: context.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.mutedText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (onAccept != null || onReject != null || onAddNote != null)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.dividerColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Row(
                children: [
                  if (onReject != null) ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Refuser',
                        icon: Icons.close_rounded,
                        color: AppColors.danger,
                        filled: false,
                        onTap: onReject!,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (onAccept != null)
                    Expanded(
                      child: _ActionButton(
                        label: 'Confirmer',
                        icon: Icons.check_rounded,
                        color: AppColors.primary,
                        filled: true,
                        onTap: onAccept!,
                      ),
                    ),
                  if (onAddNote != null)
                    Expanded(
                      child: _ActionButton(
                        label: 'Ajouter notes',
                        icon: Icons.edit_note_rounded,
                        color: AppColors.primary,
                        filled: true,
                        onTap: onAddNote!,
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

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String status;

  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      'pending' => Icons.hourglass_empty_rounded,
      'cancelled' => Icons.event_busy_rounded,
      _ => Icons.check_circle_outline_rounded,
    };
    final message = switch (status) {
      'pending' => 'Aucun RDV en attente',
      'confirmed' => 'Aucun RDV confirmé',
      'completed' => 'Aucune consultation terminée',
      'cancelled' => 'Aucun RDV annulé',
      _ => 'Aucun rendez-vous',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: context.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revenez plus tard',
            style: TextStyle(fontSize: 13, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}

// ─── Reject dialog ────────────────────────────────────────────────────────────

class _RejectDialog extends StatefulWidget {
  final String patientName;
  final void Function(String reason) onConfirm;

  const _RejectDialog({
    required this.patientName,
    required this.onConfirm,
  });

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Refuser ce RDV ?',
        style: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient : ${widget.patientName}',
            style: TextStyle(color: context.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Raison du refus (optionnel)',
              hintStyle: TextStyle(color: context.mutedText, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(color: context.mutedText),
          ),
        ),
        FilledButton(
          onPressed: () => widget.onConfirm(_ctrl.text),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Refuser'),
        ),
      ],
    );
  }
}
