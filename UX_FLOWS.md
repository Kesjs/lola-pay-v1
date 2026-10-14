# UX_FLOWS — Navigation et inventaire des vues

## Structure
**Racines uniques :** `Mon argent` ↔ `Cartes & paiements`. Balayage gauche depuis Mon argent ; droite pour revenir. Sélecteur de titre accessible pour les utilisateurs ne souhaitant pas balayer. Aucun troisième onglet.

## Écrans racines
- **M01 Mon argent :** marque, profil, solde XOF, Recharger, Envoyer, Retirer, activité récente, Voir tout.
- **M02 Cartes & paiements :** aperçu masqué, Carte virtuelle, Carte physique, Encaisser (si commerçant éligible), opérations cartes.

## Écrans secondaires et états (inventaire fermé)
| ID | Vue | Parcours détaillé |
|---|---|---|
| M03 | Inscription / identité | Téléphone → OTP → vérification demandée par partenaire → PIN |
| M04 | Réseau de recharge | Choix parmi seuls opérateurs connectés |
| M05 | Montant de recharge | Montant → frais → total → confirmer |
| M06 | Résultat recharge | Autorisation → attente → succès/échec vérifié |
| M07 | Destinataire envoi | Lola Pay ou numéro et opérateur compatible |
| M08 | Montant envoi | Vérifier destinataire → montant → frais → authentifier |
| M09 | Résultat envoi | En traitement → résultat/incident → référence |
| M10 | Retrait | Destination → montant → frais |
| M11 | Résultat retrait | Confirmer → en attente → résultat réel |
| M12 | Historique | Liste → détail (référence, frais, statut) |
| M13 | Carte virtuelle | Demande (500 FCFA provisoires) → statut → blocage/gestion |
| M14 | Carte physique | Commande (6 000 FCFA livrée provisoires) → suivi → activation |
| M15 | SoftPOS lecture | Compte vérifié → montant → NFC selon SDK |
| M16 | SoftPOS résultat | Traitement → autorisation/refus → reçu |
| M17 | Profil/sécurité | Identité et réglages de sécurité existants |
| M18 | États universels | Vide, chargement, réseau absent, échec, pending, succès |

## Consignes UX de finance
- Toujours présenter source/destination, montant, frais et total avant confirmation.
- Désactiver la répétition sur opérations non résolues ; conserver référence et état de reprise.
- En cas d'expiration, permettre vérification du statut avant réessai.
- Masquer données carte, téléphone et éléments d'identité dans les vues d'ensemble.
- OTP/PIN et authentifications restent des étapes contrôlées par le système ou le partenaire.
- Libellés explicites « Démo », « Sandbox » ou « Réel » suivant l'environnement.

## Maquettes
`LOLA_PAY_MAQUETTES.png` est **une planche d'intention seulement**, non une preuve d'implémentation individuelle validée de M01 à M18. Les écrans détaillés devront être produits et audités avant développement final.
