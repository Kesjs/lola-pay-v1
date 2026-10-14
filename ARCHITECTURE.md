# ARCHITECTURE — Lola Pay

## Stack décidée
- **Mobile :** Flutter / Dart, Android prioritaire, iOS à terme.
- **Admin :** React / TypeScript, application web privée `/admin`.
- **API :** NestJS / TypeScript ; authentification, permissions, logique métier et orchestration.
- **Base :** PostgreSQL / Supabase, migrations versionnées ; transactions financières exclusivement pilotées côté serveur.
- **SoftPOS :** SDK partenaire certifié, Kotlin natif + platform channel Flutter si requis et autorisé.

## Modules backend (domaines existants)
Identity/KYC, Wallet/Ledger, PaymentOrchestration, Transfers, Cards, SoftPOS, Admin/RBAC, PartnerAdapters, Reconciliation, Audit/Observability.

## Schéma conceptuel
`Flutter` et `React Admin` → `NestJS API` → `PostgreSQL` + `Partner Adapters` → prestataire portefeuille/PI-SPI/opérateurs, émetteur de cartes et acquéreur SoftPOS.

L'API authentifie chaque requête et autorise chaque opération ; l'application mobile **ne contacte pas directement** des API financières avec des secrets d'entreprise.

## Cycle d'une opération
1. Valider utilisateur, KYC, limites, fonds et partenaire disponible.
2. Produire devis de frais (avec durée de validité si applicable) ; demander confirmation.
3. Créer opération `pending` avec clé d'idempotence et réservation si débit.
4. Déclencher instruction partenaire ; recevoir réponse et webhook signés, ou interroger statut.
5. Valider transition d'état, inscrire atomiquement les mouvements dans registre à double entrée.
6. Réconcilier transaction, écritures et rapport de règlement partenaire.

## Invariants critiques
- Montants en entiers de FCFA ; écritures append-only équilibrées et liées à transaction, jamais mise à jour manuelle de `balance`.
- Débits et réservations atomiques ; pas de double dépense ; gestion des retries, webhooks multiples, timeouts et reversal.
- Secrets serveur en coffre approprié, rotation et journal d'accès ; chiffrement transit/repos, masquage des identifiants sensibles.
- Admin en MFA/permissions restreintes, actions traçables. Validation double pour correction financière selon règles.
- Isolation des environnements Dev / Sandbox / Production. Aucune écriture sandbox ne représente une vraie créance client.
- Limites, KYC, conservation et séparation des fonds décidées avec partenaire réglementé ; pas de conservation de données de carte ou PIN par Lola Pay.

## Déploiement
Séparer base, backend transactionnel et web Admin ; ne pas exécuter les traitements financiers critiques depuis le navigateur, ni compter uniquement sur des fonctions déclenchées à la demande sans garanties de reprise. Sauvegardes chiffrées, restauration testée, supervision, alertes, audit et procédure de réconciliation.

## Garde de production
Aucun flux réel activé avant partenaires contractés, habilitations, validation juridique et tests de certification de bout en bout.
