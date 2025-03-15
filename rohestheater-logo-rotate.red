; vim: set ts=2 sts=2 sw=2:
Red [
  Title: {Rotating rohestheater Logo}
  Author: {Yannic Kitten}
  File: %rohestheater-logo-rotate.red
  Needs: View
  License: {GNU GPL v3.0 or newer}
  Interpreter: red-view
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

; fix global variables
scale: 2
plane: scale * 1920x1080

; grid object with functions for rotation and tilt (perspective transform)
grid: context [
  size: 100002x100002
  pad: plane - size / 2
  n-edge-pts: 5
  corner-points: reduce [
      pad
      to-pair reduce [ pad/x + size/x  pad/y]
      to-pair reduce [ pad/x + size/x  pad/y + size/y]
      to-pair reduce [ pad/x           pad/y + size/y]
  ]
  edge-points: collect [
    repeat n n-edge-pts [
      keep reduce [ reduce [
        to-pair reduce [ size/x / (n-edge-pts + 1) * n + pad/x   pad/y ]
        to-pair reduce [ size/x / (n-edge-pts + 1) * n + pad/x   pad/y + size/y ]
      ]]
      keep reduce [ reduce [
        to-pair reduce [ pad/x           size/y / (n-edge-pts + 1) * n + pad/y ]
        to-pair reduce [ pad/x + size/x  size/y / (n-edge-pts + 1) * n + pad/y ]
      ]]
    ]
  ]

  rotate: func[pt-list [series!] deg [number!] return: [series!]] [
    ;; Application of 2D rotation matrix to [x y]-points
    collect [
      foreach pt pt-list [
        keep to-pair reduce [ ((pt/x - half-of plane/x) * cosine deg) - ((pt/y - half-of plane/y) *   sine deg) + half-of plane/x 
                              ((pt/x - half-of plane/x) *   sine deg) + ((pt/y - half-of plane/y) * cosine deg) + half-of plane/y ]
      ]
    ]
  ]
  corner-points-rot:    func[deg [number!] return: [series!]] [ rotate corner-points deg ]
  edge-points-rot:      func[deg [number!] return: [series!]] [ collect [ foreach edge-point-pair edge-points [ keep reduce [rotate edge-point-pair deg] ]] ]

  target-corner-points: reduce [ scale * 420x540 scale * 947x226 scale * 1462x366 scale * 1488x824 ]   ; outdated: [scale * 53x495 495x239 916x354 939x734]
  M: perspective-transform reduce [
    corner-points/1 target-corner-points/1
    corner-points/2 target-corner-points/2
    corner-points/3 target-corner-points/3
    corner-points/4 target-corner-points/4
  ]
  tilt: func[pt-list [series!] return: [series!]] [
    ;; Application of perspective transform based on observed target corner points
    collect [
      foreach pt pt-list [
        keep to-pair reduce [
            (M/1/1 * pt/x) + (M/1/2 * pt/y) + M/1/3 / ((M/3/1 * pt/x) + (M/3/2 * pt/y) + M/3/3)
            (M/2/1 * pt/x) + (M/2/2 * pt/y) + M/2/3 / ((M/3/1 * pt/x) + (M/3/2 * pt/y) + M/3/3)
        ]
      ]
    ]
  ]
  corner-points-tilt:   func[              return: [series!]] [ tilt corner-points ]
  edge-points-tilt:     func[              return: [series!]] [ collect [ foreach edge-point-pair edge-points [ keep reduce [tilt edge-point-pair] ]] ]
  
  corner-points-rotilt: func[deg [number!] return: [series!]] [ tilt corner-points-rot deg ]
  edge-points-rotilt:   func[deg [number!] return: [series!]] [ collect [ foreach edge-point-pair edge-points-rot deg [ keep reduce [tilt edge-point-pair] ]] ]
]

DejaVu-Sans: make font! compose [name: "DejaVu Sans" style: 'bold size: (scale * 95)]
bordeaux: 140.23.32

; main loop
step cnt low high [
  deg: deg-inc * cnt
  foreground: white
  text-color: white ;bordeaux
  background: black
  ellipse-size: scale * 755x150

  img: make image! reduce [plane background]
  draw img compose [
    pen (foreground)
    line-width 4
    ;anti-alias off

    ; draw grid in 3D
    polygon (grid/corner-points-rotilt deg)
    (collect [
      foreach pt-pair grid/edge-points-rotilt deg [
        keep reduce ['line first pt-pair second pt-pair]
      ]
    ]) 

    ; draw ellipse
    pen off
    fill-pen (background)
    ellipse (plane - ellipse-size / 2 - (scale * 0x52) + (scale * 120x0)) (ellipse-size)

    ; draw text
    font DejaVu-Sans
    pen (text-color)
    text (scale * 725x515) "rohestheater"
  ]

  save to-file rejoin ["frames/rohestheater-logo-rotate-frame-" pad/left/with cnt 4 #"0" ".png"] img
]


; simple tests:

;print grid/corner-points
;print grid/corner-points
;print grid/corner-points-rot 0
;print grid/corner-points-rot 90
;print mold grid/edge-points
;quit

;print grid/corner-points
;print grid/corner-points-tilt
;img: draw plane compose [ polygon (grid/corner-points-rotilt 45) (collect [ foreach pt-pair grid/edge-points-rotilt 45 [ keep compose[line (first pt-pair) (second pt-pair)] ] ])]
;save %test.png img
;quit

;img: draw plane compose [ polygon (grid/corner-points) (collect [ foreach pt-pair grid/edge-points [ keep compose[line (first pt-pair) (second pt-pair)] ] ])]
;img: draw plane compose [ polygon (grid/corner-points-rot 0) (collect [ foreach pt-pair grid/edge-points-rot 0 [ keep compose[line (first pt-pair) (second pt-pair)] ] ])]
;repeat deg 90 [
;  img: draw plane compose [ rotate (deg) (half-of plane) polygon (grid/corner-points) (collect [ foreach pt-pair grid/edge-points [ keep compose[line (first pt-pair) (second pt-pair)] ] ])]
;  save %dest-test-file.png img
;  wait 0.1
;]
;quit

