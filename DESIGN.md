---
name: Lola Pay Mobile & Admin
description: Accueil mobile vert et lisible ; administration de contrôle.
colors:
  primary: "#176B50"
  primary-dark: "#123D32"
  background: "#F7F8FA"
  surface: "#FFFFFF"
  text: "#17201D"
  muted: "#52625B"
  border: "#E2E8E4"
  tint: "#EAF4EF"
  indicator-inactive: "#AAB7AF"
  favorite-green-light: "#427963"
  favorite-green-dark: "#2B5A46"
  demonstration-label: "#DAEDE3"
  status-failed: "#B23C32"
typography:
  brand:
    fontFamily: "system sans-serif"
    fontSize: "27dp"
    fontWeight: 800
    letterSpacing: "-0.7dp"
  balance:
    fontFamily: "system sans-serif"
    fontSize: "29dp"
    fontWeight: 800
    fontFeature: "tabular figures"
  card-title:
    fontSize: "25dp"
    fontWeight: 800
  section:
    fontSize: "16dp"
    fontWeight: 700
  body:
    fontSize: "13dp"
    lineHeight: 1.5
  action:
    fontSize: "12dp"
    fontWeight: 700
  navigation:
    fontSize: "11dp"
rounded:
  interactive: "12dp"
  field-row: "14dp"
  service: "16dp"
  overview-bar: "18dp"
spacing:
  small: "8dp"
  gap: "12dp"
  section: "16dp"
  content-bottom: "32dp"
components:
  overview-card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.primary-dark}"
    rounded: "{rounded.overview-bar}"
    padding: "14dp 9dp 14dp 22dp"
  action-bar:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.muted}"
    rounded: "{rounded.overview-bar}"
    padding: "8dp 6dp 8dp 10dp"
  recharge-action:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    size: "62dp"
  service-card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.service}"
    padding: "12dp 22dp 12dp 16dp"
  transaction-row:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.field-row}"
  field:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.field-row}"
---

# Design System: Lola Pay Mobile & Admin

## Overview

La direction de l’accueil mobile a été explicitement approuvée le 13 octobre 2026 : conserver la composition de la référence à deux écrans, les favoris et la barre d’actions commune, en remplaçant ses accents jaunes et bleus par le vert Lola Pay existant. Cette approbation porte sur cette composition et cette palette ; elle ne constitue pas une validation générale de toutes les maquettes.

L’accueil Flutter associe un en-tête vert, des panneaux blancs arrondis et une hiérarchie centrée sur les montants. Les états de démonstration, d’absence de données et d’indisponibilité restent visibles. Cette extraction de `mobile/lib/main.dart` et `mobile/lib/home.dart` ne certifie aucun audit rendu, test ou contraste. Aucun nouveau nom de concept créatif n’a été sélectionné.

**Key Characteristics:**
- Vert de marque conservé et surfaces claires.
- Deux espaces balayables et une barre d’actions persistante.
- Favoris issus de la saisie utilisateur, montants tabulaires et statuts explicites.
- Administration sobre orientée suivi et contrôle.

## Colors

### Primary

Le vert primaire porte l’en-tête, les icônes d’action, Recharger et l’indicateur actif. Le vert foncé porte les titres et grands montants. La teinte claire accompagne badges et icônes de transactions. Deux verts complémentaires différencient les avatars favoris sans nouvelle famille d’accents.

### Neutral

Le fond général sépare les panneaux blancs ; texte principal, texte secondaire et bordures structurent les contenus. L’indicateur inactif est grisé. Le libellé de démonstration utilise un vert très clair sur l’en-tête. Le rouge de statut signale les opérations échouées avec un libellé et une icône.

**The Existing Green Rule.** Conserver le vert Lola Pay pour cette composition approuvée ; ne pas réintroduire les accents jaunes et bleus de la référence.

## Typography

La réalisation utilise la police sans serif système Flutter, sans famille Inter explicitement chargée. Les tailles du frontmatter sont des pixels logiques Flutter et suivent l’agrandissement système. La marque s’ajuste vers le bas quand nécessaire ; les grands montants et montants d’opération utilisent des chiffres tabulaires.

Le titre d’espace dans le panneau est de 17 dp, poids 500. Le solde domine les titres de section. Les textes secondaires utilisent un interligne de 1.4 à 1.5 selon le composant.

## Layout

L’accueil cible les téléphones Android compacts. L’en-tête suit la zone sûre supérieure : profil à gauche, marque au centre, notifications à droite. Son fond descend sur 238 dp plus l’inset supérieur avec une terminaison elliptique. Le `PageView` utilise une fraction visible de 0.94 pour suggérer la page voisine. Chaque page défile verticalement avec des marges internes de 10 dp sur les côtés, 18 dp en haut et 32 dp en bas.

« Mon argent » présente solde, actions Recharger/Envoyer/Retirer, indicateurs, favoris et dernières opérations. « Cartes & paiements » présente carte virtuelle, indicateurs, services et opérations par carte. Les deux indicateurs tactiles offrent une alternative au swipe ; les titres ne sont pas des contrôles de navigation dans le code actuel.

Les services cartes passent de deux colonnes séparées de 12 dp à une colonne si leur largeur disponible est inférieure à 290 dp ou si un texte de 14 dp est agrandi au-delà de 19 dp. Ce seuil est local au composant.

L’Admin conserve un web responsive à sidebar simple : Vue d’ensemble, Utilisateurs, Transactions, Cartes, Commerçants, Revenus et frais, Rapprochement, Paramètres. Densité modérée, filtres raisonnables, tableaux lisibles et montants alignés à droite restent les consignes Admin ; cette extraction ne constitue pas un audit React.

## Elevation & Depth

Le panneau principal utilise une ombre Flutter de couleur `0x14123D32`, décalage (0, 10), flou 24. La barre fixe utilise `0x10123D32`, décalage (0, -4), flou 18. Les services et lignes d’activité se distinguent surtout par leur fond blanc. Recharger n’ajoute pas d’élévation Flutter propre. Le sidecar fournit les équivalents CSS de prévisualisation.

## Shapes

Les panneaux principaux et les coins supérieurs de la barre utilisent overview-bar ; les services utilisent service ; champs et lignes utilisent field-row. Les avatars et Recharger sont circulaires. Recharger mesure 62 dp, avec une bordure blanche de 4 dp et un relèvement de 12 dp. Les avatars favoris mesurent 56 dp dans des cellules de 84 dp ; Nouveau reprend ce cercle avec une bordure verte de 1.5 dp.

## Components

### Panneau principal

Un badge teinté en haut à gauche, avec coin inférieur droit de 10 dp, précède le titre centré puis le montant ou l’état carte. Un séparateur fin isole les actions du bas. Icônes Material en contour, libellés centrés. Le solde dispose d’un contrôle afficher/masquer et d’un libellé sémantique adapté.

### Navigation et actions

**The Shared Action Bar Rule.** Les deux espaces partagent exactement la même barre fixe : Envoyer, Recharger, Historique, Plus. Ces commandes déclenchent des actions ; elles ne deviennent pas des onglets de navigation racine.

Chaque indicateur a une cible de 48 × 48 dp ; sa marque passe de 7 à 20 dp de largeur à l’état actif. Navigation tactile : 240 ms, `easeOutCubic` ; indicateurs : 180 ms. La réduction des animations système remplace le changement de page par un saut et supprime l’animation des indicateurs.

### Favoris et opérations

Au plus trois favoris sur l’accueil puis Nouveau ; Voir tout ouvre la liste complète. Les initiales proviennent des noms enregistrés localement. Les opérations associent icône sur teinte claire, réseau, statut textuel et montant tabulaire. Les états vides et erreurs remplacent les données absentes sans activité inventée.

### Services, champs et feuilles

Les services utilisent une icône de 33 dp et une commande de hauteur minimale 48 dp. Les champs du thème sont blancs avec contour border ; les autres états Material ne sont pas redéfinis comme tokens personnalisés. Les choix rapides et informations s’ouvrent en bottom sheet ; les confirmations sensibles et détails étendus suivent les parcours prévus.

### Admin

Conserver les statuts lisibles sans dépendre uniquement de la couleur, aucune donnée sensible en clair dans les tableaux et aucune édition libre des soldes. La direction Admin précédente est maintenue. Les maquettes M01–M18, états vide/erreur/attente et administration restent à examiner sur les véritables fichiers ; ne jamais déclarer ces audits exécutés avant de les effectuer.

## Do's and Don'ts

### Do:
- **Do** conserver la composition mobile approuvée, les favoris et les deux espaces.
- **Do** conserver la barre Envoyer, Recharger, Historique, Plus identique sur les deux pages.
- **Do** afficher clairement les états de démonstration, indisponibilité, attente et erreur.
- **Do** vérifier rendus Android, textes agrandis, TalkBack, contrastes et cibles tactiles avant de déclarer l’accessibilité validée.

### Don't:
- **Don't** ajouter un troisième espace racine ou remplacer la barre d’actions par des onglets.
- **Don't** inventer bénéficiaires, soldes, cartes ou opérations pour remplir l’interface.
- **Don't** présenter cette extraction comme un audit exécuté ou une validation de tous les parcours.
- **Don't** appliquer automatiquement la composition mobile à l’Admin web.
