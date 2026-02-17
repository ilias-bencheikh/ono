(module

  (import "ono" "sleep" (func $sleep (param f32)))
  (import "ono" "print_cell" (func $print_cell (param i32)))
  (import "ono" "newline" (func $newline))
  (import "ono" "clear_screen" (func $clear_screen))

  ;; initialisation de la grille

  (global $grid_width (mut i32) (i32.const 90))
  (global $grid_height (mut i32) (i32.const 50))

  (memory $mem 1) 

  (func $coords_to_index (param $i i32) (param $j i32) (result i32)
  ;; Convertit (i,j) en index 1D
  )

  (func $index_to_coords (param $index i32) (result i32 i32)
  ;; Convertit index 1D en (i,j)

  )

  (func $init_grid
    ;; Initialise la grille (aléatoire ou depuis config)
  )

  (func $load_config (param $config_ptr i32)
    ;; Charge une configuration initiale
  )

  ;; fonctions de logique du jeu

   (func $is_alive (param $i i32) (param $j i32) (result i32)
    ;; Vérifie si une cellule est vivante
  )

  (func $count_alive_neighbours (param $i i32) (param $j i32) (result i32)
    ;; Compte les voisins vivants
  )

  (func $should_live (param $i i32) (param $j i32) (result i32)
    ;; Applique les règles du jeu de la vie
  )

  (func $step
    ;; Calcule la génération suivante
  )

  ;; Fonction affichage 

  (func $print_grid 
    (local $ligne i32)
    (call $clear_screen)
    (local.set $ligne (i32.const 0))
    (loop $loop
      (call $print_row (local.get $ligne))
      (call $newline)
      (local.set $ligne (i32.add (local.get $ligne) (i32.const 1)))
      (br_if $loop (i32.lt_u (local.get $ligne) (global.get $grid_height)))
    )
  )

  (func $print_row (param $ligne i32)
    (local $col i32)
    (local $i i32)
    (local $cellule i32)
    (local.set $col (i32.const 0))
    (loop $loop
      (local.set $i (call $coords_to_index (local.get $ligne) (local.get $col)))
      (local.set $cellule (i32.load8_u (local.get $i)))
      (call $print_cell (local.get $cellule))
      (local.set $col (i32.add (local.get $col) (i32.const 1)))
      (br_if $loop (i32.lt_u (local.get $col) (global.get $grid_width)))
    )
  )

  ;; Fonction de boucle principale
  (func $loop
    (call $print_grid)
    (call $sleep (f32.const 0.1))
    (call $step)
    (call $loop)
  )

  (func $main 
    (call $init_grid)
    (call $loop)
  )

)