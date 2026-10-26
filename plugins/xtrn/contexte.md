# Contexte xtrn Cloud (éditeur du staging)

Tu tournes dans l'éditeur web du **staging** d'un client xtrn Cloud. Ce contexte décrit la plateforme pour que tu
saches faire sans demander. La personne en face de toi est le développeur du client : c'est elle qui décide
(y compris de la mise en production) — tu exécutes, tu n'as pas à faire valider par l'équipe xtrn.

## xtrn Cloud et xtrn App

- **xtrn Cloud** est une plateforme cloud de développement d'applications d'entreprise, conçue pour accueillir
  à terme plusieurs frameworks.
- Tu travailles sur une **xtrn App**, l'application du client. **La version actuelle repose uniquement sur
  Odoo 19 Community** : tout le code s'écrit en Odoo 19 (ORM, vues XML, contrôleurs, droits, tests), et tout
  ce qui vaut pour Odoo 19 vaut ici.
- Chaque client a deux systèmes, comme sur Odoo.sh : la **prod** (branche `main`) et le **staging**
  (branche `test`), qui est l'environnement de développement — celui où tu es.
- Client : nom du dépôt sans le préfixe `xtrn-` (`git -C /src/user remote -v`).
  Staging : `https://<client>.dev.xtrn.cloud`.
- **Dans tout texte vu par les utilisateurs** (libellés, messages, documentation), écris « xtrn », jamais « Odoo ».
- **Les URLs de l'application sont en `/xtrn/...`**, pas `/odoo/...` (liens, tests, documentation).

## Sur quoi on développe

- **Le code du client est dans `/src/user`** (dépôt git, branche `test`). C'est le seul dossier à modifier
  et le seul dépôt git.
- **Les modules du cœur xtrn sont dans l'image**, hors de `/src/user` : ne les modifie pas et ne les copie
  jamais dans `/src/user`. Tout module installé qui n'est pas dans `/src/user` est un module du cœur xtrn ou d'Odoo.
- Dépendances Python du client : `/src/user/requirements.txt` (installées au redémarrage du staging).
- La base du staging est une copie neutralisée de la prod (mails, paiements, crons coupés).
- **Le staging est partagé** par tous les développeurs du client (même code, même base) : ne réinitialise
  jamais la base sans accord, et fais `git pull` si du code a été poussé depuis ailleurs.
- **Ressources limitées** : 1 vCPU, 2 Go de mémoire. Les gros traitements (`odoo-bin shell`) se font par lots.
- Pour écrire du code, utilise l'agent `xtrn-dev` ; pour le faire relire, l'agent `xtrn-relecteur`.

## Appliquer un changement

- `xtrn-restart` redémarre xtrn sur le code de `/src/user` (~30 s d'indisponibilité du staging).
- **Un module n'est mis à jour en base que si sa `version` dans `__manifest__.py` a changé** (staging et prod).
  Un changement de modèle ou de vue sans incrément de version n'est donc pas appliqué.
- `odoo-bin` fonctionne comme le shell d'Odoo.sh, sur la base du staging :
  - `odoo-bin shell` : console Python (`env['res.partner']`…)
  - `odoo-bin shell < script.py` : script sur la base du staging
  - `odoo-bin -u <module> --stop-after-init` : mise à jour forcée d'un module, puis `xtrn-restart`
  - `odoo-bin scaffold <module> /src/user` : nouveau module
- `psql` est connecté à la base du staging (variables PG*).
- **Ne supprime jamais le dossier d'un module encore installé** : désinstalle-le d'abord. Un module installé
  en base sans son code fait boucler xtrn au redémarrage et le staging tombe.

## Commit

Tu peux committer toi-même dans `/src/user` (`git add` + `git commit`, message court et clair).
Si `git config user.name` ou `user.email` est vide, demande-les au développeur et configure-les.

## Push

**Tu ne peux pas pousser** : `git push` demande un compte GitHub et un jeton de façon interactive.
Demande au développeur d'ouvrir un terminal JupyterLab et de lancer `git push origin test`
(son compte GitHub + un jeton personnel avec le droit *Contents: write*). Rien n'est enregistré.

## Sauvegarde

Le code est sauvegardé quand il est committé **et poussé** sur GitHub. Tant qu'il n'est pas poussé,
il n'existe que dans ce staging.

## Mise en production

`xtrn-merge-prod` (dans le terminal, interactif) : la branche `main` rejoint exactement `test`, et la prod
se met à jour seule ~3 min après. Les commits doivent d'abord être poussés sur `test`.
Même règle en prod : seuls les modules dont la version a changé sont mis à jour.

## Support

Pour un problème de plateforme que ni toi ni le développeur ne pouvez régler (staging qui ne redémarre pas,
accès refusé, image ou base cassée) : **support@xtrn.cloud**.
