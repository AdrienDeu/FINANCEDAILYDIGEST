# Product Requirements Document: Finance Daily Digest

**Date:** 2026-01-21
**Auteur:** deu
**Version:** 1.0
**Type de projet:** mobile-app
**Niveau de projet:** 2
**Statut:** Draft

---

## Aperçu du document

Ce PRD (Product Requirements Document) définit les exigences fonctionnelles et non-fonctionnelles pour Finance Daily Digest. Il sert de référence pour ce qui sera développé et assure la traçabilité des exigences jusqu'à l'implémentation.

**Documents liés:**
- Product Brief: `docs/product-brief-finance-daily-digest-2026-01-21.md`

---

## Résumé exécutif

Application mobile cross-platform de veille financière quotidienne, agrégant les actualités pertinentes (marchés, économie, entreprises) pour aider à ajuster des investissements sur différentes classes d'actifs (actions, ETFs, obligations, etc.). L'app utilise l'IA pour vulgariser l'information complexe et générer des suggestions d'investissement adaptées aux débutants. Destinée à un usage personnel et familial, avec focus sur le marché européen et les valeurs éligibles PEA.

---

## Objectifs produit

### Objectifs business

- Réduire le temps consacré à la veille financière quotidienne
- Améliorer la pertinence et la qualité des décisions d'investissement
- Rendre l'information financière accessible aux débutants

### Métriques de succès

- Temps de veille réduit (objectif : < 15 min vs 1h actuellement)
- Amélioration de la performance du portefeuille
- Utilisation quotidienne de l'application
- Suggestions d'investissement perçues comme pertinentes

---

## Exigences Fonctionnelles

Les Exigences Fonctionnelles (FRs) définissent **ce que** le système fait - fonctionnalités et comportements spécifiques.

Chaque exigence inclut :
- **ID** : Identifiant unique (FR-001, FR-002, etc.)
- **Priorité** : Must Have / Should Have / Could Have (MoSCoW)
- **Description** : Ce que le système doit faire
- **Critères d'acceptation** : Comment vérifier que c'est terminé

---

### FR-001: Consultation du digest quotidien

**Priorité:** Must Have

**Description:**
L'utilisateur peut consulter un digest quotidien des actualités financières depuis l'écran principal de l'application.

**Critères d'acceptation:**
- [ ] Le digest est accessible dès l'ouverture de l'app
- [ ] Le digest affiche la date du jour
- [ ] Le digest présente les actualités sous forme de liste lisible

**Dépendances:** Aucune

---

### FR-002: Génération automatique du digest

**Priorité:** Must Have

**Description:**
Le digest est généré automatiquement chaque jour (le matin) sans intervention de l'utilisateur.

**Critères d'acceptation:**
- [ ] Le digest est mis à jour automatiquement chaque matin
- [ ] L'utilisateur voit toujours le digest du jour actuel
- [ ] Les données sont récupérées depuis l'API financière

**Dépendances:** FR-005

---

### FR-003: Focus marché européen

**Priorité:** Must Have

**Description:**
Le digest affiche les actualités les plus pertinentes du marché européen, adaptées aux valeurs éligibles PEA.

**Critères d'acceptation:**
- [ ] Les actualités concernent principalement le marché européen
- [ ] Les valeurs mentionnées sont majoritairement éligibles PEA
- [ ] Filtrage automatique des actualités non pertinentes

**Dépendances:** FR-002

---

### FR-004: Flux d'actualités

**Priorité:** Must Have

**Description:**
L'utilisateur peut consulter un flux d'actualités financières au-delà du digest quotidien.

**Critères d'acceptation:**
- [ ] Un écran "Actualités" présente un flux scrollable
- [ ] Les actualités sont triées par date (plus récentes en haut)
- [ ] Chaque actualité affiche titre, source et date

**Dépendances:** FR-005

---

### FR-005: Récupération des actualités via API

**Priorité:** Must Have

**Description:**
Les actualités sont récupérées depuis Yahoo Finance API en français.

**Critères d'acceptation:**
- [ ] Connexion fonctionnelle à Yahoo Finance API
- [ ] Récupération des actualités en français
- [ ] Gestion des erreurs réseau avec message approprié

**Dépendances:** Aucune

---

### FR-006: Rafraîchissement manuel

**Priorité:** Should Have

**Description:**
L'utilisateur peut rafraîchir le flux d'actualités manuellement (pull-to-refresh).

**Critères d'acceptation:**
- [ ] Geste pull-to-refresh fonctionnel
- [ ] Indicateur de chargement visible
- [ ] Nouvelles actualités affichées après refresh

**Dépendances:** FR-004

---

### FR-007: Filtrage par catégorie

**Priorité:** Could Have

**Description:**
L'utilisateur peut filtrer les actualités par catégorie (actions, ETF, obligations).

**Critères d'acceptation:**
- [ ] Boutons/onglets de filtrage disponibles
- [ ] Filtrage instantané sans rechargement
- [ ] Possibilité de revenir à "Toutes les actualités"

**Dépendances:** FR-004

---

### FR-008: Vulgarisation automatique par IA

**Priorité:** Must Have

**Description:**
Chaque actualité est vulgarisée automatiquement par IA (Mistral via OpenRouter) pour être compréhensible par un débutant.

**Critères d'acceptation:**
- [ ] Texte vulgarisé affiché par défaut
- [ ] Langage simple, sans jargon technique
- [ ] Termes complexes expliqués ou simplifiés

**Dépendances:** FR-005

---

### FR-009: Adaptation niveau débutant

**Priorité:** Must Have

**Description:**
Le texte vulgarisé est spécifiquement adapté au niveau débutant en investissement.

**Critères d'acceptation:**
- [ ] Vocabulaire accessible (pas de termes techniques non expliqués)
- [ ] Phrases courtes et claires
- [ ] Contexte fourni quand nécessaire

**Dépendances:** FR-008

---

### FR-010: Accès à l'article original

**Priorité:** Should Have

**Description:**
L'utilisateur peut voir l'article original (non vulgarisé) s'il le souhaite.

**Critères d'acceptation:**
- [ ] Bouton "Voir l'original" visible
- [ ] Ouverture de l'article source (in-app ou navigateur)
- [ ] Retour facile à la version vulgarisée

**Dépendances:** FR-008

---

### FR-011: Suggestions d'investissement IA

**Priorité:** Must Have

**Description:**
L'app génère des suggestions d'investissement basées sur l'actualité du jour via IA.

**Critères d'acceptation:**
- [ ] Section "Suggestions" visible dans l'app
- [ ] Suggestions générées quotidiennement
- [ ] Basées sur les actualités analysées

**Dépendances:** FR-008

---

### FR-012: Suggestions adaptées PEA/Europe

**Priorité:** Must Have

**Description:**
Les suggestions d'investissement sont adaptées au marché européen et aux valeurs éligibles PEA.

**Critères d'acceptation:**
- [ ] Valeurs suggérées majoritairement éligibles PEA
- [ ] Focus sur le marché européen
- [ ] Mention claire si une valeur n'est pas éligible PEA

**Dépendances:** FR-011

---

### FR-013: Explication des suggestions

**Priorité:** Should Have

**Description:**
Chaque suggestion inclut une explication simple du "pourquoi" cette valeur est suggérée.

**Critères d'acceptation:**
- [ ] Chaque suggestion accompagnée d'une explication
- [ ] Explication liée à l'actualité pertinente
- [ ] Langage simple et compréhensible

**Dépendances:** FR-011

---

## Exigences Non-Fonctionnelles

Les Exigences Non-Fonctionnelles (NFRs) définissent **comment** le système performe - attributs de qualité et contraintes.

---

### NFR-001: Performance - Chargement du digest

**Priorité:** Must Have

**Description:**
L'application charge le digest en moins de 3 secondes sur une connexion standard.

**Critères d'acceptation:**
- [ ] Temps de chargement < 3s mesuré sur 4G/WiFi standard
- [ ] Indicateur de chargement si > 1s

**Justification:**
Expérience utilisateur fluide pour consultation quotidienne rapide.

---

### NFR-002: Performance - Réponse IA

**Priorité:** Should Have

**Description:**
L'appel IA pour vulgarisation répond en moins de 5 secondes.

**Critères d'acceptation:**
- [ ] Temps de réponse API IA < 5s
- [ ] Affichage progressif si possible

**Justification:**
Éviter frustration utilisateur lors de la lecture.

---

### NFR-003: Disponibilité - Mode hors-ligne

**Priorité:** Should Have

**Description:**
L'application fonctionne hors-ligne avec les données en cache.

**Critères d'acceptation:**
- [ ] Digest du jour accessible sans connexion (si déjà chargé)
- [ ] Message clair si données non disponibles
- [ ] Synchronisation automatique au retour en ligne

**Justification:**
Permettre consultation dans le métro ou zones sans réseau.

---

### NFR-004: Coûts - Limite API

**Priorité:** Must Have

**Description:**
Limiter les appels API IA via caching pour rester sous 50€/mois.

**Critères d'acceptation:**
- [ ] Système de cache pour éviter appels redondants
- [ ] Monitoring des coûts API possible
- [ ] Budget mensuel respecté

**Justification:**
Projet personnel avec budget limité.

---

### NFR-005: Compatibilité - Plateformes

**Priorité:** Must Have

**Description:**
Support iOS 14+ et Android 10+.

**Critères d'acceptation:**
- [ ] App fonctionnelle sur iOS 14 et versions supérieures
- [ ] App fonctionnelle sur Android 10 et versions supérieures
- [ ] Tests sur les deux plateformes

**Justification:**
Couvrir la majorité des appareils utilisés.

---

### NFR-006: Langue - Interface française

**Priorité:** Must Have

**Description:**
Interface et contenu 100% en français.

**Critères d'acceptation:**
- [ ] Tous les textes UI en français
- [ ] Actualités en français
- [ ] Messages d'erreur en français

**Justification:**
Utilisateurs francophones, marché européen.

---

### NFR-007: Utilisabilité - Navigation simple

**Priorité:** Must Have

**Description:**
Navigation simple permettant de consulter l'essentiel en moins de 15 minutes par jour.

**Critères d'acceptation:**
- [ ] Maximum 2 taps pour accéder au contenu principal
- [ ] Interface intuitive sans tutoriel nécessaire
- [ ] Lecture du digest + suggestions en < 15 min

**Justification:**
Objectif de réduire le temps de veille.

---

### NFR-008: Maintenabilité - Architecture code

**Priorité:** Should Have

**Description:**
Code Flutter propre avec séparation UI/Logic/Data (architecture clean ou équivalent).

**Critères d'acceptation:**
- [ ] Séparation claire des couches
- [ ] Code documenté aux points critiques
- [ ] Facilité d'ajout de nouvelles fonctionnalités

**Justification:**
Faciliter les évolutions futures (version web, marchés US).

---

## Epics

Les Epics sont des regroupements logiques de fonctionnalités qui seront découpés en user stories détaillées lors du sprint planning (Phase 4).

Chaque Epic correspond à plusieurs exigences fonctionnelles et générera 2-10 stories.

---

### EPIC-001: Digest Quotidien

**Description:**
Fonctionnalité principale permettant de consulter une synthèse quotidienne des actualités financières européennes.

**Exigences Fonctionnelles:**
- FR-001: Consultation du digest quotidien
- FR-002: Génération automatique du digest
- FR-003: Focus marché européen

**Estimation stories:** 3-5 stories

**Priorité:** Must Have

**Valeur business:**
Cœur de l'application - permet de gagner du temps sur la veille quotidienne.

---

### EPIC-002: Flux d'Actualités

**Description:**
Accès à un flux d'actualités financières en temps réel, au-delà du digest quotidien.

**Exigences Fonctionnelles:**
- FR-004: Flux d'actualités
- FR-005: Récupération des actualités via API
- FR-006: Rafraîchissement manuel
- FR-007: Filtrage par catégorie

**Estimation stories:** 4-6 stories

**Priorité:** Must Have

**Valeur business:**
Permet une veille continue pour les utilisateurs souhaitant approfondir.

---

### EPIC-003: Vulgarisation IA

**Description:**
Transformation automatique des articles complexes en contenu accessible grâce à l'IA.

**Exigences Fonctionnelles:**
- FR-008: Vulgarisation automatique par IA
- FR-009: Adaptation niveau débutant
- FR-010: Accès à l'article original

**Estimation stories:** 3-4 stories

**Priorité:** Must Have

**Valeur business:**
Différenciateur clé - rend l'information accessible aux débutants.

---

### EPIC-004: Suggestions Investissement

**Description:**
Génération de recommandations d'investissement personnalisées basées sur l'actualité.

**Exigences Fonctionnelles:**
- FR-011: Suggestions d'investissement IA
- FR-012: Suggestions adaptées PEA/Europe
- FR-013: Explication des suggestions

**Estimation stories:** 3-5 stories

**Priorité:** Must Have

**Valeur business:**
Valeur ajoutée principale - aide à identifier des opportunités d'investissement.

---

## User Stories (Haut niveau)

Les user stories suivent le format : "En tant que [type utilisateur], je veux [objectif] afin de [bénéfice]."

Ces stories sont préliminaires. Les stories détaillées seront créées en Phase 4 (Implémentation).

---

### EPIC-001: Digest Quotidien

| ID | User Story |
|----|------------|
| US-001 | En tant qu'investisseur débutant, je veux consulter un digest quotidien des actualités financières, afin de me tenir informé rapidement chaque matin. |
| US-002 | En tant qu'utilisateur, je veux que le digest soit généré automatiquement, afin de ne pas avoir à chercher les infos moi-même. |
| US-003 | En tant qu'investisseur PEA, je veux que le digest se concentre sur le marché européen, afin d'avoir des infos pertinentes pour mes investissements. |

### EPIC-002: Flux d'Actualités

| ID | User Story |
|----|------------|
| US-004 | En tant qu'utilisateur, je veux parcourir un flux d'actualités financières, afin de voir les dernières news en temps réel. |
| US-005 | En tant qu'utilisateur, je veux rafraîchir le flux manuellement, afin d'obtenir les actualités les plus récentes. |
| US-006 | En tant qu'investisseur, je veux filtrer par catégorie (actions, ETF, obligations), afin de me concentrer sur ce qui m'intéresse. |

### EPIC-003: Vulgarisation IA

| ID | User Story |
|----|------------|
| US-007 | En tant qu'investisseur débutant, je veux que les articles soient vulgarisés automatiquement, afin de comprendre facilement les informations complexes. |
| US-008 | En tant qu'utilisateur, je veux pouvoir voir l'article original, afin d'avoir plus de détails si nécessaire. |

### EPIC-004: Suggestions Investissement

| ID | User Story |
|----|------------|
| US-009 | En tant qu'investisseur débutant, je veux recevoir des suggestions d'investissement basées sur l'actualité, afin d'identifier des opportunités. |
| US-010 | En tant qu'utilisateur, je veux comprendre pourquoi une valeur est suggérée, afin de prendre une décision éclairée. |

---

## Personas utilisateurs

### Persona principal : L'investisseur débutant

- **Profil** : Adulte francophone, débutant en investissement
- **Niveau** : Débutant, peu familier avec le jargon financier
- **Temps disponible** : Maximum 1 heure par jour pour la veille
- **Investissement** : PEA (Plan d'Épargne en Actions)
- **Focus** : Marché européen
- **Besoins** :
  - Information vulgarisée et accessible
  - Recommandations claires et actionnables
  - Gain de temps sur la veille

### Persona secondaire : Membre de la famille

- **Profil** : Similaire au persona principal
- **Niveau** : Débutant
- **Usage** : Consultation occasionnelle, mêmes besoins de simplification

---

## Parcours utilisateurs

### Parcours 1 : Consultation matinale (principal)

```
1. Ouvrir l'application
2. Voir le digest du jour (écran principal)
3. Lire les actualités vulgarisées
4. Consulter les suggestions d'investissement
5. (Optionnel) Approfondir une actualité
6. Fermer l'app - veille terminée en < 15 min
```

### Parcours 2 : Veille continue

```
1. Ouvrir l'application
2. Aller dans "Actualités"
3. Parcourir le flux
4. Lire un article vulgarisé
5. (Optionnel) Voir l'article original
6. (Optionnel) Filtrer par catégorie
```

---

## Dépendances

### Dépendances internes

- Aucune (projet standalone)

### Dépendances externes

| Dépendance | Description | Criticité |
|------------|-------------|-----------|
| **Yahoo Finance API** | Source des actualités financières | Haute |
| **OpenRouter.ai (Mistral)** | IA pour vulgarisation et suggestions | Haute |
| **Flutter SDK** | Framework de développement mobile | Haute |
| **Stores (App Store / Play Store)** | Distribution de l'app | Moyenne |

---

## Hypothèses

- Les utilisateurs possèdent un smartphone iOS ou Android récent
- Yahoo Finance API fournit des actualités pertinentes en français ou traduisibles
- OpenRouter.ai / Mistral est capable de vulgariser efficacement les contenus financiers
- Le budget prévu (< 50€/mois) est suffisant pour couvrir les coûts d'API
- Les utilisateurs consultent l'app principalement le matin

---

## Hors périmètre

Les éléments suivants sont explicitement exclus de cette version :

- **Suivi de portefeuille personnel** - Pas de saisie ni suivi des positions
- **Trading automatique** - Pas d'exécution d'ordres
- **Marchés hors Europe** - US, Asie, etc. exclus
- **Version web** - Mobile uniquement pour la v1
- **Notifications push** - À considérer pour v2
- **Multi-langue** - Français uniquement

---

## Questions ouvertes

Aucune question ouverte à ce stade.

---

## Approbation & validation

### Parties prenantes

- **deu (Développeur/Utilisateur principal)** - Influence: Haute
- **Famille** - Influence: Moyenne

### Statut d'approbation

- [x] Product Owner (deu)
- [ ] N/A - Projet personnel

---

## Historique des révisions

| Version | Date | Auteur | Modifications |
|---------|------|--------|---------------|
| 1.0 | 2026-01-21 | deu | PRD initial |

---

## Prochaines étapes

### Phase 3 : Architecture

Exécuter `/architecture` pour créer l'architecture système basée sur ces exigences.

L'architecture adressera :
- Toutes les exigences fonctionnelles (FRs)
- Toutes les exigences non-fonctionnelles (NFRs)
- Décisions de stack technique
- Modèles de données et APIs
- Composants système

### Phase 4 : Sprint Planning

Après l'architecture, exécuter `/sprint-planning` pour :
- Découper les epics en user stories détaillées
- Estimer la complexité des stories
- Planifier les itérations de sprint
- Commencer l'implémentation

---

**Ce document a été créé avec BMAD Method v6 - Phase 2 (Planning)**

*Pour continuer : Exécutez `/workflow-status` pour voir votre progression et le prochain workflow recommandé.*

---

## Annexe A : Matrice de traçabilité

| Epic ID | Nom Epic | Exigences Fonctionnelles | Stories estimées |
|---------|----------|--------------------------|------------------|
| EPIC-001 | Digest Quotidien | FR-001, FR-002, FR-003 | 3-5 |
| EPIC-002 | Flux d'Actualités | FR-004, FR-005, FR-006, FR-007 | 4-6 |
| EPIC-003 | Vulgarisation IA | FR-008, FR-009, FR-010 | 3-4 |
| EPIC-004 | Suggestions Investissement | FR-011, FR-012, FR-013 | 3-5 |

**Total estimé : 13-20 stories**

---

## Annexe B : Résumé des priorités

### Exigences Fonctionnelles

| Priorité | Nombre | IDs |
|----------|--------|-----|
| Must Have | 9 | FR-001, FR-002, FR-003, FR-004, FR-005, FR-008, FR-009, FR-011, FR-012 |
| Should Have | 3 | FR-006, FR-010, FR-013 |
| Could Have | 1 | FR-007 |

### Exigences Non-Fonctionnelles

| Priorité | Nombre | IDs |
|----------|--------|-----|
| Must Have | 5 | NFR-001, NFR-004, NFR-005, NFR-006, NFR-007 |
| Should Have | 3 | NFR-002, NFR-003, NFR-008 |

**Résumé :**
- 13 FRs (9 Must, 3 Should, 1 Could)
- 8 NFRs (5 Must, 3 Should)
- 4 Epics (tous Must Have)
- 10 User Stories de haut niveau
