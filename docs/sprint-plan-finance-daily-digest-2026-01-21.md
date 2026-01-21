# Sprint Plan: Finance Daily Digest

**Date:** 2026-01-21
**Scrum Master:** deu
**Niveau projet:** 2
**Total Stories:** 14
**Total Points:** 47
**Sprints planifiés:** 3

---

## Résumé exécutif

Ce plan organise le développement de Finance Daily Digest en 3 sprints avec une approche MVP-first. Le Sprint 1 livre une application fonctionnelle complète, les sprints suivants ajoutent des améliorations UX et des fonctionnalités secondaires.

**Métriques clés:**
- Total Stories: 14
- Total Points: 47
- Capacité: ~5 points/semaine (développeur solo, débutant Flutter)
- Approche: MVP d'abord, itérations ensuite

---

## Configuration équipe

| Paramètre | Valeur |
|-----------|--------|
| Développeurs | 1 (solo) |
| Niveau | Débutant Flutter |
| Heures productives/jour | ~4h |
| Ratio | 1 point = 4 heures |
| Capacité/semaine | ~5 points |

---

## Inventaire des Stories

### Infrastructure

#### STORY-000: Setup projet Flutter + architecture

**Epic:** Infrastructure
**Priorité:** Must Have
**Points:** 3

**User Story:**
En tant que développeur, je veux initialiser le projet Flutter avec l'architecture Clean, afin d'avoir une base de code structurée.

**Critères d'acceptation:**
- [ ] Projet Flutter créé avec structure de dossiers (presentation/domain/data)
- [ ] Dépendances ajoutées (riverpod, dio, hive, etc.)
- [ ] Configuration de base (pubspec.yaml, analysis_options.yaml)
- [ ] App démarre sans erreur

**Notes techniques:**
- Suivre la structure définie dans l'architecture
- Configurer les linters Dart

**Dépendances:** Aucune

---

#### STORY-001: Configuration APIs (Yahoo Finance + OpenRouter)

**Epic:** Infrastructure
**Priorité:** Must Have
**Points:** 3

**User Story:**
En tant que développeur, je veux configurer les clients API, afin de pouvoir récupérer les données financières et appeler l'IA.

**Critères d'acceptation:**
- [ ] Client Dio configuré avec interceptors (retry, logging)
- [ ] YahooFinanceDataSource fonctionnel
- [ ] OpenRouterDataSource fonctionnel
- [ ] Gestion des erreurs réseau
- [ ] Clé API OpenRouter stockée de manière sécurisée

**Notes techniques:**
- Utiliser flutter_secure_storage pour la clé API
- Configurer timeouts (10s connect, 30s receive)
- Implémenter retry avec backoff exponentiel

**Dépendances:** STORY-000

---

#### STORY-002: Setup cache local Hive

**Epic:** Infrastructure
**Priorité:** Must Have
**Points:** 3

**User Story:**
En tant que développeur, je veux configurer le cache local Hive, afin de stocker les données et permettre le mode hors-ligne.

**Critères d'acceptation:**
- [ ] Hive initialisé au démarrage de l'app
- [ ] Models Hive créés (News, Suggestion, DailyDigest)
- [ ] Boxes configurées (newsBox, suggestionsBox, digestBox)
- [ ] CacheService avec gestion TTL
- [ ] Tests de lecture/écriture fonctionnels

**Notes techniques:**
- TTL: news brutes 1h, contenu IA 24h
- Générer les adapters avec hive_generator

**Dépendances:** STORY-000

---

### EPIC-001: Digest Quotidien

#### STORY-003: Écran Home avec affichage du digest

**Epic:** EPIC-001 - Digest Quotidien
**Priorité:** Must Have
**Points:** 5

**User Story:**
En tant qu'investisseur débutant, je veux consulter un digest quotidien des actualités financières, afin de me tenir informé rapidement chaque matin.

**Critères d'acceptation:**
- [ ] HomeScreen affiche le digest du jour
- [ ] Date du jour visible en en-tête
- [ ] Liste des actualités du digest affichée
- [ ] Section suggestions visible
- [ ] Skeleton loader pendant le chargement
- [ ] Message d'erreur si échec de chargement

**Notes techniques:**
- Utiliser DigestProvider (Riverpod)
- Implémenter skeleton avec shimmer package
- Bottom navigation bar avec 2 onglets (Home, Actualités)

**Dépendances:** STORY-000, STORY-001, STORY-002

---

#### STORY-004: Récupération et génération auto du digest

**Epic:** EPIC-001 - Digest Quotidien
**Priorité:** Must Have
**Points:** 5

**User Story:**
En tant qu'utilisateur, je veux que le digest soit généré automatiquement, afin de ne pas avoir à chercher les infos moi-même.

**Critères d'acceptation:**
- [ ] GetDailyDigestUseCase implémenté
- [ ] Récupération des news depuis Yahoo Finance API
- [ ] Filtrage sur le marché européen
- [ ] Cache du digest (TTL 24h)
- [ ] Mise à jour automatique si cache expiré
- [ ] Gestion du mode hors-ligne (affiche cache)

**Notes techniques:**
- Appeler Yahoo Finance avec region=FR
- Limiter à 10 news max pour le digest
- Vérifier cache avant appel API

**Dépendances:** STORY-001, STORY-002

---

### EPIC-002: Flux d'Actualités

#### STORY-005: Écran liste des actualités

**Epic:** EPIC-002 - Flux d'Actualités
**Priorité:** Must Have
**Points:** 3

**User Story:**
En tant qu'utilisateur, je veux parcourir un flux d'actualités financières, afin de voir les dernières news en temps réel.

**Critères d'acceptation:**
- [ ] NewsScreen avec ListView scrollable
- [ ] NewsListItem widget pour chaque actualité
- [ ] Affichage: titre, source, date, thumbnail
- [ ] Navigation vers détail au tap
- [ ] Tri par date (plus récentes en haut)

**Notes techniques:**
- ListView.builder pour performance
- cached_network_image pour les thumbnails
- Pagination si >20 news

**Dépendances:** STORY-001, STORY-002

---

#### STORY-006: Pull-to-refresh du flux

**Epic:** EPIC-002 - Flux d'Actualités
**Priorité:** Should Have
**Points:** 2

**User Story:**
En tant qu'utilisateur, je veux rafraîchir le flux manuellement, afin d'obtenir les actualités les plus récentes.

**Critères d'acceptation:**
- [ ] Geste pull-to-refresh fonctionnel
- [ ] Indicateur de chargement visible
- [ ] Cache invalidé au refresh
- [ ] Nouvelles actualités affichées après refresh
- [ ] Message si pas de connexion

**Notes techniques:**
- RefreshIndicator widget
- Invalider cache newsBox au refresh

**Dépendances:** STORY-005

---

#### STORY-007: Filtrage par catégorie

**Epic:** EPIC-002 - Flux d'Actualités
**Priorité:** Could Have
**Points:** 3

**User Story:**
En tant qu'investisseur, je veux filtrer les actualités par catégorie (actions, ETF, obligations), afin de me concentrer sur ce qui m'intéresse.

**Critères d'acceptation:**
- [ ] Chips ou tabs de filtrage en haut de l'écran
- [ ] Catégories: Tous, Actions, ETF, Obligations
- [ ] Filtrage instantané (pas de rechargement)
- [ ] État du filtre persisté pendant la session

**Notes techniques:**
- FilterChip ou ChoiceChip widgets
- Filtrage côté client sur la liste en mémoire

**Dépendances:** STORY-005

---

### EPIC-003: Vulgarisation IA

#### STORY-008: Intégration OpenRouter pour vulgarisation

**Epic:** EPIC-003 - Vulgarisation IA
**Priorité:** Must Have
**Points:** 5

**User Story:**
En tant qu'investisseur débutant, je veux que les articles soient vulgarisés automatiquement, afin de comprendre facilement les informations complexes.

**Critères d'acceptation:**
- [ ] VulgarizeArticleUseCase implémenté
- [ ] Appel OpenRouter avec prompt de vulgarisation
- [ ] Réponse parsée et stockée
- [ ] Cache du contenu vulgarisé (TTL 24h)
- [ ] Texte vulgarisé adapté au niveau débutant
- [ ] Gestion des erreurs API

**Notes techniques:**
- Modèle: mistralai/mistral-7b-instruct
- Prompt système défini pour vulgarisation française
- max_tokens: 500

**Dépendances:** STORY-001, STORY-002

---

#### STORY-009: Écran détail article vulgarisé

**Epic:** EPIC-003 - Vulgarisation IA
**Priorité:** Should Have
**Points:** 3

**User Story:**
En tant qu'utilisateur, je veux voir le détail d'un article vulgarisé, afin de le lire confortablement.

**Critères d'acceptation:**
- [ ] ArticleDetailScreen créé
- [ ] Affichage: titre, source, date
- [ ] Contenu vulgarisé affiché
- [ ] Indicateur de chargement pendant vulgarisation
- [ ] Scroll si contenu long

**Notes techniques:**
- Navigation depuis NewsListItem ou DigestCard
- SingleChildScrollView pour le contenu

**Dépendances:** STORY-008

---

#### STORY-010: Accès à l'article original

**Epic:** EPIC-003 - Vulgarisation IA
**Priorité:** Should Have
**Points:** 2

**User Story:**
En tant qu'utilisateur, je veux pouvoir voir l'article original, afin d'avoir plus de détails si nécessaire.

**Critères d'acceptation:**
- [ ] Bouton "Voir l'original" visible
- [ ] Ouverture de l'URL dans le navigateur externe
- [ ] Gestion des erreurs si URL invalide

**Notes techniques:**
- url_launcher package
- launchUrl avec mode external

**Dépendances:** STORY-009

---

### EPIC-004: Suggestions Investissement

#### STORY-011: Génération suggestions via IA

**Epic:** EPIC-004 - Suggestions Investissement
**Priorité:** Must Have
**Points:** 5

**User Story:**
En tant qu'investisseur débutant, je veux recevoir des suggestions d'investissement basées sur l'actualité, afin d'identifier des opportunités.

**Critères d'acceptation:**
- [ ] GetSuggestionsUseCase implémenté
- [ ] Appel OpenRouter avec prompt suggestions
- [ ] Parsing de la réponse JSON en List<Suggestion>
- [ ] Suggestions adaptées PEA/Europe
- [ ] Cache des suggestions (TTL 24h)
- [ ] 2-3 suggestions générées par jour

**Notes techniques:**
- Prompt demandant réponse JSON structurée
- Validation du format de réponse
- Fallback si parsing échoue

**Dépendances:** STORY-001, STORY-002, STORY-004

---

#### STORY-012: Affichage suggestions sur Home

**Epic:** EPIC-004 - Suggestions Investissement
**Priorité:** Should Have
**Points:** 3

**User Story:**
En tant qu'utilisateur, je veux voir les suggestions d'investissement sur l'écran Home, afin de les consulter rapidement.

**Critères d'acceptation:**
- [ ] Section "Suggestions du jour" sur HomeScreen
- [ ] SuggestionCard widget créé
- [ ] Affichage: ticker, nom, type, recommandation
- [ ] Badge "Éligible PEA" si applicable
- [ ] Liste horizontale ou verticale des suggestions

**Notes techniques:**
- Intégrer dans HomeScreen sous le digest
- Card avec design attractif

**Dépendances:** STORY-011, STORY-003

---

#### STORY-013: Explication du "pourquoi" des suggestions

**Epic:** EPIC-004 - Suggestions Investissement
**Priorité:** Should Have
**Points:** 2

**User Story:**
En tant qu'utilisateur, je veux comprendre pourquoi une valeur est suggérée, afin de prendre une décision éclairée.

**Critères d'acceptation:**
- [ ] Champ "reasoning" affiché dans SuggestionCard
- [ ] Texte explicatif clair et compréhensible
- [ ] Lien vers l'actualité liée (si applicable)

**Notes techniques:**
- Expand/collapse pour le reasoning si long
- ExpansionTile ou AnimatedContainer

**Dépendances:** STORY-012

---

## Allocation par Sprint

### Sprint 1: MVP - 32 points

**Objectif:** Livrer un MVP fonctionnel avec digest quotidien, actualités vulgarisées et suggestions d'investissement IA

**Stories:**

| ID | Titre | Points | Status |
|----|-------|--------|--------|
| STORY-000 | Setup projet Flutter | 3 | Not Started |
| STORY-001 | Configuration APIs | 3 | Not Started |
| STORY-002 | Setup cache Hive | 3 | Not Started |
| STORY-003 | Écran Home + digest | 5 | Not Started |
| STORY-004 | Génération auto digest | 5 | Not Started |
| STORY-005 | Écran liste actualités | 3 | Not Started |
| STORY-008 | Intégration OpenRouter vulgarisation | 5 | Not Started |
| STORY-011 | Génération suggestions IA | 5 | Not Started |

**Total:** 32 points

**Livrables:**
- App Flutter fonctionnelle
- Écran Home avec digest du jour
- Écran Actualités avec liste
- Vulgarisation IA des articles
- Suggestions d'investissement générées

**Risques:**
- Intégration Yahoo Finance API (mitigation: tester early)
- Qualité des réponses OpenRouter (mitigation: itérer sur les prompts)

---

### Sprint 2: Améliorations UX - 10 points

**Objectif:** Améliorer l'expérience utilisateur avec écran détail, refresh et accès aux sources

**Stories:**

| ID | Titre | Points | Status |
|----|-------|--------|--------|
| STORY-009 | Écran détail article | 3 | Not Started |
| STORY-012 | Affichage suggestions Home | 3 | Not Started |
| STORY-006 | Pull-to-refresh | 2 | Not Started |
| STORY-010 | Accès article original | 2 | Not Started |

**Total:** 10 points

**Livrables:**
- Écran détail article complet
- Suggestions visibles sur Home
- Pull-to-refresh fonctionnel
- Liens vers articles originaux

---

### Sprint 3: Polish - 5 points

**Objectif:** Finaliser avec filtrage et explications détaillées

**Stories:**

| ID | Titre | Points | Status |
|----|-------|--------|--------|
| STORY-007 | Filtrage catégorie | 3 | Not Started |
| STORY-013 | Explication "pourquoi" | 2 | Not Started |

**Total:** 5 points

**Livrables:**
- Filtrage par catégorie (Actions, ETF, Obligations)
- Explications détaillées des suggestions

---

## Traçabilité

### Epic vers Stories

| Epic ID | Epic Name | Stories | Points | Sprint |
|---------|-----------|---------|--------|--------|
| Infrastructure | Setup projet | STORY-000, 001, 002 | 9 | 1 |
| EPIC-001 | Digest Quotidien | STORY-003, 004 | 10 | 1 |
| EPIC-002 | Flux d'Actualités | STORY-005, 006, 007 | 8 | 1, 2, 3 |
| EPIC-003 | Vulgarisation IA | STORY-008, 009, 010 | 10 | 1, 2 |
| EPIC-004 | Suggestions | STORY-011, 012, 013 | 10 | 1, 2, 3 |

### FR vers Stories

| FR ID | FR Name | Story | Sprint |
|-------|---------|-------|--------|
| FR-001 | Consultation digest | STORY-003 | 1 |
| FR-002 | Génération auto | STORY-004 | 1 |
| FR-003 | Focus Europe | STORY-004 | 1 |
| FR-004 | Flux actualités | STORY-005 | 1 |
| FR-005 | Récupération API | STORY-001 | 1 |
| FR-006 | Rafraîchissement | STORY-006 | 2 |
| FR-007 | Filtrage catégorie | STORY-007 | 3 |
| FR-008 | Vulgarisation IA | STORY-008 | 1 |
| FR-009 | Niveau débutant | STORY-008 | 1 |
| FR-010 | Article original | STORY-010 | 2 |
| FR-011 | Suggestions IA | STORY-011 | 1 |
| FR-012 | Suggestions PEA | STORY-011 | 1 |
| FR-013 | Explication suggestions | STORY-013 | 3 |

---

## Risques et Mitigation

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Yahoo Finance API indisponible | Faible | Haut | Tester early, prévoir fallback |
| Qualité vulgarisation IA | Moyenne | Moyen | Itérer sur prompts, tester avec vrais articles |
| Parsing JSON suggestions échoue | Moyenne | Moyen | Validation robuste, fallback text |
| Dépassement budget API | Faible | Moyen | Cache agressif, monitoring coûts |
| Timeline dépassée | Haute | Moyen | Focus MVP, itérer après |

---

## Definition of Done

Pour qu'une story soit considérée terminée :
- [ ] Code implémenté et commité
- [ ] Pas d'erreurs de compilation
- [ ] Fonctionnalité testée manuellement
- [ ] Critères d'acceptation validés
- [ ] Code propre (dart analyze sans erreurs)

---

## Prochaines étapes

**Immédiat:** Commencer Sprint 1

1. `/dev-story STORY-000` - Setup projet Flutter
2. Puis continuer avec STORY-001, STORY-002...
3. Ou utiliser `/create-story STORY-XXX` pour générer des docs détaillés

**Cadence suggérée:**
- Matin: Review de ce qui a été fait
- Journée: Développement
- Soir: Commit et notes pour le lendemain

---

**Ce plan a été créé avec BMAD Method v6 - Phase 4 (Implementation Planning)**

*Pour continuer: Exécutez `/dev-story STORY-000` pour commencer l'implémentation.*
