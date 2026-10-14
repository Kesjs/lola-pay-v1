# Lola Pay Admin — Spécification des 8 vues web

**Administration privée, séparée de l'application mobile** ; elle ne modifie pas les deux écrans racines Flutter.

## Shell commun
Largeur desktop 1440, sidebar 224–240 px, topbar basse, cartes KPI compactes, tableaux avec pagination, filtre unique visible et états vide/chargement/erreur. Sur tablette la sidebar se replie ; sur mobile l'administration est consultable mais les actions sensibles restent protégées. Montants à droite, chiffres tabulaires, XOF. Toutes données de maquette fictives.

| Page | Sections visibles | Actions autorisées | Restrictions |
|---|---|---|---|
| A01 Vue d'ensemble | KPI datés : utilisateurs, volume traité, recettes, incidents, graphique et dernières opérations | accès détails | volume traité ≠ revenus |
| A02 Utilisateurs | recherche, statut compte/KYC, date inscription, détails masqués | consulter / appliquer restriction selon rôle | pas de consultation identitaire excessive |
| A03 Transactions | référence, nature, source/destination masquées, montant/frais, statut, horodatage, fournisseur | consultation et suivi incident | pas de saisie directe de solde |
| A04 Cartes | virtuelles / physiques, état demande/émission/activation, coût, livraison | consultation, traitement opérationnel autorisé | PAN/CVV jamais affichés |
| A05 Commerçants | statut vérification, disponibilité SoftPOS, encaissements et rejets | consulter éligibilité | aucun accès non autorisé au SDK |
| A06 Revenus et frais | cartes facturées, rémunérations SoftPOS acquises, coûts partenaires, marge, ventilation par période | filtrer/export conforme droits | pas d'inclusion des fonds utilisateurs en recettes |
| A07 Rapprochement | rapprochements partenaires, entrées en attente, références manquantes, écarts, preuve d'investigation | traitement supervisé | corrections à double contrôle et trace immuable |
| A08 Paramètres | tarifs cibles/activés, plafonds, statut intégrations, rôles autorisés | modifications soumises à permissions | aucun secret exposé ; MFA obligatoire |

### Matrice de rôles
Viewer : lecture limitée ; Operations : transactions/incidents ; Compliance : KYC ; Finance : frais/rapprochement ; Admin : paramètres/accès. Toute consultation de donnée sensible et changement important génère une trace d'audit. Deux validations pour opération à effet financier si partenaire/législation applicable.

### États requis par page
Navigation clavier, pagination, recherche sans résultat, retard source, incident API, accès refusé, données en chargement. Chaque indicateur possède une période, une devise et une source, et les exemples sont explicitement marqués « Démonstration ».

### Direction visuelle
Référence : `PLANCHE_DESIGN_MOBILE_ADMIN.png`, dernière bande du tableau (Admin). Cette planche n'est **pas** un écran interactif audité ni un Figma validé.
