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

## Style de code

- Privilégie la simplicité et la lisibilité
- Pas de sur-ingénierie : résous le problème actuel, pas les problèmes hypothétiques
- Préfère les modifications minimales et ciblées
- dans la mesure du possible et quand c'est pertinent (principalement en bash) ajoute de la coloration syntaxique au sortie de code (ROUGE/VERT/JAUNE/BLEU)
- Ces principes s'appliquent à tout code produit : applicatif, scripts, configuration, infrastructure

## Git

- Ne committe jamais sans demande explicite
- Messages de commit concis en anglais, au présent impératif
- Préfère les commits atomiques (un changement logique = un commit)

## Tests

- lance uniquement les tests pertinents pas toute la suite de tests
- lance toute la suite de tests une fois que tu penses avoir finit
- utilise la TDD quand c'est pertinent, demande si nécessaire

## Sécurité

- Ne committe jamais de secrets, tokens, ou mots de passe
- Vérifie les fichiers .env, credentials, clés privées avant tout staging

## Workflow

- vérifie toujours si un LSP est diposnible avant de travailler sur du code, s'il y en a un qui ne fonctionne pas arrête toi et dit le
- Lis toujours le code existant avant de proposer des modifications
- Utilise les outils dédiés (Read, Edit, Grep, Glob) plutôt que bash quand possible
- Teste les changements quand un framework de test est disponible
