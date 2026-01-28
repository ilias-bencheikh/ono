# Ono

L'objectif de ce projet est de se familiariser avec un [interpréteur symbolique] pour [WebAssembly] (Wasm).
Pour cela, on va implémenter un jeu de la vie en Wasm, et réaliser une interface graphique en [OCaml].
Enfin, on cherchera à générer des configurations intéressantes du jeu de la vie.

Ce document donne les consignes pour le projet.
Avant toute chose, il est nécessaire de lire [HACKING.md] - une présentation des outils dont vous aurez besoin pour le projet.

## Consignes générales (2 points)

Le projet compote 22 points, mais la note finale sera sur 20.
Si vous obtenez 19 points, vous aurez donc 19/20. Si vous obtenez 20 points ou plus, vous obtiendrez 20/20.
Une partie bonus est proposée à la fin, elle ne sera prise en compte que si vous avez réalisé l'entièreté du sujet.
Le projet est à effectuer par groupes de trois ou quatre personnes.
Les groupes seront fixés par Giovanni 

### Git et dépôt principal

1. Utiliser une dépôt central sur lequel aucun d'entre vous ne devra directement écrire. Ce dépôt principal doit être un clone (si vous utilisez GitHub) ou une copie (si vous utilisez le GitLab de l'université ou une autre forge git) du dépôt contenant sur le sujet. Sur GitHub vous pouvez simplement faire un *fork* du dépôt contenant le sujet pour créer le dépôt principal. Sur GitLab, vous devrez l'importer vous-même pour créer le dépôt principal. Chaque contribution devra passer par une Pull Request. Faites en sorte de protéger la branche `main` du dépôt principal pour interdire l'écriture directe sur celle-ci.
2. Écrivez des messages de commit *clairs* et *informatifs*, n'en faites pas trop : ne faites pas plusieurs paragraphes si le changement peut être décrit en cinq mots.
3. À chaque Pull-Request *significative*, ajoutez une ligne au fichier [CHANGES.md] qui décrit les changements effectués, évitez de donner trop de détails, je vous conseille de lire [keepachangelog.com].
4. Au début de chaque TP, faite une *release* de votre projet. La *release* prendra la forme d'un *tag* Git, qui devra être poussé sur le dépôt principal. Pensez bien à mettre à jour le fichier [CHANGES.md] avant de publier la nouvelle version.
5. À la fin du projet, vous devrez écrire un fichier `REPORT.md` qui décrira ce que vous avez fait, ce qui a réussi, les points subtils de votre projet, les difficultés rencontrées et ce qui n'a pas fonctionné, 

### OCaml

1. Pensez à bien formater le code *à chaque commit*. Pour cela, mettez en place un [`pre-commit` hook local sur Git](https://git-scm.com/book/fr/v2/Personnalisation-de-Git-Crochets-Git) afin de vérifier ça pour vous à chaque commit.
2. Écrivez des commentaires *pertinents*.
3. Pour chaque nouveau fichier, écrivez une interface (un fichier `.mli`). N'exposez que ce qui est nécessaire : tout ce qui peut être masqué ne doit pas y être ajouté.
4. Documentez vos interfaces. Vous trouverez de la documentation sur la syntaxe d'`odoc` sur la page [odoc for Authors]. Pensez à regarder le rendu grâce à `dune build @doc` comme décrit dans [HACKING.md].

## Première partie : l'interpréteur concret

Vous devez commencer par lire [TUTORIAL_WASM.md] afin de vous familiariser avec Wasm.

### Préliminaires (2 points)

1. Écrivez un module Wasm qui contient une fonction `$factorial`. Cette fonction doit prendre en entrée un entier $n$ de type `i32` et calculer la factorielle de $n$, utilisez un appel récursif et un `(if (then) (else))`. Ajoutez une fonction `$main` qui appelle `$factorial` avec l'entier `5` et affiche le résultat en important une fonction `print_i32` comme cela est fait dans [fibonnaci.wat]. Ajoutez un *cram test* pour votre module, comme cela est fait [fibonnaci.t/run.t] : n'écrivez pas le résultat à la main, lancez `dune runtest` pour afficher le résultat, puis `dune promote` pour mettre à jour le test si le résultat vous semble correct.
2. La fonction `print_i32` du module `ono` utilisée précédemment est une fonction fournie par *l'hôte*. Elle est écrite en OCaml. Vous trouverez sa définition dans [concrete_ono_module.ml]. Ajoutez-y une fonction `print_i64`, il faut d'abord la définir, puis l'ajouter à la liste des fonctions plus bas dans le module. Écrivez ensuite un module Wasm contenant une fonction `$square_i64` qui calcule le carré d'un `i64`. Appelez la fonction avec `50_000` en entrée et affichez le résultat en important votre nouvelle fonction `print_i64`. Ajoutez un *cram test* pour votre module.
3. Ajoutez une fonction `random_i32`. Écrivez un module Wasm qui appelle cette fonction et affiche le résultat. Faites un *cram test* pour votre module. La sortie n'étant pas déterministe, le nombre change à chaque fois que vous recompilez votre programme. On ne peut donc pas en faire un *cram test* en l'état. Pour résoudre ce problème, commencez par appeler la fonction OCaml `Random.init` avec un entier de votre choix. Cet entier est appelé un *seed* et permet de rendre la génération aléatoire reproductible. Afin de laisser l'utilisateur choisir le *seed* utilisé, ajoutez à `ono run` la possibilité de lire un seed passé sous la forme `--seed 42`. Lorsque le *seed* est spécifié par l'utilisateur, vous appelerez `Random.init` avec, sinon, vous appelerez `Random.self_init`. Cette dernière permet d'obtenir une séquence de nombre différente à chaque appel de votre programme - sans quoi le seed est fixé à la compilation et l'utilisateur n'a pas vraiment l'impression que la fonction est aléatoire. Utilisez l'option que vous venez d'ajouter pour rendre votre *cram test* déterministe.

### Un jeu de la vie en Wasm

Nous allons maintenant écrire un [jeu de la Vie] en Wasm.
Commencez par regarder [la vidéo de *Science étonnante*](https://scienceetonnante.com/blog/2017/12/08/le-jeu-de-la-vie/) sur le sujet.

#### Interface textuelle (4 points)

L'affichage se fera dans le terminal.
Il sera donc nécessaire de fournir des primitives supplémentaires dans le module `ono`.
Pour vous guider, voici une version OCaml correspondant à ce que j'attends de vous :

```ocaml
let w = 90
let h = 50

let () = Random.self_init ()

let grid = Array.init h (fun _i -> Array.init w (fun _j -> Random.int 100 > 90))

let is_alive i j = try grid.(i).(j) with Invalid_argument _ -> false

let count_alive_neighbours i j =
  let neighbours =
    [| (i - 1, j - 1)
     ; (i - 1, j)
     ; (i - 1, j + 1)
     ; (i, j - 1)
     ; (i, j + 1)
     ; (i + 1, j - 1)
     ; (i + 1, j)
     ; (i + 1, j + 1)
    |]
  in
  Array.fold_left
    (fun count (i, j) -> if is_alive i j then succ count else count)
    0 neighbours

let step () =
  (* we count neighbours before changing the state *)
  let alive_neighbours =
    Array.init h (fun i -> Array.init w (fun j -> count_alive_neighbours i j))
  in
  for i = 0 to h - 1 do
    for j = 0 to w - 1 do
      let cell_alive = grid.(i).(j) in
      let alive_neighbours = alive_neighbours.(i).(j) in
      let live =
        if cell_alive then begin
          alive_neighbours = 2 || alive_neighbours = 3
        end
        else alive_neighbours = 3
      in
      (* there's a small chance a living cell appears *)
      let live = live || Random.int 10000 = 0 in
      grid.(i).(j) <- live
    done
  done

let print_grid () =
  (* clear the screen *)
  Format.printf "\027[2J";
  Array.iter
    (fun row ->
        Array.iter
          (fun cell_alive -> Format.print_string (if cell_alive then "🦊" else " "))
          row;
        Format.printf "@\n" )
    grid;
  Format.printf "@\n";
  Format.pp_print_flush Format.std_formatter ()

let rec loop () =
  print_grid ();
  step ();
  loop ()

let () = loop ()
```

Tout ce qui peut être fait en Wasm devra l'être.
Pour le reste, vous devrez le définir en OCaml ; je vous donne la liste des fonctions qui devront être exposées (vous aurez par ailleurs à nouveau besoin de la fonction `random_i32`):

```ocaml
; ("sleep",        Extern_func (f32  ^->. unit, sleep))
; ("print_cell",   Extern_func (i32  ^->. unit, cell_print))
; ("newline",      Extern_func (unit ^->. unit, newline))
; ("clear_screen", Extern_func (unit ^->. unit, clear_screen))
```

La fonction `sleep` doit mettre en pause l'exécution pour un temps donné (utile pour avoir le temps de comprendre ce qu'il se passe).

L'affichage se fera au travers d'un `Buffer.t` qui ne sera pas exposé directement au code Wasm.
La fonction `print_cell` devra interpréter l'entier qu'elle reçoit comme un booléen.
Si celui-ci est vrai (*i.e.* la cellule est vivante), elle ajoutera `"🦊"` au buffer, sinon, elle ajoutera `" "`.
La fonction `new_line` ajoutera un retour chariot au buffer.
Enfin, la fonction `clear_screen` devra afficher le contenu du buffer à l'écran puis vider celui-ci en prévision du prochain affichage.

Pour la partie Wasm, voici quelques conseils :

1. Utilisez des variables globales pour définir la hauteur et la largeur.
2. Stockez l'état du jeu (les cellules) dans la mémoire linéaire.
3. Écrivez des fonctions pour convertir des coordonnées en deux dimensions en des coordonnées en une dimension et inversement (ces fonctions dépendent de la largeur et de la hauteur).

##### Extensions

1. Ajoutez une fonction OCaml `read_int` qui permet à l'utilisateur de saisir un entier dans le terminal. Utilisez cette fonction au début de votre programme Wasm pour laisser l'utilisateur choisir les dimensions.
2. Définissez un format de fichier pour des configurations initiales. Votre moteur doit être capable de démarrer dans une configuration fournie dans un fichier écrit dans ce format.
3. Pour pouvoir tester votre implémentation, ajoutez une qui permet de ne simuler qu'un nombre fini d'étapes (par exemple `--steps 42` devra effectuer 42 tours du jeu de la vie et s'arrêter). Ajoutez également une option pour n'afficher que les $n$ dernières configurations, en les séparant par un marqueur visuel (par exemple, un saut de ligne). Ces deux options devraient vous permettre d'écrire des crams tests.
4. Écrivez des configurations initiales et des crams tests pertinents au moyen des options ajoutées précedemment.

#### Interface graphique (6 points)

Faites maintenant une version qui n'affiche pas dans le terminal mais dans une fenêtre avec un rendu graphique (vous pouvez utilisez les bibliothèques OCaml `tsdl` ou `raylib`).
Le but est d'avoir le même programme Wasm dans les deux cas mais qui sera interprété différemment côté OCaml (vous pouvez même ajouter un flag `--use-graphical-window` à `ono run` pour que l'utilisateur puisse choisir le rendu directement).

## Seconde partie : l'interpréteur symbolique

Vous devez commencer par lire [TUTORIAL_SYMEX.md] afin de vous familiariser avec l'exécution symbolique.

### Préliminaires (3 points)

Un moteur d'exécution symbolique, au-delà de servir à trouver des bugs dans des programmes peut aussi servir à *résoudre des problèmes*.
C'est une bonne façon d'implémenter ce qu'on appelle le *Solver-Aided Programming*.
L'idée consiste à faire correspondre ce qui est pour vous une "solution" avec ce qui est pour le moteur un "bug".
Ainsi, il va trouver une solution en pensant avoir trouvé un bug.

Prenons un exemple.
Imaginez que vous souhaitez résoudre l'équation $x^3 - 7x^2 + 14x -8  = 0$.
Vous pouvez écrire le programme suivant :

```c
int main() {
  int x = symbol_int();
  int x2 = x * x;
  int x3 = x * x * x;

  int a = 1;
  int b = -7;
  int c = 14;
  int d = -8;

  int poly = a * x3 + b * x2 + c * x + d;

  if (poly == 0) {
    assert(false);
  }

  return 0;
}
```

On définit tout simplement le polynôme $x^3 - 7x^2 + 14x -8$.
Puis, on fait échouer le programme lorsque le polynôme est égal à zéro - ce qui correspond exactement au cas pour lequel on cherche une solution à $x$.
On obtiendra alors une réponse du moteur symbolique nous disant que le programme a un *bug* et la valeur de $x$ associée.
Il s'agit en réalité pour nous d'une solution à notre équation.

#### Un solveur de polynômes

Implémentez un module Wasm qui résoud des polynômes de degrés au plus 3 en utilisant l'idée présentée avant.
Les valeurs des coefficients $a$, $b$, $c$ et $d$ devront être demandées à l'utilisateur et lues sur l'entrée standard.
Attention, il faut afficher *toutes* les solutions possibles.

Vous pouvez lancer `ono` en mode symbolique ainsi: `ono symbolic file.wat`. Vous pouvez regarder le dossier `test/cram/symbolic/basic_symbol.t/` pour comprendre comment créer une valeur symbolique et lancer un programme simple utilisant celle-ci.

### Génération de configurations pour le jeu de la Vie (5 points)

Le but de cette partie va être d'utiliser l'interpréteur symbolique pour *générer* des configurations intéressantes de jeu de la vie.
L'intérêt est le suivant : vous savez quelles propriétés vous souhaitez obtenir, mais vous ne voulez pas chercher vous-même les configurations qui satisfont ces propriétés.

Je vous conseille d'écrire chaque contrainte comme une fonction renvoyant un booléen (sous forme de `i32`).
Cette fonction peut bien évidemment être divisées en plusieurs fonctions, mais n'essayez pas de calculer plusieurs contraintes du même coup.

Commencez par tenter de générer une grille n'ayant aucune contrainte.
Vous devez être capable d'afficher le résultat dans le format qui est lisible par votre simulateur.
Une fois que cela est fait, implémentez diférentes contraintes de votre choix et essayer de générer des configurations initiales.
Après les avoir générées, exécutez-les dans votre moteur et vérifier qu'elles produisent le résultat attendu.

Des idées de contraintes :

1. Au tour suivant, la cellule en position $(x, y)$ doit être vivante.
2. Au tour suivant, la cellule en position $(x, y)$ doit être morte.
3. Au tour suivant, il y a au moins une cellule vivante sur la grille.
4. Au tour suivant, toutes les cellules sont vivantes.
5. Au tour suivant, toutes les cellules sont mortes.
6. Au tour suivant, il y a une ligne complète de cellules vivantes entre $(x, y)$ et $(x', y)$.
7. Au tour suivant, il y a une colonne complète de cellules vivantes entre $(x, y)$ et $(x, y')$.
8. Au tour suivant, il y a exactement $N$ cellules vivantes dans la grille.
9. Au tour suivant, il existe une cellule isolée (*i.e.* dont toutes les cellules voisines sont mortes).
10. Au tour suivant, il existe une cellule entourée de cellules vivantes.
11. Au tour suivant, il existe deux cellules vivantes côte à côte.
12. Au tour suivant, il existe un motif en "L" de trois cellules vivantes.
13. Au tour suivant, il existe un motif carré de 2*2 cellules vivantes.
14. Au tour suivant, il existe une cellule morte qui est devenue vivante.
15. Au tour suivant, il y a une ligne/colonne avec une alternance de cellules vivantes/mortes.
16. Au tour suivant, il y a un motif en clignotant (un oscillateur de période 2).
17. Au tour suivant, il y a une diagonale vivante de $N$ cellules.

Vous n'êtes pas obligé d'implémenter toutes ces contraintes, ni même ces contraintes précisément.
Il faut simplement que vous implémentiez des contraintes intéressantes, et vous avez le droit d'être créatifs.
Je vous conseille de décrire précisément chaque contrainte, et de lui attribuer un numéro.
Puis, vous pouvez ajouter une option à votre programme pour être capable de choisir quelles contraintes appliquer ou non, cela vous permettra de le tester facilement.
Il est possible (et probable) que certaines contraintes soient trop coûteuses pour le moteur d'exécution symbolique, si c'est le cas, posez-vous la question du pourquoi.
Vous pouvez notamment essayer de réduire la taille de la grille pour simplifier la vie du solveur.
Si le problème ne fonctionne pas même sur une petite grille, il est possible que vous ayiez un problème dans l'écriture de votre contrainte.

L'important n'est pas d'arriver à générer des configurations compliquées, mais d'avoir réussi à en générer quelques-unes intéressantes, d'avoir échoué sur certaines, et d'être capable d'expliquer tout cela à la fin du pmrojet.
L'objectif est d'avoir développé des intuitions sur le fonctionnement et les limites de l'outil que vous êtes en train d'utiliser.

## Bonus

Cette partie ne pourra rapporter des points supplémentaires que si vous avez déjà réalisé l'entièreté du projet.

Écrivez un programme JavaScript qui réutilise votre programme Wasm mais fait cette fois-ci un rendu dans le navigateur.
On n'utilise donc plus du tout Ono mais un autre interpréteur.
Cela vous oblige à redéfinir toutes les primitives en JavaScript.

[CHANGES.md]: ./CHANGES.md
[concrete_ono_module.ml]: ./src/lib/concrete_ono_module.ml
[fibonnaci.t/run.t]: ./test/cram/concrete/fibonacci.t/run.t
[fibonnaci.wat]: ./test/cram/concrete/fibonacci.t/fibonnaci.wat
[HACKING.md]: ./HACKING.md
[interpréteur symbolique]: https://en.wikipedia.org/wiki/Symbolic_execution
[jeu de la Vie]: https://fr.wikipedia.org/wiki/Jeu_de_la_vie
[keepachangelog.com]: https://keepachangelog.com/fr
[OCaml]: https://fr.wikipedia.org/wiki/OCaml
[odoc for Authors]: https://ocaml.github.io/odoc/odoc/odoc_for_authors.html
[TUTORIAL_SYMEX.md]: ./TUTORIAL_SYMEX.md
[TUTORIAL_WASM.md]: ./TUTORIAL_WASM.md
[WebAssembly]: https://fr.wikipedia.org/wiki/WebAssembly
