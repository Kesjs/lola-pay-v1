# Lola Pay — Récapitulatif des décisions validées

**Statut : périmètre fonctionnel figé**  
**Date : 12 octobre 2026**  
**Document : décisions produit, UX/UI, monétisation et administration et stack — version 4**

## 1. Vision du produit

**Lola Pay** est une application mobile de paiement conçue pour le Bénin. Elle réunit un **solde Lola Pay unique en francs CFA (FCFA)**, des transferts d'argent entre réseaux Mobile Money, des cartes de paiement et un terminal de paiement directement sur smartphone.

**Promesse :** utiliser son argent facilement, quel que soit son réseau Mobile Money, et accéder aux paiements par carte depuis une seule application simple.

Lola Pay **ne cherche pas à copier toutes les fonctionnalités** de MTN MoMo ou d'autres applications Mobile Money. Son périmètre reste volontairement limité.

## 2. Fonctionnalités retenues — liste fermée

### A. Portefeuille Lola Pay

- Un **solde Lola Pay unique**, affiché en FCFA.
- Recharge du solde depuis **MTN MoMo, Moov Money et Celtiis Cash**.
- Possibilité de recharger depuis **tout autre réseau compatible**, à mesure que les connexions de paiement le permettent : aucun réseau particulier ne doit être imposé à l'utilisateur.
- Retrait de fonds depuis Lola Pay vers un réseau Mobile Money pris en charge.
- Consultation des opérations et de leur statut dans l'historique.

### B. Transferts d'argent

- Envoyer de l'argent entre **MTN MoMo, Moov Money et Celtiis Cash**, quelle que soit la combinaison de réseaux prise en charge.
- Envoyer de l'argent depuis le solde Lola Pay vers un destinataire utilisant un réseau compatible.
- Transférer de l'argent entre utilisateurs Lola Pay.
- Voir les frais applicables **avant confirmation** de la transaction.

### C. Carte virtuelle

- Demander/créer une carte virtuelle via un **émetteur partenaire habilité**.
- Alimenter ou utiliser la carte depuis les fonds du portefeuille Lola Pay, **selon le fonctionnement autorisé par le partenaire**.
- Consulter et gérer sa carte, notamment la bloquer lorsque le service le permet.
- Utiliser la carte pour les paiements en ligne acceptés par le réseau de carte et l'émetteur.

### D. Carte physique

- Commander une carte de paiement physique depuis Lola Pay.
- Afficher clairement **son prix de délivrance** et les éventuels frais de livraison avant commande.
- Suivre la commande, activer la carte et la gérer selon les capacités de l'émetteur partenaire.

### E. Terminal de paiement sur smartphone (SoftPOS)

- **Pas de terminal physique externe à fournir comme produit principal.**
- Un commerçant éligible peut utiliser son **smartphone compatible NFC** pour encaisser un paiement **par carte sans contact**.
- Parcours : saisir le montant → présenter la carte → autorisation du paiement → confirmation et reçu.
- Fonction réservée aux comptes marchands activés auprès du prestataire concerné.
- Le SoftPOS n'accepte **pas automatiquement** les comptes Mobile Money : ce sont des mécanismes distincts.

## 3. Organisation de l'application : exactement 2 écrans principaux

La navigation principale se fait **par balayage horizontal** entre deux espaces. La disposition validée le 13 octobre 2026 ajoute une **barre d’actions commune** en bas : Envoyer, Recharger (bouton central), Historique et Plus. Ces actions ouvrent des parcours secondaires et ne constituent pas de nouveaux écrans racines.

### Écran 1 — « Mon argent »

Contient :
- Solde Lola Pay en FCFA.
- **Recharger**.
- **Envoyer**.
- **Retirer**.
- Historique des transactions.
- Bénéficiaires favoris, conservés conformément à la maquette validée le 13 octobre 2026.

La recharge propose les réseaux disponibles (MTN, Moov, Celtiis, puis autres réseaux compatibles) et leur processus de validation.

### Écran 2 — « Cartes & paiements »

Contient :
- Carte virtuelle : création, consultation, gestion.
- Carte physique : commande, activation, gestion.
- **Encaisser** : SoftPOS pour les marchands éligibles.
- Historique ou gestion des opérations par carte.

### Principes de navigation

- **Deux écrans d'accueil uniquement**, passant de l'un à l'autre par glissement gauche/droite.
- Un repère visuel discret indique l'écran actif.
- Les actions ouvrent des **fenêtres, feuilles modales ou parcours secondaires dédiés** : « deux écrans » ne signifie pas supprimer les étapes nécessaires aux opérations.
- Interface épurée, mobile-first, fluide et lisible.
- **Un solde central**, pas de multiples soldes par opérateur à gérer manuellement.

## 4. Parcours essentiels

**Recharge** : ouvrir « Mon argent » → Recharger → sélectionner le réseau disponible → saisir le montant → voir les éventuels frais → autoriser le paiement → créditer le solde **uniquement après confirmation du paiement**.

**Transfert** : ouvrir « Mon argent » → Envoyer → sélectionner le destinataire/le réseau compatible → saisir le montant → contrôler les détails et les frais → confirmer → afficher le résultat réel.

**Retrait** : ouvrir « Mon argent » → Retirer → choisir le réseau et la destination → saisir le montant → vérifier les frais → confirmer → suivre le résultat.

**Carte virtuelle** : ouvrir « Cartes & paiements » → demander/créer la carte → accepter le tarif affiché et les conditions → activation par l'émetteur → gestion de la carte.

**Carte physique** : ouvrir « Cartes & paiements » → commander la carte → afficher prix et livraison → confirmer → suivre/activer la carte selon le prestataire.

**SoftPOS** : compte commerçant autorisé → « Encaisser » → montant → lecture sans contact sur smartphone NFC compatible → réponse du prestataire → reçu/confirmation.

## 5. Principes de fonctionnement et de confiance

- Tous les montants et soldes sont exprimés en **FCFA**.
- Les **frais sont transparents**, affichés avant la confirmation de chaque opération concernée.
- Les statuts de transaction doivent refléter le résultat du prestataire : **aucun succès fictif**.
- Comptes utilisateurs sécurisés, authentification, historique, contrôles antifraude et vérification d'identité nécessaires au service financier.
- Les comptes commerçants peuvent avoir accès au SoftPOS, **sans créer un troisième écran principal**.
- L'argent des utilisateurs doit être pris en charge dans un **cadre réglementaire approprié** avec un ou plusieurs établissements habilités ; l'application seule ne confère aucune autorisation d'émettre de la monnaie électronique.

## 6. Tarifs commerciaux provisoires validés — 12 octobre 2026

| Service | Tarif provisoire validé |
|---|---:|
| Création de carte virtuelle | **500 FCFA** |
| Émission de carte physique | **5 000 FCFA** |
| Livraison de carte physique | **1 000 FCFA** |
| **Carte physique livrée (total)** | **6 000 FCFA** |

Ces montants constituent les **prix cibles commerciaux approuvés pour la conception de Lola Pay**, **et non des prix définitifs de commercialisation**. Ils sont sous réserve des coûts, contrats, conditions et éventuelles taxes des partenaires financiers, émetteurs de cartes et logisticiens. Si ces coûts ne permettent pas ces tarifs, les prix devront faire l'objet d'une nouvelle validation avant lancement.

Les frais de recharge, de transfert, de retrait, de recharge des cartes et les commissions SoftPOS **ne sont pas encore fixés** ; ils devront être affichés avant chaque confirmation d'opération.

## 7. Choix techniques et partenariats encore à finaliser (sans ajout de fonctionnalités)

Ces éléments sont **des conditions de réalisation**, pas de nouvelles fonctionnalités :

- Choisir le partenaire financier habilité pour la tenue des fonds/le portefeuille et les transferts interréseaux.
- Vérifier les connexions réellement disponibles avec MTN, Moov, Celtiis, d'autres réseaux et, si pertinent, l'infrastructure interopérable PI-SPI.
- Choisir un émetteur de cartes pour la carte virtuelle et la carte physique ; confirmer réseau de carte, devises, rechargement, tarifs et conditions d'utilisation.
- Choisir un prestataire d'acceptation **SoftPOS** compatible avec le Bénin et les smartphones ciblés, sous ses exigences de sécurité.
- Finaliser l'architecture mobile/backend, le registre fiable des mouvements financiers, la sécurité et la conformité réglementaire.
- Confirmer la **viabilité des tarifs provisoires validés** (carte virtuelle 500 FCFA ; carte physique 5 000 FCFA ; livraison 1 000 FCFA) et fixer les frais encore inconnus : recharge, transfert, retrait, alimentation de carte et commissions marchands.

**Important :** les anciennes hypothèses de prix sont remplacées par les **tarifs commerciaux provisoires validés au § 6**. Aucun de ces prix ne doit être présenté comme définitivement applicable avant confirmation des coûts partenaires.

Une priorité Android a été proposée pour le démarrage, mais le support exact des plateformes reste un choix d'exécution à arrêter, et non une nouvelle fonctionnalité.

## 8. Hors périmètre — ne pas ajouter sans nouvelle décision explicite

- Reproduire l'ensemble des services de MTN MoMo ou Moov Money.
- Ajouter des écrans principaux ou rubriques de navigation supplémentaires.
- Ajouter des fonctionnalités annexes non mentionnées dans les cinq blocs validés.
- Proposer un TPE physique distinct comme offre principale : le terminal choisi est **sur smartphone**.
- Présenter comme disponibles des connexions, cartes ou opérations réelles tant que les partenaires et validations ne sont pas en place.

## 9. Définition de « terminé »

**Produit techniquement construit :** les deux écrans, parcours, comptes et contrôles sont réalisés et testés en environnement de démonstration ou de test.

**Produit financièrement opérationnel :** les partenaires et autorisations nécessaires sont obtenus, les transactions réelles sont intégrées, les cartes sont effectivement émises, le SoftPOS est certifié/opéré selon les exigences applicables, et les flux sont testés de bout en bout.

Ces deux jalons ne doivent pas être confondus.

---

**Décision finale : le périmètre fonctionnel de Lola Pay est fermé aux ajouts.** Les travaux suivants portent sur la conception détaillée, la réalisation, les partenariats, la conformité et les tests des seules fonctionnalités décrites ici.


## 10. Décisions de conception des écrans — 12 octobre 2026

### Direction UX/UI retenue

- **Deux écrans racines uniquement**, « Mon argent » et « Cartes & paiements », reliés par balayage horizontal (vers la gauche depuis Mon argent pour voir Cartes & paiements, vers la droite pour revenir). Une touche sur leur libellé et un indicateur discret permettent aussi de changer de page : aucun parcours critique ne dépend exclusivement du geste.
- Aucun menu inférieur à cinq rubriques. En-tête compact avec identité « lola pay. » et accès aux paramètres du compte existant. Pas de troisième écran principal.
- **Palette de conception proposée :** vert principal `#176B50`, vert foncé `#123D32`, fond `#F7F8FA`, surfaces `#FFFFFF`, texte `#17201D`, texte secondaire `#52625B`, bordures `#E2E8E4`, teinte douce `#EAF4EF` ; ajustable lors de la validation graphique finale sans changement fonctionnel.
- Priorité : lisibilité, montants FCFA très visibles, grandes cibles tactiles, contrastes accessibles, bandeaux d'état explicites, clavier numérique pour montants, transactions protégées contre le double envoi.
- Les actions transactionnelles utilisent des **feuilles modales ou écrans secondaires temporaires** avec bouton retour et confirmation explicite. Leur nombre ne change pas la décision « deux écrans principaux ».
- L'historique ne doit pas consommer un troisième espace racine : aperçu sur « Mon argent », détail complet ouvert à la demande.

### Maquette A — Mon argent (écran principal 1)

1. En-tête avec logo Lola Pay et accès compact au compte.
2. Carte de **solde disponible FCFA**, sans inventer de disponibilité de fonds.
3. Actions directes **Recharger**, **Envoyer**, **Retirer** ; l'historique est visible par aperçu + lien « Voir tout ».
4. Activité récente : date, type d'opération, montant signé et statut réel.
5. Indicateur de la page active et invitation discrète au balayage.

### Maquette B — Cartes & paiements (écran principal 2)

1. Aperçu de carte **masquée** (ne jamais exposer numéro intégral, cryptogramme ni secret dans l'interface non authentifiée).
2. Accès **Carte virtuelle** : créer pour **500 FCFA (provisoire)**, consulter le statut, bloquer et gérer sous réserve des capacités de l'émetteur.
3. Accès **Carte physique** : commander **5 000 FCFA** + livraison **1 000 FCFA**, soit **6 000 FCFA (provisoire)** ; suivi et activation selon le partenaire.
4. Accès **Encaisser** : SoftPOS sur Android NFC uniquement pour les commerçants habilités ; si non éligible, information de disponibilité et de vérification, **sans promettre d'encaissement opérationnel**.
5. Gestion des cartes intégrée à cet espace, sans écran principal supplémentaire.

### Inventaire fermé des maquettes de parcours

| Identifiant | Interface / état à maquettiser | Règle de conception |
|---|---|---|
| M01 | Mon argent | Solde, recharge, envoi, retrait, historique récent |
| M02 | Cartes & paiements | Carte(s), commander, SoftPOS selon éligibilité |
| M03 | Inscription et vérification | Numéro, OTP, identité selon partenaire, PIN |
| M04 | Recharger : choix réseau | MTN, Moov, Celtiis et réseaux effectivement pris en charge |
| M05 | Recharger : montant et récapitulatif | Montant, frais éventuels, destination du crédit |
| M06 | Recharger : autorisation / attente / résultat | Crédit seulement sur confirmation authentique |
| M07 | Envoyer : destinataire / réseau | Lola Pay ou réseau externe pris en charge |
| M08 | Envoyer : montant / frais / confirmation | Bénéficiaire, total débité, PIN ou authentification renforcée |
| M09 | Envoyer : attente / succès / échec | Référence et vrai statut, pas de faux succès |
| M10 | Retirer : destination / montant | Réseau, numéro, frais préalables |
| M11 | Retirer : récapitulatif / résultat | Transaction traçable et reprise sûre si interruption |
| M12 | Historique : liste et détail | Types, dates, montants, statuts, références |
| M13 | Carte virtuelle : création et gestion | Prix provisoire 500 FCFA, statut et blocage |
| M14 | Carte physique : commande et suivi | 5 000 + 1 000 = 6 000 FCFA provisoires, suivi et activation |
| M15 | SoftPOS : montant / présentation carte | Vérification marchand, appareil NFC compatible, prestataire certifié |
| M16 | SoftPOS : attente / reçu / refus | Ne confirmer que sur autorisation effective |
| M17 | Profil et sécurité minimale | Données du compte, statut de vérification, accès aux réglages de sécurité ; **aucun service financier supplémentaire** |
| M18 | États transversaux | Chargement, vide, hors connexion, opération en attente, erreur, refus, succès |

Les identifiants M03–M18 désignent des **étapes et états secondaires**, pas des écrans principaux ou des nouvelles fonctionnalités. Les contrôles d'identité et paramètres sont des exigences d'exploitation et de sécurité déjà décidées.

### Règles UI non négociables

- Afficher les frais connus avant la confirmation. Si le prestataire ne peut pas encore fournir les frais exacts, empêcher la confirmation réelle et expliquer pourquoi.
- Afficher clairement la différence entre **démonstration**, **sandbox partenaire** et **production**.
- Jamais de solde fictif présenté comme de l'argent utilisable, ni d'opération « réussie » sur la seule réponse du frontend.
- Les données bancaires sensibles et PIN ne sont pas stockés ou journalisés en clair ; affichage masqué par défaut et contrôlé par le fournisseur de cartes.
- Le mouvement des fonds est confirmé par le backend et rapproché avec le prestataire ; les états de paiement sont idempotents.
- Tout rejet, attente ou problème réseau doit être compréhensible ; aucune incitation à répéter aveuglément une opération non résolue.

## 11. Livrables visuels de conception

- Planche des maquettes : `LOLA_PAY_MAQUETTES.png` (vue d'ensemble illustrative).
- Présent document : `LOLA_PAY_DECISIONS.md` ; copie pratique `DECISIONS.md`.

La planche constitue une **direction visuelle de travail**, pas une preuve que les intégrations financières fonctionnent. Certains libellés accessoires générés dans l'illustration peuvent apparaître à titre d'habillage : ils ne doivent **pas** être interprétés comme des fonctionnalités validées. Le contenu autoritaire reste le présent document et son inventaire M01–M18.

## 12. Points externes restant ouverts (sans blocage pour les maquettes)

1. Partenariat de conservation/émission de monnaie électronique et connexions opérateurs.
2. Contrats/agréments et conformité applicables, limites et conditions KYC.
3. Émetteur de cartes et capacité réelle à financer les cartes depuis le portefeuille unique.
4. Partenaire SoftPOS réellement disponible pour les commerçants du Bénin.
5. Confirmation des prix cibles et fixation des frais variables de transactions.

**Décision de clôture :** aucun élargissement fonctionnel. Les travaux suivants portent sur les maquettes détaillées, le PRD, l'architecture, le code de test et les partenariats de production.


## 13. Décision figée — Lola Pay Mobile + Lola Pay Admin + modèle de revenus (12 octobre 2026)

> **Décision formellement validée :** « Lola Pay Mobile + Lola Pay Admin + un modèle de revenus principalement fondé sur les cartes et l’encaissement commerçant, sans faire dépendre l’entreprise de frais systématiques sur les transferts. »

### A. Deux interfaces distinctes

**Lola Pay Mobile** reste l'application destinée aux particuliers et commerçants, avec **exactement deux écrans principaux** et balayage horizontal :

1. **Mon argent** : solde FCFA unique, recharges multi-réseaux (MTN MoMo, Moov Money, Celtiis Cash, puis tout autre réseau compatible), envois, retraits, historique.
2. **Cartes & paiements** : carte virtuelle, carte physique, gestion des cartes, encaissement SoftPOS via smartphone compatible pour les commerçants autorisés.

Les étapes transactionnelles, l'inscription, la sécurité et les confirmations restent des parcours secondaires, **sans ajout d'une troisième rubrique principale**.

**Lola Pay Admin** est un **dashboard web privé**, séparé de l'application mobile et accessible uniquement au personnel habilité (route indicative `/admin`). Il pilote les services existants et ne constitue **pas une nouvelle fonctionnalité client**.

### B. Périmètre figé de Lola Pay Admin

| Module admin | Objectif opérationnel |
|---|---|
| Vue d'ensemble | Suivre l'activité, les transactions, les utilisateurs, les recettes et les incidents |
| Utilisateurs | Consulter les comptes, statuts de vérification et restrictions autorisées |
| Transactions | Examiner les recharges, transferts, retraits, paiements, statuts et références |
| Cartes | Suivre les demandes de cartes virtuelles et physiques et leur statut chez l'émetteur |
| Commerçants / SoftPOS | Voir les commerçants habilités et leurs encaissements |
| Revenus et frais | Distinguer volumes traités, recettes brutes, coûts partenaires et marges |
| Rapprochement financier | Vérifier la concordance entre écritures internes et rapports des prestataires |
| Paramètres | Gérer uniquement les tarifs, limites et intégrations que les accords permettent de configurer |

Règles de sécurité : permissions par rôle, traçabilité des actions sensibles, accès restreint aux données personnelles, double contrôle des ajustements financiers. **Un administrateur ne peut jamais réécrire directement un solde utilisateur** ; toute correction passe par une écriture contrôlée et auditée.

### C. Modèle de revenus prioritaire et figé

1. **Cartes** : marge éventuelle après coûts d'émission, fabrication, traitement et autres frais partenaires.
   - Carte virtuelle : **500 FCFA** (prix commercial *provisoire*).
   - Carte physique : **5 000 FCFA** (prix commercial *provisoire*).
   - Livraison : **1 000 FCFA**, donc **6 000 FCFA livrée** (prix commercial *provisoire*). La livraison ne doit pas être assimilée automatiquement à une marge.
2. **Encaissement SoftPOS** : commission ou partage contractuel des revenus de paiement commerçant, avec frais transparents ; taux encore **non fixé**.
3. **Transferts et retraits** : **pas de dépendance à une commission systématique**. Frais éventuels seulement s'ils sont réglementairement autorisés et contractuellement possibles, annoncés avant confirmation.
4. **Rémunération éventuelle des partenaires** : seulement si explicitement contractualisée, **non prise pour acquise**.

**Compte particulier sans abonnement prévu.** Ne pas présenter le total des fonds détenus ou les volumes transférés comme du chiffre d'affaires Lola Pay. Les revenus réels sont distincts des fonds clients, des remboursements, des coûts partenaires et du résultat net.

### D. Choix partenaires et maîtrise des coûts

- Privilégier un **établissement financier agréé avec accès interopérable PI-SPI lorsque disponible et autorisé**, puis les connexions directes aux opérateurs en complément si nécessaire.
- Ne choisir un agrégateur généraliste que si sa **couverture effective, ses droits d'exploitation et son coût total** sont meilleurs que les alternatives ; le « zéro frais » n'est pas présumé.
- Émission des cartes via un partenaire financier habilité et réseau de cartes disponible ; SoftPOS via acquéreur et solution de sécurité conformes.
- Les noms commerciaux des prestataires, les frais réels, les autorisations et les conditions définitives d'exploitation **restent à contractualiser** ; cela n'empêche pas les maquettes et le développement sur sandbox.

### E. État des maquettes et livrables

- **Planche Mobile** : `LOLA_PAY_MAQUETTES.png`, direction visuelle illustrative des deux écrans et des parcours déjà répertoriés M01 à M18.
- **Dashboard Admin** : périmètre fonctionnel désormais figé par le présent document ; **sa maquette graphique détaillée reste à produire/valider**. Il ne faut pas présenter la planche Mobile comme une maquette du dashboard Admin.
- Ce document `DECISIONS.md` est la référence de décision mise à jour (identique à `LOLA_PAY_DECISIONS.md`).

**Gel du périmètre confirmé :** aucune autre fonctionnalité client ajoutée. Les travaux restants concernent la conception détaillée du dashboard Admin, la validation des écrans, les intégrations, les accords, la conformité, les tests et la livraison.


## 14. Décision technique validée — Flutter pour Lola Pay Mobile (12 octobre 2026)

**Décision : remplacer React Native + Expo par Flutter + Dart pour l’application Lola Pay Mobile.** Le périmètre fonctionnel et les deux écrans principaux restent inchangés.

| Couche | Choix retenu | Rôle |
|---|---|---|
| Lola Pay Mobile | **Flutter + Dart** | Application Android en premier ; iOS dans un second temps |
| Lola Pay Admin | **React + TypeScript** | Dashboard web privé `/admin` |
| Backend | **Node.js + NestJS + TypeScript** | API métier, orchestration, authentification des opérations et contrôles de sécurité |
| Données | **PostgreSQL via Supabase** | Données applicatives, contrôle des accès et registre financier transactionnel géré côté serveur |
| SoftPOS | **SDK certifié du prestataire + Kotlin natif si nécessaire** | Paiement NFC sur Android compatible ; pont Flutter natif si le SDK le permet |
| Maquettes et qualité UI | **Figma + Impeccable** | Design des deux interfaces et audit de qualité, sous réserve de compatibilité des workflows disponibles |

### Contraintes techniques non négociables

- L’app Flutter n’enregistre ni PIN, ni PAN complet, ni données secrètes de paiement en clair ; les composants sensibles sont confiés aux partenaires habilités.
- Les soldes ne sont jamais calculés ni validés par le client mobile : le backend s’appuie sur un registre d’écritures atomiques, idempotentes et rapprochées avec les confirmations des prestataires.
- Supabase ne signifie pas qu’une application cliente dispose d’un accès direct en écriture aux soldes ou au registre financier.
- Les flux de recharge, transfert, retrait et carte restent désactivés en production tant que les intégrations, autorisations et contrôles ne sont pas effectifs.
- **Compatibilité SoftPOS à valider avant le développement de cette intégration** : un SDK Android peut imposer des conditions qui nécessitent Kotlin natif ou une adaptation de l’architecture. Flutter ne garantit pas à lui seul l’acceptation NFC des cartes.

**Conséquence documentaire :** toute ancienne référence à React Native + Expo comme stack choisie est remplacée par Flutter + Dart. React reste réservé à Lola Pay Admin. Aucun changement de fonctionnalité, tarification ou modèle économique.
