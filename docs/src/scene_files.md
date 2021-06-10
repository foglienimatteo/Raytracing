```@meta
DocTestSetup = quote
    using Raytracing
end
```

# Scene Files

```@docs
Raytracing.isdigit
Raytracing.isdecimal
Raytracing.isalpha
Raytracing.isalnum 
Raytracing.SourceLocation
Raytracing.copy(::Raytracing.SourceLocation)
Raytracing.KeywordEnum
Raytracing.Token
Raytracing.KeywordToken
Raytracing.IdentifierToken
Raytracing.StringToken
Raytracing.LiteralNumberToken
Raytracing.SymbolToken
Raytracing.StopToken
Raytracing.GrammarError
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