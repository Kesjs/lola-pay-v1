# INTEGRATIONS — Partenaires financiers

## Stratégie approuvée
Prioriser l'**interopérabilité PI-SPI via un établissement participant habilité**, sous réserve que les parcours souhaités et les réseaux soient contractuellement disponibles. Recourir aux API officielles d'opérateurs au cas par cas si nécessaire. **Ne pas imposer un agrégateur généraliste** sans comparatif de coût total et de couverture.

## Trois familles de partenaires visées
| Bloc | Partenaire | Vérifications obligatoires |
|---|---|---|
| Fonds, recharges, transferts, retraits | Établissement habilité + connexions PI-SPI/opérateurs | Détention des fonds, statuts, payout, sandbox, frais, réconciliation, SLA |
| Cartes virtuelle et physique | Banque/émetteur ou programme habilité | Éligibilité Bénin, Visa/Mastercard ou réseau disponible, émission, funding, conformité PCI, coûts et livraison |
| SoftPOS | Acquéreur + solution certifiée | Acceptation Bénin, Android NFC, SDK Flutter/Kotlin autorisé, certification, commission, règlements |

## Grille comparative obligatoire
Pour chaque candidat : **disponibilité contractuelle au Bénin**, autorisation réglementaire, frais d'installation, abonnement, coût par opération, minimum de facturation, devises, garde des fonds, webhooks signés, latence, plafonds, règlement, chargebacks, couverture MTN/Moov/Celtiis, mode test, support et conditions de sortie.

## Tarifs validés, à ne pas transformer en garanties
- Carte virtuelle : **500 FCFA provisoires**.
- Carte physique : **5 000 FCFA provisoires**.
- Livraison : **1 000 FCFA provisoires**.
- SoftPOS, recharges, transferts, retraits : **frais non fixés**.

## Procédure d'intégration
1. Demander documentation API et convention ; vérifier faisabilité juridique.
2. Tester sandbox avec scénario nominal, erreur, double webhook, expiration, timeout et remboursement/réversion.
3. Mesurer coût complet et valider le modèle économique.
4. Obtenir validation conformité, certifier si requis et tester la réconciliation.
5. Activer production seulement par configuration contrôlée et auditée.

**Statut :** aucun partenaire commercial n'est signé ou certifié dans ce dossier ; aucun service ne doit être commercialisé comme opérationnel.
