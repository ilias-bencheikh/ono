(module
  (include "memory.wat")
  (include "logic.wat")
  (include "init.wat")
  (include "display.wat")
  (import "ono" "sleep" (func $sleep (param f32)))
  (import "env" "print_grid" (func $print_grid))
  (import "env" "step" (func $step))

  (func $loop
    (call $print_grid)
    (call $sleep (f32.const 0.1))
    (call $step)
    (call $loop)
  )

  (func $main (export "main")
    (call $init_grid)
    (call $loop)
  )

)