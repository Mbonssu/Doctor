import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../core/di/app_services.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  int _selectedDay = DateTime.now().weekday - 1;
  bool _isSaving = false;
  bool _isLoading = true;
  String? _error;

  final _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  // État local éditable
  int _consultDuration = 30;
  int _breakDuration = 10;
  int _maxPatients = 20;
  final Set<int> _restDays = {5, 6};
  final Map<int, Set<String>> _slots = {
    for (int i = 0; i < 7; i++) i: {},
  };
  final Map<int, Set<String>> _bookedSlots = {}; // créneaux pris (non modifiables)

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  // ─── API ────────────────────────────────────────────────────────────────────

  Future<void> _loadSchedule() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await AppServices.doctorRepository.getMySchedule();

      // Construire l'état local depuis la réponse API
      for (final s in data.schedules) {
        if (!s.isWorkingDay) _restDays.add(s.dayOfWeek);
        // Utiliser les settings du premier jour comme config globale
        if (s.dayOfWeek == _selectedDay) {
          _consultDuration = s.consultDurationMin;
          _breakDuration = s.breakDurationMin;
          _maxPatients = s.maxPatients;
        }
      }
      for (final slot in data.slots) {
        if (slot.isActive) {
          (_slots[slot.dayOfWeek] ??= {}).add(slot.time);
        }
      }
    } catch (e) {
      // En cas d'erreur (ex: pas encore de schedule), on garde les valeurs par défaut
      _error = null; // pas bloquant, l'utilisateur peut configurer depuis zéro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final daySlots = (_slots[_selectedDay] ?? {})
          .where((t) => !(_bookedSlots[_selectedDay] ?? {}).contains(t))
          .toList()
        ..sort();

      await AppServices.doctorRepository.updateMySchedule(
        dayOfWeek: _selectedDay,
        isWorkingDay: !_restDays.contains(_selectedDay),
        consultDurationMin: _consultDuration,
        breakDurationMin: _breakDuration,
        maxPatients: _maxPatients,
        slots: daySlots,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: const [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Horaires enregistrés'),
        ]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e.toString()}'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Actions locales ────────────────────────────────────────────────────────

  void _toggleSlot(String time) {
    if ((_bookedSlots[_selectedDay] ?? {}).contains(time)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Ce créneau a déjà un RDV réservé'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      final s = _slots[_selectedDay] ??= {};
      if (s.contains(time)) s.remove(time); else s.add(time);
    });
  }

  void _toggleRestDay(int day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_restDays.contains(day)) {
        _restDays.remove(day);
      } else {
        _restDays.add(day);
        _slots[day]?.clear();
      }
    });
  }

  // ─── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddSlotSheet() {
    final allSlots = <String>[];
    for (int h = 7; h < 20; h++) {
      allSlots.add('${h.toString().padLeft(2,'0')}:00');
      allSlots.add('${h.toString().padLeft(2,'0')}:30');
    }
    String? selected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Container(
        height: MediaQuery.of(ctx).size.height * 0.6,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 8),
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: context.dividerColor, borderRadius: BorderRadius.circular(2)))),
          Padding(padding: const EdgeInsets.all(20), child: Row(children: [
            Text('Ajouter un créneau — ${_days[_selectedDay]}',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
          ])),
          Expanded(child: ListView.builder(
            itemCount: allSlots.length,
            itemBuilder: (_, i) {
              final t = allSlots[i];
              final exists = (_slots[_selectedDay] ?? {}).contains(t);
              final booked = (_bookedSlots[_selectedDay] ?? {}).contains(t);
              return ListTile(
                enabled: !booked,
                title: Text(t, style: TextStyle(
                  color: exists ? AppColors.accent : booked ? context.mutedText : context.textColor,
                  fontWeight: selected == t ? FontWeight.w700 : FontWeight.normal,
                )),
                trailing: exists
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18)
                    : booked
                        ? Text('RDV', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600))
                        : selected == t
                            ? const Icon(Icons.radio_button_checked_rounded, color: AppColors.primary)
                            : const Icon(Icons.radio_button_unchecked_rounded),
                onTap: exists || booked ? null : () => setS(() => selected = t),
              );
            },
          )),
          Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: ElevatedButton(
              onPressed: selected == null ? null : () {
                setState(() => (_slots[_selectedDay] ??= {}).add(selected!));
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Ajouter le créneau', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      )),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: context.dividerColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Paramètres de consultation',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
          const SizedBox(height: 24),
          _SettingSlider(label: 'Durée de consultation', value: _consultDuration,
            min: 15, max: 90, step: 15, suffix: 'min',
            onChanged: (v) { setS(() {}); setState(() => _consultDuration = v); }),
          const SizedBox(height: 20),
          _SettingSlider(label: 'Pause entre RDV', value: _breakDuration,
            min: 0, max: 30, step: 5, suffix: 'min',
            onChanged: (v) { setS(() {}); setState(() => _breakDuration = v); }),
          const SizedBox(height: 20),
          _SettingSlider(label: 'Max patients / jour', value: _maxPatients,
            min: 5, max: 40, step: 5, suffix: 'patients',
            onChanged: (v) { setS(() {}); setState(() => _maxPatients = v); }),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Fermer'),
          ),
        ]),
      )),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final isRest = _restDays.contains(_selectedDay);
    final daySlots = (_slots[_selectedDay] ?? {}).toList()..sort();
    final dayBooked = _bookedSlots[_selectedDay] ?? {};
    final bookedCount = daySlots.where((s) => dayBooked.contains(s)).length;
    final freeCount = daySlots.length - bookedCount;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: context.bgColor,
            elevation: 0,
            centerTitle: true,
            title: Text('Horaires & Disponibilités',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.textColor)),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                onPressed: _showSettingsSheet,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(92),
              child: Column(children: [
                SizedBox(height: 80, child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _days.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final sel = _selectedDay == i;
                    final rest = _restDays.contains(i);
                    final count = (_slots[i] ?? {}).length;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = i),
                      onLongPress: () => _toggleRestDay(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : rest
                              ? AppColors.dangerBg : context.cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: sel ? AppColors.primary : rest
                              ? AppColors.danger.withValues(alpha: 0.3) : context.dividerColor),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_days[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : rest ? AppColors.danger : context.mutedText)),
                          const SizedBox(height: 3),
                          Text('${(DateTime.now().weekday - 1 == i) ? DateTime.now().day : DateTime.now().add(Duration(days: i - DateTime.now().weekday + 1)).day}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : context.textColor)),
                          if (!rest && count > 0)
                            Container(margin: const EdgeInsets.only(top: 3), width: 5, height: 5,
                              decoration: BoxDecoration(shape: BoxShape.circle,
                                color: sel ? Colors.white60 : AppColors.primary)),
                          if (rest)
                            Text('repos', style: TextStyle(fontSize: 8, color: AppColors.danger)),
                        ]),
                      ),
                    );
                  },
                )),
                const SizedBox(height: 6),
              ]),
            ),
          ),
        ],
        body: isRest
            ? _RestDayView(day: _days[_selectedDay], onEnable: () => _toggleRestDay(_selectedDay))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Résumé
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.accent.withValues(alpha: 0.05),
                      ]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(children: [
                      Expanded(child: _DayStat(value: '${daySlots.length}', label: 'Créneaux', color: AppColors.primary)),
                      Container(width: 1, height: 36, color: context.dividerColor),
                      Expanded(child: _DayStat(value: '$bookedCount', label: 'Réservés', color: AppColors.warning)),
                      Container(width: 1, height: 36, color: context.dividerColor),
                      Expanded(child: _DayStat(value: '$freeCount', label: 'Libres', color: AppColors.accent)),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Créneaux — ${_days[_selectedDay]}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textColor)),
                    GestureDetector(
                      onTap: _showAddSlotSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: const [
                          Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text('Ajouter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),

                  if (daySlots.isEmpty)
                    _EmptySlotsView(onAdd: _showAddSlotSheet)
                  else ...[
                    // Matin
                    final morning = daySlots.where((s) => int.parse(s.split(':')[0]) < 13).toList();
                    final afternoon = daySlots.where((s) => int.parse(s.split(':')[0]) >= 13).toList();
                    if (morning.isNotEmpty) ...[
                      _slotGroupLabel('Matin', Icons.wb_sunny_outlined, AppColors.warning),
                      const SizedBox(height: 8),
                      _SlotGrid(slots: morning, booked: dayBooked, onToggle: _toggleSlot),
                      const SizedBox(height: 20),
                    ],
                    if (afternoon.isNotEmpty) ...[
                      _slotGroupLabel('Après-midi', Icons.nights_stay_outlined, AppColors.primary),
                      const SizedBox(height: 8),
                      _SlotGrid(slots: afternoon, booked: dayBooked, onToggle: _toggleSlot),
                    ],
                  ],

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.cardColor, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.dividerColor)),
                    child: Row(children: [
                      Expanded(child: _ConfigChip(icon: Icons.timer_outlined, label: 'Durée', value: '$_consultDuration min')),
                      Expanded(child: _ConfigChip(icon: Icons.pause_circle_outline, label: 'Pause', value: '$_breakDuration min')),
                      Expanded(child: _ConfigChip(icon: Icons.people_outline_rounded, label: 'Max', value: '$_maxPatients/j')),
                    ]),
                  ),
                ]),
              ),
      ),
      floatingActionButton: isRest ? null : FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        backgroundColor: AppColors.primary,
        icon: _isSaving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _slotGroupLabel(String label, IconData icon, Color color) =>
    Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ]);
}

// ── WIDGETS PARTAGÉS ──────────────────────────────────────────────────────────

class _SlotGrid extends StatelessWidget {
  final List<String> slots;
  final Set<String> booked;
  final void Function(String) onToggle;
  const _SlotGrid({required this.slots, required this.booked, required this.onToggle});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.0),
    itemCount: slots.length,
    itemBuilder: (_, i) {
      final t = slots[i];
      final isBooked = booked.contains(t);
      return GestureDetector(
        onTap: () => onToggle(t),
        child: Container(
          decoration: BoxDecoration(
            color: isBooked ? AppColors.warningBg : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isBooked
                ? AppColors.warning.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Stack(alignment: Alignment.center, children: [
            Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: isBooked ? AppColors.warningText : AppColors.primary)),
            if (isBooked)
              Positioned(top: 4, right: 4, child: Container(width: 6, height: 6,
                decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle))),
          ]),
        ),
      );
    },
  );
}

class _SettingSlider extends StatelessWidget {
  final String label, suffix;
  final int value, min, max, step;
  final void Function(int) onChanged;
  const _SettingSlider({required this.label, required this.value, required this.min,
    required this.max, required this.step, required this.suffix, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textColor)),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text('$value $suffix', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary))),
    ]),
    Slider(value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
      divisions: (max - min) ~/ step, activeColor: AppColors.primary,
      onChanged: (v) => onChanged(v.round())),
  ]);
}

class _DayStat extends StatelessWidget {
  final String value, label; final Color color;
  const _DayStat({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: TextStyle(fontSize: 11, color: context.mutedText)),
  ]);
}

class _ConfigChip extends StatelessWidget {
  final IconData icon; final String label, value;
  const _ConfigChip({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.textColor)),
    Text(label, style: TextStyle(fontSize: 10, color: context.mutedText)),
  ]);
}

class _RestDayView extends StatelessWidget {
  final String day; final VoidCallback onEnable;
  const _RestDayView({required this.day, required this.onEnable});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 80, height: 80,
      decoration: BoxDecoration(color: AppColors.dangerBg, shape: BoxShape.circle),
      child: const Icon(Icons.hotel_rounded, size: 36, color: AppColors.danger)),
    const SizedBox(height: 16),
    Text('Jour de repos — $day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textColor)),
    const SizedBox(height: 8),
    Text('Appuie longuement sur le jour pour activer/désactiver',
      textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: context.mutedText)),
    const SizedBox(height: 24),
    OutlinedButton.icon(onPressed: onEnable,
      icon: const Icon(Icons.work_outline_rounded),
      label: Text('Activer $day'),
      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
  ]));
}

class _EmptySlotsView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySlotsView({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(child: Column(children: [
    const SizedBox(height: 40),
    Icon(Icons.schedule_outlined, size: 56, color: context.mutedText),
    const SizedBox(height: 12),
    Text('Aucun créneau configuré', style: TextStyle(fontSize: 15, color: context.mutedText)),
    const SizedBox(height: 16),
    ElevatedButton.icon(onPressed: onAdd,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Ajouter des créneaux'),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
    const SizedBox(height: 40),
  ]));
}
