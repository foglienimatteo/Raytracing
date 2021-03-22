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

@testset "HDRimage_constructors" begin
	rgb_matrix=fill(RGB(0., 0., 0.0), (6,))
	img_1 = Raytracing.HDRimage(3, 2, rgb_matrix)
	img_2 = Raytracing.HDRimage(3, 2)

	@test img_1.width == 3
	@test img_1.height == 2
	@test img_1.rgb_m==img_2.rgb_m
	@test_throws AssertionError img = Raytracing.HDRimage(3, 3, rgb_matrix)
	@test_throws AssertionError img = Raytracing.HDRimage(1, 3, rgb_matrix)

end

@testset "test_coordinates" begin
	img = Raytracing.HDRimage(7, 4)

	@test Raytracing.valid_coordinates(img, 0, 0)
	@test Raytracing.valid_coordinates(img, 3, 2)
    	@test Raytracing.valid_coordinates(img, 6, 3)

	@test !Raytracing.valid_coordinates(img, 6, 4)
	@test !Raytracing.valid_coordinates(img, 7, 3)
    	@test !Raytracing.valid_coordinates(img, -1, 0)
    	@test !Raytracing.valid_coordinates(img, 0, -1)
	
end

@testset "test_pixel_offset" begin
	rgb_matrix= [ RGB( 3i/255, (3i+1)/255, (3i+2)/255 ) for i in 0:5]
	img = Raytracing.HDRimage(3, 2, rgb_matrix)

	@test_throws AssertionError Raytracing.pixel_offset(img, 3, 0)
	@test_throws AssertionError Raytracing.pixel_offset(img, 2, 2)

	@test img.rgb_m[Raytracing.pixel_offset(img, 0, 0)] ≈ RGB(0/255, 1/255, 2/255)
	@test img.rgb_m[Raytracing.pixel_offset(img, 2, 0)] ≈ RGB(6/255, 7/255, 8/255)
	@test img.rgb_m[Raytracing.pixel_offset(img, 2, 1)] ≈ RGB(15/255, 16/255, 17/255)

end

@testset "test_get_pixel" begin
	rgb_matrix= [ RGB( 3i/255, (3i+1)/255, (3i+2)/255 ) for i in 0:5]
	img = Raytracing.HDRimage(3, 2, rgb_matrix)

	@test_throws AssertionError Raytracing.get_pixel(img, 3, 0)
	@test_throws AssertionError Raytracing.get_pixel(img, 2, 2)

	@test Raytracing.get_pixel(img, 0, 0)  ≈ RGB(0/255, 1/255, 2/255)
	@test Raytracing.get_pixel(img, 2, 0) ≈ RGB(6/255, 7/255, 8/255)
	@test Raytracing.get_pixel(img, 2, 1) ≈ RGB(15/255, 16/255, 17/255)

end


@testset "test_set_pixel" begin
	rgb_matrix= [ RGB( 3i/255, (3i+1)/255, (3i+2)/255 ) for i in 0:5]
	img = Raytracing.HDRimage(3, 2, rgb_matrix)
	C = RGB(0.,0.,0.)

	@test_throws AssertionError Raytracing.set_pixel(img, 3, 0, C)
	@test_throws AssertionError Raytracing.set_pixel(img, 2, 2, C)

	Raytracing.set_pixel(img, 2, 0, C)
	@test Raytracing.get_pixel(img, 2, 0) ≈ RGB(0., 0., 0.)
	@test Raytracing.get_pixel(img, 0, 0)  ≈ RGB(0/255, 1/255, 2/255)
	@test Raytracing.get_pixel(img, 2, 1) ≈ RGB(15/255, 16/255, 17/255)

end

@testset "test_write_pfm" begin

	img = Raytracing.HDRimage(3, 2)
	Raytracing.set_pixel(img, 0, 0, RGB(1.0e1, 2.0e1, 3.0e1)) # Each component is
	Raytracing.set_pixel(img, 1, 0, RGB(4.0e1, 5.0e1, 6.0e1)) # different from any
	Raytracing.set_pixel(img, 2, 0, RGB(7.0e1, 8.0e1, 9.0e1)) # other: important in
	Raytracing.set_pixel(img, 0, 1, RGB(1.0e2, 2.0e2, 3.0e2)) # tests!
	Raytracing.set_pixel(img, 1, 1, RGB(4.0e2, 5.0e2, 6.0e2))
	Raytracing.set_pixel(img, 2, 1, RGB(7.0e2, 8.0e2, 9.0e2))


	inpf = open("reference_le.pfm", "r") do file
    			read(file)
		end

	io = IOBuffer(UInt8[], read=true, write=true)
	Raytracing.write(io, img)

	reference_bytes = [
  		0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  		0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  		0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  		0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  		0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  		0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  		0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
	]



	value = take!(io)
	@test value == inpf
	@test value == reference_bytes
	@test reference_bytes == inpf

end
