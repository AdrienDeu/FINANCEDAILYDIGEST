# STORY-014: Onglet Statistiques avec Time Series Marketaux

**Epic:** EPIC-005 - Analytics & Statistiques
**Priorité:** Should Have
**Story Points:** 8
**Statut:** Completed
**Assigné à:** deu
**Créé le:** 2026-01-30
**Sprint:** 4 (à planifier)

---

## User Story

En tant qu'**utilisateur de l'application Finance Daily Digest**
Je veux **visualiser les tendances de sentiment et le volume d'actualités par symbole sur différentes périodes**
Afin de **comprendre l'évolution de l'intérêt médiatique et du sentiment du marché pour mes actions favorites**

---

## Description

### Contexte
L'application affiche actuellement les actualités financières et un digest quotidien, mais ne permet pas de visualiser les tendances historiques. Les utilisateurs souhaitent comprendre comment le sentiment et la couverture médiatique évoluent dans le temps pour prendre des décisions d'investissement éclairées.

L'API Marketaux dispose d'un endpoint `entity/stats/intraday` qui fournit des données de time series parfaites pour cette fonctionnalité.

### Périmètre

**Inclus :**
- Nouvel onglet "Statistiques" dans la navigation principale
- Graphique linéaire pour l'évolution du sentiment par symbole
- Graphique en barres pour le volume d'actualités par symbole
- Sélecteur de période configurable (7 jours, 30 jours, 90 jours)
- Sélecteur de symboles (multi-sélection parmi les symboles par défaut)
- Cache local des données time series (TTL 1 heure)
- Affichage du sentiment moyen et du total d'articles sur la période

**Hors périmètre :**
- Données de prix des actions (pas disponible sur Marketaux)
- Export des données en CSV
- Comparaison entre plusieurs symboles sur le même graphique (v2)
- Alertes basées sur les tendances

### Flux Utilisateur

1. L'utilisateur navigue vers le nouvel onglet "Statistiques"
2. L'écran affiche par défaut les données des 7 derniers jours pour les symboles principaux (AAPL, MSFT, GOOGL)
3. L'utilisateur peut :
   - Changer la période via des chips (7j / 30j / 90j)
   - Sélectionner un ou plusieurs symboles via un menu dropdown
   - Basculer entre la vue "Sentiment" et "Volume"
4. Les graphiques se mettent à jour avec les nouvelles données
5. En tapant sur un point du graphique, l'utilisateur voit le détail (date, valeur exacte)

---

## Critères d'Acceptation

- [x] Un nouvel onglet "Statistiques" (icône: bar_chart) est visible dans la navigation inférieure
- [x] L'onglet charge les données depuis l'endpoint `/entity/stats/intraday` de Marketaux
- [x] Le graphique linéaire affiche l'évolution du sentiment (-1 à +1) avec code couleur :
  - Vert : sentiment > 0.2
  - Jaune : sentiment entre -0.2 et 0.2
  - Rouge : sentiment < -0.2
- [x] Le graphique en barres affiche le volume d'actualités (nombre d'articles/jour)
- [x] Les chips de période (7j, 30j, 90j) fonctionnent et rechargent les données
- [x] Le sélecteur de symboles permet de choisir parmi : AAPL, MSFT, GOOGL, AMZN, NVDA, META, TSLA, MC.PA, SAP.DE
- [x] Un indicateur de chargement (shimmer) s'affiche pendant le fetch des données
- [x] Les données sont mises en cache localement (TTL: 1 heure)
- [x] Un message d'erreur clair s'affiche si l'API échoue (rate limit, quota, erreur réseau)
- [x] L'écran affiche un résumé textuel : "Sentiment moyen: X | Articles: Y"
- [x] Le graphique supporte le zoom/pan horizontal pour naviguer dans le temps
- [x] L'écran est responsive et fonctionne en mode portrait et paysage

---

## Notes Techniques

### Composants à créer/modifier

**Data Layer :**
- `lib/data/datasources/marketaux_datasource.dart` - Ajouter méthode `fetchEntityStats()`
- `lib/data/models/entity_stats_model.dart` - Nouveau modèle pour les données time series
- `lib/data/models/entity_stats_model.g.dart` - Hive adapter généré

**Domain Layer :**
- `lib/domain/entities/entity_stats_entity.dart` - Nouvelle entité
- `lib/domain/usecases/get_entity_stats_usecase.dart` - Nouveau use case
- `lib/domain/repositories/stats_repository.dart` - Nouveau repository abstrait

**Presentation Layer :**
- `lib/presentation/screens/stats_screen.dart` - Nouvel écran
- `lib/presentation/widgets/sentiment_line_chart.dart` - Widget graphique linéaire
- `lib/presentation/widgets/volume_bar_chart.dart` - Widget graphique en barres
- `lib/presentation/widgets/period_selector.dart` - Chips de période
- `lib/presentation/widgets/symbol_selector.dart` - Dropdown multi-sélection
- `lib/presentation/screens/main_screen.dart` - Ajouter 3ème onglet

**Providers :**
- `lib/presentation/providers/providers.dart` - Nouveaux providers pour stats

### API Endpoint

```
GET https://api.marketaux.com/v1/entity/stats/intraday
```

**Paramètres :**
```dart
{
  'api_token': apiToken,
  'symbols': 'AAPL,MSFT,GOOGL',  // Configurable
  'interval': 'day',             // Fixe pour cette story
  'group_by': 'symbol',          // Regrouper par symbole
  'published_after': '2026-01-23',  // Calculé selon période
  'published_before': '2026-01-30',
  'language': 'en',
  'limit': 100
}
```

**Réponse attendue :**
```json
{
  "meta": {
    "found": 42,
    "returned": 42,
    "limit": 100
  },
  "data": [
    {
      "date": "2026-01-30",
      "data": [
        {
          "key": "AAPL",
          "total_documents": 15,
          "sentiment_avg": 0.35
        },
        {
          "key": "MSFT",
          "total_documents": 8,
          "sentiment_avg": -0.12
        }
      ]
    }
  ]
}
```

### Modèle de données

```dart
@HiveType(typeId: 4)
class EntityStatsModel {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int totalDocuments;

  @HiveField(3)
  final double sentimentAvg;

  @HiveField(4)
  final DateTime cachedAt;
}
```

### Bibliothèque de graphiques

Utiliser **fl_chart** (déjà populaire dans l'écosystème Flutter) :

```yaml
dependencies:
  fl_chart: ^0.68.0
```

### Cache

- Box Hive: `entityStatsBox`
- Clé de cache: `{symbol}_{startDate}_{endDate}`
- TTL: 1 heure (les stats ne changent pas fréquemment)

### Gestion d'erreurs

- **403 Forbidden** : L'endpoint nécessite le plan Standard ou supérieur
  - Message: "Cette fonctionnalité nécessite un abonnement Marketaux Standard"
- **429 Rate Limit** : Trop de requêtes
  - Message: "Trop de requêtes. Réessayez dans quelques secondes."
- **Erreur réseau** : Afficher données en cache si disponibles

---

## Dépendances

**Stories Prérequises :**
- STORY-001: Configuration APIs (Marketaux déjà configuré) ✓

**Stories Bloquées :**
- Aucune

**Dépendances Externes :**
- Plan Marketaux "Standard" ou supérieur requis pour l'endpoint entity/stats
- Package fl_chart pour les graphiques

---

## Definition of Done

- [ ] Code implémenté et commité sur une branche feature
- [ ] Tests unitaires écrits et passants (≥80% couverture)
  - [ ] Tests du datasource (mock API)
  - [ ] Tests du repository
  - [ ] Tests du use case
  - [ ] Tests des widgets de graphique
- [ ] Tests d'intégration passants
  - [ ] Test du flux complet (sélection symbole → affichage graphique)
- [ ] Code reviewé et approuvé (1+ reviewer)
- [ ] Documentation mise à jour
  - [ ] Commentaires sur les nouveaux endpoints
- [ ] Critères d'acceptation validés (tous ✓)
- [ ] Déployé sur environnement de test
- [ ] Tests manuels complétés
- [ ] Validation Product Owner
- [ ] Mergé sur main
- [ ] Déployé en production

---

## Estimation des Points

| Composant | Points | Justification |
|-----------|--------|---------------|
| Data Layer (datasource, model, mapper) | 2 | Endpoint simple, modèle existant à adapter |
| Domain Layer (entity, usecase, repo) | 1 | Pattern existant, copier/adapter |
| UI - Écran Stats + navigation | 2 | Nouvel écran, modification main_screen |
| UI - Graphiques (fl_chart) | 2 | Intégration nouvelle lib, 2 types de graphiques |
| Cache + Gestion erreurs | 1 | Pattern existant à répliquer |
| **Total** | **8** | Complexité modérée avec nouvelle bibliothèque |

---

## Notes Additionnelles

### Considérations UX

- Les graphiques doivent être lisibles sur petit écran (téléphone)
- Prévoir un état vide si aucune donnée disponible pour un symbole
- Animation fluide lors du changement de période/symbole

### Évolutions futures (hors périmètre)

- Comparaison multi-symboles sur même graphique
- Notifications push si sentiment chute drastiquement
- Export PDF/CSV des données
- Widget récapitulatif sur l'écran Home

### Sources API

- [Documentation Marketaux](https://www.marketaux.com/documentation)
- Endpoint: `/v1/entity/stats/intraday`

---

## Suivi de Progression

**Historique des statuts :**
- 2026-01-30: Créée par Scrum Master (BMAD)
- 2026-01-30: Implémentation commencée par deu
- 2026-01-30: Completed par deu

**Effort réel :** 8 points (égal à l'estimation)

**Notes d'implémentation :**
- Hive adapter créé pour EntityStatsModel (typeId: 4)
- Providers ajoutés : getEntityStatsUseCaseProvider, statsPeriodProvider, selectedStatsSymbolsProvider, statsViewModeProvider, entityStatsProvider
- SentimentLineChart avec code couleur (vert/jaune/rouge) et affichage des tendances
- VolumeBarChart avec affichage du volume d'articles par jour
- StatsScreen avec sélecteurs de période et symboles, toggle sentiment/volume
- Navigation ajoutée dans main_screen.dart (3ème onglet)
- Build APK debug réussi

---

**Cette story a été créée avec BMAD Method v6 - Phase 4 (Implementation Planning)**
