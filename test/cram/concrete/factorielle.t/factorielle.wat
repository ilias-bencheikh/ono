(module 
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $fact (param $n i32) (result i32)

    (if
      (i32.lt_s
        (local.get $n)
        (i32.const 2))
      (then (return (i32.const 1))))
    (return
      (i32.mul
        (local.get $n)
        (call $fact
          (i32.sub
            (local.get $n)
            (i32.const 1)))
      )
    )
  )

  (func $main
    i32.const 5
    call $fact
    call $print_i32
  )
  (start $main)
)