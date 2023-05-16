# HEAD

## VERSION 1.2.0

- fixed bug in camera settings (conflicts between CLI command-default and file parsing)
- added Torus as new shape

## VERSION 1.1.1

- fixed a bug in the point-light renderer algorithm;

- modified the scenefile examples;
  
## VERSION 1.1.0

- added the `render_animation` function and improved the CLI; now it's possible to read an animation from a file; see PR[#19](https://github.com/cosmofico97/Raytracing/pull/19)

## VERSION 1.0.0

- added the `render` function and implemented lexer and parser; now it's possible to read a scene from a file and render it; see PR[#18](https://github.com/cosmofico97/Raytracing/pull/18)

- Added the shape AABB, see PR[#22](https://github.com/cosmofico97/Raytracing/pull/22)
  
- Added the shape Cube, see PR[#21](https://github.com/cosmofico97/Raytracing/pull/21)

- Added the shape Triangle, see PR[#20](https://github.com/cosmofico97/Raytracing/pull/20)

## VERSION 0.5.0

- Added a third demo world and modified `sphere_to_point_uv`

## VERSION 0.4.0

- Added point-light tracing algorithm, see PR[#17](https://github.com/cosmofico97/Raytracing/pull/17)

## VERSION 0.3.0

- Added antialiasing algorithm, see PR[#16](https://github.com/cosmofico97/Raytracing/pull/16)

## VERSION 0.2.0

- Feature: it's possible to create animations of `demo` (required [ffmpeg](https://www.ffmpeg.org) software)
  
- Implemented `demo` function: two possible world versions can be rendered

- Impleented an ortho-normal basis (ONB) generator algorithm based on [Duff et al. 2017](https://graphics.pixar.com/library/OrthonormalB/paper.pdf) 
  
- Implemented `PCG` random number generator (see Melissa E. O’Neill (2014), ["PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation"](https://www.pcg-random.org/paper.html)

- Implemented Renderers: `OnOffRenderer`, `FlatRRenderer`, `PathTracer`

- Implemented BRDFs: `BRDF`, `DiffuseBRDF`, `SpecularBRDF`
  
- Implemented Pigments: `Pigment`, `UniformPigment`, `CheckeredPigment`, `ImagePigment`

- Implemented Shapes: `Shape`, `Sphere`, `World`, `Plane`
  
- First bug fixed in the code (!); see PR[#7](https://github.com/cosmofico97/Raytracing/pull/7#issue-630790415))
  
- Implemented interface from command line
  
- Implemented a first main interface

## VERSION 0.1.0

- Added feature: now can convert from a .pfm image to .png and .tiff one 

- Completed function for reading and writing a .pfm image file format
  