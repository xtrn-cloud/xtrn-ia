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
- **xtrn n'est pas un ERP.** La xtrn App s'appuie uniquement sur le socle du framework : utilisateurs et droits,
  ORM, vues, mail et activités, automatisations, import, API, portail. Les applications métier d'Odoo (Ventes,
  Comptabilité, Stock, Fabrication, Achats, CRM, RH…) ne font pas partie de xtrn : ne les installe pas et ne
  t'appuie pas sur elles. Si le besoin y ressemble (produits, commandes, factures…), modélise-le dans le module
  du client, à la mesure du besoin.
- Un module qui n'apparaît pas dans l'écran Applications n'existe pas sur la plateforme.
- Si le projet dépend déjà d'une application métier (héritage d'avant xtrn), garde l'existant tel quel, mais
  n'ajoute aucune nouvelle dépendance métier.
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

- **Code** : sauvegardé quand il est committé **et poussé** sur GitHub. Tant qu'il n'est pas poussé, il n'existe
  que dans ce staging.
- **Données de la production** (dans la console, onglet Sauvegardes) : quotidienne chaque nuit (base à la minute
  près, et fichiers, gardée 30 jours), hebdomadaire (5 semaines) et mensuelle (3 mois) au format sauvegarde Odoo,
  et **manuelle** à la demande (« Sauvegarder maintenant », admin, 5 par jour au plus, gardée 3 jours).
- **Le staging n'a pas de sauvegarde automatique** (comme Odoo.sh) : on le reprend de la production (Rebuild).
  Avant une opération risquée sur les données du staging, préviens le développeur qu'elles ne sont pas sauvegardées.

## Mise en production

- Dans la console, **Merge → production** (admin) : `main` reprend exactement `test` (avance rapide), puis la
  prod se déploie seule (~5 min). Le premier Merge crée la production. Les commits doivent d'abord être poussés
  sur `test`.
- Équivalent en terminal : `xtrn-merge-prod` (interactif, compte GitHub + jeton demandés).
- Si `main` contient des commits absents de `test`, le merge est refusé : ramener d'abord `main` dans `test`
  (`git merge origin/main` sur `test`, puis push).
- Même règle en prod : seuls les modules dont la version a changé sont mis à jour.

## Console du projet

`https://xtrn.cloud/projet/<client>` (connexion avec le compte GitHub). Tu ne peux pas l'utiliser toi-même :
quand une action s'y fait, dis au développeur où cliquer. Les actions sur les données et la prod sont réservées
aux **admins** du projet.

- **Collaborateurs** : comptes GitHub du projet, rôle **admin** (éditeur + gestion des accès et des opérations)
  ou **membre** (éditeur seulement). Les droits d'écriture sur le dépôt se gèrent sur GitHub.
- **Accès SSH** au staging (shell, `sftp`, `scp`, même environnement que ce terminal) : chaque collaborateur ajoute
  sa clé publique, un admin autorise les adresses IP ; connexion `ssh <code>@ssh.dev.xtrn.cloud`.
- **Projet** : état test / production, **Merge → production**, historique de la branche `test`.
- **Se connecter** : ouvre la xtrn App avec l'utilisateur de son choix, sans mot de passe (staging : tous les
  collaborateurs ; production : admins).
- **Rebuild** (staging) : remplace la base et les fichiers du staging par ceux de la production, neutralisés
  (mails, paiements, tâches planifiées coupés). **Le code de `test` est conservé.**
- **Reset to production** (staging) : données **et** code de la production ; la branche `test` est ramenée sur
  `main` (les commits non mis en production en sortent, ils restent dans l'historique GitHub).
- **Restaurer…** (onglet Sauvegardes) : depuis une sauvegarde de la production, soit **sur le staging** (données
  neutralisées et code de cette date, `test` ramenée sur ce commit), soit **la production elle-même** (arrêt de
  quelques minutes, tout ce qui a été saisi depuis est remplacé, une sauvegarde de sécurité est faite juste avant).
- Rebuild, Reset et Restaurer **effacent les modifications non committées** de ce staging : avant de les
  conseiller, fais committer et pousser le travail en cours.
- URLs : production `https://<client>.xtrn.cloud`, staging `https://<client>.dev.xtrn.cloud`,
  éditeur `https://<client>.dev.xtrn.cloud/editeur/`.

## Support

Pour un problème de plateforme que ni toi ni le développeur ne pouvez régler (staging qui ne redémarre pas,
accès refusé, image ou base cassée) : **support@xtrn.cloud**.
