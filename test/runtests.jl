using Raytracing
using Test

import ColorTypes:RGB

@testset "Colors" begin
	@test 1+1==2
	@test Raytracing.are_close(1.00000000001, 1)

	a = RGB{Float64}(0.1, 0.2, 0.3)
	b = RGB{Float64}(0.5, 0.6, 0.7)
	err = 1e-11

	@test a ≈ RGB{Float64}(0.1 + err, 0.2, 0.3 - 2*err)
	@test b ≈ RGB{Float64}(0.5, 0.6 + err, 0.7 + 2*err)

	@test a+b ≈ RGB(0.6, 0.8+err, 1.0)
	@test b-a ≈ RGB(0.4, 0.4-2err, 0.4)
	@test 2.0*a ≈ RGB(0.2 + err, 0.4, 0.6)
	@test b*0.5 ≈ RGB(0.25 + err, 0.3, 0.35)

end
