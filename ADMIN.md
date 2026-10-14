# ADMIN — Lola Pay Admin (web privé)

## Statut
Outil interne déjà validé. Ne crée **aucune nouvelle fonctionnalité utilisateur**. Adresse indicative : `/admin`, séparée de Lola Pay Mobile.

## Navigation fermée
1. **Vue d'ensemble :** comptes actifs, volumes financiers, recettes, taux d'échec, incidents ; chiffres sourcés et datés.
2. **Utilisateurs :** liste, vérification, statuts et restrictions dans le cadre des droits accordés.
3. **Transactions :** rechercher, consulter les références, statuts, frais et suites d'incidents.
4. **Cartes :** suivre émission virtuelle, commandes physiques et statuts émetteur.
5. **Commerçants / SoftPOS :** état d'éligibilité et des encaissements autorisés.
6. **Revenus et frais :** distinguer recettes brutes, coût d'émission, coûts acquéreur et marges ; ne pas confondre volume traité et recettes.
7. **Rapprochement :** opérations manquantes/doublées, règlements et anomalies.
8. **Paramètres :** tarifs, limites, état des connexions et permissions autorisées.

## Autorisations initiales
- `viewer`: consulter métriques agrégées et pages autorisées, données masquées.
- `operations`: suivi de transactions et incidents, sans réécrire de solde.
- `compliance`: KYC/restrictions dans le cadre contractuel.
- `finance`: rapprochement, frais, journaux et correction supervisée.
- `admin`: gestion des accès et paramètres sous journal d'audit.

Les rôles sont une proposition d'implémentation interne des droits déjà exigés ; attribution exacte et séparation des fonctions à valider avant mise en production.

## Règles
MFA administrateur, session courte, principe du moindre privilège, journalisation des consultations sensibles et des modifications, double validation pour actes à effet financier. **Aucun champ « modifier le solde »**. Export de données uniquement si autorisé par conformité et politique de confidentialité.

## Maquette
Dashboard détaillé **non encore dessiné/validé** : prévoir en revue UI une sidebar compacte, KPI datés, liste incidents priorisés et tableau des dernières opérations avec références. Les chiffres de démonstration doivent être explicitement fictifs.
