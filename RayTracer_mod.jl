### Shapes.jl/AABB_intersection ##################################################################

function ray_intersection(AABB::AABB, ray::Ray)

    m = AABB.m
    M = AABB.M
    O = ray.origin
    D = ray.dir

    (tmin, tmax) = (Tuple( sort([m.x, M.x])) - O.x) / D.x
    (tymin, tymax) = (Tuple( sort([m.y, M.y])) - O.y) / D.y
 
    ((tmin > tymax) || (tymin > tmax)) && (return false)
 
    (tymin > tmin) && (tmin = tymin)
    (tymax < tmax) && (tmax = tymax)

    (tzmin, tzmax) = (Tuple( sort([m.z, M.z])) - O.z) / D.z
 
    ((tmin > tzmax) || (tzmin > tmax)) && (return false)
 
    (tzmin > tmin) && (tmin = tzmin)
    (tzmax < tmax) && (tmax = tzmax)
 
    if (ray.tmin ≤ tmin ≤ ray.tmax) || ( ray.tmin ≤ tmax ≤ ray.tmax)
        return true
    else
        return false
    end
end

### TUTORIAL #######################################################################################

#=
Agguingere al file 'tutorial_basic_syntax' gli esempi per costruire un oggetto CAMERA e tutte
le forme, mancano!

FARE TUTTI GLI ESEMPI ASTRATTI MA COMPLETI CON TUTTI GLI ARGOMENTI <-> TIPOLOGIA
=#
#=
Note: the rendering typology (onoff/flat/pathtracer/pointlight) has to be selected from CLI
or Julia REPL (see README.md), as width and height of the image.

CAMERA(TYPE_OF_CAMERA, arg1::TRANSFORMATION, [arg2::FLOAT])
where TYPE_OF_CAMERA can be:
- PERSPECTIVE;
- ORTHOGONAL;
and the other arguments:
- arg1: transformation to specify the CAMERA position;
- arg2: distance of the camera from the screen, ONLY FOR PERSPECTIVE CAMERA TYPE_OF_BRDF.

PIGMENT pig_name(TYPE_OF_PIGMENT(args...))
where TYPE_OF_PIGMENT can be:
- UNIFORM(arg::COLOR);
- CHECKERED(arg1::COLOR, arg2::COLOR, n::INT);
- IMAGE(arg::STRING).   # here the argument is the path to the .jpg image file

BRDF brdf_name(TYPE_OF_BRDF(arg::PIGMENT))
where TYPE_OF_BRDF can be:
- DIFFUSE(arg1::PIGMENT, arg2::FLOAT)
    * arg2: reflectance;
- SPECULAR(arg::PIGMENT, arg2::FLOAT)
    * arg2: theresold angle in rad.

MATERIAL material_name(arg1::BRDF, arg2::PIGMENT)

TRANSFORMATION trans_name(arg)
where arg can be (a product of):
- ROTATION_X(arg::FLOAT);    # arg is the angle of rotation in radiant
- ROTATION_Y(arg::FLOAT);    # arg is the angle of rotation in radiant
- ROTATION_Z(arg::FLOAT);    # arg is the angle of rotation in radiant
- SCALING(arg::VECTOR);
- TRANSLATION(arg::VECTOR).

POINTLIGHT(arg1::VECTOR, arg2::COLOR)
where the arguments means:
- arg1: position of the source of light;
- arg2: color of the light.

CUBE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
where the arguments are:
- arg1: material of the cube;
- arg2: transformation for position and "reshape" of the figure;
- b1: optional argument, set to 'true' if inside there is a POINTLIGHT;
- b2: optional argument, set to 'true' if this is the shape of background.

PLANE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
- arg1: material of the cube;
- arg2: transformation for position and "reshape" of the figure;
- b1: optional argument, set to 'true' if inside there is a POINTLIGHT;
- b2: optional argument, set to 'true' if this is the shape of background.

SPHERE(arg1::MATERIAL, arg2::TRANSFORMATION, b1::BOOL=false, b2::BOOL=false)
- arg1: material of the cube;
- arg2: transformation for position and "reshape" of the figure;
- b1: optional argument, set to 'true' if inside there is a POINTLIGHT;
- b2: optional argument, set to 'true' if this is the shape of background.

TORUS(arg1::MATERIAL, arg2::TRANSFORMATION, arg3::FLOAT=1, arg4::FLOAT=3*arg3, b1::BOOL=false, b2::BOOL=false)
- arg1: material of the cube;
- arg2: transformation for position and "reshape" of the figure;
- arg3: minor radius of the torus, has default value of 1;
- arg3: major radius of the torus, has default value the triple of minor radius (arg3);
- b1: optional argument, set to 'true' if inside there is a POINTLIGHT;
- b2: optional argument, set to 'true' if this is the shape of background.

TRIANGLE(arg1::MATERIAL, arg2::VECTOR, arg3::VECTOR, arg4::VECTOR, b1::BOOL=false, b2::BOOL=false)
- arg1: material of the cube;
- arg2, arg3, arg4: vertices of the triangle;
- b1: optional argument, set to 'true' if inside there is a POINTLIGHT;
- b2: optional argument, set to 'true' if this is the shape of background.


There are some default values:
- FLOAT types:
    * pi: stands for \pi                         # CONTROLLA!!!
    * e: stands for Neper number
- COLOR types:
    * BLACK (<0., 0., 0.>)
    * WHITE (<255., 255., 255.>)
    * RED (<255., 0., 0.>)
    * LIME (<0., 255., 0.>)
    * BLUE 	(<0., 0., 255.>)
    * YELLOW (<255., 255., 0.>)
    * CYAN 	(<0., 255., 255.>)
    * MAGENTA (<255., 0., 255.>)
    * SYLVER (<192., 192., 192.>)
    * GRAY (<128., 128., 128.>)
    * MAROON (<128., 0., 0.>)
    * OLIVE (<128., 128., 0.>)
    * GREEN (<0., 128., 0.>)
    * PURPLE (<128., 0., 128.>)
    * TEAL (<0., 128., 128.>)
    * NAVY (<0., 0., 128.>)
    * ORANGE (<255., 165., 0.>)
    * GOLD (<255., 215., 0.>)
=#

### src/Raytracing.jl #####################################################################################

SYM_COL = Dict(
    "BLACK" => RGB{Float32}(0., 0., 0.),
    "WHITE" => RGB{Float32}(255., 255., 255.),
    "RED" => RGB{Float32}(255., 0., 0.),
    "LIME" => RGB{Float32}(0., 255., 0.),
    "BLUE" => RGB{Float32}(0., 0., 255.),
    "YELLOW" => RGB{Float32}(255., 255., 0.),
    "CYAN" => RGB{Float32}(0., 255., 255.),
    "MAGENTA" => RGB{Float32}(255., 0., 255.),
    "SYLVER" => RGB{Float32}(192., 192., 192.),
    "GRAY" => RGB{Float32}(128., 128., 128.),
    "MAROON" => RGB{Float32}(128., 0., 0.),
    "OLIVE" => RGB{Float32}(128., 128., 0.),
    "GREEN" => RGB{Float32}(0., 128., 0.),
    "PURPLE" => RGB{Float32}(128., 0., 128.),
    "TEAL" => RGB{Float32}(0., 128., 128.),
    "NAVY" => RGB{Float32}(0., 0., 128.),
    "ORANGE" => RGB{Float32}(255., 165., 0.),
    "GOLD" => RGB{Float32}(255., 215., 0.)
)


### Structs.jl #####################################################################################

# HEAD
## Aggiungere colori di default

# TORUS
## Modificare il costruttore di Torus:
function Torus(
    T::Transformation = Transformation(),
    Material::Material = Material(),
    r::Float64 = 0.5,
    R::Float64 = 3*r,
    flag_pointlight::Bool = false,
    flag_background::Bool = false
    )
    #    @assert r<R
    new(T, M, r, R, b1, b2, AABB(Torus, T, r, R))
end


### Structs.jl #####################################################################################

function AABB(::Type{Torus}, T::Transformation, r::Float64, R::Float64)
    S = R + r
    v1 = SVector{8, Point}(
        Point(S, r, S),
        Point(S, -r, S),
        Point(-S, r, S),
        Point(-S, -r, S),
        Point(S, r, -S),
        Point(S, -r, -S),
        Point(-S, r, -S),
        Point(-S, -r, -S),
    )

    v2 = SVector{8, Point}([T*p for p in v1])

    P2 = Point(
        maximum([v2[i].x for i in eachindex(v2)]),
        maximum([v2[i].y for i in eachindex(v2)]),
        maximum([v2[i].z for i in eachindex(v2)]) 
    )
    P1 = Point(
        minimum([v2[i].x for i in eachindex(v2)]),
        minimum([v2[i].y for i in eachindex(v2)]),
        minimum([v2[i].z for i in eachindex(v2)]) 
    )

    AABB(P1, P2)
end


### interpreter/parser_functions.jl/parse_torus ####################################################

function parse_torus(inputstream::InputStream, scene::Scene)
    expect_symbol(inputstream, "(")

    material_name = expect_identifier(inputstream)
    if material_name ∉ keys(scene.materials)
        # We raise the exception here because inputstream is pointing to the end of the wrong identifier
        throw(GrammarError(inputstream.location, "unknown material $(material_name)"))
    end
    expect_symbol(inputstream, ",")
    transformation = parse_transformation(inputstream, scene)

    token = read_token(inputstream)
    if typeof(token.value) == LiteralNumberToken
        small_rad = token.value.number

        read_token(inputstream)
        if typeof(token.value) == SymbolToken && token.value.symbol == ","
            expect_symbol(inputstream, ",")
            read_token(inputstream)
            if typeof(token.value) == LiteralNumberToken
                big_rad = token.value.number
            else
                big_rad = 3 * small_rad
            end

        end
#        unread_token(inputstream, token)
    else
        small_rad = -1
        big_rad = -1
#        unread_token(inputstream, token)
    end
   
#    token = read_token(inputstream)
    if typeof(token.value) == SymbolToken && token.value.symbol == ","
        expect_symbol(inputstream, ",")
        flag_pointlight = expect_bool(inputstream, scene)
        expect_symbol(inputstream, ",")
        flag_background = expect_bool(inputstream, scene)
        expect_symbol(inputstream, ")")
    else
        unread_token(inputstream, token)
        expect_symbol(inputstream, ")")
        flag_pointlight = false
        flag_background = false
    end

    if small_rad<0 && big_rad<0
        return Torus(transformation, scene.materials[material_name], flag_pointlight, flag_background)
    else
        return Torus(transformation, scene.materials[material_name], small_rad, big_rad, flag_pointlight, flag_background)
end

### Render.jl #####################################################################################

# Controlla le indentazioni


### Shapes.jl #####################################################################################

function torus_point_to_uv(P::Point, r::Float64, R::Float64)
    # metodo basato usando l'angolo alla circonferenza (Molinari)
    if (0 <= P.y < 1e-10) && (√(P.x^2+P.z^2) < R - r + 1e-10)
        u = π/2 # π
    elseif (- 1e-10 < P.y < 0) && (√(P.x^2+P.z^2) < R - r + 1e-10)
        u = -π/2 #0
    else
        u = 2 * atan( P.y/( r - R + √(P.x^2+P.z^2) ) ) # +π/2
    end


    if (0 <= P.z < 1e-10) && (P.x < - R - r + 1e-10)
        v = π/2 # π
    elseif (- 1e-10 < P.z < 0) && (P.x < - R - r + 1e-10)
        v = -π/2 #0
    else
        v = 2 * atan( P.z/(P.x + r + R) ) # +π/2
    end

    # u = 2 * atan( P.y/( r - R + √(P.x^2+P.z^2) ) ) # +π/2
    # v = 2 * atan( P.z/(P.x + r + R) ) # +π/2

    return Vec2d(u+π/2, v+π/2) / π
end


### Shapes.jl ######################################################################################################

function torus_normal(P::Point, ray_dir::Vec, r::Float64, R::Float64)

    #=
    # u e v mi danno gia' tutte le info che mi servono per la retta della normale, il verso ancora
    # dalla provenienza del raggio luce

    u, v = torus_point_to_uv(P, r, R)... # CONTROLLA!!
    N = Normal(cos(2.*u*pi), cos(2.*v*pi), sin(2.*v*pi))
    N ⋅ ray_dir < 0.0 ? nothing : N = -N
    return N
    =#

    # http://cosinekitty.com/raytrace/chapter13_torus.html
    Q = R/√(P.x^2-P.z^2) * Point(P.x, 0, P.z)
    N = Normal(P - Q)
    N ⋅ ray_dir < 0.0 ? nothing : N = -N
    return N
end


### Shapes.jl ######################################################################################################

function ray_intersection(torus::Torus, ray::Ray)

    (ray_intersection(torus.AABB, ray) == true) || (return nothing)

    inv_ray = inverse(torus.T) * ray
    o = Vec(inv_ray.origin)
    d = inv_ray.dir
    norm2_d = squared_norm(d)
    norm2_o =  squared_norm(o)
    scalar_od = o ⋅ d
    r = torus.r
    R = torus.R
    calc = norm2_o - r^2 - R^2

    # coefficienti per calcolo soluzioniintersezione
    c4 = norm2_d^2
    c3 = 4 * norm2_d * scalar_od
    c2 = 4 * scalar_od^2 + 2 * norm2_d * norm2_o - 4 * R^2 * (norm2_d - d.z^2) + 2 * norm2_d * (R^2 - r^2)
    # c2 = 2 * norm2_d * calc + 4 * scalar_od^2 + 4 * R^2 * d.y^2
    c1 = 4 * norm2_o * scalar_od + 4 * scalar_od * (R^2 - r^2) - 8 * R^2 * (scalar_od - (o.z * d.z))
    # c1 = 4 * calc * scalar_od + 8 * R^2 * o.y * d.y
    c0 = norm2_o^2 + (R^2 - r^2)^2 + 2 * norm2_o * (R^2 - r^2) - 4 * R^2 * (norm2_o - o.z^2)
    # c0 = calc^2 - 4 * R^2 * (r^2 - o.y^2)

    # calcolo soluzioni
    t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

    # verifico esistenza di almeno una soluzione
    (t_ints == nothing) && (return nothing)

    hit_ts = Vector{Float64}()

    # controllo che le soluzioni siano reali positive o che la parte immaginaria sia quasi nulla
    for i in t_ints
        if (typeof(i) == ComplexF64) && (abs(i.im) > 1e-10) #1e-8
            continue
        elseif ((typeof(i) == Float64) && (1e-5 < i < inv_ray.tmax)) ||
               ((typeof(i) == ComplexF64) && (abs(i.im) < 1e-10) && (1e-5 < i < inv_ray.tmax)) 
            (typeof(i) == Float64) && push!(hit_ts, i)
            continue
            (typeof(i) == ComplexF64) && push!(hit_ts, i.re)
        else
            nothing
        end
    end

    (length(hit_ts) == 0) && return nothing

    hit_t = min(hit_ts...)

    hit_point = at(inv_ray, hit_t)

    return HitRecord(
        torus.T * hit_point,
        torus.T * torus_normal(hit_point, inv_ray.dir, r, R),
        torus_point_to_uv(hit_point, r, R),
        hit_t,
        ray, 
        torus
    )
end


### Shapes.jl ######################################################################################################

function quick_ray_intersection(torus::Torus, ray::Ray)

    inv_ray = inverse(torus.T) * ray
    o = Vec(inv_ray.origin)
    d = inv_ray.dir
    norm2_d = squared_norm(d)
    norm2_o =  squared_norm(o)
    scalar_od = o ⋅ d
    r = torus.r
    R = torus.R
    calc = norm2_o - r^2 - R^2

    # coefficienti per calcolo soluzioniintersezione
    c4 = norm2_d^2
    c3 = 4 * norm2_d * scalar_od
    c2 = 4 * scalar_od^2 + 2 * norm2_d * norm2_o - 4 * R^2 * (norm2_d - d.z^2) + 2 * norm2_d * (R^2 - r^2)
    # c2 = 2 * norm2_d * calc + 4 * scalar_od^2 + 4 * R^2 * d.y^2
    c1 = 4 * norm2_o * scalar_od + 4 * scalar_od * (R^2 - r^2) - 8 * R^2 * (scalar_od - (o.z * d.z))
    # c1 = 4 * calc * scalar_od + 8 * R^2 * o.y * d.y
    c0 = norm2_o^2 + (R^2 - r^2)^2 + 2 * norm2_o * (R^2 - r^2) - 4 * R^2 * (norm2_o - o.z^2)
    # c0 = calc^2 - 4 * R^2 * (r^2 - o.y^2)

    # calcolo soluzioni
    t_ints = roots(Polynomial([c0, c1, c2, c3, c4]))

    # verifico esistenza di almeno una soluzione
    t_ints === nothing && (return nothing)

    hit_ts = Vector{Float64}()

    # controllo che le soluzioni siano reali positive o che la parte immaginaria sia quasi nulla
    for i in t_ints
        if (typeof(i) == ComplexF64) && (abs(i.im) > 1e-10) #1e-8
            continue
        elseif ((typeof(i) == Float64) && (1e-5 < i < inv_ray.tmax)) ||
               ((typeof(i) == ComplexF64) && (abs(i.im) < 1e-10) && (1e-5 < i < inv_ray.tmax)) 
            (typeof(i) == Float64) && push!(hit_ts, i)
            continue
            (typeof(i) == ComplexF64) && push!(hit_ts, i.re)
        else
            nothing
        end
    end

    length(hit_ts) == 0 ? (return true) : (return false)

end    # quick_ray_intersection


### interpreter/tokens.jl ##########################################################################################

# riga 147 aggiungere:
# "TORUS" => TORUS,

# riga 104 aggiungere:
# TORUS = 65

# riga 62 aggiungere:
# TORUS = 65


### interpreter/parse_scene.jl #####################################################################################

# riga 213 aggiungere:
# elseif what.value.keyword == TORUS
#     add_shape!(scene.world, parse_torus(inputstream, scene))


### debug_torus.txt ################################################################################################
#=
CAMERA(ORTHOGONAL, TRANSLATION([-2, 0, 1]), 1.0)

COLOR purple(<128, 0, 128>)
COLOR lime(<0, 255, 0>)

VECTOR donut_pos([3.5, -3.0, 0.0])
FLOAT small_r(1.0)
FLOAT big_r(3.0)
PIGMENT donut_pigment(CHECKERED(purple, lime, 8))
BRDF donut_brdf(DIFFUSE, donut_pigment)

MATERIAL donut_material(
    donut_brdf,
    donut_pigment
)

TRANSFORMATION donut_trans(
    TRANSLATION(donut_pos)
    * SCALING(1., 2., 3.)
)

TORUS(
    donut_material,
    donut_trans
)

POINTLIGHT(
    [-3.5, +3.0, 0.0],
    <255, 255, 255>
)
=#

### interpreter/parser_functions.jl ################################################################################################

function parse_color(inputstream::InputStream, scene::Scene, open::Bool=false)
    token = read_token(inputstream)
    result = ""

    if typeof(token.value) == SymbolToken && token.value.symbol == "("
         result *= "("*parse_vector(inputstream, scene, true)
         expect_symbol(inputstream, ")")
         result *= ")"
         token = read_token(inputstream)
    end
    
    if typeof(token.value) == SymbolToken && token.value.symbol == "-"
         result *= "-"
         token = read_token(inputstream)
    end
    
    if typeof(token.value)

    while true
         if (typeof(token.value) == SymbolToken) && (token.value.symbol ∈ OPERATIONS)
              result *= token.value.symbol
         elseif (typeof(token.value) == IdentifierToken) && (token.value.identifier ∈ keys(SYM_NUM))
              result *=  string(SYM_NUM[token.value.identifier])
         elseif typeof(token.value) == IdentifierToken
              variable_name = token.value.identifier
              
              if (variable_name ∈ keys(scene.color_variables) )
                   next_color = scene.color_variables[variable_name]
                   result *= repr(next_color)
              elseif (variable_name ∈ keys(scene.float_variables) )
                   next_number = scene.float_variables[variable_name]
                   result *= repr(next_number)
              elseif isdefined(Raytracing, Symbol(variable_name)) || isdefined(Base, Symbol(variable_name))
                   unread_token(inputstream, token)
                   result *= parse_function(inputstream, scene)
              else
                   throw(GrammarError(token.location, "unknown float/color variable '$(token)'"))
              end
              
         elseif typeof(token.value) == SymbolToken && token.value.symbol =="<"
              unread_token(inputstream, token)

              expect_symbol(inputstream, "<")
              x = expect_number(inputstream, scene)
              expect_symbol(inputstream, ",")
              y = expect_number(inputstream, scene)
              expect_symbol(inputstream, ",")
              z = expect_number(inputstream, scene)
              expect_symbol(inputstream, ">")
              result*= repr(RGB{Float32}(x, y, z))

         elseif (typeof(token.value) == SymbolToken) && (token.value.symbol=="(")
              result *= "("*parse_color(inputstream, scene, true)
              expect_symbol(inputstream, ")")
              result *= ")"

         elseif typeof(token.value) == LiteralNumberToken
              result *= repr(token.value.number)
         else
              unread_token(inputstream, token)
              break
         end

         #=
         elseif (typeof(token.value) == SymbolToken) && (token.value.symbol==")")
              unread_token(inputstream, token)
              break
         else
              throw(GrammarError(token.location, "unknown variable '$(token)'"))
         end
         =#

         token = read_token(inputstream)
    end

    if open == true
         return result
    else
         return eval(Meta.parse(result))
    end
end
