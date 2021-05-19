# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software. THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

print(io::IO, c::RGB{T}) where T = print(io, "RGB = (", c.r, ", ", c.g, ", ", c.b, ")" )
print(c::RGB{T}) where T = print(stdout, c)
println(io::IO, c::RGB{T}) where T = println(io, "RGB = (", c.r, ", ", c.g, ", ", c.b, ")" )
println(c::RGB{T}) where T = println(stdout, c)

print(io::IO, p::Point) = print(io, "Point = (", p.x, ", ", p.y, ", ", p.z, ")" )
print(p::Point) = print(stdout, p)
println(io::IO, p::Point) = print(io, "Point = (", p.x, ", ", p.y, ", ", p.z, ")" )
println(p::Point) = println(stdout, p)

print(io::IO, v::Vec) = print(io, "Vec = (", v.x, ", ", v.y, ", ", v.z, ")" )
print(v::Vec) = print(stdout, v)
println(io::IO,v::Vec) = println(io, "Vec = (", v.x, ", ", v.y, ", ", v.z, ")" )
println(v::Vec) = println(stdout,v)


function println(img::HDRimage, n::Int64=5)
     n>=1 || throw(ArgumentError("not a valid index; $n must be >0"))
     n<=50 || throw(ArgumentError("too big index; $n must be <=50"))

     w=img.width
     h=img.height
     println("HDRImage to be printed")
     println("width = ", w, "\t height = ", h)
     if w*h <= 2*n
          for c in img.rgb_m; println(c); end
     else
          for i in 1:n; println(img.rgb_m[n]);end
          println("...")
          for i in 1:n; println(img.rgb_m[end-n+i]);end
     end
     nothing
end

function println(io::IO, ray::Ray)
     print("Ray with origin and direction: \t")
     println(ray.origin, "  ,  ", ray.dir)
end
function print(io::IO, ray::Ray)
     print("Ray with origin and direction: \t")
     print(ray.origin, "  ,  ", ray.dir)
end
println(ray::Ray) = println(stdout, ray)
print(ray::Ray) = print(stdout, ray)


println(io::IO, uv::Vec2d) =  println(io, "Vec2d = (", uv.u, ", ", uv.v, ")" )
println(uv::Vec2d) =  println(stdout, "Vec2d = (", uv.u, ", ", uv.v, ")" )
print(io::IO, uv::Vec2d) =  print(io, "Vec2d = (", uv.u, ", ", uv.v, ")" )
print(uv::Vec2d) =  print(stdout, "Vec2d = (", uv.u, ", ", uv.v, ")" )

function print_not_black(img::HDRimage)
     w=img.width
     h=img.height
     println("HDRImage to be printed")
     println("width = ", w, "\t height = ", h)

     for (i, color) in enumerate(img.rgb_m)
          color==BLACK ? nothing : println(i, "\t", color)
     end

     nothing
end
