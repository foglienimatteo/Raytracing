# INSTRUCTIONS TO PROPELY WRITE YOUR TEXT FILE AND GENERATE IMAGES

This is a simple documentation where you can find instructions about the language you need to use
when writing your .txt file containing the instructions to generate your world.

#### Note

A first warning must be done: some variables can be passed both from command line (or Julia REPL) and inside the file;
if you use CLI method, those values have priprity over those in the file.

There are then instructions that you can specify and pass only through CLI (or Julia REPL):

- rendering typology (onoff/flat/pathtracer/pointlight);

- width and height of the image.

```console
unsername@PathToProject:~$ ./Raytracer.jl render [OPTIONS_FOR_THE_IMAGE] my_file.txt --width=NUMBER --height=NUMBER {onoff|flat|pathtracer|pointlight}[OPTIONS_FOR_THE_RENDERER]
```

</br>

## Variables

When you create a variable you must follow a specific order:

- define with a keyword its type,

- give to the variable a name,

- give the required arguments with the specified order and syntax.

You can define variables of the followint types:

- `FLOAT`: real number in Float64 Julia type

- `BOOL`: a boolean variable,

- `VECTOR`: a real 3D vector, numbers inside square brackets,

- `STRING`: a simple string,

- `COLOR`: a RGB color, each value must be between 0 and 255 and inside triangle brackets; can use also some defined color keywords (see below)

Those are the simplest variables you can create, here a brief example to resume:

```Julia
   FLOAT name(000)
   BOOL mybool(TRUE)
   BOOL mybool(FALSE)
   VECTOR myvec([1, 2, 3])
   STRING mystr("let's create a string")
   COLOR mycol1(<1, 2, 3>)
   COLOR mycol2(PURPLE)
```

</br>

Now we see how to create variables we need to use to give birth to the image; they are a bit more complex to initialize and we'll see later the various way we can use.

</br>

### PIGMENT

`PIGMENT` is the way your shape is colored, describes the self-emitted radiance of the object; can be in a uniform or checkered way or you can print on it an image.
You initialize a PIGMENT object in this way:

```Julia
PIGMENT pig_name(TYPE_OF_PIGMENT(args...))
```

where `TYPE_OF_PIGMENT` can be:

- ```UNIFORM(arg::COLOR)```;

- ```CHECKERED(arg1::COLOR, arg2::COLOR, n::INT)```;

- ```IMAGE(arg::STRING)```; here the argument is the path to the .jpg image file

</br>

### BRDF

`BRDF` describes the object surface and is the way light interacts with the object; this can be diffusive or specular (e.g. a mirror)

```Julia
BRDF brdf_name(TYPE_OF_BRDF(arg1::PIGMENT); arg2::FLOAT)
```

where the `;` char means that `arg2` is oprional; don't use `,` to separate the arguments.
`TYPE_OF_BRDF` can be:

- ```DIFFUSE(arg1::PIGMENT)```;

  `arg2`: for diffuse brdf is the reflectance value;

- ```SPECULAR(arg::PIGMENT)```;

  `arg2`: for specular brdf is theresold angle in rad.

</br>

### MATERIAL

`MATERIAL` is the way we describe the matierial that composes our object

```Julia
MATERIAL material_name(arg1::BRDF, arg2::PIGMENT)
```

when you give the arguments you can both give an existing variable name or create inside the required object (without giving type keyword and name)

</br>

### TRANSFORMATION

`TRANSFORMATION` are useful object to rotate, translate and scale your object in the way you prefer. If you have to apply more then just one transformaton,
you have to multiply them; remember to use the orrect order: the transformations are applied from the right to the left (in linear algebra way).

```Julia
TRANSFORMATION trans_name(arg)
```

where arg can be (a product of):

- ```ROTATION_X(arg::FLOAT)```: rotates along the x axis, `arg` is the angle in radiant;
- ```ROTATION_Y(arg::FLOAT)```: rotates along the y axis, `arg` is the angle in radiant;
- ```ROTATION_Z(arg::FLOAT)```: rotates along the z axis, `arg` is the angle in radiant;
- ```SCALING(arg::VECTOR)```: deforms along the three axises
- ```TRANSLATION(arg::VECTOR)```: translates in the specified position; it is applied to the (bari-)center of each figure.

</br>

## Non-variables

There are only two objects that don't require a name to be defined, since they are global settings and you have to inizialize them just once.
Those objects are directly created in the world.

### CAMERA

`CAMERA` defines form where you watch your creation and witch wiew you want.

```Julia
CAMERA(TYPE_OF_CAMERA, arg1::TRANSFORMATION, [arg2::FLOAT])
```

where `TYPE_OF_CAMERA` can be:

- ```PERSPECTIVE```;
- ```ORTHOGONAL```.

The other arguments are:

- ```arg1```: transformation to specify the camera position;
- ```arg2```: distance of the camera from the screen, ONLY for `PERSPECTIVE CAMERA`.

</br>

### POINTLIGHT

`POINTLIGHT` is the source of light, you can use more the one.

```Julia
POINTLIGHT(arg1::VECTOR, arg2::COLOR)
```

where the arguments means:

- ```arg1```: position of the source of light;
- ```arg2```: color of the light.

</br>

## Shapes

Here following there are the avaiable shapes of this ray tracer.

### CUBE

A cube has its centre in the origin, it has unit side.

```Julia
CUBE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
```

where the arguments are:

- ```arg1```: material of the cube;
- ```arg2```: transformation for position and "reshape" of the figure;
- ```b1```: optional argument, set to `true` if inside there is a [`POINTLIGHT`](#POINTLIGHT);
- ```b2```: optional argument, set to `true` if this is the shape of background.

</br>

### PLANE

An infinite plane on xy plane.

```Julia
PLANE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
```

The arguments are:

- ```arg1```: material of the cube;
- ```arg2```: transformation for position and "reshape" of the figure;
- ```b1```: optional argument, set to `true` if inside there is a [`POINTLIGHT`](#POINTLIGHT);
- ```b2```: optional argument, set to `true` if this is the shape of background.

</br>

### SPHERE

The initial condition of the sphere are: unit radius and centre in the origin (of the axes).

```Julia
SPHERE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
```

The arguments are:

- ```arg1```: material of the cube;
- ```arg2```: transformation for position and "reshape" of the figure;
- ```b1```: optional argument, set to `true` if inside there is a [`POINTLIGHT`](#POINTLIGHT);
- ```b2```: optional argument, set to `true` if this is the shape of background.

</br>

### TORUS

A torus with axis of symmetry along the z axis and circular section.

```Julia
TORUS(arg1::MATERIAL, arg2::TRANSFORMATION, arg3::FLOAT=1, arg4::FLOAT=3*arg3, b1::BOOL=false, b2::BOOL=false)
```

where the arguments are:

- ```arg1```: material of the cube;
- ```arg2```: transformation for position and "reshape" of the figure;
- ```arg3```: minor radius of the torus, has default value of 1;
- ```arg4```: major radius of the torus, has default value the triple of minor radius (arg3);
- ```b1```: optional argument, set to `true` if inside there is a [`POINTLIGHT`](#POINTLIGHT);
- ```b2```: optional argument, set to `true` if this is the shape of background.

</br>

### TRIANGLE

The triangle from plane geometry. It is an equilateral triangle on the xy plane, with vertexes (√3 / 2, 0, 0), (0, 0.5, 0) and (0, -0.5, 0).

```Julia
TRIANGLE(arg1::MATERIAL, arg2::VECTOR, arg3::VECTOR, arg4::VECTOR, b1::BOOL=false, b2::BOOL=false)
```

where the arguments are:

- ```arg1```: material of the cube;
- ```arg2```, ```arg3```, ```arg4```: vertices of the triangle;
- ```b1```: optional argument, set to `true` if inside there is a [`POINTLIGHT`](#POINTLIGHT);
- ```b2```: optional argument, set to `true` if this is the shape of background.

</br>

## Default values

There are some default numbers and colors that one can use.

There :

- ```FLOAT``` types:
  - `pi`: stands for $\pi$;
  - `e`: stands for Neper number;

- ```COLOR``` types:
  - `BLACK` (<0.0, 0.0, 0.0>);
  - `WHITE` (<255.0, 255.0, 255.0>);
  - `RED` (<255.0, 0.0, 0.0>);
  - `LIME` (<0.0, 255.0, 0.0>);
  - `BLUE` 	(<0.0, 0.0, 255.0>);
  - `YELLOW` (<255.0, 255.0, 0.0>);
  - `CYAN` 	(<0.0, 255.0, 255.0>);
  - `MAGENTA` (<255.0, 0.0, 255.0>);
  - `SYLVER` (<192.0, 192.0, 192.0>);
  - `GRAY` (<128.0, 128.0, 128.0>);
  - `MAROON` (<128.0, 0.0, 0.0>);
  - `OLIVE` (<128.0, 128.0, 0.0>);
  - `GREEN` (<0.0, 128.0, 0.0>);
  - `PURPLE` (<128.0, 0.0, 128.0>);
  - `TEAL` (<0.0, 128.0, 128.0>);
  - `NAVY` (<0.0, 0.0, 128.0>);
  - `ORANGE` (<255.0, 165.0, 0.0>);
  - `GOLD` (<255.0, 215.0, 0.0>).
