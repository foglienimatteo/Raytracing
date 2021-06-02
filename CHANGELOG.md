# HEAD
<<<<<<< HEAD
- Divided code in runtests.jl in minor files
- New struct from Shape: `Plane`
- Modified operations and constructors between `Transformation` and `Normal`, `Vec` and `Point` for time optimization
- Added test for `World`, modified test for `Sphere`
=======

# VERSION 0.2.0

- Modified `demo` function: now two possible world versions can be rendered
- New struct for generate a better image considering lights and angles (`PathTracer`) and tests
- Implemented scalar and vector products between two `Normal` and between `Normal` and `Vec`
- New struct `SpecularBRDF`
- Implemented PCG new struct (`PCG`) and algorithm for random numbers
- Functions to decide which type of render use
- Functions to get the color from a pigment and evaluete it thanks to the BRDF
- New structs for rendering (`OnOffRenderer`, `FlatRRenderer`) and tests
- New struct for implement the material of a Shape (`Material`) and tests
- New structs for BRDF implementtion (`BRDF`, `DiffuseBRDF`) and tests
- New structs for pigment implementation (`Pigment`, `UniformPigment`, `CheckeredPigment`, `ImagePigment`) and tests
- Modified operation between `Transformation` and `Normal`, `Vec` and `Point` for time optimization
- Added test for World, modified test for Sphere
>>>>>>> 1f1ea5e247e5b114b31f086772a2e2bb3790b5eb
- Added feature: now can create an animation
- New interface from command line
- Added test for camera orientation ([PR#8](https://github.com/cosmofico97/Raytracing/pull/8#issue-631504956))
- Fixed bug in the code ([PR#7](https://github.com/cosmofico97/Raytracing/pull/7#issue-630790415))
- Implemented a first main interface
- Implemented structs: `Shape`, `Sphere`, `World` for a first image creation

# VERSION 0.1.0

- Added feature: now can convert from a .pfm image to .png and .tiff one 
- Completed function for reading and writing a .pfm image file format