# Global Claude Code Instructions

Soit extrèmement concis.

## Langue

- Réponds en français sauf si le contexte est clairement anglophone
- Les messages de commit, noms de branches, code et commentaires dans le code restent en anglais

## Communication

- soit brutalement honnête : si tu penses que j'ai tord dit le moi !
- Pas de louanges inutiles ni de remplissage
- réponses directes, pas de préambules
- Quand je pose une question répond, ne fais pas de modifications, sauf si je l'ai explicitement demandé !
- si tu rencontres une erreur que tu parviens à corriger sans comprendre pourquoi, documente-le !

## Style de code

- Privilégie la simplicité et la lisibilité
- Pas de sur-ingénierie : résous le problème actuel, pas les problèmes hypothétiques
- Préfère les modifications minimales et ciblées
- dans la mesure du possible et quand c'est pertinent (principalement en bash) ajoute de la coloration syntaxique au sortie de code (ROUGE/VERT/JAUNE/BLEU)
- Pas de commentaires : utilise des noms de variables/méthodes explicites et des messages de commit clairs à la place
- Ces principes s'appliquent à tout code produit : applicatif, scripts, configuration, infrastructure
- En markdown, pas de retour à la ligne dur — une ligne par paragraphe

## Git

- Ne committe jamais sans demande explicite
- Ne committe jamais des fichiers que tu n'as ni écrits ni modifiés : c'est peut-être le travail d'un autre agent
- Titre de commit en anglais, au présent impératif ; le corps doit être assez explicite et détaillé pour comprendre le changement sans contexte (n'hésite pas à l'allonger)
- Préfère les commits atomiques (un changement logique = un commit)
- Quand tu dois stager une partie d'un fichier, stage les chunks concernés (`git add -p`) plutôt que de retirer le code hors contexte, committer, puis le remettre : au moment du commit le code est validé, le modifier reviendrait à committer du code non testé
- En rebase, revérifie que tu n'as rien perdu

## Tests

- lance uniquement les tests pertinents pas toute la suite de tests
- lance toute la suite de tests une fois que tu penses avoir finit
- utilise la TDD quand c'est pertinent, demande si nécessaire

## Sécurité

- Ne committe jamais de secrets, tokens, ou mots de passe
- Vérifie les fichiers .env, credentials, clés privées avant tout staging

## Workflow

- avant d'explorer du code ou de proposer une analyse vérifie la liste des skills disponibles. Si une skill matche la tâche (description ou trigger keywords) invoque là !
- vérifie toujours si un LSP est diposnible avant de travailler sur du code, s'il y en a un qui ne fonctionne pas arrête toi et dit le
- Lis toujours le code existant avant de proposer des modifications
- Quand un code est peu clair ou illogique, lis ses messages de commit pour comprendre le contexte (le titre d'abord, la description ensuite si besoin)
- Utilise les outils dédiés (Read, Edit, Grep, Glob) plutôt que bash quand possible
- Teste les changements quand un framework de test est disponible
