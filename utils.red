; vim: set ts=2 sts=2 sw=2:
Red [
  Title: {Utensils}
  Author: {Yannic Kitten}
  File: %utils.red
  License: {GNU GPL v3.0 or newer}
]

step: function [
  {Evaluates body for each value between low and high inclusively}
  'word   [word!]     {Iteration counter; not local to loop}
  low     [integer!]  {Lower bound of iteration series} 
  high    [integer!]  {Upper bound of iteration series}
  body    [block!]    {Block to execute}
  /down               {Iterate backwards, from high to low}
] [
  repeat _ high - (low - 1) [
    set word either down [high + 1 - _][low - 1 + _]
    do body
  ]
]

half-of: function [
  {Calculates the half of value}
  value [number! pair! point2D!] 
  return: [number! pair! point2D!]
] [
  value / 2
]

