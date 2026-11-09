; TEST-ARGS: -src-unroll=2 -tgt-unroll=2
; CHECK: Transformation doesn't verify!

; Negative control for the exit-value repair: the join phi's latch-edge value
; is changed from 0 to 1. That edge only fires when %4 == 0, so the target
; genuinely returns a different value (path %0 = 2: one iteration, then the
; latch exits with %4 == 0). The repair must not mask the real mismatch.

define i32 @src(i32 %0) {
entry:
  br label %H

H:
  %4 = phi i32 [ %0, %entry ], [ 0, %L ]
  switch i32 %0, label %X [
    i32 1, label %T
    i32 2, label %L
    i32 3, label %J
  ]

T:
  br label %J

L:
  %c = icmp eq i32 %4, 0
  br i1 %c, label %J, label %H

J:
  %m = phi i32 [ %4, %H ], [ %4, %T ], [ 0, %L ]
  br label %X

X:
  %r = phi i32 [ %m, %J ], [ 0, %H ]
  ret i32 %r
}

define i32 @tgt(i32 %0) {
entry:
  br label %H

H:
  %4 = phi i32 [ %0, %entry ], [ 0, %L ]
  switch i32 %0, label %X [
    i32 1, label %T
    i32 2, label %L
    i32 3, label %J
  ]

T:
  br label %J

L:
  %c = icmp eq i32 %4, 0
  br i1 %c, label %J, label %H

J:
  %m = phi i32 [ %4, %H ], [ %4, %T ], [ 1, %L ]
  br label %X

X:
  %r = phi i32 [ %m, %J ], [ 0, %H ]
  ret i32 %r
}
