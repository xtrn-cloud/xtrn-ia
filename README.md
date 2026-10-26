# xtrn-ia

Catalogue de plugins Claude Code de la plateforme xtrn Cloud (dépôt **public** : aucun secret, aucun nom de client).

- `plugins/xtrn/contexte.md` : contexte injecté à chaque session Claude des éditeurs (hook `SessionStart`)
- `plugins/xtrn/agents/` : agents `xtrn-dev` et `xtrn-relecteur`
- `plugins/xtrn/scripts/mise-a-jour.sh` : mise à jour du plugin en arrière-plan à chaque démarrage de session (au plus toutes les 10 min)

Les éditeurs déclarent ce catalogue dans `/etc/claude-code/managed-settings.json` (image `xtrn-ci/editeur`),
avec mise à jour automatique. Pas de champ `version` dans le plugin : chaque commit poussé sur `main`
est récupéré en arrière-plan au démarrage de chaque session et s'applique à la session suivante.

Avant de pousser : `claude plugin validate .` (l'avertissement « No version specified » est voulu).
