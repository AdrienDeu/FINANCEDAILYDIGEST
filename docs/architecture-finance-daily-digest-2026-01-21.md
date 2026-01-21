# Architecture Système : Finance Daily Digest

**Date:** 2026-01-21
**Architecte:** deu
**Version:** 1.0
**Type de projet:** mobile-app
**Niveau de projet:** 2
**Statut:** Validé

---

## Aperçu du document

Ce document définit l'architecture système de Finance Daily Digest. Il fournit le blueprint technique pour l'implémentation, adressant toutes les exigences fonctionnelles et non-fonctionnelles du PRD.

**Documents liés:**
- PRD: `docs/prd-finance-daily-digest-2026-01-21.md`
- Product Brief: `docs/product-brief-finance-daily-digest-2026-01-21.md`

---

## Résumé exécutif

Application mobile Flutter (iOS/Android) de veille financière quotidienne utilisant :
- **Yahoo Finance API** pour les actualités financières
- **OpenRouter (Mistral)** pour la vulgarisation IA et les suggestions d'investissement
- **Hive** pour le cache local et le mode hors-ligne
- **Riverpod** pour la gestion d'état

Architecture Clean simplifiée en 3 couches (Presentation, Domain, Data) optimisée pour le budget API et les performances.

---

## Drivers architecturaux

Ces NFRs influencent fortement les décisions architecturales :

| NFR | Exigence | Impact architectural |
|-----|----------|---------------------|
| **NFR-001** | Chargement < 3s | Cache local, optimisation réseau |
| **NFR-003** | Mode hors-ligne | Stockage local persistant (Hive) |
| **NFR-004** | Budget API < 50€/mois | Cache agressif des appels IA, batching |
| **NFR-007** | Navigation simple | Architecture UI simple, 3 écrans max |

**Driver principal:** NFR-004 (Budget API) - L'architecture doit minimiser les appels IA coûteux via un caching intelligent.

---

## Vue d'ensemble du système

### Architecture de haut niveau

```
┌─────────────────────────────────────────────────────┐
│                    FLUTTER APP                       │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────┐    │
│  │           PRESENTATION (UI)                  │    │
│  │  • Screens (Home, News, Article)            │    │
│  │  • Widgets (DigestCard, SuggestionCard)     │    │
│  │  • State Management (Riverpod)              │    │
│  └─────────────────────────────────────────────┘    │
│                        ▼                            │
│  ┌─────────────────────────────────────────────┐    │
│  │           DOMAIN (Business Logic)            │    │
│  │  • Use Cases                                 │    │
│  │  • Entities (News, Suggestion, Digest)      │    │
│  │  • Repository Interfaces                    │    │
│  └─────────────────────────────────────────────┘    │
│                        ▼                            │
│  ┌─────────────────────────────────────────────┐    │
│  │              DATA (Sources)                  │    │
│  │  • Yahoo Finance API Client                 │    │
│  │  • OpenRouter API Client                    │    │
│  │  • Local Cache (Hive)                       │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        ▼                               ▼
┌───────────────┐               ┌───────────────┐
│ Yahoo Finance │               │  OpenRouter   │
│     API       │               │   (Mistral)   │
└───────────────┘               └───────────────┘
```

### Pattern architectural

**Pattern:** Clean Architecture simplifiée (3 couches)

**Rationale:**
- Simple à implémenter (timeline serrée de quelques jours)
- Séparation claire UI/Logic/Data
- Facilite les tests unitaires
- Évolutif pour les versions futures (web, marchés US)

---

## Stack technique

### Mobile Framework

| Technologie | Version | Justification |
|-------------|---------|---------------|
| **Flutter** | 3.x | Cross-platform iOS/Android, performant, écosystème riche |
| **Dart** | 3.x | Langage natif Flutter, null-safety |

**Trade-offs:**
- ✓ Gain: Une seule codebase pour iOS et Android
- ✗ Perte: Performances légèrement inférieures au natif (négligeable pour ce cas)

### State Management

| Technologie | Justification |
|-------------|---------------|
| **Riverpod** | Moderne, testable, gère bien le cache, injection de dépendances intégrée |

**Trade-offs:**
- ✓ Gain: Code déclaratif, auto-dispose, excellent pour les données async
- ✗ Perte: Courbe d'apprentissage vs Provider simple

### Stockage local

| Technologie | Justification |
|-------------|---------------|
| **Hive** | NoSQL rapide, parfait pour Flutter, API simple, supporte le chiffrement |

**Trade-offs:**
- ✓ Gain: Très rapide, pas de configuration SQL
- ✗ Perte: Pas de requêtes complexes (non nécessaire ici)

### HTTP Client

| Technologie | Justification |
|-------------|---------------|
| **Dio** | Interceptors, retry, timeout configurable, logging |

### APIs externes

| Service | Utilisation | Coût |
|---------|-------------|------|
| **Yahoo Finance API** | Actualités financières en français | Gratuit |
| **OpenRouter (Mistral 7B)** | Vulgarisation IA + suggestions | ~0.002€/requête |

### Sécurité

| Technologie | Utilisation |
|-------------|-------------|
| **flutter_secure_storage** | Stockage chiffré de la clé API OpenRouter |

### Résumé de la stack

```
┌────────────────────────────────────────┐
│            STACK TECHNIQUE             │
├────────────────────────────────────────┤
│ Framework:     Flutter 3.x             │
│ Language:      Dart 3.x                │
│ State:         Riverpod                │
│ HTTP:          Dio                     │
│ Cache:         Hive                    │
│ Secure Store:  flutter_secure_storage  │
│ API Finance:   Yahoo Finance           │
│ API IA:        OpenRouter (Mistral)    │
└────────────────────────────────────────┘
```

---

## Composants système

### Couche Présentation (UI)

#### HomeScreen

**Objectif:** Écran principal affichant le digest quotidien et les suggestions

**Responsabilités:**
- Afficher le digest du jour
- Afficher les suggestions d'investissement
- Gérer le pull-to-refresh
- Navigation vers les détails

**FRs adressées:** FR-001, FR-002, FR-003, FR-011, FR-012

---

#### NewsScreen

**Objectif:** Flux d'actualités scrollable

**Responsabilités:**
- Afficher la liste des actualités
- Pull-to-refresh (FR-006)
- Filtrage par catégorie (FR-007)
- Navigation vers ArticleDetailScreen

**FRs adressées:** FR-004, FR-006, FR-007

---

#### ArticleDetailScreen

**Objectif:** Affichage d'un article vulgarisé

**Responsabilités:**
- Afficher le contenu vulgarisé
- Bouton "Voir l'original"
- Afficher la source et la date

**FRs adressées:** FR-008, FR-009, FR-010

---

#### Widgets réutilisables

| Widget | Responsabilité |
|--------|----------------|
| **DigestCard** | Carte d'actualité dans le digest |
| **NewsListItem** | Item dans le flux d'actualités |
| **SuggestionCard** | Carte de suggestion avec explication |
| **LoadingIndicator** | Skeleton loader pendant le chargement |
| **ErrorWidget** | Affichage d'erreur avec retry |

---

### Couche Domain (Business Logic)

#### GetDailyDigestUseCase

**Responsabilité:** Récupère et formate le digest du jour

**Logique:**
```
1. Vérifier cache Hive (TTL 24h)
2. Si cache valide → retourner
3. Sinon → appeler Yahoo Finance API
4. Vulgariser les articles (si non en cache)
5. Générer suggestions
6. Sauvegarder en cache
7. Retourner DailyDigest
```

---

#### GetNewsListUseCase

**Responsabilité:** Récupère le flux d'actualités paginé

**Logique:**
```
1. Vérifier cache (TTL 1h)
2. Si cache valide → retourner
3. Sinon → appeler Yahoo Finance API
4. Sauvegarder en cache
5. Retourner List<News>
```

---

#### VulgarizeArticleUseCase

**Responsabilité:** Vulgarise un article via OpenRouter/Mistral

**Logique:**
```
1. Vérifier si déjà vulgarisé en cache
2. Si oui → retourner version cached
3. Sinon → appeler OpenRouter API
4. Sauvegarder résultat en cache (TTL 24h)
5. Retourner contenu vulgarisé
```

---

#### GetSuggestionsUseCase

**Responsabilité:** Génère les suggestions d'investissement

**Logique:**
```
1. Vérifier cache suggestions du jour
2. Si valide → retourner
3. Sinon → analyser actualités du jour
4. Appeler OpenRouter pour générer suggestions
5. Sauvegarder en cache (TTL 24h)
6. Retourner List<Suggestion>
```

---

### Couche Data (Repositories)

#### YahooFinanceRepository

**Responsabilité:** Encapsule les appels à Yahoo Finance API

**Interface:**
```dart
abstract class YahooFinanceRepository {
  Future<List<News>> getFinanceNews({String region = 'FR', int count = 20});
  Future<News> getNewsDetail(String newsId);
}
```

---

#### OpenRouterRepository

**Responsabilité:** Encapsule les appels à OpenRouter/Mistral

**Interface:**
```dart
abstract class OpenRouterRepository {
  Future<String> vulgarizeContent(String content);
  Future<List<Suggestion>> generateSuggestions(List<News> news);
}
```

---

#### LocalCacheRepository

**Responsabilité:** Gestion du cache Hive

**Interface:**
```dart
abstract class LocalCacheRepository {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> delete(String key);
  Future<void> clear();
  bool isExpired(String key);
}
```

---

### Services transverses

#### CacheService

**Responsabilité:** Gestion TTL et invalidation

**Configuration TTL:**
| Type | TTL |
|------|-----|
| News brutes | 1 heure |
| News vulgarisées | 24 heures |
| Suggestions | 24 heures |
| Digest | 24 heures |

---

#### ConnectivityService

**Responsabilité:** Détection online/offline

**Utilisation:**
- Afficher indicateur offline
- Basculer sur cache si offline
- Sync quand retour online

---

## Architecture des données

### Modèle de données

#### News

```dart
@HiveType(typeId: 0)
class News {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String originalContent;

  @HiveField(3)
  final String? vulgarizedContent;

  @HiveField(4)
  final String source;

  @HiveField(5)
  final String url;

  @HiveField(6)
  final DateTime publishedAt;

  @HiveField(7)
  final NewsCategory category;

  @HiveField(8)
  final bool isVulgarized;
}

enum NewsCategory { action, etf, obligation, general }
```

#### Suggestion

```dart
@HiveType(typeId: 1)
class Suggestion {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String ticker;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final AssetType type;

  @HiveField(4)
  final String recommendation;

  @HiveField(5)
  final String reasoning;

  @HiveField(6)
  final String relatedNewsId;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final bool isPEAEligible;
}

enum AssetType { action, etf, obligation }
```

#### DailyDigest

```dart
@HiveType(typeId: 2)
class DailyDigest {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<News> news;

  @HiveField(2)
  final List<Suggestion> suggestions;

  @HiveField(3)
  final DateTime generatedAt;
}
```

### Flux de données

```
[Utilisateur ouvre l'app]
         │
         ▼
[HomeScreen demande Digest]
         │
         ▼
[GetDailyDigestUseCase]
         │
    ┌────┴────┐
    ▼         ▼
[Cache?]   [Non caché]
    │         │
    │         ▼
    │    [YahooFinanceRepo]
    │         │
    │         ▼
    │    [VulgarizeUseCase] ──► [OpenRouterRepo]
    │         │
    │         ▼
    │    [GetSuggestionsUseCase] ──► [OpenRouterRepo]
    │         │
    │         ▼
    │    [Sauvegarde cache]
    │         │
    └────┬────┘
         ▼
    [Retourne DailyDigest]
         │
         ▼
    [UI affiche]
```

### Design de la base de données (Hive)

```
Hive Boxes:
├── newsBox           (Box<News>)
├── suggestionsBox    (Box<Suggestion>)
├── digestBox         (Box<DailyDigest>)
└── cacheMetaBox      (Box<CacheMeta>)  // TTL tracking
```

---

## Design des APIs

### Yahoo Finance API

**Endpoint News:**
```
GET https://query1.finance.yahoo.com/v1/finance/search
Params:
  - q: "finance" (ou terme de recherche)
  - newsCount: 20
  - region: FR
  - lang: fr-FR
```

**Response:**
```json
{
  "news": [
    {
      "uuid": "abc123",
      "title": "Titre de l'actualité",
      "publisher": "Les Echos",
      "link": "https://...",
      "providerPublishTime": 1737417600,
      "thumbnail": { "resolutions": [...] }
    }
  ]
}
```

### OpenRouter API (Mistral)

**Endpoint:**
```
POST https://openrouter.ai/api/v1/chat/completions
Headers:
  - Authorization: Bearer {OPENROUTER_API_KEY}
  - Content-Type: application/json
  - HTTP-Referer: https://financedailydigest.app
```

**Body vulgarisation:**
```json
{
  "model": "mistralai/mistral-7b-instruct",
  "messages": [
    {
      "role": "system",
      "content": "Tu es un expert financier pédagogue. Vulgarise cet article pour un investisseur débutant. Utilise des termes simples, explique le jargon, et indique l'impact potentiel sur le marché européen. Réponds en français."
    },
    {
      "role": "user",
      "content": "{ARTICLE_CONTENT}"
    }
  ],
  "max_tokens": 500
}
```

**Body suggestions:**
```json
{
  "model": "mistralai/mistral-7b-instruct",
  "messages": [
    {
      "role": "system",
      "content": "Tu es un conseiller financier. Basé sur ces actualités, suggère 2-3 valeurs européennes éligibles PEA à surveiller. Pour chaque suggestion, indique: ticker, nom, type (action/ETF), et une explication simple du pourquoi. Réponds en JSON."
    },
    {
      "role": "user",
      "content": "{NEWS_SUMMARY}"
    }
  ],
  "max_tokens": 800
}
```

### Gestion des erreurs API

| Code | Signification | Action |
|------|---------------|--------|
| 200 | Succès | Traiter la réponse |
| 429 | Rate limit | Retry avec backoff (1s, 2s, 4s) |
| 401 | Non autorisé | Vérifier clé API, afficher erreur |
| 500+ | Erreur serveur | Utiliser cache, retry plus tard |
| Timeout | Délai dépassé | Utiliser cache si disponible |

### Configuration Dio

```dart
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
));

dio.interceptors.add(RetryInterceptor(
  retries: 3,
  retryDelays: [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ],
));
```

---

## Couverture des exigences non-fonctionnelles

### NFR-001: Performance - Chargement < 3s

**Exigence:** L'application charge le digest en moins de 3 secondes

**Solution architecturale:**
- Cache Hive local pour données précédemment chargées
- Chargement asynchrone avec FutureProvider (Riverpod)
- Skeleton loaders pendant le chargement
- Compression des images (thumbnails)

**Validation:**
- Mesurer temps de chargement avec Stopwatch
- Test sur connexion 4G standard

---

### NFR-002: Performance - Réponse IA < 5s

**Exigence:** L'appel IA pour vulgarisation répond en moins de 5 secondes

**Solution architecturale:**
- Timeout Dio configuré à 30s max
- Indicateur de chargement spécifique "Vulgarisation en cours..."
- Streaming de la réponse si possible

**Validation:**
- Monitoring des temps de réponse OpenRouter
- Alerting si > 5s fréquemment

---

### NFR-003: Disponibilité - Mode hors-ligne

**Exigence:** L'application fonctionne hors-ligne avec les données en cache

**Solution architecturale:**
- Hive stocke tout le contenu consulté
- ConnectivityService détecte l'état réseau
- Bannière "Mode hors-ligne" visible
- Pas de tentative d'appel API si offline
- Sync automatique au retour online

**Validation:**
- Test en mode avion
- Vérifier affichage données cached

---

### NFR-004: Coûts - Budget < 50€/mois

**Exigence:** Limiter les appels API IA via caching

**Solution architecturale:**
- Cache 24h pour tout contenu vulgarisé
- Maximum 5 articles vulgarisés par jour
- Suggestions générées 1x/jour uniquement
- Modèle Mistral 7B (économique)
- Pas de re-vulgarisation si déjà en cache

**Estimation:**
| Élément | Calcul | Coût |
|---------|--------|------|
| Vulgarisation | 5 articles × 30 jours × 0.002€ | ~3€/mois |
| Suggestions | 1 appel × 30 jours × 0.003€ | ~1€/mois |
| **Total** | | **< 5€/mois** |

**Validation:**
- Dashboard OpenRouter pour suivi des coûts
- Alerte si dépassement 30€

---

### NFR-005: Compatibilité - iOS 14+ / Android 10+

**Exigence:** Support des versions iOS 14+ et Android 10+

**Solution architecturale:**
- Flutter SDK configuré avec minSdkVersion approprié
- Test sur émulateurs des versions minimales
- Pas d'utilisation d'APIs récentes uniquement

**Configuration:**
```yaml
# android/app/build.gradle
minSdkVersion 29  # Android 10

# ios/Podfile
platform :ios, '14.0'
```

**Validation:**
- Build et test sur iOS 14 simulator
- Build et test sur Android 10 emulator

---

### NFR-006: Langue - Interface 100% français

**Exigence:** Interface et contenu entièrement en français

**Solution architecturale:**
- Tous les strings UI en français (hardcodés ou fichier l10n)
- Prompts IA en français
- Yahoo Finance API avec region=FR, lang=fr-FR
- Messages d'erreur en français

**Validation:**
- Review de tous les textes avant release

---

### NFR-007: Utilisabilité - Navigation < 15 min

**Exigence:** Navigation simple permettant consultation en moins de 15 minutes

**Solution architecturale:**
- 3 écrans principaux maximum (Home, News, Detail)
- Bottom navigation bar simple
- Digest visible dès l'ouverture
- Maximum 2 taps pour accéder au contenu

**Structure navigation:**
```
BottomNavigationBar:
├── Home (Digest + Suggestions)
└── Actualités (News Feed)
    └── Detail (Article vulgarisé)
```

**Validation:**
- Test utilisateur : consultation complète < 15 min

---

### NFR-008: Maintenabilité - Code propre

**Exigence:** Code Flutter avec séparation UI/Logic/Data

**Solution architecturale:**
- Clean Architecture 3 couches
- Riverpod pour injection de dépendances
- Naming conventions cohérentes
- Documentation des méthodes complexes

**Structure projet:**
```
lib/
├── main.dart
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
├── domain/
│   ├── entities/
│   ├── usecases/
│   └── repositories/
└── data/
    ├── datasources/
    ├── models/
    └── repositories/
```

**Validation:**
- Code review avant merge
- Analyse statique (dart analyze)

---

## Architecture sécurité

### Authentification

**Contexte:** Application personnelle sans authentification utilisateur

**Sécurité API:**
- Clé OpenRouter stockée via `flutter_secure_storage`
- Utilise Keychain (iOS) et Keystore (Android)
- Chiffrement AES-256

### Stockage sécurisé

```dart
final storage = FlutterSecureStorage();

// Sauvegarder la clé API
await storage.write(key: 'openrouter_api_key', value: apiKey);

// Récupérer la clé API
final apiKey = await storage.read(key: 'openrouter_api_key');
```

### Bonnes pratiques sécurité

| Pratique | Implémentation |
|----------|----------------|
| HTTPS uniquement | Dio configuré pour rejeter HTTP |
| Pas de logs sensibles | Clés API jamais loggées, même en debug |
| Validation inputs | Sanitization des entrées utilisateur |
| Obfuscation | Build release avec `--obfuscate --split-debug-info` |
| ProGuard | Activé pour Android release |

### Configuration sécurité

```dart
// Dio HTTPS only
dio.options.baseUrl = 'https://...';

// Interceptor pour masquer les clés dans les logs
dio.interceptors.add(LogInterceptor(
  requestHeader: false,  // Ne pas logger les headers (contient Auth)
  responseHeader: false,
));
```

---

## Scalabilité & Performance

### Stratégie de scaling

**Contexte:** Application personnelle, pas de scaling serveur nécessaire

**Optimisations locales:**
- Cache intelligent pour réduire les appels réseau
- Lazy loading des images
- Pagination du flux d'actualités

### Optimisation des performances

| Technique | Implémentation |
|-----------|----------------|
| Cache first | Toujours vérifier le cache avant l'API |
| Image caching | cached_network_image package |
| Lazy loading | ListView.builder avec pagination |
| Compression | gzip pour les requêtes API |

### Stratégie de caching

```
┌─────────────────────────────────────────┐
│           STRATÉGIE DE CACHE            │
├─────────────────────────────────────────┤
│                                         │
│  [Request] → [Check Cache]              │
│                  │                      │
│         ┌───────┴───────┐               │
│         ▼               ▼               │
│    [Cache Hit]    [Cache Miss]          │
│         │               │               │
│         │               ▼               │
│         │         [API Call]            │
│         │               │               │
│         │               ▼               │
│         │         [Update Cache]        │
│         │               │               │
│         └───────┬───────┘               │
│                 ▼                       │
│           [Return Data]                 │
│                                         │
└─────────────────────────────────────────┘
```

---

## Fiabilité & Disponibilité

### Design haute disponibilité

**Contexte:** Application mobile, pas d'infrastructure serveur

**Résilience client:**
- Mode offline avec cache local
- Retry automatique sur erreurs réseau
- Graceful degradation si API indisponible

### Stratégie de backup

| Donnée | Backup |
|--------|--------|
| Préférences | SharedPreferences (auto-backup Android/iCloud) |
| Cache | Hive (reconstruit si perdu) |
| Clé API | Secure storage (saisie manuelle si perdu) |

### Monitoring & Alerting

**Niveau application:**
- Crashlytics/Sentry pour les erreurs
- Analytics pour l'usage (optionnel)

**Niveau API:**
- Dashboard OpenRouter pour coûts et usage
- Alerte email si budget dépassé

---

## Architecture de développement

### Organisation du code

```
finance_daily_digest/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── network/
│   │   └── utils/
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── news_screen.dart
│   │   │   └── article_detail_screen.dart
│   │   ├── widgets/
│   │   │   ├── digest_card.dart
│   │   │   ├── news_list_item.dart
│   │   │   └── suggestion_card.dart
│   │   └── providers/
│   │       ├── digest_provider.dart
│   │       ├── news_provider.dart
│   │       └── suggestions_provider.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── news.dart
│   │   │   ├── suggestion.dart
│   │   │   └── daily_digest.dart
│   │   ├── repositories/
│   │   │   ├── news_repository.dart
│   │   │   └── ai_repository.dart
│   │   └── usecases/
│   │       ├── get_daily_digest.dart
│   │       ├── get_news_list.dart
│   │       ├── vulgarize_article.dart
│   │       └── get_suggestions.dart
│   │
│   └── data/
│       ├── datasources/
│       │   ├── yahoo_finance_datasource.dart
│       │   ├── openrouter_datasource.dart
│       │   └── local_cache_datasource.dart
│       ├── models/
│       │   ├── news_model.dart
│       │   ├── suggestion_model.dart
│       │   └── digest_model.dart
│       └── repositories/
│           ├── news_repository_impl.dart
│           └── ai_repository_impl.dart
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml
└── README.md
```

### Stratégie de test

| Type | Couverture cible | Outils |
|------|------------------|--------|
| Unit tests | 70%+ | flutter_test |
| Widget tests | Écrans principaux | flutter_test |
| Integration | Flux critiques | integration_test |

### Pipeline CI/CD

```
┌─────────────────────────────────────────┐
│              CI/CD Pipeline             │
├─────────────────────────────────────────┤
│                                         │
│  [Push] → [Lint] → [Test] → [Build]     │
│                               │         │
│                    ┌──────────┴───────┐ │
│                    ▼                  ▼ │
│              [Android APK]      [iOS IPA]│
│                    │                  │ │
│                    └──────────┬───────┘ │
│                               ▼         │
│                         [Release]       │
│                                         │
└─────────────────────────────────────────┘
```

**Outils recommandés:**
- GitHub Actions ou Codemagic
- Fastlane pour le déploiement stores

---

## Architecture de déploiement

### Environnements

| Environnement | Usage |
|---------------|-------|
| Development | Debug local, hot reload |
| Release | Build optimisé pour stores |

### Stratégie de déploiement

**Android:**
- APK/AAB généré via `flutter build appbundle`
- Distribution via Play Store ou direct APK

**iOS:**
- IPA généré via `flutter build ipa`
- Distribution via App Store ou TestFlight

### Configuration par environnement

```dart
// config/env.dart
class Env {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');

  static String get openRouterBaseUrl =>
    'https://openrouter.ai/api/v1';

  static String get yahooFinanceBaseUrl =>
    'https://query1.finance.yahoo.com';
}
```

---

## Traçabilité des exigences

### Couverture des exigences fonctionnelles

| FR ID | Exigence | Composants | Statut |
|-------|----------|------------|--------|
| FR-001 | Consultation digest | HomeScreen, GetDailyDigestUseCase | Adressé |
| FR-002 | Génération auto digest | GetDailyDigestUseCase, CacheService | Adressé |
| FR-003 | Focus marché européen | YahooFinanceRepo (region=FR) | Adressé |
| FR-004 | Flux d'actualités | NewsScreen, GetNewsListUseCase | Adressé |
| FR-005 | Récupération API | YahooFinanceRepository | Adressé |
| FR-006 | Rafraîchissement manuel | NewsScreen (pull-to-refresh) | Adressé |
| FR-007 | Filtrage catégorie | NewsScreen, NewsProvider | Adressé |
| FR-008 | Vulgarisation IA | VulgarizeArticleUseCase, OpenRouterRepo | Adressé |
| FR-009 | Niveau débutant | Prompts IA configurés | Adressé |
| FR-010 | Article original | ArticleDetailScreen | Adressé |
| FR-011 | Suggestions IA | GetSuggestionsUseCase | Adressé |
| FR-012 | Suggestions PEA/Europe | Prompts IA configurés | Adressé |
| FR-013 | Explication suggestions | SuggestionCard (reasoning) | Adressé |

### Couverture des exigences non-fonctionnelles

| NFR ID | Exigence | Solution | Statut |
|--------|----------|----------|--------|
| NFR-001 | Chargement < 3s | Cache Hive, async loading | Adressé |
| NFR-002 | Réponse IA < 5s | Timeout Dio, loading indicator | Adressé |
| NFR-003 | Mode hors-ligne | Hive cache, ConnectivityService | Adressé |
| NFR-004 | Budget < 50€/mois | Cache 24h, batching | Adressé |
| NFR-005 | iOS 14+/Android 10+ | SDK config | Adressé |
| NFR-006 | 100% français | Prompts FR, API region FR | Adressé |
| NFR-007 | Navigation simple | 3 écrans, bottom nav | Adressé |
| NFR-008 | Code maintenable | Clean Architecture | Adressé |

---

## Trade-offs & Décisions

### Décision 1: Clean Architecture simplifiée vs Full Clean

**Choix:** Clean Architecture 3 couches (simplifié)

**Trade-off:**
- ✓ Gain: Implémentation rapide, moins de boilerplate
- ✗ Perte: Moins de flexibilité que full Clean avec mappers

**Rationale:** Timeline serrée (quelques jours), projet personnel, évolutif si besoin

---

### Décision 2: Hive vs SQLite

**Choix:** Hive

**Trade-off:**
- ✓ Gain: API simple, performances élevées, intégration Flutter native
- ✗ Perte: Pas de requêtes SQL complexes

**Rationale:** Pas besoin de requêtes relationnelles, cache simple clé-valeur

---

### Décision 3: Riverpod vs Provider vs BLoC

**Choix:** Riverpod

**Trade-off:**
- ✓ Gain: Moderne, testable, auto-dispose, bon pour async
- ✗ Perte: Syntaxe différente de Provider classique

**Rationale:** Meilleure gestion du cache et des états async

---

### Décision 4: Mistral 7B vs GPT-4

**Choix:** Mistral 7B via OpenRouter

**Trade-off:**
- ✓ Gain: Coût 10-20x inférieur, performances suffisantes pour vulgarisation
- ✗ Perte: Qualité légèrement inférieure à GPT-4

**Rationale:** Budget limité, Mistral excellent pour le français

---

## Risques & Issues ouverts

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Yahoo Finance API change | Moyenne | Haut | Abstraction Repository, fallback |
| Qualité vulgarisation insuffisante | Moyenne | Moyen | Itération sur prompts |
| Coûts API dépassent budget | Faible | Moyen | Cache agressif, monitoring |
| App rejetée par stores | Faible | Haut | Suivre guidelines, pas de conseils financiers "garantis" |

---

## Hypothèses & Contraintes

### Hypothèses

- Yahoo Finance API reste gratuite et accessible
- OpenRouter/Mistral maintient ses tarifs actuels
- Les utilisateurs ont une connexion internet pour le premier chargement
- Le contenu vulgarisé par Mistral est de qualité acceptable

### Contraintes

- Budget API < 50€/mois
- Timeline : quelques jours
- Une seule personne (développeur = utilisateur)
- Pas de backend serveur (tout côté client)

---

## Considérations futures

Pour les versions ultérieures :

| Version | Fonctionnalité | Impact architectural |
|---------|----------------|---------------------|
| v2 | Version web | Flutter Web, même codebase |
| v2 | Marchés US/mondiaux | Extension YahooFinanceRepo, nouveaux filtres |
| v3 | Notifications push | Firebase Cloud Messaging |
| v3 | Suivi portefeuille | Nouvelle entité Portfolio, écran dédié |

---

## Approbation

**Statut de review:**
- [x] Architecte (deu)
- [x] Product Owner (deu)

---

## Historique des révisions

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.0 | 2026-01-21 | deu | Architecture initiale |

---

## Prochaines étapes

### Phase 4: Sprint Planning & Implémentation

Exécuter `/sprint-planning` pour :
- Découper les epics en user stories détaillées
- Estimer la complexité des stories
- Planifier les itérations de sprint
- Commencer l'implémentation

**Principes d'implémentation clés:**
1. Suivre les frontières de composants définies
2. Implémenter les solutions NFR comme spécifié
3. Utiliser la stack technique définie
4. Respecter la structure de code proposée
5. Suivre les guidelines sécurité et performance

---

**Ce document a été créé avec BMAD Method v6 - Phase 3 (Solutioning)**

*Pour continuer : Exécutez `/workflow-status` pour voir votre progression.*

---

## Annexe A: Dépendances Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0

  # Network
  dio: ^5.4.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Secure Storage
  flutter_secure_storage: ^9.0.0

  # Connectivity
  connectivity_plus: ^5.0.0

  # UI
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

  # Utils
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  riverpod_generator: ^2.3.0

  # Linting
  flutter_lints: ^3.0.0

  # Testing
  mockito: ^5.4.0
  mocktail: ^1.0.0
```

---

## Annexe B: Estimation des coûts

| Service | Usage mensuel | Coût unitaire | Total |
|---------|---------------|---------------|-------|
| OpenRouter (Mistral) | ~150 requêtes | ~0.002€/req | ~3€ |
| Yahoo Finance | Illimité | Gratuit | 0€ |
| Apple Developer | Annuel | 99€/an | ~8€/mois |
| Google Play | One-time | 25€ | ~2€/mois (amorti) |
| **Total** | | | **~13€/mois** |

*Note: Les frais stores sont optionnels si distribution en APK direct*
