# HEAD

- Added the shape Cube, see PR[#21](https://github.com/cosmofico97/Raytracing/pull/21)

- Added the shape Triangle, see PR[#20](https://github.com/cosmofico97/Raytracing/pull/20)

# VERSION 0.5.0

- Added a third demo world and modified `sphere_to_point_uv`

# VERSION 0.4.0

- Added point-light tracing algorithm, see PR[#17](https://github.com/cosmofico97/Raytracing/pull/17)


# VERSION 0.3.0

- Added antialiasing algorithm, see PR[#16](https://github.com/cosmofico97/Raytracing/pull/16)


# VERSION 0.2.0

- Feature: it's possible to create animations of `demo` (required [ffmpeg](https://www.ffmpeg.org) software)
  
- Implemented `demo` function: two possible world versions can be rendered

- Implemented `PCG` random number generator (see Melissa E. O’Neill (2014), ["PCG: A Family of Simple Fast Space-Efficient Statistically Good Algorithms for Random Number Generation"](https://www.pcg-random.org/paper.html)

- Implemented Renderers: `OnOffRenderer`, `FlatRRenderer`, `PathTracer`

- Implemented BRDFs: `BRDF`, `DiffuseBRDF`, `SpecularBRDF`
  
- Implemented Pigments: `Pigment`, `UniformPigment`, `CheckeredPigment`, `ImagePigment`

- Implemented Shapes: `Shape`, `Sphere`, `World`, `Plane`
  
- First bug fixed in the code (!); see PR[#7](https://github.com/cosmofico97/Raytracing/pull/7#issue-630790415))
  
- Implemented interface from command line
  
- Implemented a first main interface


# VERSION 0.1.0

- Added feature: now can convert from a .pfm image to .png and .tiff one 

- Completed function for reading and writing a .pfm image file format
  