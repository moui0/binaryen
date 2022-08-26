;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt --new-wat-parser --hybrid -all %s -S -o - | filecheck %s

(module $parse
 ;; types
 (rec
  ;; CHECK:      (type $void (func_subtype func))

  ;; CHECK:      (type $i32_=>_none (func_subtype (param i32) func))

  ;; CHECK:      (rec
  ;; CHECK-NEXT:  (type $s0 (struct_subtype  data))
  (type $s0 (sub (struct)))
  ;; CHECK:       (type $s1 (struct_subtype  data))
  (type $s1 (struct (field)))
 )

 (rec)

 ;; CHECK:      (type $many (func_subtype (param i32 i64 f32 f64) (result anyref (ref func)) func))

 ;; CHECK:      (type $none_=>_i32 (func_subtype (result i32) func))

 ;; CHECK:      (type $s2 (struct_subtype (field i32) data))
 (type $s2 (struct i32))
 ;; CHECK:      (type $s3 (struct_subtype (field i64) data))
 (type $s3 (struct (field i64)))
 ;; CHECK:      (type $s4 (struct_subtype (field $x f32) data))
 (type $s4 (struct (field $x f32)))
 ;; CHECK:      (type $s5 (struct_subtype (field i32) (field i64) data))
 (type $s5 (struct i32 i64))
 ;; CHECK:      (type $s6 (struct_subtype (field i64) (field f32) data))
 (type $s6 (struct (field i64 f32)))
 ;; CHECK:      (type $s7 (struct_subtype (field $x f32) (field $y f64) data))
 (type $s7 (struct (field $x f32) (field $y f64)))
 ;; CHECK:      (type $s8 (struct_subtype (field i32) (field i64) (field $z f32) (field f64) (field (mut i32)) data))
 (type $s8 (struct i32 (field) i64 (field $z f32) (field f64 (mut i32))))

 ;; CHECK:      (type $a0 (array_subtype i32 data))
 (type $a0 (array i32))
 ;; CHECK:      (type $a1 (array_subtype i64 data))
 (type $a1 (array (field i64)))
 ;; CHECK:      (type $a2 (array_subtype (mut f32) data))
 (type $a2 (array (mut f32)))
 ;; CHECK:      (type $a3 (array_subtype (mut f64) data))
 (type $a3 (array (field $x (mut f64))))

 (rec
   (type $void (func))
 )

 ;; CHECK:      (type $subvoid (func_subtype $void))
 (type $subvoid (sub $void (func)))

 (type $many (func (param $x i32) (param i64 f32) (param) (param $y f64)
                   (result anyref (ref func))))

 ;; CHECK:      (type $submany (func_subtype (param i32 i64 f32 f64) (result anyref (ref func)) $many))
 (type $submany (sub $many (func (param i32 i64 f32 f64) (result anyref (ref func)))))

 ;; globals
 (global $g1 (export "g1") (export "g1.1") (import "mod" "g1") i32)
 (global $g2 (import "mod" "g2") (mut i64))
 (global (import "" "g3") (ref 0))
 (global (import "mod" "") (ref null $many))

 (global i32 i32.const 0)
 ;; CHECK:      (type $ref|$s0|_ref|$s1|_ref|$s2|_ref|$s3|_ref|$s4|_ref|$s5|_ref|$s6|_ref|$s7|_ref|$s8|_ref|$a0|_ref|$a1|_ref|$a2|_ref|$a3|_ref|$subvoid|_ref|$submany|_=>_none (func_subtype (param (ref $s0) (ref $s1) (ref $s2) (ref $s3) (ref $s4) (ref $s5) (ref $s6) (ref $s7) (ref $s8) (ref $a0) (ref $a1) (ref $a2) (ref $a3) (ref $subvoid) (ref $submany)) func))

 ;; CHECK:      (import "mod" "g1" (global $g1 i32))

 ;; CHECK:      (import "mod" "g2" (global $g2 (mut i64)))

 ;; CHECK:      (import "" "g3" (global $gimport$0 (ref $s0)))

 ;; CHECK:      (import "mod" "" (global $gimport$1 (ref null $many)))

 ;; CHECK:      (import "mod" "f5" (func $fimport$1))

 ;; CHECK:      (global $2 i32 (i32.const 0))

 ;; CHECK:      (global $i32 i32 (i32.const 42))
 (global $i32 i32 i32.const 42)

 ;; functions
 (func)

 ;; CHECK:      (export "g1" (global $g1))

 ;; CHECK:      (export "g1.1" (global $g1))

 ;; CHECK:      (export "f5.0" (func $fimport$1))

 ;; CHECK:      (export "f5.1" (func $fimport$1))

 ;; CHECK:      (func $0 (type $void)
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )

 ;; CHECK:      (func $f1 (type $i32_=>_none) (param $0 i32)
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 (func $f1 (param i32))
 ;; CHECK:      (func $f2 (type $i32_=>_none) (param $x i32)
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 (func $f2 (param $x i32))
 ;; CHECK:      (func $f3 (type $none_=>_i32) (result i32)
 ;; CHECK-NEXT:  (i32.const 0)
 ;; CHECK-NEXT: )
 (func $f3 (result i32)
  i32.const 0
 )
 ;; CHECK:      (func $f4 (type $void)
 ;; CHECK-NEXT:  (local $0 i32)
 ;; CHECK-NEXT:  (local $1 i64)
 ;; CHECK-NEXT:  (local $l f32)
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 (func $f4 (type 13) (local i32 i64) (local $l f32))
 (func (export "f5.0") (export "f5.1") (import "mod" "f5"))

 ;; CHECK:      (func $use-types (type $ref|$s0|_ref|$s1|_ref|$s2|_ref|$s3|_ref|$s4|_ref|$s5|_ref|$s6|_ref|$s7|_ref|$s8|_ref|$a0|_ref|$a1|_ref|$a2|_ref|$a3|_ref|$subvoid|_ref|$submany|_=>_none) (param $0 (ref $s0)) (param $1 (ref $s1)) (param $2 (ref $s2)) (param $3 (ref $s3)) (param $4 (ref $s4)) (param $5 (ref $s5)) (param $6 (ref $s6)) (param $7 (ref $s7)) (param $8 (ref $s8)) (param $9 (ref $a0)) (param $10 (ref $a1)) (param $11 (ref $a2)) (param $12 (ref $a3)) (param $13 (ref $subvoid)) (param $14 (ref $submany))
 ;; CHECK-NEXT:  (nop)
 ;; CHECK-NEXT: )
 (func $use-types
  (param (ref $s0))
  (param (ref $s1))
  (param (ref $s2))
  (param (ref $s3))
  (param (ref $s4))
  (param (ref $s5))
  (param (ref $s6))
  (param (ref $s7))
  (param (ref $s8))
  (param (ref $a0))
  (param (ref $a1))
  (param (ref $a2))
  (param (ref $a3))
  (param (ref $subvoid))
  (param (ref $submany))
 )
)
