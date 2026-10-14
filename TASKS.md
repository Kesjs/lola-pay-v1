# TASKS — Plan de développement sans dérive fonctionnelle

## J0 — Figer la référence
- [x] DECISIONS v4 copiées au dossier.
- [x] PRD, modèle conceptuel, architecture, parcours, design et admin spécifiés.
- [ ] Valider individuellement les M01–M18 à partir de `SCREENS_SPEC.md` et des planches ; créer sources Figma éditables et exécuter un vrai audit Impeccable (non exécuté).
- [ ] Valider les huit vues A01–A08 décrites dans `ADMIN_SCREENS.md` ; déclinaisons responsive et fichier Figma éditable à produire.

## J1 — Préparer la base technique
- [ ] Monorepo ou dépôts coordonnés Flutter mobile / React Admin / NestJS API ; CI et environnements séparés.
- [ ] Migrations PostgreSQL, authentification, RBAC, secrets, journal d'audit et jeux de test.
- [ ] Registre financier à double entrée testé en invariants, concurrence, idempotence et reversal.

## J2 — Réaliser Lola Pay Mobile
- [ ] M03 inscription/OTP/KYC (mode test).
- [ ] M01/M02 navigation horizontale et accessibilité.
- [ ] M04–M06 recharge sandbox, M07–M09 envoi sandbox, M10–M11 retrait sandbox.
- [ ] M12 historique et statuts ; M13–M14 cartes via doubles de test du partenaire.
- [ ] M15–M16 contrat SoftPOS et faisabilité SDK avant code NFC ; M17–M18 sécurité/états.

## J3 — Réaliser Lola Pay Admin
- [ ] Vue d'ensemble, utilisateurs, transactions, cartes et commerçants.
- [ ] Revenus et frais, rapprochement, paramètres autorisés et permissions.
- [ ] Audit des actions sensibles, tests d'accès non autorisé et données privées.

## J4 — Intégrations et fiabilité
- [ ] Comparer et sélectionner les prestataires sur devis et conformité.
- [ ] Connecteurs PI-SPI/opérateurs, cartes et SoftPOS selon contrats.
- [ ] Tests de perte réseau, doublons, retries, chargebacks, rapprochement, settlement et alertes.
- [ ] Revue sécurité, sauvegarde/restauration, contrôle anti-fraude et réponse aux incidents.

## Jalons de validation
- **Démonstration utilisable :** deux écrans, parcours et Admin fonctionnels en test ; toutes les transactions clairement marquées sandbox/démo.
- **Production financière :** accords habilités, conformité, frais validés, tests E2E, certification applicable, opérations et settlement rapprochés.

## Hors périmètre
Aucune fonctionnalité client au-delà de `DECISIONS.md`. Toute demande nouvelle doit être consignée séparément comme proposition non approuvée, sans être développée.
