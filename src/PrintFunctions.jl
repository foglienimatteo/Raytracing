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

print(io::IO, v::Point) = print(io, "Point:\t ", v.x, "\t", v.y, "\t", v.z)
print(v::Point) = print(stdout, v)
println(io::IO,v::Point) = println(io, "Point:\t ", v.x, "\t", v.y, "\t", v.z)
println(v::Point) = println(stdout,v)

print(io::IO, v::Vec) = print(io, "Vec:\t ", v.x, "\t", v.y, "\t", v.z)
print(v::Vec) = print(stdout, v)
println(io::IO,v::Vec) = println(io, "Vec:\t ", v.x, "\t", v.y, "\t", v.z)
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