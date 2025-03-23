; vim: set ts=2 sts=2 sw=2:
Red [
  Title: {Simple raw library for perspective transformations}
  Author: {Yannic Kitten}
  File: %perspective.red
  License: {GNU GPL v3.0 or newer}
]

do %utils.red

gauss-jordan-elimination: function [
  {Solve linear equation system in the form of Ax = b using gauss-jordan algorithm}
  A       [block!]          {Quadratic system matrix}
  b       [block! vector!]  {Right-hand-side vector}
  /pmax                     {Use row with biggest entry for pivoting (default: first match)}
  return: [block! vector!]  {Solution (x) of Ax = b}
] [
  E: copy/deep A
  len: length? E
  x: copy b

  pivot-if: func [cond [logic!] /local swp-loc-val] [
    unless cond [return none]
    swp-loc-val: to-pair reduce [diag 0]
    step k diag + 1 len [
      if E/:k/:diag <> 0 [
        either pmax [   ; maximum-based
          if E/:k/:diag > swp-loc-val/2 [ swp-loc-val: to-pair reduce [k E/:k/:diag] ]
        ] [             ; first match
          swp-loc-val/1: k
          break
        ]
      ]
    ]
    swap skip E (diag - 1) skip E (swp-loc-val/1 - 1)
    swap skip x (diag - 1) skip x (swp-loc-val/1 - 1)
  ]

  ; forward (gauss) step
  repeat diag len [
    ; pivoting if required
    pivot-if E/:diag/:diag = 0
    step row diag + 1 len [
      l: (E/:row/:diag) / (E/:diag/:diag)
      x/:row: x/:row - (l * x/:diag)
      step col diag len [
        E/:row/:col: E/:row/:col - (l * E/:diag/:col)
      ]
    ]
  ]
  ; backward (jordan) step
  step/down diag 1 len [
    repeat row diag - 1 [
      l: E/:row/:diag / E/:diag/:diag
      x/:row: x/:row - (l * x/:diag)
    ]
    x/:diag: x/:diag / E/:diag/:diag
  ]
  return x
]


perspective-transform: function [
  {Calculate transformation matrix for a perspective transformation based on 4 pairs of source and target 2D-points}
  mapping [block! map!] {Map of correlation points in the form of #[src1: target1 ... ]}
  return: [block!]      {Transformation matrix (row-major)}
] [
  A: copy []
  b: copy []
  ; construct equation system
  foreach [src trg] to-map mapping [
    append/only A reduce [ src/x  src/y  1  0      0      0  negate src/x * trg/x  negate src/y * trg/x ]
    append/only A reduce [ 0      0      0  src/x  src/y  1  negate src/x * trg/y  negate src/y * trg/y ]
    append b reduce [ trg/x trg/y ]
  ]
  ; solve equations
  x: gauss-jordan-elimination A b
  ; construct transformation matrix
  M: compose/deep [
    [(x/1) (x/2) (x/3)]
    [(x/4) (x/5) (x/6)]
    [(x/7) (x/8)   1  ]
  ]
  return M
]

