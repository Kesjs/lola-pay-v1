# LOLA PAY — Politique tarifaire des transferts et stratégie de gratuité

**Version :** 1.0  
**Date :** 12 octobre 2026  
**Statut :** politique produit retenue ; coûts contractuels, éligibilité réglementaire et tarifs non couverts encore à confirmer  
**Document associé :** `DECISIONS.md` (sans modification du périmètre fonctionnel)

## 1. Objectif

Lola Pay veut permettre aux particuliers de transférer facilement de petits montants en FCFA entre les réseaux compatibles, notamment MTN MoMo, Moov Money et Celtiis Cash, sans supporter de commissions disproportionnées.

**Positionnement retenu : petits transferts gratuits lorsqu'ils sont éligibles ; frais transparents sur les autres opérations ; rentabilité principalement fondée sur les cartes et l'encaissement commerçant.**

La gratuité est une politique de prix, **pas** une nouvelle fonctionnalité.

## 2. Règles commerciales

| Opération | Politique cible | Condition / réserve |
|---|---|---|
| Lola Pay → Lola Pay | Gratuit pour le client | À valider avec le partenaire qui tient les portefeuilles ; coûts supportables et droits contractuels établis |
| Transfert national interopérable entre particuliers via PI-SPI | Gratuit jusqu'au seuil réglementaire éligible | À compter du 2 novembre 2026 : 8 000 FCFA **cumulés par jour, par utilisateur et par participant** ; vérifier le traitement contractuel du cas Lola Pay |
| Transfert national via PI-SPI au-dessus du seuil | Frais éventuels affichés à l'avance | Cadre BCEAO : taux éventuel entre 0 et 0,8 % sur le montant hors taxes, selon les dispositions applicables |
| Réception de transfert éligible PI-SPI | Gratuite | Dans le champ d'application du dispositif BCEAO |
| Transfert via autre connecteur (ex. FedaPay) | Prix calculé selon le coût réel ; aucune gratuité automatique | Sous réserve de l'autorisation d'usage, des conditions du fournisseur et de la réglementation ; **ne pas promettre un tarif gratuit que Lola Pay devrait subventionner sans plafond** |
| Recharge du portefeuille | Rechercher les frais les plus bas possibles | Gratuite pour le client uniquement si les coûts et accords le permettent ; règle PI-SPI sur les transferts ≠ gratuité automatique des recharges |
| Retrait vers Mobile Money | Frais transparents, aussi faibles que possible | Conditions opérateur/partenaire ; ne pas promettre une gratuité générale |

**Important :** l'annonce de la BCEAO concerne les transferts de monnaie électronique entre personnes physiques dans son champ d'application. Elle ne dispense pas Lola Pay d'obtenir les autorisations et contrats nécessaires. Les dispositions nationales prennent effet le **2 novembre 2026** ; les conditions régionales identiques sont annoncées à compter du **1er juin 2027**.

## 3. Pourquoi on évite les frais fixes de 500 FCFA sur les petits transferts

Un client qui envoie 2 000 FCFA et paie 500 FCFA de frais supporte des frais équivalant à **25 % du montant envoyé**. Ce prix va à l'encontre de l'objectif d'accessibilité de Lola Pay.

**Décision :** ne pas instaurer de frais fixes de 500 ou 570 FCFA sur tous les transferts. Les frais éventuels doivent dépendre de l'opération, de ses coûts, de son éligibilité et des règles applicables.

## 4. PI-SPI : rail prioritaire, sous réserve d'accès contractuel

Architecture cible :

`Lola Pay Mobile → Backend Lola Pay → partenaire financier habilité → PI-SPI → compte bénéficiaire compatible`

1. Privilégier un partenaire ayant la capacité d'offrir des transferts interopérables via PI-SPI.
2. Vérifier l'éligibilité effective des comptes MTN, Moov et Celtiis concernés et les types de transactions couverts.
3. Obtenir les coûts réellement facturés à Lola Pay, y compris frais mensuels, techniques et opérationnels, le cas échéant.
4. Calculer automatiquement le prix affiché à l'utilisateur sur la base de l'opération et des limites réglementaires autorisées.
5. Ne pas confondre **gratuité pour le client** et **absence de coût pour Lola Pay**.

## 5. FedaPay : solution complémentaire, pas le rail gratuit par défaut

Tarification publique consultée le 12 octobre 2026 sur https://www.fedapay.com/pricing :

- Collecte MTN / Moov / Celtiis : **1,80 %** du montant collecté.
- Payouts vers ces opérateurs : **150 FCFA** entre 0 et 10 000 FCFA ; **300 FCFA** entre 10 001 et 50 000 FCFA ; puis autres paliers publiés.
- Les payouts doivent être **activés sur demande** ; un payout vers un tiers n'est pas équivalent à un retrait de la balance FedaPay.
- Les soldes des différents moyens de paiement ne sont pas nécessairement fusionnés, selon la documentation d'assistance.

**Simulation illustrative, non tarif contractuel :** si une recharge de 2 000 FCFA (1,8 % = 36 FCFA) est suivie d'un payout séparé de 2 000 FCFA (150 FCFA), la somme des frais publiés serait de **186 FCFA**. Cela ne signifie pas que chaque transfert Lola Pay coûtera forcément 186 FCFA : les flux peuvent différer, et des frais ou conditions additionnels sont possibles.

**Décision :** utiliser FedaPay comme candidat à l'intégration et au sandbox, surtout en solution complémentaire ; **ne pas fonder la promesse de gratuité générale sur ses tarifs publics**. Obtenir d'abord l'accord écrit permettant l'usage dans une fintech avec solde client, les payouts vers des particuliers et les conditions B2B réelles.

## 6. Sources de revenus qui financent Lola Pay

| Source | Politique retenue |
|---|---|
| Carte virtuelle | **500 FCFA** par émission (prix client provisoire) |
| Carte physique | **5 000 FCFA** par carte (prix client provisoire) |
| Livraison de carte physique | **1 000 FCFA** (prix client provisoire) |
| Carte physique livrée | **6 000 FCFA** au total |
| Encaissement SoftPOS | Rémunération / commission contractuelle sur opérations commerçants |
| Transferts | **Pas une source de revenus indispensable** : frais éventuels uniquement lorsque permis et justifiés |

**Règle comptable :** chiffre d'affaires ≠ sommes transférées ≠ soldes clients. Les coûts de carte, de conformité, de support, de paiement et de prévention de fraude doivent être retranchés avant de parler de bénéfice.

## 7. Garde-fous économiques

- Ne pas financer automatiquement des transferts déficitaires sans budget ni contrôle explicites.
- Avant le lancement, comparer le coût complet d'une transaction gratuite et les marges nettes attendues des autres activités.
- Afficher à l'utilisateur **montant envoyé, frais, montant débité, montant reçu**, avant confirmation.
- Si une opération n'est pas disponible aux conditions annoncées, afficher son indisponibilité ou son tarif autorisé ; ne pas masquer les frais.
- Vérifier les paliers, les taxes, le règlement des litiges, les annulations et les frais de remboursement dans les contrats.
- Tester le calcul et les états de transactions en sandbox avant l'activation réelle.
- Assurer le suivi des coûts et marges par rail de paiement dans **Lola Pay Admin**, sans créer de nouvelle rubrique mobile.

## 8. Conséquences pour les interfaces existantes

**Lola Pay Mobile — écran « Mon argent » :** aucune rubrique nouvelle. Dans les parcours *Envoyer / Recharger / Retirer*, afficher les frais avant validation et indiquer « Gratuit » seulement si l'opération est effectivement éligible.

**Lola Pay Admin :** utiliser les rubriques existantes *Transactions*, *Revenus et frais*, *Réconciliation* et *Paramètres* pour comparer les coûts partenaires, surveiller les opérations subventionnées et contrôler les règles tarifaires autorisées.

## 9. Ce qui est figé et ce qui reste à confirmer

### Figé

- Les petits transferts gratuits éligibles sont une priorité produit.
- Aucun frais fixe généralisé de 500/570 FCFA pour envoyer 2 000 FCFA.
- PI-SPI est la priorité stratégique pour les transferts interopérables.
- FedaPay demeure un candidat secondaire / de test ; il n'est pas désigné comme fournisseur définitif.
- La rentabilité repose d'abord sur les cartes et l'encaissement SoftPOS.
- Les **deux écrans mobiles** et les **fonctionnalités validées** ne changent pas.

### À confirmer avant les paiements réels

- Partenaire agréé portant légalement les fonds du portefeuille.
- Disponibilité réelle PI-SPI pour chaque destination et droits d'accès à l'API.
- Convention FedaPay autorisant le modèle fintech, les payouts et leurs tarifs négociés.
- Émetteur des cartes, acquéreur SoftPOS et commissions effectives.
- Application juridique précise des seuils BCEAO aux différents parcours de Lola Pay.
- Viabilité du modèle après calcul de la marge et des coûts de fonctionnement.

## 10. Sources officielles

1. BCEAO, communiqué du 2 octobre 2026, *Transactions de monnaie électronique entre personnes physiques via PI-SPI* : https://www.bceao.int/index.php/fr/communique-presse/transactions-de-monnaie-electronique-entre-personnes-physiques-par-0
2. FedaPay, tarifs publics Bénin : https://www.fedapay.com/pricing
3. FedaPay, documentation des payouts : https://support.fedapay.com/portal/fr/kb/articles/comment-faire-des-paiements-en-masse-payouts

---

**Résumé de décision :** *Lola Pay privilégie les petits transferts sans frais pour les utilisateurs éligibles, via un partenaire PI-SPI. Elle ne fonde pas sa rentabilité sur la facturation systématique des transferts. FedaPay reste une intégration complémentaire éventuelle, soumise à des frais et autorisations explicites.*
