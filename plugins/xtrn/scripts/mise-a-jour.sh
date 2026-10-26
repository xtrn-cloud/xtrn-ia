#!/bin/sh
# Met a jour le plugin xtrn en arriere-plan a chaque demarrage de session (au plus toutes les 10 min) :
# l'auto-update de Claude Code ne passe qu'apres le premier message et un delai aleatoire (jusqu'a 10 min),
# trop tard pour les sessions courtes. La nouvelle version s'applique a la session suivante.
T="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/xtrn-xtrn}/derniere-maj"
mkdir -p "$(dirname "$T")"
[ -n "$(find "$T" -mmin -10 2>/dev/null)" ] && exit 0
touch "$T"
( claude plugin marketplace update xtrn && claude plugin update xtrn@xtrn ) </dev/null >/dev/null 2>&1 &
exit 0
