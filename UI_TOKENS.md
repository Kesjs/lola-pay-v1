# Lola Pay — Contrat de design system

Ces tokens sont les choix de réalisation proposés à partir de la direction validée ; les couleurs restent une direction visuelle tant qu'une revue finale des maquettes n'a pas été signée.

| Usage | Valeur |
|---|---|
| Vert primaire | `#176B50` |
| Vert foncé | `#123D32` |
| Fond général | `#F7F8FA` |
| Surface | `#FFFFFF` |
| Texte principal | `#17201D` |
| Texte secondaire | `#52625B` |
| Bordure | `#E2E8E4` |
| Surface teintée | `#EAF4EF` |
| Typographie | Inter si licenciée/distribuable dans l'application, repli police système |
| Échelle espace | 4, 8, 12, 16, 24, 32 px logiques |
| Rayon | 8, 12, 16, 24 px logiques |
| Tactile | au moins 48 × 48 dp |
| Grandes sommes | chiffres tabulaires, groupement des milliers |

## Composants verrouillés par le besoin
`BalanceCard`, `TransactionRow`, `NetworkChoice`, `AmountInput`, `FeeBreakdown`, `ConfirmationSummary`, `SecureApproval`, `StatusView`, `MaskedCard`, `CardOrderSummary`, `SoftPOSAmountView`, `KycStep`, `PaginationIndicator`, `AdminKpi`, `AdminDataTable`, `AdminStatusChip`.

## Micro-interactions
- Navigation racine : swipe court et fluide, sans mise en mouvement excessive ; alternative tactile explicite.
- Montant : affichage des frais recalculés côté serveur, chargement sans clignotement, pas de confirmation multiple.
- Opération : progressif `créée → en attente → réussie/refusée` selon état métier ; jamais animation « succès » sur timeout.
- Message erreur : action récupérable et référence quand disponible, sans divulguer détails internes.

## Accessibilité
Contraste texte et composants vérifié avant code (WCAG 2.2 AA visé), police agrandissable, lecture d'écran, ordre de focus, thèmes système si requis sans modifier l'architecture, réduction des animations, labels de statut explicites. Vérifications réelles à effectuer : pas d'audit Impeccable exécuté à cette étape.
