# Product Brief: Finance Daily Digest

**Date:** 2026-01-21
**Auteur:** deu
**Version:** 1.0
**Type de projet:** mobile-app
**Niveau de projet:** 2

---

## Résumé exécutif

Application mobile cross-platform de veille financière quotidienne, agrégant les actualités pertinentes (marchés, économie, entreprises) pour aider à ajuster des investissements sur différentes classes d'actifs (actions, ETFs, obligations, etc.). L'app utilise l'IA pour vulgariser l'information complexe et générer des suggestions d'investissement adaptées aux débutants. Destinée à un usage personnel et familial, avec focus sur le marché européen et les valeurs éligibles PEA.

---

## Problème à résoudre

### Le problème

Les sources d'information financière actuelles (Google Actualités, actualités bancaires) sont soit trop complexes à comprendre pour un investisseur débutant, soit trop éloignées des sujets financiers pertinents. Il n'existe pas de solution simple qui filtre le bruit, vulgarise l'information et fournit des recommandations d'investissement actionnables.

### Pourquoi maintenant ?

Besoin d'avoir uniquement les informations les plus pertinentes pour prendre de meilleures décisions d'investissement, ainsi que des recommandations claires et compréhensibles.

### Impact si non résolu

- Mauvaises décisions d'investissement par manque d'information claire
- Opportunités d'investissement manquées faute de veille efficace

---

## Audience cible

### Utilisateurs principaux

Investisseur débutant avec les caractéristiques suivantes :
- Niveau en investissement : Débutant
- Temps disponible pour la veille : Maximum 1 heure par jour
- Type d'investissement : PEA (Plan d'Épargne en Actions)
- Focus géographique : Marché européen
- Besoin : Information vulgarisée et recommandations simples

### Utilisateurs secondaires

Membres de la famille avec un profil similaire (débutants en investissement, même besoin de simplification).

### Besoins utilisateurs

- Informations financières simplifiées et vulgarisées (adaptées au niveau débutant)
- Format digestible consultable en moins d'1 heure
- Focus sur le marché européen et les valeurs éligibles PEA
- Recommandations d'investissement claires et actionnables

---

## Solution proposée

### Description de la solution

Application mobile Flutter (iOS + Android) proposant :
1. **Digest quotidien** : Synthèse des actualités financières importantes du jour
2. **Flux d'actualités** : Accès aux news en temps réel
3. **Vulgarisation IA** : Transformation automatique des articles complexes en contenu accessible
4. **Suggestions d'investissement** : Recommandations générées par IA basées sur l'actualité

### Fonctionnalités clés

- Digest quotidien des actualités financières européennes
- Flux d'actualités en temps réel
- Vulgarisation automatique par IA des articles complexes
- Suggestions d'investissement générées par IA
- Interface entièrement en français
- Focus marché européen / valeurs PEA

### Proposition de valeur

Une application qui transforme l'information financière complexe en conseils simples et actionnables pour investisseurs débutants sur le marché européen, permettant de gagner du temps et de prendre de meilleures décisions d'investissement.

---

## Objectifs

### Objectifs du projet

- Réduire le temps consacré à la veille financière quotidienne
- Améliorer la pertinence et la qualité des décisions d'investissement
- Rendre l'information financière accessible aux débutants

### Métriques de succès

- Temps de veille réduit par rapport à l'heure actuelle
- Amélioration de la performance du portefeuille
- Utilisation quotidienne de l'application

### Valeur apportée

Gain de temps significatif sur la veille financière et amélioration de la qualité des investissements grâce à une information claire et des recommandations pertinentes.

---

## Périmètre

### Dans le périmètre (v1)

- Digest quotidien des actualités financières
- Flux d'actualités en temps réel
- Vulgarisation par IA des articles
- Suggestions d'investissement générées par IA
- Focus marché européen / valeurs éligibles PEA
- Interface en français
- Application mobile cross-platform (iOS + Android) en Flutter

### Hors périmètre

- Suivi de portefeuille personnel
- Trading automatique
- Marchés hors Europe (US, Asie, etc.)
- Version web

### Considérations futures

- Version web de l'application
- Extension aux marchés US et mondiaux

---

## Parties prenantes

- **deu (Développeur/Utilisateur principal)** - Influence: Haute. Responsable du développement et utilisateur principal de l'application.
- **Famille** - Influence: Moyenne. Utilisateurs secondaires avec besoins similaires.

---

## Contraintes et hypothèses

### Contraintes

- **Framework** : Flutter (cross-platform iOS/Android)
- **Budget** : Petit budget disponible pour les APIs (financières + IA)
- **Ressources** : Projet personnel, développement à temps partiel
- **Langue** : Données et interface en français obligatoires

### Hypothèses

- Les utilisateurs possèdent un smartphone iOS ou Android
- Une API financière fournissant des données en français est disponible et accessible
- Un service IA (type GPT) est disponible pour la vulgarisation et les suggestions
- Le budget prévu est suffisant pour couvrir les coûts d'API

---

## Critères de succès

- Utilisation quotidienne de l'application
- Suggestions d'investissement perçues comme pertinentes et actionnables
- Information financière significativement plus claire et compréhensible qu'avec les sources actuelles (Google Actualités, banque)

---

## Timeline et jalons

### Objectif de lancement

Quelques jours

### Jalons clés

1. **MVP** : Digest quotidien fonctionnel avec récupération des actualités
2. **Vulgarisation IA** : Intégration de l'IA pour simplifier les articles
3. **Suggestions** : Ajout des recommandations d'investissement par IA
4. **Lancement** : Version finale prête à l'usage quotidien

---

## Risques et mitigation

- **API financière française difficile à trouver / coûteuse**
  - Probabilité : Moyenne
  - Mitigation : Rechercher plusieurs alternatives, prévoir marge dans le budget

- **Qualité des suggestions IA insuffisante**
  - Probabilité : Moyenne
  - Mitigation : Tests itératifs, ajustement des prompts, feedback utilisateur

- **Timeline serrée (quelques jours)**
  - Probabilité : Haute
  - Mitigation : Prioriser un MVP minimal fonctionnel, itérer ensuite

- **Coûts API IA élevés à l'usage**
  - Probabilité : Faible
  - Mitigation : Limiter le nombre d'appels, implémenter du caching

---

## Prochaines étapes

1. Créer le Product Requirements Document (PRD) - `/prd`
2. Définir l'architecture technique - `/architecture`
3. Planifier le sprint de développement - `/sprint-planning`

---

**Ce document a été créé avec BMAD Method v6 - Phase 1 (Analysis)**

*Pour continuer : Exécutez `/workflow-status` pour voir votre progression et le prochain workflow recommandé.*
