; TEST-ARGS: -src-unroll=2 -tgt-unroll=2

; The natural loop is only H <-> L; T (transit) and J (join) are outside it.
; %m equals %4 on every edge into J (the L edge carries 0 but is only taken
; when %4 == 0), so folding the join phi away is sound. The exit-value repair
; must not fabricate values on the transit edge T -> J.

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
  br label %X

X:
  %r = phi i32 [ %4, %J ], [ 0, %H ]
  ret i32 %r
}
