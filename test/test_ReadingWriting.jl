# -*- encoding: utf-8 -*-
#
# The MIT License (MIT)
#
# Copyright © 2021 Matteo Foglieni and Riccardo Gervasoni
#




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