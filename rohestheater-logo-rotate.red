; vim: set ts=2 sts=2 sw=2:
Red [
  Title: {Rotating rohestheater Logo}
  Author: {Yannic Kitten}
  File: %rohestheater-logo-rotate.red
  Needs: View
  License: {GNU GPL v3.0 or newer}
  Interpreter: red-view
  Notes: {
    - Clean rotation can be accomplished with parameters:
        deg-inc: 0.05 low:1 high:1800
      This will result in 1800 frames performing an 90° rotation
      which can be converted into a 60s video using 30fps.
  }
  Possible Improvement: {
    - (?) make ellipse gauss-blurring or almost transparent (with gradient maybe?) (?)
  }
]

; get input from CLI
deg-inc: 1
low: 1
high: 90
args: reverse system/options/args
if (not none? find args "-h") or (not none? find args "--help") [
  print {Usage: ./rohestheater-logo-rotate.red [[[<degree-increment>] <low-iterations>] <high-iterations>]}
  high: -1
]
if (length? args) >= 1 [
  high: to-integer args/1
  if (length? args) >= 2 [
    low: to-integer args/2
    if (length? args) >= 3 [
      deg-inc: to-float args/3
    ]
  ]
]

; load other modules
do %perspective.red
do %utils.red

; global variables
scale: 1
plane: scale * 1920x1080

foreground: white
text-color: white
background: black

ellipse-size: scale * 755x150
ellipse-pos: plane - ellipse-size / 2 - (scale * (-120, 52))

DejaVu-Sans: make font! compose [
  name: "DejaVu Sans"
  size: (scale * 95)
  style: 'bold
  color: (text-color)
]
text-font: DejaVu-Sans
text-pos: scale * 725x515


; grid object with functions for rotation and tilt (perspective transform)
grid: context [
  size: 120x120
  n-edge-pts: 5
  line-wd: 1
  half-line-wd: half-of line-wd

  corner-pts: reduce [
      (-1, -1) * half-of size
      ( 1, -1) * half-of size
      ( 1,  1) * half-of size
      (-1,  1) * half-of size
  ]

  edge-pts: collect [
    repeat n n-edge-pts [
      keep reduce [
        reduce [ ; corresponding edge-points in x-direction
          subtract as-point2D size/x / (n-edge-pts + 1) * n  0        half-of size
          subtract as-point2D size/x / (n-edge-pts + 1) * n  size/y   half-of size
        ]
        reduce [ ; corresponding edge-points in y-direction
          subtract as-point2D 0       size/y / (n-edge-pts + 1) * n   half-of size
          subtract as-point2D size/x  size/y / (n-edge-pts + 1) * n   half-of size
        ]
      ]
    ]
  ]

  target-corner-pts: reduce [ scale * 420x540 scale * 947x226 scale * 1462x366 scale * 1488x824 ]

  M: perspective-transform reduce [
    corner-pts/1 target-corner-pts/1
    corner-pts/2 target-corner-pts/2
    corner-pts/3 target-corner-pts/3
    corner-pts/4 target-corner-pts/4
  ]

  outer-edge-boxes: reduce [ ; upper-left and lower-right points of boxes around outer edges
    reduce [ corner-pts/1 - half-line-wd  corner-pts/1 + (-1x1 * half-line-wd)  corner-pts/2 + half-line-wd  corner-pts/2 + (1x-1 * half-line-wd) ]
    reduce [ corner-pts/2 - half-line-wd  corner-pts/2 + (1x-1 * half-line-wd)  corner-pts/3 + half-line-wd  corner-pts/3 + (-1x1 * half-line-wd) ]
    reduce [ corner-pts/3 + half-line-wd  corner-pts/3 + (1x-1 * half-line-wd)  corner-pts/4 - half-line-wd  corner-pts/4 + (-1x1 * half-line-wd) ]
    reduce [ corner-pts/4 + half-line-wd  corner-pts/4 + (-1x1 * half-line-wd)  corner-pts/1 - half-line-wd  corner-pts/1 + (1x-1 * half-line-wd) ]
  ]

  inner-edge-boxes: collect [ ; upper-left and lower-right points of boxes around inner edges
    while [not tail? edge-pts] [
      ; y-boxes
      edge: first edge-pts
      keep/only reduce [ edge/1 - half-line-wd  edge/1 + (1x-1 * half-line-wd)  edge/2 + half-line-wd  edge/2 + (-1x1 * half-line-wd) ]
      ; x-boxes
      edge: second edge-pts
      keep/only reduce [ edge/1 - half-line-wd  edge/1 + (-1x1 * half-line-wd)  edge/2 + half-line-wd  edge/2 + (1x-1 * half-line-wd) ]

      edge-pts: skip edge-pts 2
    ]
    edge-pts: head edge-pts
  ]

  edge-boxes: append outer-edge-boxes inner-edge-boxes


  rotate: func[pt-list [series!] deg [number!] return: [block!]] [
    ;; Application of 2D rotation matrix to [x y]-points
    collect [
      foreach pt pt-list [
        keep as-point2D subtract pt/x * cosine deg  pt/y *   sine deg
                        add      pt/x *   sine deg  pt/y * cosine deg
      ]
    ]
  ]
  ;rotate-corner-pts: func[deg [number!] return: [block!]] [ rotate corner-pts deg ]
  ;rotate-edge-pts:   func[deg [number!] return: [block!]] [ collect [ foreach pt-pair edge-pts [ keep reduce [rotate pt-pair deg] ]] ]
  rotate-edge-boxes: func[deg [number!] return: [block!]] [
    collect [
      foreach box edge-boxes [
        keep reduce [ rotate box deg ]
      ]
    ]
  ]

  tilt: func[pt-list [series!] return: [block!]] [
    ;; Application of perspective transform based on observed target corner points
    collect [
      foreach pt pt-list [
        keep as-point2D (M/1/1 * pt/x) + (M/1/2 * pt/y) + M/1/3 / ((M/3/1 * pt/x) + (M/3/2 * pt/y) + M/3/3)
                        (M/2/1 * pt/x) + (M/2/2 * pt/y) + M/2/3 / ((M/3/1 * pt/x) + (M/3/2 * pt/y) + M/3/3)
      ]
    ]
  ]
  
  ;rotilt-corner-pts: func[deg [number!] return: [block!]] [ tilt rotate-corner-pts deg ]
  ;rotilt-edge-pts:   func[deg [number!] return: [block!]] [ collect [ foreach pt-pair rotate-edge-pts deg [ keep reduce [tilt pt-pair] ]] ]
  rotilt-edge-boxes: func[deg [number!] return: [block!]] [
    collect [
      foreach box rotate-edge-boxes deg [
        keep reduce [ tilt box ]
      ]
    ]
  ]
]


; main loop
step cnt low high [
  deg: deg-inc * cnt

  ; draw image
  img: make image! reduce [plane background]
  draw img compose [
    pen (foreground)
    fill-pen (foreground)
    line-width (1 * scale)

    ; draw grid in 3D
    ;polygon (grid/rotilt-corner-pts deg)
    (collect [
      foreach box grid/rotilt-edge-boxes deg [
        keep compose [ polygon (box) ]
      ]
    ])

    ; draw ellipse
    pen off
    fill-pen (background)
    ellipse (ellipse-pos) (ellipse-size)

    ; draw text
    font (text-font)
    text (text-pos) "rohestheater"
  ]

  save to-file rejoin ["frames/rohestheater-logo-rotate-frame-" pad/left/with cnt 4 #"0" ".png"] img
]

