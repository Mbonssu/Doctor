import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  String _searchQuery = '';

  final List<String> _categories = [
    'Tous',
    'Rendez-vous',
    'Paiement',
    'Compte',
    'Médecins',
    'Technique',
  ];

  final List<FaqItem> _faqs = [
    FaqItem(
      category: 'Rendez-vous',
      question: 'Comment prendre un rendez-vous ?',
      answer:
          'Pour prendre un rendez-vous, allez dans l\'onglet "Médecins", sélectionnez un médecin, choisissez une date et heure disponible, puis confirmez votre réservation.',
    ),
    FaqItem(
      category: 'Rendez-vous',
      question: 'Puis-je annuler ou modifier un rendez-vous ?',
      answer:
          'Oui, vous pouvez annuler ou modifier un rendez-vous jusqu\'à 24h avant l\'heure prévue. Allez dans "Mes rendez-vous", sélectionnez le rendez-vous et choisissez l\'option souhaitée.',
    ),
    FaqItem(
      category: 'Rendez-vous',
      question: 'Que faire si je suis en retard ?',
      answer:
          'Si vous êtes en retard, contactez immédiatement le cabinet médical via le chat ou par téléphone. Le médecin pourra vous recevoir selon sa disponibilité.',
    ),
    FaqItem(
      category: 'Paiement',
      question: 'Quels moyens de paiement sont acceptés ?',
      answer:
          'Nous acceptons les cartes bancaires (Visa, Mastercard), Mobile Money (Orange Money, MTN Money, Moov Money) et les paiements en espèces au cabinet.',
    ),
    FaqItem(
      category: 'Paiement',
      question: 'Puis-je obtenir une facture ?',
      answer:
          'Oui, une facture est automatiquement générée après chaque paiement. Vous pouvez la télécharger depuis l\'historique des paiements dans votre profil.',
    ),
    FaqItem(
      category: 'Paiement',
      question: 'Les consultations sont-elles remboursables ?',
      answer:
          'Le remboursement dépend de votre assurance santé. Nous fournissons tous les documents nécessaires pour vos demandes de remboursement.',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Comment modifier mes informations personnelles ?',
      answer:
          'Allez dans votre profil, cliquez sur "Modifier le profil" et mettez à jour vos informations. N\'oubliez pas de sauvegarder les modifications.',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Comment changer mon mot de passe ?',
      answer:
          'Dans votre profil, sélectionnez "Changer le mot de passe", entrez votre mot de passe actuel puis le nouveau mot de passe deux fois pour confirmer.',
    ),
    FaqItem(
      category: 'Compte',
      question: 'Mes données sont-elles sécurisées ?',
      answer:
          'Oui, toutes vos données sont cryptées et stockées de manière sécurisée. Nous respectons strictement les normes de confidentialité médicale.',
    ),
    FaqItem(
      category: 'Médecins',
      question: 'Comment choisir un bon médecin ?',
      answer:
          'Consultez les profils des médecins avec leurs spécialités, expériences et avis des patients. Vous pouvez filtrer par spécialité, localisation et disponibilité.',
    ),
    FaqItem(
      category: 'Médecins',
      question: 'Puis-je consulter les avis sur les médecins ?',
      answer:
          'Oui, chaque profil de médecin affiche les avis et notes laissés par les patients. Vous pouvez également laisser votre propre avis après une consultation.',
    ),
    FaqItem(
      category: 'Technique',
      question: 'L\'application ne fonctionne pas, que faire ?',
      answer:
          'Essayez de fermer et rouvrir l\'application. Si le problème persiste, vérifiez votre connexion internet ou contactez notre support technique.',
    ),
    FaqItem(
      category: 'Technique',
      question: 'Comment activer les notifications ?',
      answer:
          'Allez dans les paramètres de votre téléphone, trouvez DoctoPing dans la liste des applications et activez les notifications.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FaqItem> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory =
          _selectedCategory == 'Tous' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        title: const Text('Questions fréquentes'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
        ),
      ),
      body: Column(
        children: [
          // Recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une question...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: context.textMuted,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: context.textMuted,
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Catégories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: context.surfaceColor,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : context.textSecondary,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : context.borderColor,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Liste des FAQs
          Expanded(
            child: _filteredFaqs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: context.textMutedColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune question trouvée',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez avec d\'autres mots-clés',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textMutedColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredFaqs.length,
                    itemBuilder: (context, index) {
                      return _FaqCard(faq: _filteredFaqs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final FaqItem faq;

  const _FaqCard({required this.faq});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : context.borderColor,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.faq.question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _isExpanded ? AppColors.primary : context.textPrimary,
            ),
          ),
          trailing: Icon(
            _isExpanded
                ? Icons.remove_circle_outline_rounded
                : Icons.add_circle_outline_rounded,
            color: _isExpanded ? AppColors.primary : context.textMuted,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.primaryLightColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.faq.category,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.faq.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                      height: 1.5,
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

class FaqItem {
  final String category;
  final String question;
  final String answer;

  FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
