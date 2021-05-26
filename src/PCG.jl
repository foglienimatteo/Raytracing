# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
PCG Uniform Pseudo-random Number Generator
"""
mutable struct PCG 
     state::UInt64
     inc::UInt64

     function PCG(init_state::UInt64 = UInt64(42), init_seq::UInt64 = UInt64(54))
          self = new(UInt64(0), (init_seq << UInt64(1)) | UInt64(1))
          random(self)
          self.state += init_state
          random(self)
          self
     end
end


"""
Return a new random number and advance PCG's internal state
"""
function random(pcg::PCG, ::Type{UInt32})
     # 64-bit
     oldstate = pcg.state

     # 64-bit
     #pcg.state = UInt64(oldstate * UInt64(6364136223846793005) + pcg.inc) # % typemax(UInt64)
     pcg.state = UInt64(oldstate * 6364136223846793005 + pcg.inc)

     # 32-bit
     #xorshifted = UInt32( (((oldstate >> UInt64(18)) ⊻ oldstate) >> UInt64(27)) % typemax(UInt32))
     xorshifted = UInt32( ((oldstate >> 18) ⊻ oldstate) >> 27 )

     # 32-bit
     #rot = oldstate >> UInt64(59)
     rot = oldstate >> 59

     # 32-bit
     #return UInt32((xorshifted >> rot) | (xorshifted << ((-rot) & UInt32(31)))) # % typemax(UInt32)
     return UInt32( ((xorshifted >> rot) | (xorshifted << ((-rot) & 31))) % typemax(UInt32) ) 
end

random(pcg::PCG, ::Type{Float64}) = random(pcg, UInt32) / typemax(UInt32)
random(pcg::PCG) = random(pcg, Float64)
