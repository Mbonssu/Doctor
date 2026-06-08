import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  int _selectedDay = 0;
  bool _isLoading = false;

  final _daysOfWeek = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  
  // Schedule données
  final Map<int, List<_TimeSlot>> _schedule = {
    0: [ // Lundi
      _TimeSlot(time: '08:00', available: true),
      _TimeSlot(time: '09:00', available: true),
      _TimeSlot(time: '10:00', available: false),
      _TimeSlot(time: '11:00', available: true),
      _TimeSlot(time: '14:00', available: true),
      _TimeSlot(time: '15:00', available: true),
      _TimeSlot(time: '16:00', available: false),
    ],
    1: [ // Mardi
      _TimeSlot(time: '08:00', available: true),
      _TimeSlot(time: '09:00', available: false),
      _TimeSlot(time: '10:00', available: true),
      _TimeSlot(time: '11:00', available: true),
      _TimeSlot(time: '14:00', available: true),
      _TimeSlot(time: '15:00', available: true),
      _TimeSlot(time: '16:00', available: true),
    ],
    2: [], // Mercredi (repos)
    3: [ // Jeudi
      _TimeSlot(time: '09:00', available: true),
      _TimeSlot(time: '10:00', available: true),
      _TimeSlot(time: '11:00', available: false),
      _TimeSlot(time: '14:00', available: true),
      _TimeSlot(time: '15:00', available: true),
    ],
    4: [ // Vendredi
      _TimeSlot(time: '08:00', available: true),
      _TimeSlot(time: '09:00', available: true),
      _TimeSlot(time: '10:00', available: true),
      _TimeSlot(time: '11:00', available: true),
      _TimeSlot(time: '14:00', available: false),
      _TimeSlot(time: '15:00', available: true),
    ],
    5: [], // Samedi
    6: [], // Dimanche
  };

  @override
  Widget build(BuildContext context) {
    final daySlots = _schedule[_selectedDay] ?? [];
    
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Horaires & Disponibilités',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de jour
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _daysOfWeek.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final isSelected = _selectedDay == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = index),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : context.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _daysOfWeek[index],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : context.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${26 + index}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : context.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Plages horaires
            if (daySlots.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 64,
                      color: context.mutedText,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pas de consultation ce jour',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: context.mutedText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Ajouter des horaires
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Ajouter horaires'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Text(
                'Plages horaires',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: daySlots.map((slot) {
                  return _TimeSlotButton(
                    slot: slot,
                    onToggle: () {
                      setState(() {
                        slot.available = !slot.available;
                      });
                    },
                    context: context,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSchedule,
                icon: const Icon(Icons.save_rounded),
                label: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Configuration générale
            Text(
              'Configuration générale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              title: 'Durée de consultation',
              subtitle: '30 minutes',
              icon: Icons.timer_outlined,
              context: context,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingTile(
              title: 'Intervalle entre RDV',
              subtitle: '15 minutes',
              icon: Icons.schedule_outlined,
              context: context,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _SettingTile(
              title: 'Nombre de patients par jour',
              subtitle: '20 patients',
              icon: Icons.people_outline_rounded,
              context: context,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Sauvegarder l'horaire via l'API
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Horaires enregistrés')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _TimeSlot {
  final String time;
  bool available;

  _TimeSlot({required this.time, required this.available});
}

class _TimeSlotButton extends StatelessWidget {
  final _TimeSlot slot;
  final VoidCallback onToggle;
  final BuildContext context;

  const _TimeSlotButton({
    required this.slot,
    required this.onToggle,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: slot.available ? AppColors.primary : context.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: slot.available
                ? AppColors.primary
                : context.dividerColor,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            slot.time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: slot.available ? Colors.white : context.textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final BuildContext context;
  final VoidCallback onTap;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.context,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.dividerColor, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.mutedText),
          ],
        ),
      ),
    );
  }
}
