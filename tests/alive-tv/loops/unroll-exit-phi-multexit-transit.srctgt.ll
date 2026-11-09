; TEST-ARGS: -src-unroll=2 -tgt-unroll=2

; The loop H <-> L has two exits (H -> A, H -> B) that reconverge at P, which
; is outside the loop and is a transit predecessor of the phi at Q. The value
; read through P is the one of the last executed copy of H; keeping the
; original (first-copy) definition on that edge is stale whenever the loop
; exits from a later copy (e.g. %0 = 4: iteration 2 sees %4 = 1).

define i32 @src(i32 %0) {
entry:
  switch i32 %0, label %H [
    i32 7, label %Q
  ]

H:
  %4 = phi i32 [ %0, %entry ], [ %n, %L ]
  switch i32 %4, label %L [
    i32 1, label %A
    i32 2, label %B
  ]

L:
  %n = sub i32 %4, 3
  br label %H

A:
  br label %P

B:
  br label %P

P:
  br label %Q

Q:
  %q = phi i32 [ %4, %P ], [ 42, %entry ]
  ret i32 %q
}

define i32 @tgt(i32 %0) {
entry:
  switch i32 %0, label %H [
    i32 7, label %Q
  ]

H:
  %4 = phi i32 [ %0, %entry ], [ %n, %L ]
  switch i32 %4, label %L [
    i32 1, label %A
    i32 2, label %B
  ]

L:
  %n = sub i32 %4, 3
  br label %H

A:
  %a = phi i32 [ %4, %H ]
  br label %P

B:
  %b = phi i32 [ %4, %H ]
  br label %P

P:
  %p = phi i32 [ %a, %A ], [ %b, %B ]
  br label %Q

Q:
  %q = phi i32 [ %p, %P ], [ 42, %entry ]
  ret i32 %q
}
