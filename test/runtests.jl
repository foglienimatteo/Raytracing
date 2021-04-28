using Raytracing, Test, LinearAlgebra, StaticArrays
import ColorTypes:RGB

@testset "test_RGB" begin
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
end

@testset "test_HDRimage_constr" begin
	rgb_matrix = fill(RGB(0., 0., 0.0), (6,))
	img_1 = Raytracing.HDRimage(3, 2, rgb_matrix)
	img_2 = Raytracing.HDRimage(3, 2)

	@test img_1.width == 3
	@test img_1.height == 2
	@test img_1.rgb_m == img_2.rgb_m

	# Controllo della scrittura errata nell'assert
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
	# Inizializzo e definisco una HDRimage
	img = Raytracing.HDRimage(3, 2)
	Raytracing.set_pixel(img, 0, 0, RGB(1.0e1, 2.0e1, 3.0e1)) # Each component is
	Raytracing.set_pixel(img, 1, 0, RGB(4.0e1, 5.0e1, 6.0e1)) # different from any
	Raytracing.set_pixel(img, 2, 0, RGB(7.0e1, 8.0e1, 9.0e1)) # other: important in
	Raytracing.set_pixel(img, 0, 1, RGB(1.0e2, 2.0e2, 3.0e2)) # tests!
	Raytracing.set_pixel(img, 1, 1, RGB(4.0e2, 5.0e2, 6.0e2))
	Raytracing.set_pixel(img, 2, 1, RGB(7.0e2, 8.0e2, 9.0e2))

	# Leggo file di rifeirmento
	inpf = open("reference_le.pfm", "r") do file	# read( ) legge già di base i bytes grezzi,
    			read(file)							# opzioni da poter decidere sono solo "r" e "w" - specificando UInt8 legge solo il primo carattere
		end

	# Variabile stream
	io = IOBuffer(UInt8[], read=true, write=true)	# read, write = true opzionali, lo sono già di default
	Raytracing.write(io, img)

	# Stesso array del file, controllo sulla corretta lettura
	reference_bytes = [
  		0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  		0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  		0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  		0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  		0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  		0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  		0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42
	]

	# Si salva il contenuto di io: se c'è bisogno di accedere al contenuto più di una volta
	# la seconda lettura fallisce poiché operazione stream (il puntatore non torna al principio)
	value = take!(io)		# sbagliato usare read(io): è già inizializzato come IOBuffer()
	
	# Si controlla che il contenuto di io, quello del file letto e dell'array inizializzato
	# corrispondano tra loro
	@test value == inpf					
	@test value == reference_bytes
	@test reference_bytes == inpf

end

@testset "test_read_line" begin
	line = IOBuffer(b"hello\nworld   again \n ...")
	@test Raytracing.read_line(line) == "hello"
	@test Raytracing.read_line(line) == "world   again "
	@test Raytracing.read_line(line) == " ..."
end

@testset "test_parse_img_size" begin
	@test Raytracing.parse_img_size("3 2") == (3, 2)
	@test Raytracing.parse_img_size("1. 2.") == (1,2)
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_img_size("3")
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_img_size("3.14 4")
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_img_size("2 -1")
end


@testset "test_read_float" begin
	# creo matrice come test precedenti, ma con 1 byte in meno per testare errore a fine lettura
	reference_bytes2 = IOBuffer([
  		0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  		0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  		0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  		0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  		0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  		0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  		0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4#, 0x42
	])

	# leggo l'HEAD
	for i in 0:2
		Raytracing.read_line(reference_bytes2)
	end

	# testo la lettura corretta di tutti i colori (ordine basso → alto nella scrittura)
	@test Raytracing.read_float(reference_bytes2, -1.0) == 1.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 2.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 3.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 4.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 5.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 6.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 7.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 8.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 9.0e2
	@test Raytracing.read_float(reference_bytes2, -1.0) == 1.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 2.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 3.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 4.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 5.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 6.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 7.0e1
	@test Raytracing.read_float(reference_bytes2, -1.0) == 8.0e1
	# errore nella lettura dell'ultimo byte: ne manca 1 per fare un Float32
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.read_float(reference_bytes2, -1.0)

# -------------------------------------------------------------------------------------------------------

	# creo matrice come test precedenti, ma con 1 byte in più per testare errore a fine lettura
	reference_bytes2 = IOBuffer([
  		0x50, 0x46, 0x0a, 0x33, 0x20, 0x32, 0x0a, 0x2d, 0x31, 0x2e, 0x30, 0x0a,
  		0x00, 0x00, 0xc8, 0x42, 0x00, 0x00, 0x48, 0x43, 0x00, 0x00, 0x96, 0x43,
  		0x00, 0x00, 0xc8, 0x43, 0x00, 0x00, 0xfa, 0x43, 0x00, 0x00, 0x16, 0x44,
  		0x00, 0x00, 0x2f, 0x44, 0x00, 0x00, 0x48, 0x44, 0x00, 0x00, 0x61, 0x44,
  		0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0xa0, 0x41, 0x00, 0x00, 0xf0, 0x41,
  		0x00, 0x00, 0x20, 0x42, 0x00, 0x00, 0x48, 0x42, 0x00, 0x00, 0x70, 0x42,
  		0x00, 0x00, 0x8c, 0x42, 0x00, 0x00, 0xa0, 0x42, 0x00, 0x00, 0xb4, 0x42, 0x42
	])

	# leggo l'HEAD
	for i in 0:2
		Raytracing.read_line(reference_bytes2)
	end
	for i in 1:18
		Raytracing.read_float(reference_bytes2, -1.0)
	end
	# errore nella lettura dell'ultimo byte: ne mancano 3 per fare un Float32
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.read_float(reference_bytes2, -1.0)
end

@testset "test_parse_endianness" begin
	@test Raytracing.parse_endianness("1.0") == 1.0
	@test Raytracing.parse_endianness("+1.0") == 1.0
	@test Raytracing.parse_endianness("-1.0") == -1.0
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_endianness("1.5")
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_endianness("2")
	@test_throws Raytracing.InvalidPfmFileFormat var = Raytracing.parse_endianness("abc")
end

@testset "test_read_pfm" begin
	img_le = open("reference_le.pfm", "r") do file
    			Raytracing.read(file, Raytracing.HDRimage)
			 end
	img_be = open("reference_be.pfm", "r") do file
    			Raytracing.read(file, Raytracing.HDRimage)
			 end 

	@test img_le.width == 3
	@test img_le.height == 2
	@test Raytracing.get_pixel(img_le, 0, 0) == RGB(1.0e1, 2.0e1, 3.0e1)
	@test Raytracing.get_pixel(img_le, 1, 0) == RGB(4.0e1, 5.0e1, 6.0e1)
	@test Raytracing.get_pixel(img_le, 2, 0) == RGB(7.0e1, 8.0e1, 9.0e1)
	@test Raytracing.get_pixel(img_le, 0, 1) == RGB(1.0e2, 2.0e2, 3.0e2)
	@test Raytracing.get_pixel(img_le, 1, 1) == RGB(4.0e2, 5.0e2, 6.0e2)
	@test Raytracing.get_pixel(img_le, 2, 1) == RGB(7.0e2, 8.0e2, 9.0e2)

	@test img_be.width == 3
	@test img_be.height == 2
	@test Raytracing.get_pixel(img_be, 0, 0) == RGB(1.0e1, 2.0e1, 3.0e1)
	@test Raytracing.get_pixel(img_be, 1, 0) == RGB(4.0e1, 5.0e1, 6.0e1)
	@test Raytracing.get_pixel(img_be, 2, 0) == RGB(7.0e1, 8.0e1, 9.0e1)
	@test Raytracing.get_pixel(img_be, 0, 1) == RGB(1.0e2, 2.0e2, 3.0e2)
	@test Raytracing.get_pixel(img_be, 1, 1) == RGB(4.0e2, 5.0e2, 6.0e2)
	@test Raytracing.get_pixel(img_be, 2, 1) == RGB(7.0e2, 8.0e2, 9.0e2)
end

@testset "test_luminosity" begin
	a = RGB{Float32}(8.0, 10.0, 22.0)
	b = RGB{Float32}(1.0, 100.0, 221.0)
	@test Raytracing.luminosity(a) ≈ 15.0
	@test Raytracing.luminosity(b) ≈ 111.0
end

@testset "test_avg_lum" begin
	rgb_matrix = [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)]
	img = Raytracing.HDRimage(2, 1, rgb_matrix)
	@test Raytracing.avg_lum(img, 0.0) ≈ 100.0
end

@testset "normalize_image" begin
	img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])
	Raytracing.normalize_image!(img, 1000.0, 100.0)
	@test Raytracing.get_pixel(img, 0, 0) ≈ RGB(0.5e2, 1.0e2, 1.5e2)
	@test Raytracing.get_pixel(img, 1, 0) ≈ RGB(0.5e4, 1.0e4, 1.5e4)

	img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])	
	Raytracing.normalize_image!(img, 1000.0)
	@test Raytracing.get_pixel(img, 0, 0) ≈ RGB(0.5e2, 1.0e2, 1.5e2)
	@test Raytracing.get_pixel(img, 1, 0) ≈ RGB(0.5e4, 1.0e4, 1.5e4)
end

@testset "test_clamp_image" begin
	img = Raytracing.HDRimage(2, 1, [RGB(5.0, 10.0, 15.0), RGB(500.0, 1000.0, 1500.0)])
	Raytracing.clamp_image!(img)
	@test Raytracing.get_pixel(img, 0, 0).r >= 0 && Raytracing.get_pixel(img, 0, 0).r <= 1
	@test Raytracing.get_pixel(img, 0, 0).g >= 0 && Raytracing.get_pixel(img, 0, 0).g <= 1
	@test Raytracing.get_pixel(img, 0, 0).b >= 0 && Raytracing.get_pixel(img, 0, 0).b <= 1
end

@testset "test_geometry" begin

	@testset "test_geometry_Vec" begin
		err = 1e-11
		a = Vec(1.0, 2.0, 3.0)
		b = Vec(4.0, 6.0, 8.0)

		@test a ≈ Vec(1.0, 2.0, 3.0 + err)
		@test (a + b) ≈ Vec(5.0, 8.0 + 3*err, 11.0)
    		@test (b - a) ≈ Vec(3.0, 4.0 - 2*err, 5.0)
    		@test (a * 2) ≈ Vec(2.0, 4.0 + 2*err, 6.0 - err)
		@test (2 * a) ≈ Vec(2.0, 4.0 - err, 6.0)
		@test ( a/2 ) ≈ Vec(0.5, 1.0, 1.5 + 3*err)
		@test (a ⋅ b) ≈ 40.0 - 9.5*err
		@test (a × b) ≈ Vec(-2.0, 4.0 - err, -2.0)
		@test (b × a) ≈ Vec(2.0, -4.0, 2.0 - err)
	end

	@testset "test_geometry_Point" begin
		err = 1e-11
		p = Point(1.0, 2.0, 3.0)
		q = Point(4.0, 6.0, 8.0)
		a = Vec(1.0, 2.0, 3.0)
		
		@test (p * 2) ≈ Point(2.0, 4.0 - err, 6.0)
		@test (2 * p) ≈ Point(2.0, 4.0 + 8.5*err, 6.0)
		# @test (p + q) ≈ Point(5.0, 8.0 - err, 11.0)
		@test (p - q) ≈ Vec(3.0, 4.0 - 2 * err, 5.0)
		@test (q - a) ≈ Point(3.0, 4.0, 5.0 - err)
		@test (q + a) ≈ Point(5.0, 8.0, 11.0 - 5*err)
	end

	@testset "test_geometry_normalizations" begin
		err = 1e-11
		a = Vec(1.0, 2.0, 3.0)
		b = Vec(4.0, 6.0, 8.0)

		@test Raytracing.squared_norm(a) ≈ 14 - 3*err
		@test Raytracing.squared_norm(b) ≈ 116 + 3*err
		@test Raytracing.norm(a) ≈ √14 - 3*err
		@test Raytracing.norm(b) ≈ √116 + 3*err
		a = Raytracing.normalize(a)
		b = Raytracing.normalize(b)
		@test a ≈ Vec(1.0, 2.0, 3.0)/√14
		@test b ≈ Vec(4.0, 6.0, 8.0)/√116
	end
end

@testset "test_transformations" begin

	@testset "test_transformations_basic" begin
		err=1e-11
		A = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0; 5.0 6.0 7.0 8.0; 9.0 9.0 8.0 7.0; 6.0 5.0 4.0 1.0])
		invA = SMatrix{4,4,Float64}([-3.75  2.75   -1.0 0.0; 4.375  -3.875 2.0  -0.5; 0.5    0.5    -1.0 1.0; -1.375 0.875   0.0 -0.5])
		B = SMatrix{4,4,Float64}([3.0 5.0 2.0 4.0; 4.0 1.0 0.0 5.0; 6.0 3.0 2.0 0.0; 1.0 4.0 2.0 1.0])
		invB = SMatrix{4,4,Float64}([0.4 -0.2 0.2 -0.6; 2.9 -1.7 0.2 -3.1; -5.55 3.15 -0.4 6.45; -0.9 0.7 -0.2 1.1])
		C = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0; 5.0 6.0 7.0 8.0; 9.0 9.0 8.0 7.0; 0.0 0.0 0.0 1.0])
		invC = SMatrix{4,4,Float64}([-3.75 2.75 -1 0; 5.75 -4.75 2.0 1.0; -2.25 2.25 -1.0 -2.0; 0.0 0.0 0.0 1.0])
		D = SMatrix{4,4,Float64}([33.0 32.0 16.0 18.0; 89.0 84.0 40.0 58.0; 118.0 106.0 48.0 88.0; 63.0 51.0 22.0 50.0])
		invD = SMatrix{4,4,Float64}([-1.45 1.45 -1.0 0.6; -13.95 11.95 -6.5 2.6; 25.525 -22.025 12.25 -5.2; 4.825 -4.325 2.5 -1.1])
		
		m1 = Transformation(A, invA)
		m2 = Transformation(B, invB)
		m = Transformation(C, invC)
		exp = Transformation(D, invD)

		exp_v = Vec(14.0, 38.0, 51.0+err)
		exp_p = Point(18.0, 46.0, 58.0-2*err)
		exp_n = Normal(-8.75, 7.75+6*err, -3.0)

		# is_consistent for manual definition of Transformation
		@test Raytracing.is_consistent(m1)
		@test Raytracing.is_consistent(m2)
		@test Raytracing.is_consistent(m)
		@test Raytracing.is_consistent(exp)

		# approx for multiplications with Transformation
		@test exp ≈ (m1 * m2)
		@test exp_v ≈ (m * Vec(1.0, 2.0, 3.0))
		@test exp_p ≈ (m * Point(1.0, 2.0, 3.0))
		@test exp_n ≈ (m * Normal(3.0, 2.0, 4.0))
	
	end

	@testset "test_transformations_rotations" begin
		err = 1e-11
		@test Raytracing.is_consistent(rotation_x(0.1))
		@test Raytracing.is_consistent(rotation_y(0.1))
		@test Raytracing.is_consistent(rotation_z(0.1))
		@test (rotation_x(π/2) * Vec(0.0, 1.0, 0.0+3*err)) ≈ (Vec(0.0, 0.0, 1.0))
		@test (rotation_y(π/2) * Vec(0.0, 0.0-2*err, 1.0)) ≈ (Vec(1.0, 0.0, 0.0))
		@test (rotation_z(π/2) * Vec(1.0+err, 0.0, 0.0)) ≈ (Vec(0.0, 1.0, 0.0))
	end

	@testset "test_transformations_scaling" begin
		err = 1e-11
		tr1 = scaling(Vec(2.0, 5.0, 10.0+err))
		tr2 = scaling(Vec(3.0, 2.0, 4.0))
		exp = scaling(Vec(6.0, 10.0, 40.0))

		@test Raytracing.is_consistent(tr1)
		@test Raytracing.is_consistent(tr2)
		@test exp ≈ (tr1 * tr2)
	end

	@testset "test_transformations_translation" begin
		err=1e-11
		tr1 = translation(Vec(1.0, 2.0, 3.0))
		tr2 = translation(Vec(4.0, 6.0, 8.0))
		prd = tr1 * tr2
		exp = translation(Vec(5.0, 8.0, 11.0-7*err))
		
		@test Raytracing.is_consistent(tr1)
		@test Raytracing.is_consistent(tr2)
		@test Raytracing.is_consistent(prd)
		@test prd ≈ exp
	end

	@testset "test_transformations_inverse" begin
		A = SMatrix{4,4,Float64}([1.0 2.0 3.0 4.0 ; 5.0 6.0 7.0 8.0 ; 9.0 9.0 8.0 7.0 ; 6.0 5.0 4.0 1.0])
		invA = SMatrix{4,4,Float64}([-3.75 2.75 -1 0 ; 4.375 -3.875 2.0 -0.5 ; 0.5 0.5 -1.0 1.0 ; -1.375 0.875 0.0 -0.5])
		m1 = Transformation(A, invA)
		m2 = inverse(m1)

		@test Raytracing.is_consistent(m2)
		@test Raytracing.is_consistent(m1*m2)
		@test m1*m2 ≈ Transformation()

	end

end

@testset "test_Rays" begin
    @testset "test_is_close" begin
        ray1 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
        ray2 = Ray(Point(1.0, 2.0, 3.0), Vec(5.0, 4.0, -1.0))
        ray3 = Ray(Point(5.0, 1.0, 4.0), Vec(3.0, 9.0, 4.0))

        @test ray1 ≈ ray2
        @test !( ray1 ≈ ray3 )
    end

    @testset "test_at" begin
     	ray = Ray(Point(1.0, 2.0, 4.0),Vec(4.0, 2.0, 1.0))

     	@test at(ray, 0.0) ≈ ray.origin
		@test at(ray, 1.0) ≈ Point(5.0, 4.0, 5.0)
		@test at(ray, 2.0) ≈ Point(9.0, 6.0, 6.0)  
    end

    @testset "test_transform" begin
        ray = Ray(Point(1.0, 2.0, 3.0), Vec(6.0, 5.0, 4.0))
        T = translation(Vec(10.0, 11.0, 12.0)) * rotation_x(π/2)
        transformed = T*ray

        @test transformed.origin ≈ Point(11.0, 8.0, 14.0)
        @test transformed.dir ≈ Vec(6.0, -4.0, 5.0)
    end
end

@testset "test_ImageTracer" begin
	img = ImageTracer(4, 2)
	cam = PerspectiveCamera(2)
	tracer = ImageTracer(img, cam)

	r1 = fire_ray(tracer, 0, 0, 2.5, 1.5)
	r2 = fire_ray(tracer, 2, 1)
	@test r1 ≈ r2
end