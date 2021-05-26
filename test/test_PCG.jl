# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#

pcg = PCG()

@test pcg.state == UInt64(1753877967969059832)
@test pcg.inc == UInt64(109)

for expected in [
          2707161783,
          2068313097,
          3122475824,
          2211639955,
          3215226955,
          3421331566,
     ]
     @test UInt32(expected) == random(pcg, UInt32)
end
