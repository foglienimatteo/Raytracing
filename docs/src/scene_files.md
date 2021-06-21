```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Scene Files

## Basic functions

```@docs
Raytracing.isdigit
Raytracing.isdecimal
Raytracing.isalpha
Raytracing.isalnum
```

## SourceLocation and Tokens

```@docs
Raytracing.SourceLocation
Raytracing.KeywordEnum
Raytracing.Token
Raytracing.KeywordToken
Raytracing.IdentifierToken
Raytracing.StringToken
Raytracing.LiteralNumberToken
Raytracing.SymbolToken
Raytracing.StopToken
Raytracing.GrammarError
```


## Parsing and readingTokens

```@docs
Raytracing.InputStream
Raytracing.update_pos
Raytracing.read_char
Raytracing.unread_char
Raytracing.skip_whitespaces_and_comments
Raytracing.parse_string_token
Raytracing.parse_float_token
Raytracing.parse_keyword_or_identifier_token
Raytracing.read_token
Raytracing.unread_token
```

## Scene and basic parsing scene functions

```@docs
Raytracing.Scene
Raytracing.expect_symbol
Raytracing.expect_keywords
Raytracing.expect_number
Raytracing.expect_bool
Raytracing.expect_string
Raytracing.expect_identifier
Raytracing.parse_vector
Raytracing.parse_color
Raytracing.parse_pigment
Raytracing.parse_brdf
Raytracing.parse_material
Raytracing.parse_transformation
Raytracing.parse_pointlight
Raytracing.parse_camera
Raytracing.return_token_value
Raytracing.assert
Raytracing.parse_scene
```

## Parsing Shapes

```@docs
Raytracing.parse_sphere
Raytracing.parse_plane
```