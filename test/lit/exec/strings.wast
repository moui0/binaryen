;; NOTE: Assertions have been generated by update_lit_checks.py --output=fuzz-exec and should not be edited.

;; RUN: wasm-opt %s -all --fuzz-exec -q -o /dev/null 2>&1 | filecheck %s

(module
  (type $array16 (array (mut i16)))

  (memory 1 1)

  (import "fuzzing-support" "log" (func $log (param i32)))

  ;; CHECK:      [fuzz-exec] calling new_wtf16_array
  ;; CHECK-NEXT: [fuzz-exec] note result: new_wtf16_array => string("ello")
  (func $new_wtf16_array (export "new_wtf16_array") (result stringref)
    (string.new_wtf16_array
      (array.new_fixed $array16 5
        (i32.const 104) ;; h
        (i32.const 101) ;; e
        (i32.const 108) ;; l
        (i32.const 108) ;; l
        (i32.const 111) ;; o
      )
      (i32.const 1) ;; start from index 1, to chop off the 'h'
      (i32.const 5)
    )
  )

  ;; CHECK:      [fuzz-exec] calling const
  ;; CHECK-NEXT: [fuzz-exec] note result: const => string("world")
  (func $const (export "const") (result stringref)
    (string.const "world")
  )

  ;; CHECK:      [fuzz-exec] calling eq.1
  ;; CHECK-NEXT: [fuzz-exec] note result: eq.1 => 0
  (func $eq.1 (export "eq.1") (result i32)
    (string.eq
      (string.const "hello")
      (string.const "world")
    )
  )

  ;; CHECK:      [fuzz-exec] calling eq.2
  ;; CHECK-NEXT: [fuzz-exec] note result: eq.2 => 1
  (func $eq.2 (export "eq.2") (result i32)
    (string.eq
      (string.const "hello")
      (string.const "hello")
    )
  )

  ;; CHECK:      [fuzz-exec] calling eq.3
  ;; CHECK-NEXT: [fuzz-exec] note result: eq.3 => 0
  (func $eq.3 (export "eq.3") (result i32)
    (string.eq
      (string.const "hello")
      (ref.null string)
    )
  )

  ;; CHECK:      [fuzz-exec] calling eq.4
  ;; CHECK-NEXT: [fuzz-exec] note result: eq.4 => 0
  (func $eq.4 (export "eq.4") (result i32)
    (string.eq
      (ref.null string)
      (string.const "world")
    )
  )

  ;; CHECK:      [fuzz-exec] calling eq.5
  ;; CHECK-NEXT: [fuzz-exec] note result: eq.5 => 1
  (func $eq.5 (export "eq.5") (result i32)
    (string.eq
      (ref.null string)
      (ref.null string)
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.1
  ;; CHECK-NEXT: [trap null ref]
  (func $compare.1 (export "compare.1") (result i32)
    (string.compare
      (string.const "hello")
      (ref.null string)
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.2
  ;; CHECK-NEXT: [trap null ref]
  (func $compare.2 (export "compare.2") (result i32)
    (string.compare
      (ref.null string)
      (string.const "world")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.3
  ;; CHECK-NEXT: [trap null ref]
  (func $compare.3 (export "compare.3") (result i32)
    (string.compare
      (ref.null string)
      (ref.null string)
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.4
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.4 => 0
  (func $compare.4 (export "compare.4") (result i32)
    (string.compare
      (string.const "hello")
      (string.const "hello")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.5
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.5 => -1
  (func $compare.5 (export "compare.5") (result i32)
    (string.compare
      (string.const "hello")
      (string.const "hezlo")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.6
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.6 => 1
  (func $compare.6 (export "compare.6") (result i32)
    (string.compare
      (string.const "hezlo")
      (string.const "hello")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.7
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.7 => -1
  (func $compare.7 (export "compare.7") (result i32)
    (string.compare
      (string.const "he")
      (string.const "hello")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.8
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.8 => 1
  (func $compare.8 (export "compare.8") (result i32)
    (string.compare
      (string.const "hello")
      (string.const "he")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.9
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.9 => 1
  (func $compare.9 (export "compare.9") (result i32)
    (string.compare
      (string.const "hf")
      (string.const "hello")
    )
  )

  ;; CHECK:      [fuzz-exec] calling compare.10
  ;; CHECK-NEXT: [fuzz-exec] note result: compare.10 => -1
  (func $compare.10 (export "compare.10") (result i32)
    (string.compare
      (string.const "hello")
      (string.const "hf")
    )
  )

  ;; CHECK:      [fuzz-exec] calling get_codeunit
  ;; CHECK-NEXT: [fuzz-exec] note result: get_codeunit => 99
  (func $get_codeunit (export "get_codeunit") (result i32)
    ;; Reads 'c' which is code 99.
    (stringview_wtf16.get_codeunit
      (string.as_wtf16
        (string.const "abcdefg")
      )
      (i32.const 2)
    )
  )

  ;; CHECK:      [fuzz-exec] calling get_length
  ;; CHECK-NEXT: [fuzz-exec] note result: get_length => 7
  (func $get_length (export "get_length") (result i32)
    ;; This should return 7.
    (stringview_wtf16.length
      (string.as_wtf16
        (string.const "1234567")
      )
    )
  )

  ;; CHECK:      [fuzz-exec] calling encode
  ;; CHECK-NEXT: [LoggingExternalInterface logging 3]
  ;; CHECK-NEXT: [LoggingExternalInterface logging 0]
  ;; CHECK-NEXT: [LoggingExternalInterface logging 97]
  ;; CHECK-NEXT: [LoggingExternalInterface logging 98]
  ;; CHECK-NEXT: [LoggingExternalInterface logging 99]
  ;; CHECK-NEXT: [LoggingExternalInterface logging 0]
  (func $encode (export "encode")
    (local $array16 (ref $array16))
    (local.set $array16
      (array.new_default $array16
        (i32.const 10)
      )
    )
    ;; Log out that we wrote 3 things.
    (call $log
      (string.encode_wtf16_array
        (string.const "abc")
        (local.get $array16)
        (i32.const 4)
      )
    )
    ;; We wrote 3 things at offset 4. Log out the values at 3,4,5,6,7 (the first
    ;; and last should be 0, and "abc" in between).
    (call $log
      (array.get $array16
        (local.get $array16)
        (i32.const 3)
      )
    )
    (call $log
      (array.get $array16
        (local.get $array16)
        (i32.const 4)
      )
    )
    (call $log
      (array.get $array16
        (local.get $array16)
        (i32.const 5)
      )
    )
    (call $log
      (array.get $array16
        (local.get $array16)
        (i32.const 6)
      )
    )
    (call $log
      (array.get $array16
        (local.get $array16)
        (i32.const 7)
      )
    )
  )
)
;; CHECK:      [fuzz-exec] calling new_wtf16_array
;; CHECK-NEXT: [fuzz-exec] note result: new_wtf16_array => string("ello")

;; CHECK:      [fuzz-exec] calling const
;; CHECK-NEXT: [fuzz-exec] note result: const => string("world")

;; CHECK:      [fuzz-exec] calling eq.1
;; CHECK-NEXT: [fuzz-exec] note result: eq.1 => 0

;; CHECK:      [fuzz-exec] calling eq.2
;; CHECK-NEXT: [fuzz-exec] note result: eq.2 => 1

;; CHECK:      [fuzz-exec] calling eq.3
;; CHECK-NEXT: [fuzz-exec] note result: eq.3 => 0

;; CHECK:      [fuzz-exec] calling eq.4
;; CHECK-NEXT: [fuzz-exec] note result: eq.4 => 0

;; CHECK:      [fuzz-exec] calling eq.5
;; CHECK-NEXT: [fuzz-exec] note result: eq.5 => 1

;; CHECK:      [fuzz-exec] calling compare.1
;; CHECK-NEXT: [trap null ref]

;; CHECK:      [fuzz-exec] calling compare.2
;; CHECK-NEXT: [trap null ref]

;; CHECK:      [fuzz-exec] calling compare.3
;; CHECK-NEXT: [trap null ref]

;; CHECK:      [fuzz-exec] calling compare.4
;; CHECK-NEXT: [fuzz-exec] note result: compare.4 => 0

;; CHECK:      [fuzz-exec] calling compare.5
;; CHECK-NEXT: [fuzz-exec] note result: compare.5 => -1

;; CHECK:      [fuzz-exec] calling compare.6
;; CHECK-NEXT: [fuzz-exec] note result: compare.6 => 1

;; CHECK:      [fuzz-exec] calling compare.7
;; CHECK-NEXT: [fuzz-exec] note result: compare.7 => -1

;; CHECK:      [fuzz-exec] calling compare.8
;; CHECK-NEXT: [fuzz-exec] note result: compare.8 => 1

;; CHECK:      [fuzz-exec] calling compare.9
;; CHECK-NEXT: [fuzz-exec] note result: compare.9 => 1

;; CHECK:      [fuzz-exec] calling compare.10
;; CHECK-NEXT: [fuzz-exec] note result: compare.10 => -1

;; CHECK:      [fuzz-exec] calling get_codeunit
;; CHECK-NEXT: [fuzz-exec] note result: get_codeunit => 99

;; CHECK:      [fuzz-exec] calling get_length
;; CHECK-NEXT: [fuzz-exec] note result: get_length => 7

;; CHECK:      [fuzz-exec] calling encode
;; CHECK-NEXT: [LoggingExternalInterface logging 3]
;; CHECK-NEXT: [LoggingExternalInterface logging 0]
;; CHECK-NEXT: [LoggingExternalInterface logging 97]
;; CHECK-NEXT: [LoggingExternalInterface logging 98]
;; CHECK-NEXT: [LoggingExternalInterface logging 99]
;; CHECK-NEXT: [LoggingExternalInterface logging 0]
;; CHECK-NEXT: [fuzz-exec] comparing compare.1
;; CHECK-NEXT: [fuzz-exec] comparing compare.10
;; CHECK-NEXT: [fuzz-exec] comparing compare.2
;; CHECK-NEXT: [fuzz-exec] comparing compare.3
;; CHECK-NEXT: [fuzz-exec] comparing compare.4
;; CHECK-NEXT: [fuzz-exec] comparing compare.5
;; CHECK-NEXT: [fuzz-exec] comparing compare.6
;; CHECK-NEXT: [fuzz-exec] comparing compare.7
;; CHECK-NEXT: [fuzz-exec] comparing compare.8
;; CHECK-NEXT: [fuzz-exec] comparing compare.9
;; CHECK-NEXT: [fuzz-exec] comparing const
;; CHECK-NEXT: [fuzz-exec] comparing encode
;; CHECK-NEXT: [fuzz-exec] comparing eq.1
;; CHECK-NEXT: [fuzz-exec] comparing eq.2
;; CHECK-NEXT: [fuzz-exec] comparing eq.3
;; CHECK-NEXT: [fuzz-exec] comparing eq.4
;; CHECK-NEXT: [fuzz-exec] comparing eq.5
;; CHECK-NEXT: [fuzz-exec] comparing get_codeunit
;; CHECK-NEXT: [fuzz-exec] comparing get_length
;; CHECK-NEXT: [fuzz-exec] comparing new_wtf16_array
