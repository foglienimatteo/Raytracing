# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

"""
     PCG(state::UInt64 = UInt64(42), inc::UInt64 = UInt64(54))

A mutable struct for the Permuted Congruential Generator (PCG) 
which is a uniform pseudo-random number generator.

## Parameters

- `state::UInt64 = UInt64(42)` : initial state number
- `inc::UInt64 = UInt64(54)` : initial sequence number

## References

Melissa E. O’Neill (2014), ["PCG: A Family of Simple Fast 
Space-Efficient Statistically Good Algorithms 
for Random Number Generation"](https://www.pcg-random.org/paper.html)

See also: [`random(pcg::PCG, ::Type{UInt32})`](@ref), 
[`random(pcg::PCG, ::Type{Float64})`](@ref)
"""
mutable struct PCG 
     state::UInt64
     inc::UInt64

     function PCG(init_state::UInt64 = UInt64(42), init_seq::UInt64 = UInt64(54))
          # 64-bit
          self = new(UInt64(0), (init_seq << UInt64(1)) | UInt64(1))
     
          random(self, UInt32)

          # 64-bit
          self.state += init_state

          random(self, UInt32)
          return self
     end
end

function get_state(pcg::PCG)
     value = pcg.state
     return Int128(value)
end     

function get_inc(pcg::PCG)
     value = pcg.inc
     return Int128(value)
end

"""
     random(pcg::PCG, ::Type{UInt32}) :: UInt32

Return a new random UInt32 number and advance PCG's internal state.

This function is based on the paper of Melissa E. O’Neill (2014), 
where the Permuted Congruential Generator (PCG) family of random 
number generators is defined and explained.

## References

Melissa E. O’Neill (2014), ["PCG: A Family of Simple Fast 
Space-Efficient Statistically Good Algorithms 
for Random Number Generation"](https://www.pcg-random.org/paper.html)

See also: [`random(pcg::PCG, ::Type{Float64})`](@ref), [`PCG`](@ref)
"""
function random(pcg::PCG, ::Type{UInt32})
     # 64-bit
     oldstate = pcg.state

     # 64-bit
     pcg.state = UInt64(oldstate * UInt64(6364136223846793005) + pcg.inc) # % typemax(UInt64)

     # 32-bit
     xorshifted = UInt32( ((oldstate >> UInt64(18)) ⊻ oldstate) >> UInt64(27) & typemax(UInt32))

     # 32-bit
     rot = oldstate >> UInt64(59)

     # 32-bit
     return UInt32( ((xorshifted >> rot) | (xorshifted << ((-rot) & 31))))  # % typemax(UInt32)
end

"""
     random(pcg::PCG, ::Type{Float64}) :: Float64

Returns a `Float64` random number inside `[0,1]` interval obtained 
with a PCG Uniform Pseudo-random Number Generator.

It calls the `random(pcg::PCG, ::Type{UInt32})` function, which
returns a `UInt32` random number, and divides it with ` typemax(UInt32)`.

See also: [`random(pcg::PCG, ::Type{UInt32})`](@ref), [`PCG`](@ref)
"""
random(pcg::PCG, ::Type{Float64}) = random(pcg, UInt32) / typemax(UInt32)

"""
     random(pcg::PCG) :: Float64

Returns a `Float64` random number inside `[0,1]` interval obtained 
with a PCG Uniform Pseudo-random Number Generator.

It calls the `random(pcg::PCG, ::Type{Float64})` function.

See also: [`random(pcg::PCG, ::Type{Float64})`](@ref),
[`random(pcg::PCG, ::Type{UInt32})`](@ref), [`PCG`](@ref)
"""
random(pcg::PCG) = random(pcg, Float64)
  
