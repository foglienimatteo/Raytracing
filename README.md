# Raytracing

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

![julia-version] ![status] ![package-version] ![CI-build]
![size] ![license]

[julia-version]: https://img.shields.io/badge/julia_version-v1.6-9558B2?style=flat&logo=julia
[status]: https://img.shields.io/badge/project_status-🚧_work--in--progress-ba8a11?style=flat
[size]: https://img.shields.io/github/repo-size/cosmofico97/Raytracing
[package-version]: https://img.shields.io/badge/package_version-0.1-blue?style=flat
[license]: https://img.shields.io/github/license/cosmofico97/Raytracing
[CI-build]: https://img.shields.io/github/workflow/status/cosmofico97/Raytracing/Unit%20tests

This software is a simple raytracing program written in the [Julia Programming Language](julia).
It's based on the lectures of the [*Numerical techniques for photorealistic image generation*](PIM) curse (AY2020-2021), held by Associate Professor [Maurizio Tomasi](Tomasi) at University of Milan [Department of
Physics "Aldo Pontremoli"](dip-fisica).

## Table of Contents

- [Raytracing](#raytracing)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Animation Tutorial](#animation-tutorial)
  - [Usage](#usage)
  - [Licence](#licence)
  - [Contributors ✨](#contributors-)

## Installation

The simplest way to install this software is cloning the repository where it is built in. Run in the command line
```bash
git clone https://github.com/cosmofico97/Raytracing
```
or download the source code from the github repository https://github.com/cosmofico97/Raytracing

## Animation Tutorial

To star of and checks the correct behavior of the software run one of (or both) the following command inside the main directory
```bash
./Raytracer.jl demo-animation --camera_type=per --algorithm=flat --width=640 --height=480
```
```bash
./Raytracer.jl demo --world-type=B --camera-type=per --algorithm=pathtracing --camera-position=-1,0,1 --width=640 --height=480
```
and enjoy respectively the animation `demo/demo_anim_Flat_640x480x360.mp4` and the image `demo/demo_B_PathTracing_640x480.png`

<!---
<video width="640" height="480"  type="video/mp4" "src="https://user-images.githubusercontent.com/79974922/119556147-ef2b3200-bd9e-11eb-956f-17de6ea6bdda.mp4"  autoplay loop> </video>"
-->

Animation with FlatRenderer            | Image with PathTracing
:-------------------------------------:|:-------------------------:
![](demo/demo_anim_Flat_640x480x360.gif)  |  ![](demo/demo_B_PathTracing_640x480.png)


It may takes few minutes to renderer the animation; you might also gives smaller (integer and even) values to `--width` and `--height` in order to obtain the same animation in a smaller amount of time (the price to pay is a worse definition of the animation itself).

## Usage


## Licence
All the files in this repository are under a MIT license. See the file [LICENSE.md](./LICENSE.md)



[julia]: https://julialang.org
[PIM]: https://www.unimi.it/en/education/degree-programme-courses/2021/numerical-tecniques-photorealistic-image-generation
[Tomasi]: http://cosmo.fisica.unimi.it/persone/maurizio-tomasi
[dip-fisica]: http://eng.fisica.unimi.it/ecm/home

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://ziotom78.blogspot.it/"><img src="https://avatars.githubusercontent.com/u/377795?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Maurizio Tomasi</b></sub></a><br /><a href="#mentoring-ziotom78" title="Mentoring">🧑‍🏫</a></td>
    <td align="center"><a href="https://github.com/Paolo97Gll"><img src="https://avatars.githubusercontent.com/u/49845775?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Paolo Galli</b></sub></a><br /><a href="#tool-Paolo97Gll" title="Tools">🔧</a> <a href="#ideas-Paolo97Gll" title="Ideas, Planning, & Feedback">🤔</a></td>
    <td align="center"><a href="https://github.com/Samuele-Colombo"><img src="https://avatars.githubusercontent.com/u/79973069?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Samuele-Colombo</b></sub></a><br /><a href="#ideas-Samuele-Colombo" title="Ideas, Planning, & Feedback">🤔</a> <a href="#tool-Samuele-Colombo" title="Tools">🔧</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!

