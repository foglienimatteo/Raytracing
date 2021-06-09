# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
     GrammarError <: Exception(
          location::SourceLocation
          message::str
     )

An error found by the lexer/parser while reading a scene file

## Arguments

- `location::SourceLocation` : a struct containing the name of the file 
  (or the empty string if there is no real file) and the line and column 
  number where the error was discovered (both starting from 1)

- `message::String` : a user-frendly error message

See also: [`SourceLocation`](@ref)
"""
struct GrammarError <: Exception 
    location::SourceLocation
    message::String
end


"""
     @enum KeywordEnum

Enumeration for all the possible keywords recognized by the lexer:
```ditaa
|:-----------------:|:-----------------:|:-----------------:|
| NEW = 1           | CHECKERED = 8     | SCALING = 15      |
| MATERIAL = 2      | IMAGE = 9         | ORTHOGONAL = 17   |
| PLANE = 3         | IDENTITY = 10     | ORTHOGONAL = 17   |
| SPHERE = 4        | TRANSLATION = 11  | PERSPECTIVE = 18  |
| DIFFUSE = 5       | ROTATION_X = 12   | FLOAT = 19        |
| SPECULAR = 6      | ROTATION_Y = 13   |
| UNIFORM = 7       | ROTATION_Z = 14   |
|:-----------------:|:-----------------:|:-----------------:|
```
"""
@enum KeywordEnum begin
    NEW = 1
    MATERIAL = 2
    PLANE = 3
    SPHERE = 4
    DIFFUSE = 5
    SPECULAR = 6
    UNIFORM = 7
    CHECKERED = 8
    IMAGE = 9
    IDENTITY = 10
    TRANSLATION = 11
    ROTATION_X = 12
    ROTATION_Y = 13
    ROTATION_Z = 14
    SCALING = 15
    CAMERA = 16
    ORTHOGONAL = 17
    PERSPECTIVE = 18
    FLOAT = 19
end

KEYWORDS = Dict{String, KeywordEnum}(
    "new" => KeywordEnum.NEW,
    "material" => KeywordEnum.MATERIAL,
    "plane" => KeywordEnum.PLANE,
    "sphere" => KeywordEnum.SPHERE,
    "diffuse" => KeywordEnum.DIFFUSE,
    "specular" => KeywordEnum.SPECULAR,
    "uniform" => KeywordEnum.UNIFORM,
    "checkered" => KeywordEnum.CHECKERED,
    "image" => KeywordEnum.IMAGE,
    "identity" => KeywordEnum.IDENTITY,
    "translation" => KeywordEnum.TRANSLATION,
    "rotation_x" => KeywordEnum.ROTATION_X,
    "rotation_y" => KeywordEnum.ROTATION_Y,
    "rotation_z" => KeywordEnum.ROTATION_Z,
    "scaling" => KeywordEnum.SCALING,
    "camera" => KeywordEnum.CAMERA,
    "orthogonal" => KeywordEnum.ORTHOGONAL,
    "perspective" => KeywordEnum.PERSPECTIVE,
    "float" => KeywordEnum.FLOAT,
)