```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Scene Files

## Basic functions

```@docs
Raytracing.Interpreter.isdigit
Raytracing.Interpreter.isdecimal
Raytracing.Interpreter.isalpha
Raytracing.Interpreter.isalnum
Raytracing.Interpreter.close_bracket
```

## SourceLocation and Tokens

```@docs
Raytracing.Interpreter.SourceLocation
Raytracing.Interpreter.KeywordEnum
Raytracing.Interpreter.Token
Raytracing.Interpreter.KeywordToken
Raytracing.Interpreter.IdentifierToken
Raytracing.Interpreter.StringToken
Raytracing.Interpreter.LiteralNumberToken
Raytracing.Interpreter.SymbolToken
Raytracing.Interpreter.StopToken
Raytracing.Interpreter.GrammarError
```


## Parsing and readingTokens

```@docs
Raytracing.Interpreter.InputStream
Raytracing.Interpreter.update_pos
Raytracing.Interpreter.read_char
Raytracing.Interpreter.unread_char
Raytracing.Interpreter.skip_whitespaces_and_comments
Raytracing.Interpreter.parse_string_token
Raytracing.Interpreter.parse_float_token
Raytracing.Interpreter.parse_keyword_or_identifier_token
Raytracing.Interpreter.read_token
Raytracing.Interpreter.unread_token
```

## Scene and basic parsing scene functions

```@docs
Raytracing.Interpreter.Scene
Raytracing.Interpreter.expect_symbol
Raytracing.Interpreter.expect_keywords
Raytracing.Interpreter.expect_number
Raytracing.Interpreter.expect_bool
Raytracing.Interpreter.expect_string
Raytracing.Interpreter.expect_identifier
Raytracing.Interpreter.parse_vector
Raytracing.Interpreter.parse_color
Raytracing.Interpreter.parse_pigment
Raytracing.Interpreter.parse_brdf
Raytracing.Interpreter.parse_material
Raytracing.Interpreter.parse_transformation
Raytracing.Interpreter.parse_pointlight
Raytracing.Interpreter.parse_camera
Raytracing.Interpreter.return_token_value
Raytracing.Interpreter.assert
Raytracing.Interpreter.parse_scene
```

## Parsing Shapes

```@docs
Raytracing.Interpreter.parse_sphere
Raytracing.Interpreter.parse_plane
```