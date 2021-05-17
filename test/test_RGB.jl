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

@test 1+1==2
@test Raytracing.are_close(1.00000000001, 1)

a = RGB{Float64}(0.1, 0.2, 0.3)
b = RGB{Float64}(0.5, 0.6, 0.7)
err = 1e-11

# Controllo della inizializzazione
@test a ≈ RGB{Float64}(0.1 + err, 0.2, 0.3 - 2*err)
@test b ≈ RGB{Float64}(0.5, 0.6 + err, 0.7 + 2*err)

# Controllo nuove operazioni
@test a+b ≈ RGB(0.6, 0.8+err, 1.0)
@test b-a ≈ RGB(0.4, 0.4-2err, 0.4)
@test 2.0*a ≈ RGB(0.2 + err, 0.4, 0.6)
@test b*0.5 ≈ RGB(0.25 + err, 0.3, 0.35)
@test a/2. ≈ RGB(0.05, 0.1, 0.15 + 3*err)