# 📱 HospitalCare Mobile - Application Patient

## 🎯 Vue d'ensemble

Application mobile Flutter destinée aux patients pour la prise de rendez-vous médicaux avec un design européen épuré et moderne.

## ✨ Fonctionnalités

### 🔐 **Authentification**
- Connexion sécurisée par email/mot de passe
- Inscription avec validation des données
- Connexion via Google (prévu)
- Récupération de mot de passe

### 🏠 **Écran d'accueil**
- Salutation personnalisée
- Barre de recherche intelligente
- Actions rapides (RDV, Urgences)
- Spécialités populaires
- Prochains rendez-vous

### 👨‍⚕️ **Médecins**
- Liste des médecins par spécialité
- Profils détaillés avec avis
- Disponibilités en temps réel
- Système de notation

### 📅 **Rendez-vous**
- Historique des consultations
- Rendez-vous à venir
- Notifications de rappel
- Annulation/Reprogrammation

### 👤 **Profil**
- Informations personnelles
- Préférences de thème (clair/sombre)
- Paramètres de notification
- Support et aide

## 🎨 Design System

### **Couleurs**
```dart
// Mode Clair
primary: #2563EB        // Bleu médical
background: #F8FAFF     // Fond principal
surface: #FFFFFF        // Cartes et surfaces
textPrimary: #0F172A    // Texte principal

// Mode Sombre
primaryDark: #3B82F6    // Bleu adapté
backgroundDark: #0B1220 // Fond sombre européen
surfaceDark: #111B2E    // Surfaces sombres
textPrimaryDark: #F1F5F9 // Texte clair
```

### **Typographie**
```dart
// Hiérarchie des textes
displayLarge: 32px, w800, -0.8px
displayMedium: 28px, w700, -0.6px
headlineLarge: 22px, w700, -0.4px
titleLarge: 16px, w600
bodyLarge: 16px, w400
bodySmall: 12px, w400
```

### **Composants**
- **Cards** : Bordure 1px, radius 16px
- **Boutons** : Radius 12px, padding 16px
- **Champs** : Radius 12px, filled style
- **Navigation** : Bottom bar avec indicateurs

## 🏗️ Architecture

### **Structure des dossiers**
```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Palette de couleurs
│   │   └── app_theme.dart       # Thèmes clair/sombre
│   └── providers/
│       └── theme_provider.dart  # Gestion du thème
├── presentation/
│   ├── screens/
│   │   ├── splash/              # Écran de démarrage
│   │   ├── auth/                # Authentification
│   │   ├── home/                # Accueil et navigation
│   │   ├── doctors/             # Médecins
│   │   ├── appointments/        # Rendez-vous
│   │   └── profile/             # Profil utilisateur
│   └── widgets/                 # Composants réutilisables
└── main.dart                    # Point d'entrée
```

### **Patterns utilisés**
- **Provider** : State management
- **Consumer** : Écoute des changements
- **ChangeNotifier** : Notifications d'état
- **SharedPreferences** : Persistance locale

## 🌙 Mode Sombre

### **Implémentation**
```dart
// Provider de thème
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
    // Sauvegarde automatique
  }
}
```

### **Utilisation**
```dart
// Dans les widgets
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Container(
      color: themeProvider.isDarkMode 
          ? AppColors.surfaceDark 
          : AppColors.surface,
    );
  },
)
```

## 📱 Écrans Principaux

### **1. Splash Screen**
- Animation de démarrage
- Logo HospitalCare
- Transition fluide vers Welcome

### **2. Welcome Screen**
- Présentation de l'app
- Boutons Connexion/Inscription
- Design européen épuré

### **3. Login/Register**
- Formulaires validés
- Design cohérent
- Gestion des erreurs

### **4. Home Screen**
- Dashboard patient
- Navigation intuitive
- Actions rapides

### **5. Profile Screen**
- Informations utilisateur
- Toggle mode sombre
- Options de compte

## 🔧 Configuration

### **Dépendances principales**
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
  provider: ^6.1.1

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^6.0.0
```

### **Configuration du thème**
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeProvider.themeMode,
)
```

## 🚀 Installation

### **Prérequis**
- Flutter 3.11.4+
- Dart 3.0+
- Android Studio / VS Code

### **Commandes**
```bash
# Installation des dépendances
flutter pub get

# Lancement en mode debug
flutter run

# Build pour production
flutter build apk --release
flutter build ios --release
```

## 📊 Performance

### **Optimisations**
- Lazy loading des écrans
- Images optimisées
- Animations 60fps
- Mémoire gérée efficacement

### **Métriques cibles**
- Temps de démarrage < 2s
- Navigation fluide
- Consommation batterie optimisée
- Taille APK < 50MB

## 🧪 Tests

### **Types de tests**
```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test/

# Tests de widgets
flutter test test/widget_test.dart
```

### **Couverture**
- Logique métier : 90%+
- Widgets : 80%+
- Intégration : 70%+

## 🔒 Sécurité

### **Mesures implémentées**
- Validation des entrées utilisateur
- Stockage sécurisé des tokens
- Chiffrement des données sensibles
- Protection contre les injections

### **Bonnes pratiques**
- Pas de données sensibles en dur
- Validation côté client ET serveur
- Gestion sécurisée des erreurs
- Logs sans informations sensibles

## 🌍 Internationalisation

### **Support prévu**
- Français (par défaut)
- Anglais
- Allemand
- Espagnol

### **Configuration**
```dart
// Ajout futur
MaterialApp(
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
  ],
)
```

## 🐛 Débogage

### **Outils utiles**
```bash
# Logs détaillés
flutter run --verbose

# Analyse du code
flutter analyze

# Formatage automatique
dart format lib/
```

### **Debug mode**
- Hot reload activé
- Logs de développement
- Outils de performance
- Inspector de widgets

## 📈 Roadmap Mobile

### **Version 1.1** (Q1 2025)
- [ ] Notifications push
- [ ] Mode offline
- [ ] Géolocalisation des médecins
- [ ] Partage de rendez-vous

### **Version 1.2** (Q2 2025)
- [ ] Téléconsultation
- [ ] Paiement intégré
- [ ] Historique médical
- [ ] Export PDF

### **Version 2.0** (Q3 2025)
- [ ] IA d'assistance
- [ ] Reconnaissance vocale
- [ ] Réalité augmentée
- [ ] Intégration IoT

## 🤝 Contribution

### **Guidelines**
1. Suivre le style Dart officiel
2. Documenter les nouvelles fonctionnalités
3. Ajouter des tests pour le nouveau code
4. Respecter l'architecture existante

### **Processus**
1. Fork et clone
2. Créer une branche feature
3. Développer et tester
4. Soumettre une PR

---

**Développé avec ❤️ en Flutter pour une expérience patient moderne**