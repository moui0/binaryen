;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --coalesce-locals -all -S -o - \
;; RUN:   | filecheck %s

(module
 ;; CHECK:      (type $A (sub (struct (field structref))))

 ;; CHECK:      (type $array (array (mut i8)))
 (type $array (array (mut i8)))

 (type $A (sub (struct (field (ref null struct)))))

 ;; CHECK:      (type $B (sub $A (struct (field (ref struct)))))
 (type $B (sub $A (struct (field (ref struct)))))

 ;; CHECK:      (global $global (ref null $array) (ref.null none))
 (global $global (ref null $array) (ref.null $array))

 ;; CHECK:      (global $nn-tuple-global (mut ((ref any) i32)) (tuple.make 2
 ;; CHECK-NEXT:  (ref.i31
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (i32.const 1)
 ;; CHECK-NEXT: ))
 (global $nn-tuple-global (mut ((ref any) i32)) (tuple.make 2 (ref.i31 (i32.const 0)) (i32.const 1)))


 ;; CHECK:      (func $test-dead-get-non-nullable (type $6) (param $0 (ref struct))
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result (ref struct))
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $test-dead-get-non-nullable (param $func (ref struct))
  (unreachable)
  (drop
   ;; A useless get (that does not read from any set, or from the inputs to the
   ;; function). Normally we replace such gets with nops as best we can, but in
   ;; this case the type is non-nullable, so we must leave it alone.
   (local.get $func)
  )
 )

 ;; CHECK:      (func $br_on_null (type $7) (param $0 (ref null $array)) (result (ref null $array))
 ;; CHECK-NEXT:  (block $label$1 (result (ref null $array))
 ;; CHECK-NEXT:   (block $label$2
 ;; CHECK-NEXT:    (br $label$1
 ;; CHECK-NEXT:     (br_on_null $label$2
 ;; CHECK-NEXT:      (local.get $0)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (local.set $0
 ;; CHECK-NEXT:    (global.get $global)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (local.get $0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $br_on_null (param $ref (ref null $array)) (result (ref null $array))
  (local $1 (ref null $array))
  (block $label$1 (result (ref null $array))
   (block $label$2
    (br $label$1
     ;; Test that we properly model the basic block connections around a
     ;; BrOnNull. There should be a branch to $label$2, and also a fallthrough.
     ;; As a result, the local.set below is reachable, and should not be
     ;; eliminated (turned into a drop).
     (br_on_null $label$2
      (local.get $ref)
     )
    )
   )
   (local.set $1
    (global.get $global)
   )
   (local.get $1)
  )
 )

 ;; CHECK:      (func $nn-dead (type $3)
 ;; CHECK-NEXT:  (local $0 funcref)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (ref.func $nn-dead)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block $inner
 ;; CHECK-NEXT:   (local.set $0
 ;; CHECK-NEXT:    (ref.func $nn-dead)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (br_if $inner
 ;; CHECK-NEXT:    (i32.const 1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (ref.as_non_null
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $nn-dead
  (local $x (ref func))
  (local.set $x
   (ref.func $nn-dead) ;; this will be removed, as it is not needed.
  )
  (block $inner
   (local.set $x
    (ref.func $nn-dead) ;; this is not enough for validation of the get, so we
                        ;; will end up making the local nullable.
   )
   ;; refer to $inner to keep the name alive (see the next testcase)
   (br_if $inner
    (i32.const 1)
   )
  )
  (drop
   (local.get $x)
  )
 )

 ;; CHECK:      (func $nn-dead-nameless (type $3)
 ;; CHECK-NEXT:  (local $0 (ref func))
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (ref.func $nn-dead)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (block
 ;; CHECK-NEXT:   (local.set $0
 ;; CHECK-NEXT:    (ref.func $nn-dead)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (local.get $0)
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $nn-dead-nameless
  (local $x (ref func))
  (local.set $x
   (ref.func $nn-dead)
  )
  ;; As above, but now the block has no name. Nameless blocks do not interfere
  ;; with validation, so we can keep the local non-nullable.
  (block
   (local.set $x
    (ref.func $nn-dead)
   )
  )
  (drop
   (local.get $x)
  )
 )

 ;; CHECK:      (func $unreachable-get-null (type $3)
 ;; CHECK-NEXT:  (local $0 anyref)
 ;; CHECK-NEXT:  (local $1 i31ref)
 ;; CHECK-NEXT:  (unreachable)
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result anyref)
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (drop
 ;; CHECK-NEXT:   (block (result i31ref)
 ;; CHECK-NEXT:    (ref.i31
 ;; CHECK-NEXT:     (i32.const 0)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $unreachable-get-null
  ;; Check that we don't replace the local.get $null with a ref.null, which
  ;; would have a more precise type.
  (local $null-any anyref)
  (local $null-i31 i31ref)
  (unreachable)
  (drop
   (local.get $null-any)
  )
  (drop
   (local.get $null-i31)
  )
 )

 ;; CHECK:      (func $remove-tee-refinalize (type $5) (param $0 (ref null $A)) (param $1 (ref null $B)) (result structref)
 ;; CHECK-NEXT:  (struct.get $A 0
 ;; CHECK-NEXT:   (block (result (ref null $A))
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $remove-tee-refinalize
  (param $a (ref null $A))
  (param $b (ref null $B))
  (result (ref null struct))
  ;; The local.tee receives a $B and flows out an $A. We want to avoid changing
  ;; types here, so we'll wrap it in a block, and leave further improvements
  ;; for other passes.
  (struct.get $A 0
   (local.tee $a
    (local.get $b)
   )
  )
 )

 ;; CHECK:      (func $remove-tee-refinalize-2 (type $5) (param $0 (ref null $A)) (param $1 (ref null $B)) (result structref)
 ;; CHECK-NEXT:  (struct.get $A 0
 ;; CHECK-NEXT:   (block (result (ref null $A))
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $remove-tee-refinalize-2
  (param $a (ref null $A))
  (param $b (ref null $B))
  (result (ref null struct))
  ;; As above, but with an extra tee in the middle. The result should be the
  ;; same.
  (struct.get $A 0
   (local.tee $a
    (local.tee $a
     (local.get $b)
    )
   )
  )
 )

 ;; CHECK:      (func $replace-i31-local (type $8) (result i32)
 ;; CHECK-NEXT:  (local $0 i31ref)
 ;; CHECK-NEXT:  (i32.add
 ;; CHECK-NEXT:   (unreachable)
 ;; CHECK-NEXT:   (ref.test (ref i31)
 ;; CHECK-NEXT:    (ref.cast i31ref
 ;; CHECK-NEXT:     (block (result i31ref)
 ;; CHECK-NEXT:      (ref.i31
 ;; CHECK-NEXT:       (i32.const 0)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $replace-i31-local (result i32)
  (local $local i31ref)
  (i32.add
   (unreachable)
   (ref.test (ref i31)
    (ref.cast i31ref
     ;; This local.get is in unreachable code, and coalesce-locals will remove
     ;; it in order to avoid using the local index at all. While doing so it
     ;; must emit something of the exact same type so validation still works
     ;; (we can't turn this into a non-nullable reference, in particular - that
     ;; would hit a validation error as the cast outside of us is nullable).
     (local.get $local)
    )
   )
  )
 )

 ;; CHECK:      (func $replace-struct-param (type $9) (param $0 f64) (param $1 (ref null $A)) (result f32)
 ;; CHECK-NEXT:  (call $replace-struct-param
 ;; CHECK-NEXT:   (block (result f64)
 ;; CHECK-NEXT:    (unreachable)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (ref.cast (ref null $A)
 ;; CHECK-NEXT:    (block (result (ref null $A))
 ;; CHECK-NEXT:     (struct.new_default $A)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $replace-struct-param (param $unused f64) (param $A (ref null $A)) (result f32)
  ;; As above, but now the value is a struct reference and it is on a local.tee.
  ;; Again, we should replace the local operation with something of identical
  ;; type to avoid a validation error.
  (call $replace-struct-param
   (block (result f64)
    (unreachable)
   )
   (ref.cast (ref null $A)
    (local.tee $A
     (struct.new_default $A)
    )
   )
  )
 )

 ;; CHECK:      (func $test (type $10) (param $0 (ref any)) (result (ref any) i32)
 ;; CHECK-NEXT:  (local $1 (anyref i32))
 ;; CHECK-NEXT:  (tuple.drop 2
 ;; CHECK-NEXT:   (tuple.make 2
 ;; CHECK-NEXT:    (local.get $0)
 ;; CHECK-NEXT:    (i32.const 0)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (if
 ;; CHECK-NEXT:   (i32.const 0)
 ;; CHECK-NEXT:   (local.set $1
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (local.get $0)
 ;; CHECK-NEXT:     (i32.const 1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (local.set $1
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (local.get $0)
 ;; CHECK-NEXT:     (i32.const 2)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (global.set $nn-tuple-global
 ;; CHECK-NEXT:   (block (type $1) (result (ref any) i32)
 ;; CHECK-NEXT:    (local.set $1
 ;; CHECK-NEXT:     (if (type $1) (result (ref any) i32)
 ;; CHECK-NEXT:      (i32.const 0)
 ;; CHECK-NEXT:      (tuple.make 2
 ;; CHECK-NEXT:       (ref.as_non_null
 ;; CHECK-NEXT:        (tuple.extract 0
 ;; CHECK-NEXT:         (local.get $1)
 ;; CHECK-NEXT:        )
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:       (tuple.extract 1
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:      (tuple.make 2
 ;; CHECK-NEXT:       (ref.as_non_null
 ;; CHECK-NEXT:        (tuple.extract 0
 ;; CHECK-NEXT:         (local.get $1)
 ;; CHECK-NEXT:        )
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:       (tuple.extract 1
 ;; CHECK-NEXT:        (local.get $1)
 ;; CHECK-NEXT:       )
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:    (tuple.make 2
 ;; CHECK-NEXT:     (ref.as_non_null
 ;; CHECK-NEXT:      (tuple.extract 0
 ;; CHECK-NEXT:       (local.get $1)
 ;; CHECK-NEXT:      )
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:     (tuple.extract 1
 ;; CHECK-NEXT:      (local.get $1)
 ;; CHECK-NEXT:     )
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT:  (tuple.make 2
 ;; CHECK-NEXT:   (ref.as_non_null
 ;; CHECK-NEXT:    (tuple.extract 0
 ;; CHECK-NEXT:     (local.get $1)
 ;; CHECK-NEXT:    )
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:   (tuple.extract 1
 ;; CHECK-NEXT:    (local.get $1)
 ;; CHECK-NEXT:   )
 ;; CHECK-NEXT:  )
 ;; CHECK-NEXT: )
 (func $test (param $any (ref any)) (result (ref any) i32)
  (local $x ((ref any) i32))
  (local $y ((ref any) i32))
  ;; This store is dead and will be removed.
  (local.set $x
   (tuple.make 2
    (local.get $any)
    (i32.const 0)
   )
  )
  (if
   (i32.const 0)
   ;; These two sets will remain.
   (local.set $x
    (tuple.make 2
     (local.get $any)
     (i32.const 1)
    )
   )
   (local.set $x
    (tuple.make 2
     (local.get $any)
     (i32.const 2)
    )
   )
  )
  (global.set $nn-tuple-global
   ;; This tee will have to be fixed up for the new type.
   (local.tee $y
    (if (result (ref any) i32)
     (i32.const 0)
     ;; These gets will be invalid, so the local will have to be made nullable.
     (local.get $x)
     (local.get $x)
    )
   )
  )
  (local.get $y)
 )
)
