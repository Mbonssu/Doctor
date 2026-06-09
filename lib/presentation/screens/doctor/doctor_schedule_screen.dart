import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

// ─── Modèle ──────────────────────────────────────────────────────────────────

class TimeSlot {
  final String time;
  bool available;
  bool isBooked; // true = créneau pris par un patient

  TimeSlot({
    required this.time,
    required this.available,
    this.isBooked = false,
  });

  TimeSlot copyWith({bool? available, bool? isBooked}) => TimeSlot(
        time: time,
        available: available ?? this.available,
        isBooked: isBooked ?? this.isBooked,
      );
}

class _DayConfig {
  final String shortName;
  final String fullName;
  final int dateOffset; // relatif à aujourd'hui

  const _DayConfig({
    required this.shortName,
    required this.fullName,
    required this.dateOffset,
  });
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedDayIndex = 0;
  bool _isSaving = false;

  final _today = DateTime.now();

  final _days = const [
    _DayConfig(shortName: 'Lun', fullName: 'Lundi', dateOffset: 0),
    _DayConfig(shortName: 'Mar', fullName: 'Mardi', dateOffset: 1),
    _DayConfig(shortName: 'Mer', fullName: 'Mercredi', dateOffset: 2),
    _DayConfig(shortName: 'Jeu', fullName: 'Jeudi', dateOffset: 3),
    _DayConfig(shortName: 'Ven', fullName: 'Vendredi', dateOffset: 4),
    _DayConfig(shortName: 'Sam', fullName: 'Samedi', dateOffset: 5),
    _DayConfig(shortName: 'Dim', fullName: 'Dimanche', dateOffset: 6),
  ];

  // TODO: charger depuis API au lieu de données mock
  late final Map<int, List<TimeSlot>> _schedule = {
    0: _buildSlots(['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        booked: ['10:00']),
    1: _buildSlots(['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        unavailable: ['09:00']),
    2: [],
    3: _buildSlots(['09:00', '10:00', '11:00', '14:00', '15:00'],
        booked: ['11:00']),
    4: _buildSlots(['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
        unavailable: ['14:00']),
    5: [],
    6: [],
  };

  // Config générale (éditable)
  int _consultDurationMinutes = 30;
  int _bufferMinutes = 15;
  int _maxPatientsPerDay = 20;

  @override
  bool get wantKeepAlive => true;

  List<TimeSlot> _buildSlots(
    List<String> times, {
    List<String> unavailable = const [],
    List<String> booked = const [],
  }) {
    return times
        .map((t) => TimeSlot(
              time: t,
              available: !unavailable.contains(t),
              isBooked: booked.contains(t),
            ))
        .toList();
  }

  List<TimeSlot> get _currentSlots => _schedule[_selectedDayIndex] ?? [];

  int get _availableCount =>
      _currentSlots.where((s) => s.available && !s.isBooked).length;

  int get _bookedCount => _currentSlots.where((s) => s.isBooked).length;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _WeekSelector(
              days: _days,
              selectedIndex: _selectedDayIndex,
              today: _today,
              onSelect: (i) => setState(() => _selectedDayIndex = i),
            ),
            const SizedBox(height: 20),
            _DaySummary(
              dayName: _days[_selectedDayIndex].fullName,
              availableCount: _availableCount,
              bookedCount: _bookedCount,
            ),
            const SizedBox(height: 20),
            if (_currentSlots.isEmpty)
              _EmptyDayView(
                onAdd: () => _showAddSlotsSheet(context),
              )
            else ...[
              _SlotsGrid(
                slots: _currentSlots,
                onToggle: (slot) {
                  if (slot.isBooked) return; // ne peut pas désactiver un slot pris
                  setState(() => slot.available = !slot.available);
                },
              ),
              const SizedBox(height: 16),
              _SaveButton(
                isSaving: _isSaving,
                onSave: _saveSchedule,
              ),
            ],
            const SizedBox(height: 32),
            _ConsultationConfig(
              durationMinutes: _consultDurationMinutes,
              bufferMinutes: _bufferMinutes,
              maxPatients: _maxPatientsPerDay,
              onEditDuration: () => _showPickerDialog(
                context,
                title: 'Durée de consultation',
                values: [15, 20, 30, 45, 60],
                unit: 'min',
                current: _consultDurationMinutes,
                onSelect: (v) => setState(() => _consultDurationMinutes = v),
              ),
              onEditBuffer: () => _showPickerDialog(
                context,
                title: 'Intervalle entre RDV',
                values: [5, 10, 15, 20, 30],
                unit: 'min',
                current: _bufferMinutes,
                onSelect: (v) => setState(() => _bufferMinutes = v),
              ),
              onEditMaxPatients: () => _showPickerDialog(
                context,
                title: 'Patients par jour',
                values: [5, 10, 15, 20, 25, 30],
                unit: 'patients',
                current: _maxPatientsPerDay,
                onSelect: (v) => setState(() => _maxPatientsPerDay = v),
              ),
            ),
          ],
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horaires',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textColor,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'Gérez vos disponibilités',
            style: TextStyle(
              fontSize: 12,
              color: context.mutedText,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          onPressed: () => _showAddSlotsSheet(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Future<void> _saveSchedule() async {
    setState(() => _isSaving = true);
    try {
      // TODO: sauvegarder via API
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Horaires enregistrés'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAddSlotsSheet(BuildContext context) {
    // TODO: bottom sheet pour ajouter des créneaux
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddSlotsPlaceholder(),
    );
  }

  void _showPickerDialog(
    BuildContext context, {
    required String title,
    required List<int> values,
    required String unit,
    required int current,
    required void Function(int) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _PickerDialog(
        title: title,
        values: values,
        unit: unit,
        current: current,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ─── Week selector ────────────────────────────────────────────────────────────

class _WeekSelector extends StatelessWidget {
  final List<_DayConfig> days;
  final int selectedIndex;
  final DateTime today;
  final ValueChanged<int> onSelect;

  const _WeekSelector({
    required this.days,
    required this.selectedIndex,
    required this.today,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = selectedIndex == i;
          final date = today.add(Duration(days: days[i].dateOffset));
          final isToday = days[i].dateOffset == 0;

          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 56,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : context.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : isToday
                          ? AppColors.primary
                          : context.dividerColor,
                  width: isToday && !isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[i].shortName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : context.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : context.textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Day summary ──────────────────────────────────────────────────────────────

class _DaySummary extends StatelessWidget {
  final String dayName;
  final int availableCount;
  final int bookedCount;

  const _DaySummary({
    required this.dayName,
    required this.availableCount,
    required this.bookedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            dayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          _SummaryChip(
            label: '$availableCount libres',
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          _SummaryChip(
            label: '$bookedCount pris',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Slots grid ───────────────────────────────────────────────────────────────

class _SlotsGrid extends StatelessWidget {
  final List<TimeSlot> slots;
  final void Function(TimeSlot) onToggle;

  const _SlotsGrid({required this.slots, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux horaires',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Appuyez pour activer / désactiver un créneau',
          style: TextStyle(fontSize: 12, color: context.mutedText),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
          ),
          itemCount: slots.length,
          itemBuilder: (_, i) => _SlotChip(
            slot: slots[i],
            onToggle: () => onToggle(slots[i]),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          children: [
            _LegendItem(color: AppColors.primary, label: 'Disponible'),
            const SizedBox(width: 16),
            _LegendItem(color: AppColors.warning, label: 'Réservé'),
            const SizedBox(width: 16),
            _LegendItem(color: AppColors.border, label: 'Inactif'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.mutedText),
        ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  final TimeSlot slot;
  final VoidCallback onToggle;

  const _SlotChip({required this.slot, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final Color borderColor;

    if (slot.isBooked) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      textColor = AppColors.warning;
      borderColor = AppColors.warning.withValues(alpha: 0.3);
    } else if (slot.available) {
      bg = AppColors.primary.withValues(alpha: 0.1);
      textColor = AppColors.primary;
      borderColor = AppColors.primary.withValues(alpha: 0.3);
    } else {
      bg = context.cardColor;
      textColor = context.mutedText;
      borderColor = context.dividerColor;
    }

    return GestureDetector(
      onTap: slot.isBooked ? null : onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            slot.time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Save button ──────────────────────────────────────────────────────────────

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveButton({required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isSaving ? null : onSave,
        icon: isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_rounded, size: 18),
        label: Text(isSaving ? 'Enregistrement...' : 'Enregistrer'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ─── Consultation config ──────────────────────────────────────────────────────

class _ConsultationConfig extends StatelessWidget {
  final int durationMinutes;
  final int bufferMinutes;
  final int maxPatients;
  final VoidCallback onEditDuration;
  final VoidCallback onEditBuffer;
  final VoidCallback onEditMaxPatients;

  const _ConsultationConfig({
    required this.durationMinutes,
    required this.bufferMinutes,
    required this.maxPatients,
    required this.onEditDuration,
    required this.onEditBuffer,
    required this.onEditMaxPatients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration générale',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.textColor,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        _ConfigTile(
          icon: Icons.timer_outlined,
          title: 'Durée de consultation',
          value: '$durationMinutes min',
          onTap: onEditDuration,
        ),
        const SizedBox(height: 8),
        _ConfigTile(
          icon: Icons.schedule_outlined,
          title: 'Intervalle entre RDV',
          value: '$bufferMinutes min',
          onTap: onEditBuffer,
        ),
        const SizedBox(height: 8),
        _ConfigTile(
          icon: Icons.people_outline_rounded,
          title: 'Patients par jour',
          value: '$maxPatients patients',
          onTap: onEditMaxPatients,
        ),
      ],
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ConfigTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textColor,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty day ────────────────────────────────────────────────────────────────

class _EmptyDayView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyDayView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: context.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.event_available_outlined,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pas de consultation ce jour',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ajoutez des créneaux pour ce jour',
              style: TextStyle(fontSize: 13, color: context.mutedText),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter des créneaux'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Picker dialog ────────────────────────────────────────────────────────────

class _PickerDialog extends StatelessWidget {
  final String title;
  final List<int> values;
  final String unit;
  final int current;
  final ValueChanged<int> onSelect;

  const _PickerDialog({
    required this.title,
    required this.values,
    required this.unit,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
      ),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values.map((v) {
          final isSelected = v == current;
          return GestureDetector(
            onTap: () => onSelect(v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : context.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : context.dividerColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$v $unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : context.textColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Fermer',
            style: TextStyle(color: context.mutedText),
          ),
        ),
      ],
    );
  }
}

// ─── Add slots placeholder ────────────────────────────────────────────────────

class _AddSlotsPlaceholder extends StatelessWidget {
  const _AddSlotsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ajouter des créneaux',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fonctionnalité à venir — sélection manuelle de plages horaires.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.mutedText,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
