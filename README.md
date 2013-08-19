# Timeline

Event timeline utilizing HTML, CoffeeScript, d3, Stylus, and Mimosa to tie it all together.

Working copy [here](http://timeline-d3.herokuapp.com/)

## Dependencies
This timeline has the following dependencies:
* d3
* jQuery

## Build
To build the Timeline library, `cd` to the root of this project and run the command `mimosa build -omp`.  This will deposit three library versions in the `build` folder.
* An optimized version with shim and dependencies excluded.
* An optimized version without a shim, but includes dependencies.
* A fully inclusive version which includes an AMD shim (Almond) and all dependencies.
