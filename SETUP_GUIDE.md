# Guide de Configuration et Test - Finance Daily Digest

## 📋 Prérequis

- Flutter SDK installé ✅
- Chrome installé ✅
- Git installé ✅

## 🚀 Démarrage Rapide

### 1. Se placer dans le projet

```bash
cd /home/deu/Documents/financeDailyDigest/finance_daily_digest
```

### 2. Vérifier les dépendances

```bash
flutter pub get
```

### 3. Vérifier que tout compile

```bash
flutter analyze
```

Résultat attendu: `No issues found!` (ou quelques warnings mineurs de style)

### 4. Lancer les tests

```bash
flutter test
```

Résultat attendu: `All tests passed!`

## 🌐 Lancer l'Application

### Option 1: Sur Chrome (Web) - Recommandé

```bash
flutter run -d chrome
```

L'application va:
1. Compiler le code Dart en JavaScript
2. Ouvrir Chrome automatiquement
3. Afficher l'écran de démarrage avec "Finance Daily Digest"

**Raccourcis clavier dans le terminal:**
- `r` - Hot reload (recharger l'app sans la relancer)
- `R` - Hot restart (redémarrer complètement)
- `q` - Quitter l'application
- `h` - Afficher l'aide

### Option 2: Sur Linux Desktop

**Installation des dépendances (une seule fois):**
```bash
sudo apt install clang cmake ninja-build libgtk-3-dev
```

**Lancer:**
```bash
flutter run -d linux
```

### Option 3: Sur Android

**Prérequis:**
1. Installer Android Studio
2. Configurer Android SDK
3. Créer un émulateur Android ou connecter un téléphone en USB

**Lancer:**
```bash
flutter run -d <device-id>
```

## 🔧 Configuration de l'API OpenRouter

Pour utiliser les fonctionnalités IA, vous devez configurer une clé API:

### 1. Obtenir une clé API OpenRouter

- Aller sur: https://openrouter.ai/
- Créer un compte
- Générer une clé API

### 2. Stocker la clé dans l'application

La clé sera stockée de manière sécurisée via `SecureStorageService`.

**Code pour sauvegarder la clé (à exécuter dans l'app):**

```dart
import 'package:finance_daily_digest/data/datasources/secure_storage_service.dart';

// Dans votre code
final secureStorage = SecureStorageService();
await secureStorage.saveOpenRouterApiKey('votre_clé_api_ici');
```

**Vérifier si la clé est sauvegardée:**

```dart
final hasKey = await secureStorage.hasOpenRouterApiKey();
print('API Key configurée: $hasKey');
```

## 🧪 Tester les API DataSources

### Test Yahoo Finance

```dart
import 'package:finance_daily_digest/data/datasources/yahoo_finance_datasource.dart';

void testYahooFinance() async {
  final dataSource = YahooFinanceDataSource();

  try {
    // Récupérer les actualités françaises
    final news = await dataSource.fetchNews(region: 'FR', count: 5);
    print('Nombre d\'actualités récupérées: ${news.length}');
    print('Première actualité: ${news.first}');
  } catch (e) {
    print('Erreur: $e');
  }
}
```

### Test OpenRouter (nécessite clé API)

```dart
import 'package:finance_daily_digest/data/datasources/openrouter_datasource.dart';

void testOpenRouter() async {
  final dataSource = OpenRouterDataSource();

  try {
    final response = await dataSource.generateCompletion(
      prompt: 'Explique en français simple ce qu\'est une action.',
      maxTokens: 100,
    );
    print('Réponse IA: $response');
  } catch (e) {
    print('Erreur: $e');
  }
}
```

## 📱 Ce que vous devriez voir

### Écran de démarrage actuel

L'application affiche:
- Icône 📈 (trending_up) en bleu
- Titre "Finance Daily Digest"
- Message "Architecture setup complete ✓"

### Prochaines étapes d'implémentation

Après STORY-002 (Cache Hive), vous pourrez:
- Récupérer des actualités financières réelles
- Les afficher dans une liste
- Les stocker en cache
- Tester le mode hors-ligne

## 🐛 Résolution de Problèmes

### Erreur: "Unable to locate Android SDK"

➡️ Solution: Utilisez Chrome ou Linux desktop pour tester

### Erreur de compilation

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter run
```

### Tests qui échouent

```bash
# Vérifier les détails
flutter test --verbose
```

### Application blanche/vide

➡️ Vérifiez la console pour les erreurs
➡️ Ouvrez les DevTools: `flutter run --dart-define=FLUTTER_WEB_USE_SKIA=false`

## 📊 Commandes Utiles

```bash
# Vérifier l'état de Flutter
flutter doctor -v

# Lister les devices disponibles
flutter devices

# Voir les logs en temps réel
flutter logs

# Mesurer les performances
flutter run --profile

# Build pour production (web)
flutter build web

# Analyser le code
flutter analyze

# Formatter le code
dart format lib/ test/

# Mettre à jour les dépendances
flutter pub upgrade
```

## 🎯 Checklist de Vérification

Avant de continuer le développement, vérifiez:

- [ ] `flutter pub get` fonctionne sans erreur
- [ ] `flutter analyze` ne montre aucune erreur (warnings OK)
- [ ] `flutter test` passe tous les tests
- [ ] L'application démarre sur Chrome ou Linux
- [ ] L'écran de démarrage s'affiche correctement

## 📚 Structure du Projet

```
finance_daily_digest/
├── lib/
│   ├── data/
│   │   └── datasources/
│   │       ├── exceptions/     # Exceptions personnalisées
│   │       ├── http/           # Configuration HTTP (Dio)
│   │       ├── yahoo_finance_datasource.dart
│   │       ├── openrouter_datasource.dart
│   │       └── secure_storage_service.dart
│   ├── domain/                 # Business logic (vide pour l'instant)
│   ├── presentation/           # UI
│   │   └── app.dart           # Widget principal
│   └── main.dart              # Point d'entrée
├── test/                       # Tests unitaires
├── pubspec.yaml               # Dépendances
└── analysis_options.yaml      # Règles de linting
```

## 🔗 Ressources

- Documentation Flutter: https://docs.flutter.dev
- API Yahoo Finance: https://finance.yahoo.com
- OpenRouter Docs: https://openrouter.ai/docs
- Architecture du projet: `docs/architecture-finance-daily-digest-2026-01-21.md`
- Sprint Plan: `docs/sprint-plan-finance-daily-digest-2026-01-21.md`

## ✨ Prochaines Stories

1. **STORY-002**: Setup cache local Hive (3 points)
2. **STORY-003**: Écran Home avec digest (5 points)
3. **STORY-004**: Génération auto du digest (5 points)

---

**Status actuel:** Infrastructure de base complète (6/32 points) 🎉
