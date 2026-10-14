# PRD — Exigences de Lola Pay

## Périmètre fonctionnel verrouillé

### F01 — Compte et accès
- Inscription par téléphone et vérification OTP ; vérification d'identité adaptée au niveau de service et au partenaire.
- Écran de profil/sécurité secondaire, PIN ou authentification renforcée pour les opérations sensibles.
- Un utilisateur ne doit voir que ses informations ; rôles et permissions contrôlés côté serveur.

**Acceptation :** compte non vérifié limité selon règles applicables ; OTP invalide/expiré refusé ; accès direct à une ressource d'autrui interdit.

### F02 — Solde centralisé
- Affichage solde disponible FCFA alimenté exclusivement par le registre validé côté serveur.
- Distinguer disponible, réservé et opération en attente si nécessaire aux calculs ; **ne pas créer plusieurs portefeuilles visibles par opérateur**.

**Acceptation :** aucune mutation client directe ; pas de soldes négatifs non autorisés ; réconciliation possible.

### F03 — Recharger
- Afficher uniquement les réseaux réellement disponibles ; MTN, Moov, Celtiis sont des cibles de couverture, pas des connexions garanties.
- Réseau → montant → frais réels → confirmation et autorisation partenaire → statut de paiement → crédit uniquement après validation vérifiée.

**Acceptation :** double webhook ne double pas le crédit ; délai/erreur = statut en attente ou échoué sans crédit anticipé.

### F04 — Envoyer
- Destinataire Lola Pay ou numéro sur un réseau externe pris en charge ; présentation du bénéficiaire lorsqu'il est vérifiable.
- Montant, frais, total, confirmation renforcée ; exécution idempotente.

**Acceptation :** deux pressions ne créent pas deux transferts ; fonds insuffisants refusés ; statut non définitif présenté comme tel.

### F05 — Retirer
- Choisir opérateur et destination autorisés, montant et frais, confirmer et suivre le statut.

**Acceptation :** réservation préalable ; débit final selon confirmation ; compensation/annulation comptable en cas d'échec conformément au contrat.

### F06 — Historique
- Liste filtrée sur l'utilisateur : type, montant signé, date, statut, référence, frais ; détail accessible depuis l'écran Mon argent.

**Acceptation :** les statuts historiques reflètent les écritures et réponses réelles, jamais un simple retour écran.

### F07 — Carte virtuelle
- Demande via émetteur habilité ; prix affiché **500 FCFA provisoires**, gestion et blocage selon SDK/API partenaire ; données sensibles externalisées.

**Acceptation :** émission uniquement après acquittement et validation de l'émetteur ; secret de carte jamais conservé en clair par l'application.

### F08 — Carte physique
- Commande et suivi ; affichage **5 000 FCFA + 1 000 FCFA = 6 000 FCFA provisoires** ; activation et statut selon l'émetteur.

**Acceptation :** prix complet avant confirmation ; commande sans duplication ; suivi reflétant les étapes confirmées.

### F09 — SoftPOS
- Réservé aux comptes marchands autorisés, appareils Android NFC compatibles, SDK d'un partenaire d'acquisition certifié ; saisie du montant, lecture, attente, verdict et reçu.

**Acceptation :** téléphone non compatible bloqué clairement ; aucun paiement déclaré réussi sans autorisation de l'acquéreur.

### F10 — Administration
- Rubriques figées : vue d'ensemble, utilisateurs, transactions, cartes, commerçants, revenus/frais, rapprochement, paramètres.

**Acceptation :** contrôle d'accès par rôle ; toutes les actions sensibles auditables ; impossibilité d'éditer arbitrairement un solde.

## Exigences transversales
- Montants en entiers XOF, pas en flottants ; timestamps en UTC, affichage local approprié.
- Validation du tarif avant engagement ; si frais inconnus, empêcher exécution réelle.
- États `draft`, `pending`, `processing`, `succeeded`, `failed`, `reversed` selon les flux ; transitions validées côté serveur.
- Webhooks authentifiés + idempotence + traçabilité + rapprochement quotidien et lors d'incidents.
- Pas de vraies opérations avant contrats, contrôles, habilitations et validation réglementaire.

## Non-objectifs
Tout ce qui n'apparaît pas dans F01 à F10 ou dans `DECISIONS.md` est exclu du périmètre commercial. Tests, observabilité, audit et sécurité sont des propriétés d'exploitation, pas des fonctionnalités client.
