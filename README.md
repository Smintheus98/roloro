# rohestheater-logo-rotate
Code for rotating rohestheater logo animation

## structure
This repository mainly consists of the two [Red](https://www.red-lang.org/p/about.html) files
 - `./perspective.red`
 - `./rohestheater-logo-rotate.red`
 - `./utils.red`.

The file `utils.red` supplies some helping functions.
The file `perspective.red` contains some functions that can be used to calculate a 3x3 matrix that performs a perspective transformation.
The `rohestheater-logo-rotate.red` file makes use of this matrix to tranform a rotated virtual 2D-grid to a position and orientation in 3-dimensional space to project it back to a series of 2D-images.
Afterwards the 'rohestheater'-title is put upon that grid so that it is always fully surrounded by the borders of the (rotated) grid.

## Notes
 - As there currently is an issue with a segmentation fault probably due to a GC issue, the program is wrapped into a script, which calls the script on a subset of the frames to be generated.
 - For stability of the grid representation the output-format is twice the size of the intended output-format and needs to be scaled down. This procedure removes jittering-effects reliably.

## Todo
 - [x] Test if the virtual 2D-grid can be smaller when replacing pair! with point2D! for internal calculations, as pair! enforces conversion to positive integers.
 - [ ] Try using point2D! as result of tilt
 - [x] Center virtual 2D-grid around (0, 0)
 - [ ] Use as-<type> instead of to-<type>, as it has cleaner syntax and might be faster
 - [ ] Re-observe target points for perspective transform
 - [ ] Try to calculate the 1920x1080-sized output-image internally
