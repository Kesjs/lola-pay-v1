# Lola Pay — Dossier de conception

**Version :** 1.0 — 12 octobre 2026  
**Référence normative :** `DECISIONS.md` (version 4).  
**Statut :** Conception spécifiée ; intégrations financières non opérationnelles.

## Documents

| Fichier | Utilité |
|---|---|
| `DECISIONS.md` | Décisions figées et réserves externes (source de vérité) |
| `PRODUCT.md` | Vision, utilisateurs, périmètre |
| `PRD.md` | Exigences détaillées et critères d'acceptation |
| `UX_FLOWS.md` | Deux écrans racines et 18 vues/états secondaires |
| `DESIGN.md` | Système visuel et règles de maquettes Flutter + Admin |
| `ARCHITECTURE.md` | Infrastructure, API, connecteurs, sécurité |
| `DATA_MODEL.md` | Entités, écritures comptables et transactions |
| `ADMIN.md` | Fonctions et permissions de l'espace web Admin |
| `INTEGRATIONS.md` | Choix, comparaison et tests des partenaires externes |
| `TASKS.md` | Ordre d'exécution, jalons et critères de livraison |
| `LOLA_PAY_MAQUETTES.png` | Planche illustrative mobile, **non définitive** |

## Règle absolue

Aucune fonctionnalité client supplémentaire. **Mobile = deux écrans racines uniquement**. Les sous-écrans de paiement et les fonctions de sécurité ne modifient pas cette règle. Le tableau de bord Admin est une interface privée, distincte.

## Limites

Aucune API de paiement, licence, émission de carte, disponibilité SoftPOS ou tarification contractuelle n'est présumée active. Toute donnée de démonstration doit être étiquetée « Démo ». Les prix des cartes sont provisoires.

## Compléments de conception (12 octobre 2026)
- `SCREENS_SPEC.md` : inventaire M01–M18 et états/contraintes détaillés.
- `ADMIN_SCREENS.md` : 8 écrans Admin, droits et règles d'exploitation.
- `UI_TOKENS.md` : tokens et composants.
- `PRE_CODE_CHECKLIST.md` : ce qui est spécifié et ce qui n'est pas encore validé.
- `PLANCHE_DESIGN_MOBILE_ADMIN.png` : illustration complémentaire mobile et Admin.

Les planches sont des maquettes **conceptuelles**, non des écrans Figma individuels audités. Ne pas interpréter les détails décoratifs générés comme exigences fonctionnelles.

## Prototype sandbox en cours

Le premier vertical slice fonctionnel couvre la recharge :

- `api/` : API NestJS, devis, idempotence, traitement asynchrone, ledger équilibré et persistance locale de sandbox dans `.data/` ;
- `admin/` : dashboard React connecté aux mêmes routes API ;
- `mobile/` : application Flutter avec les deux écrans racines et le parcours de recharge branché sur l'API.

L'environnement reste explicitement sandbox : aucun partenaire financier réel n'est appelé et aucune opération ne représente des fonds réels. Le stockage local est un adaptateur de prototype ; il devra être remplacé par PostgreSQL/Supabase avant le jalon financier.

### Lancer le prototype

```powershell
npm install
npm run dev:api
npm run dev:admin
```

Puis ouvrir `http://localhost:5173`. Pour Flutter Android, lancer l'émulateur avec l'API sur le port 3000 ; l'app utilise `10.0.2.2` par défaut et accepte `--dart-define=LOLA_API_URL=...`.
# lola-pay-v1
