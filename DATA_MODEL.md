# DATA_MODEL — Structure conceptuelle

**Principe :** PostgreSQL avec clés UUID, références externes propres aux partenaires, horodatages UTC et montants `BIGINT` en XOF. Ce document décrit un modèle logique, non une migration déjà appliquée.

| Entité | Champs structurants | Notes |
|---|---|---|
| `users` | `id`, `phone_e164`, `status`, `created_at` | Téléphone unique et vérifié |
| `identity_verifications` | `id`, `user_id`, `provider_ref`, `level`, `status` | Ne pas copier plus de données KYC que nécessaire |
| `wallets` | `id`, `user_id`, `currency`, `status` | Une vue portefeuille utilisateur en XOF |
| `ledger_accounts` | `id`, `owner_type`, `owner_id`, `account_type`, `currency` | Comptes utilisateur, suspens, clearing, revenus et frais selon modèle partenaire |
| `ledger_entries` | `id`, `journal_id`, `account_id`, `direction`, `amount_xof` | Append-only ; total débits = total crédits par journal |
| `ledger_journals` | `id`, `transaction_id`, `type`, `posted_at`, `reversal_of` | Reversal par écritures compensatoires |
| `transactions` | `id`, `user_id`, `type`, `amount_xof`, `fee_xof`, `status`, `idempotency_key`, `created_at` | Recharge / envoi / retrait / cartes / encaissement |
| `payment_routes` | `id`, `provider`, `network`, `capability`, `enabled` | Disponibilité effective par sens d'opération |
| `partner_operations` | `id`, `transaction_id`, `provider`, `external_ref`, `status`, `payload_digest` | Rapprochement et idempotence externe |
| `cards` | `id`, `user_id`, `kind`, `issuer_ref`, `masked_last4`, `status` | Jamais de PAN/CVV/PIN en clair |
| `card_orders` | `id`, `card_id`, `issue_price_xof`, `shipping_xof`, `status`, `delivery_ref` | Prix fixés par commande ; provisoires lors de la conception |
| `merchants` | `id`, `user_id`, `acquirer_ref`, `verification_status` | Statut d'habilitation |
| `softpos_payments` | `id`, `merchant_id`, `transaction_id`, `acquirer_ref`, `status` | Résultat du prestataire |
| `settlements` | `id`, `provider`, `period`, `reported_total_xof`, `status` | Rapports partenaire |
| `reconciliation_items` | `id`, `settlement_id`, `partner_operation_id`, `difference_xof`, `status` | Écarts et suivi |
| `fee_rules` | `id`, `service`, `effective_at`, `config_json`, `approved_by` | Tarifs configurés selon droits contractuels |
| `admin_users` | `id`, `role`, `status` | Accès administrateur séparé |
| `audit_events` | `id`, `actor_id`, `action`, `subject`, `created_at` | Inaltérabilité opérationnelle et rétention adaptée |

## Contraintes fortes
- `UNIQUE(provider, external_ref)` lorsque référence disponible ; unicité transaction + clé idempotence.
- Index sur `transactions(user_id, created_at)`, statuts et références partenaires.
- Aucune transaction partenaire n'est comptabilisée deux fois ; événements doublons reconnus.
- Journaux **équilibrés** et liés à une preuve d'autorisation ; interdiction de suppression des écritures postées.
- Droits lecture/écriture de ledger réservés à l'API serveur ; RLS des vues utilisateurs par propriétaire ; impossible pour un client d'écrire une transaction `succeeded`.
- Calcul de solde disponible fondé sur compte + réservations selon conventions comptables spécifiées et validées avant implémentation.

## Exemple logique
Recharge validée : constater le financement côté clearing partenaire et le crédit dû au client via **deux écritures équilibrées**, selon la structure comptable approuvée par le partenaire. Les fonds clients ne deviennent jamais du chiffre d'affaires Lola Pay.
