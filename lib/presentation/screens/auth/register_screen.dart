import 'package:flutter/material.dart';
import '../../../core/di/app_services.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';
import '../../../data/models/auth/register_request.dart';
import '../../authenticated_content.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  bool _acceptTerms = false;
  int _currentStep = 0;
  String _selectedRole = 'patient'; // 'patient' ou 'doctor'

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _passwordCtrl,
      _confirmCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snack(
          'Veuillez accepter les conditions d\'utilisation',
          AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AppServices.authRepository.register(
        RegisterRequest(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          role: _selectedRole,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Compte créé avec succès ! 🎉', AppColors.success));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthenticatedContent()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snack(error.message, AppColors.danger));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        _snack('Erreur inattendue. Veuillez réessayer.', AppColors.danger),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      _selectedRole == 'doctor'
                          ? 'Rejoignez notre réseau de médecins'
                          : 'Rejoignez des milliers de patients',
                      style: const TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicateur d'étapes
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        _StepDot(
                          active: true,
                          done: _currentStep > 0,
                          label: '1',
                        ),
                        _StepLine(active: _currentStep > 0),
                        _StepDot(
                          active: _currentStep >= 1,
                          done: _currentStep > 1,
                          label: '2',
                        ),
                        _StepLine(active: _currentStep > 1),
                        _StepDot(
                          active: _currentStep >= 2,
                          done: false,
                          label: '3',
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _currentStep == 0
                              ? 'Identité'
                              : _currentStep == 1
                              ? 'Contact'
                              : 'Sécurité',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Étape 1 — Identité
                      if (_currentStep == 0) ...[
                        // ── SÉLECTEUR DE RÔLE ──
                        _SectionHeader(title: 'Je suis…'),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(child: _RoleCard(
                            label: 'Patient',
                            subtitle: 'Je cherche un médecin',
                            icon: Icons.person_rounded,
                            color: AppColors.primary,
                            selected: _selectedRole == 'patient',
                            onTap: () => setState(() => _selectedRole = 'patient'),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _RoleCard(
                            label: 'Médecin',
                            subtitle: 'Je propose des consultations',
                            icon: Icons.medical_services_rounded,
                            color: const Color(0xFF00C48C),
                            selected: _selectedRole == 'doctor',
                            onTap: () => setState(() => _selectedRole = 'doctor'),
                          )),
                        ]),
                        const SizedBox(height: 28),
                        _SectionHeader(title: 'Votre identité'),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Prénom'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _firstNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      hintText: 'Gérome',
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        size: 20,
                                        color: context.textMuted,
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v?.isEmpty ?? true) ? 'Requis' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Nom'),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _lastNameCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      hintText: 'Kegne',
                                    ),
                                    validator: (v) =>
                                        (v?.isEmpty ?? true) ? 'Requis' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // Sexe
                        const _Label('Genre'),
                        const SizedBox(height: 10),
                        _GenderSelector(),
                        const SizedBox(height: 22),
                        // Date de naissance
                        const _Label('Date de naissance'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime(1990),
                              firstDate: DateTime(1920),
                              lastDate: DateTime.now(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: context.inputFillColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  size: 20,
                                  color: context.textMuted,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'JJ / MM / AAAA',
                                  style: TextStyle(
                                    color: context.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 18,
                                  color: context.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Étape 2 — Contact
                      if (_currentStep == 1) ...[
                        _SectionHeader(title: 'Vos coordonnées'),
                        const SizedBox(height: 20),
                        const _Label('Adresse email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'géromekegne@gmail.com',
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              size: 20,
                              color: context.textMuted,
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Email requis';
                            if (!v!.contains('@')) return 'Email invalide';
                            return null;
                          },
                        ),
                        const SizedBox(height: 22),
                        const _Label('Téléphone'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '+237 6XX XXX XXX',
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              size: 20,
                              color: context.textMuted,
                            ),
                          ),
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Téléphone requis' : null,
                        ),
                        const SizedBox(height: 22),
                        // Groupe sanguin
                        const _Label('Groupe sanguin (optionnel)'),
                        const SizedBox(height: 10),
                        _BloodGroupSelector(),
                      ],

                      // Étape 3 — Sécurité
                      if (_currentStep == 2) ...[
                        _SectionHeader(title: 'Sécurisez votre compte'),
                        const SizedBox(height: 20),
                        const _Label('Mot de passe'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: context.textMuted,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) {
                              return 'Mot de passe requis';
                            }
                            if (v!.length < 8) {
                              return 'Au moins 8 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Force du mot de passe
                        _PasswordStrengthBar(password: _passwordCtrl.text),
                        const SizedBox(height: 22),
                        const _Label('Confirmer le mot de passe'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: !_showConfirm,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: context.textMuted,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _showConfirm = !_showConfirm),
                              icon: Icon(
                                _showConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) {
                              return 'Confirmation requise';
                            }
                            if (v != _passwordCtrl.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Conditions
                        GestureDetector(
                          onTap: () =>
                              setState(() => _acceptTerms = !_acceptTerms),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _acceptTerms
                                  ? context.primaryLightColor
                                  : context.surfaceColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _acceptTerms
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: _acceptTerms
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _acceptTerms
                                          ? AppColors.primary
                                          : AppColors.borderMid,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: _acceptTerms
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text: "J'accepte les ",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.textSecondary,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'CGU',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' et la '),
                                        TextSpan(
                                          text: 'politique de confidentialité',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 36),

                      // Boutons de navigation
                      Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentStep--),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Retour',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 14),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (_currentStep < 2) {
                                        setState(() => _currentStep++);
                                      } else {
                                        _handleRegister();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
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
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _currentStep < 2
                                          ? 'Continuer →'
                                          : 'Créer mon compte',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: 'Déjà un compte ? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Se connecter',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.textSecondary,
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final String label;

  const _StepDot({
    required this.active,
    required this.done,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.accent
            : active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.2),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 2,
      color: active ? AppColors.accent : Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _GenderSelector extends StatefulWidget {
  const _GenderSelector();

  @override
  State<_GenderSelector> createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<_GenderSelector> {
  int _selected = -1;
  final _options = [
    {'icon': Icons.male_rounded, 'label': 'Homme'},
    {'icon': Icons.female_rounded, 'label': 'Femme'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_options.length, (i) {
        final opt = _options[i];
        final isSelected = _selected == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.primaryLightColor
                    : context.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt['icon'] as IconData,
                    color: isSelected ? AppColors.primary : context.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BloodGroupSelector extends StatefulWidget {
  @override
  State<_BloodGroupSelector> createState() => _BloodGroupSelectorState();
}

class _BloodGroupSelectorState extends State<_BloodGroupSelector> {
  int _selected = -1;
  final _groups = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_groups.length, (i) {
        final isSelected = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primaryLightColor
                  : context.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              _groups[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : context.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _strength {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength;
    final color = s <= 1
        ? AppColors.danger
        : s <= 2
        ? AppColors.warning
        : AppColors.success;
    final label = s <= 1
        ? 'Faible'
        : s <= 2
        ? 'Moyen'
        : s <= 3
        ? 'Fort'
        : 'Très fort';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ...List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < s ? color : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── ROLE CARD ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : context.dividerColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: selected ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? color : Colors.transparent,
                border: Border.all(
                  color: selected ? color : context.dividerColor,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
            ),
          ]),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: selected ? color : context.textColor,
          )),
          const SizedBox(height: 3),
          Text(subtitle, style: TextStyle(
            fontSize: 11, color: context.mutedText, height: 1.3,
          )),
        ]),
      ),
    );
  }
}
