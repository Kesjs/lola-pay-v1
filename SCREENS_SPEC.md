# Lola Pay — Spécifications des maquettes M01–M18

**Statut : spécifications de conception prêtes pour revue.** Les planches fournissent la direction visuelle ; les écrans individuels haute fidélité n'ont pas encore été approuvés manuellement dans Figma. Aucune fonctionnalité nouvelle.

## Navigation et règles globales
- Deux pages racines uniquement : M01 « Mon argent » et M02 « Cartes & paiements », geste horizontal + indicateur de page et activation accessible sans geste.
- Une opération financière se déroule dans une route secondaire plein écran pour les champs, le récapitulatif et la confirmation ; retour préserve la saisie non sensible lorsque sûr.
- Montants en FCFA, espaces de milliers, séparateur adapté au français, saisie numérique et dénomination du réseau partout où nécessaire.
- Un seul solde utilisateur ; la donnée de solde n'est jamais recalculée côté client. La carte peut avoir des règles de financement dépendantes de l'émetteur.
- Tous exemples de numéros, bénéficiaires et montants de maquette sont fictifs. Aucun logo Visa/Mastercard n'est à utiliser comme promesse de partenariat signé.

## Inventaire détaillé

| ID | En-tête | Composition obligatoire | Action principale | États et erreurs visibles |
|---|---|---|---|---|
| M01 | Mon argent | marque, accès profil, solde XOF, actions Recharger / Envoyer / Retirer, 3 dernières transactions, Voir tout, pagination 1/2 | Ouvrir opération sélectionnée | masquage solde, solde indisponible, liste vide, chargement |
| M02 | Cartes & paiements | carte masquée ou carte absente, créer/gérer carte virtuelle, commander/suivre carte physique, encaisser SoftPOS si compte marchand éligible, pagination 2/2 | Ouvrir parcours | carte indisponible, émission en cours, éligibilité refusée, NFC absent |
| M03 | Bienvenue / inscription | n° +229, OTP, code PIN, vérification d'identité requise par partenaire | Continuer selon étape | code expiré, trop d'essais, vérification en examen |
| M04 | Recharger — réseau | choix MTN, Moov, Celtiis et réseaux réellement activés ; état indisponible si non connecté | Sélectionner réseau | absence de réseaux ; indisponibilité temporaire |
| M05 | Recharger — montant | réseau, montant, frais, total à payer, montant crédité et récapitulatif | Payer | montant incorrect, plafond, solde source insuffisant signalé par partenaire |
| M06 | Recharger — statut | paiement externe, état `en attente`, référence, succès / refus | Terminer / Historique | réseau coupé, statut inconnu, vérification différée ; ne pas créditer prématurément |
| M07 | Envoyer — destination | choix Lola Pay ou réseau compatible, téléphone bénéficiaire, identité confirmée si disponible | Continuer | bénéficiaire introuvable, réseau non pris en charge |
| M08 | Envoyer — montant | destinataire, montant, frais, total débité, récapitulatif, autorisation PIN | Confirmer | fonds insuffisants, dépassement limite, authentification échouée |
| M09 | Envoyer — statut | attente, résultat réel, référence, destinataire, total | Voir historique | refus et délai de traitement clairement différenciés |
| M10 | Retirer | compte Mobile Money destinataire, opérateur, montant, frais et total débité | Continuer | compte non admissible, plafond et erreur réseau |
| M11 | Retirer — confirmation/statut | résumé, confirmation sécurisée, attente / résultat, référence | Terminer | pas de second débit suite à double clic ou reconnexion |
| M12 | Historique/détail | transactions chronologiques, filtres légers par type/statut, lignes datées, détail référence, frais et destinataire masqué | Voir détail | vide / chargement / erreur / transactions en attente |
| M13 | Carte virtuelle | coût provisoire 500 FCFA, état demande/active/bloquée, représentation masquée, actions de gestion permises | Demander / Bloquer | refus émetteur, frais non acquis, indisponibilité temporaire |
| M14 | Carte physique | coût 5 000 FCFA + livraison 1 000 FCFA, montant total 6 000 FCFA provisoire, commande/suivi/activation | Commander | adresse non confirmée, livraison non couverte, échec émission |
| M15 | Encaisser SoftPOS | montant, statut commerçant, compatibilité NFC/Android, mode lecture approuvé SDK | Encaisser | compte non éligible, NFC absent, SDK indisponible |
| M16 | Encaisser — résultat | autorisation en traitement, acceptation ou refus du partenaire, référence, reçu | Terminer | annulation et réseau perdu ; aucune confirmation anticipée |
| M17 | Profil / sécurité | identité minimale, vérification, paramètres sécurité, sortie de session | Modifier donnée autorisée | informations sensibles masquées, session expirée |
| M18 | Composants d'état | skeleton, liste vide, hors-ligne, erreur, statut inconnu, attente, rejet et succès | Réessayer de façon sûre | pas de nouvel ordre financier lors d'un simple rafraîchissement |

## Comportement de contrôle
- Chaque champ de montant présente les frais **avant** l'authentification finale ; si les frais changent, retour au récapitulatif avec nouvelle validation.
- Le résultat définitif ne provient jamais de la simple réponse de navigation du client ; il exige un retour confirmé du serveur/partenaire.
- Pas de bouton ou message invitant à repayer tant qu'une opération identifiée est encore en attente ; consultation du statut possible.
- Pour toute émission carte, prélèvement conditionné à l'acceptation ; remboursement/reversal conforme au partenaire en cas d'échec.
- Sécurité : ne jamais rendre le PIN, OTP, numéro complet de carte ou jetons dans captures, notifications, journaux ou analytics.

## Contrat de livraison visuelle
- Deux captures racines (M01, M02), seize vues/parcours secondaires documentés ci-dessus et leurs états, plus états responsive Android compacts.
- Fichiers source Figma éditables et revue formelle restent à faire si la livraison nécessite une conception approuvée pixel à pixel. La planche PNG est conceptuelle et peut contenir du texte approximatif généré.
