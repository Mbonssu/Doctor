import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  
  String _selectedRelation = 'Époux/Épouse';
  String _selectedBloodType = 'O+';
  String _selectedGender = 'Masculin';
  bool _isLoading = false;

  final List<String> _relations = [
    'Époux/Épouse',
    'Fils',
    'Fille',
    'Père',
    'Mère',
    'Frère',
    'Sœur',
    'Grand-parent',
    'Autre',
  ];

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Membre ajouté avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Ajouter un membre'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom complet
              Text(
                'Nom complet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Ex: Marie Kouassi',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                    color: context.textMuted,
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nom requis' : null,
              ),

              const SizedBox(height: 20),

              // Relation
              Text(
                'Relation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRelation,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.family_restroom_rounded,
                    size: 20,
                    color: context.textMuted,
                  ),
                ),
                items: _relations.map((relation) {
                  return DropdownMenuItem(
                    value: relation,
                    child: Text(relation),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRelation = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Genre et Âge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genre',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.wc_rounded,
                              size: 20,
                              color: context.textMuted,
                            ),
                          ),
                          items: ['Masculin', 'Féminin'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedGender = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Âge',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Ex: 25',
                            prefixIcon: Icon(
                              Icons.cake_rounded,
                              size: 20,
                              color: context.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requis';
                            final age = int.tryParse(v);
                            if (age == null || age < 0 || age > 150) {
                              return 'Invalide';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Groupe sanguin
              Text(
                'Groupe sanguin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedBloodType,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.bloodtype_rounded,
                    size: 20,
                    color: context.textMuted,
                  ),
                ),
                items: _bloodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedBloodType = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Téléphone (optionnel)
              Text(
                'Téléphone (optionnel)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+225 07 XX XX XX XX',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: context.textMuted,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Allergies (optionnel)
              Text(
                'Allergies (optionnel)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _allergiesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: Pénicilline, Arachides...',
                  prefixIcon: Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: context.textMuted,
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 28),

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
                        'Ces informations nous aident à mieux prendre soin de votre famille.',
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

              const SizedBox(height: 28),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Ajouter le membre',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
