# rohestheater-logo-rotate
Code for rotating rohestheater logo animation

## structure
This repository mainly consists of the two [Red](https://www.red-lang.org/p/about.html) files
 - `./perspective.red`
 - `./rohestheater-logo-rotate.red`
 - `./utils.red`.

The file `utils.red` supplies some helping functions.
The file `perspective.red` contains some functions that make it possible to calculate a 3x3 matrix that can be used to perform a perspective transformation.
The `rohestheater-logo-rotate.red` file makes use of this matrix to tranform a rotated 2D-grid to a position and orientation in 3-dimensional space to project it back to a series of 2D-images.
Afterwards the 'rohestheater'-title is put upon that grid so that is always fully surrounded by the borders of the (rotated) grid.

## Notes
 - As there currently is an issue with a segmentation fault when (purely speculative) allocating too much memory in total, the program is wrapped into a script, which calls the script on a subset of the frames to be generated.
 - For stability of the grid representation the output-format is twice the size of the intended output-format and needs to be scaled down. This procedure together with a big virtual size of the 2D-grid removes jittering-effects reliably.
