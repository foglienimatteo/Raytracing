#!/usr/bin/env julia

include("main")

using Printf

width = 50 # default: 640
height = 30 # default: 480
for angle in 0:359
    angleNNN = @sprintf "%03d" angle
    println(angle)
    #main(["demo", "--per", "--width=640", "--height=480", "--alpha=$angle", "--set-png-name=\"animazione/image$(angleNNN).png\""])
    demo(false, 1. *angle, width, height, "demo.pfm","animazione/image$(angleNNN).png" )
end


# -r 25: Number of frames per second
run(`ffmpeg -r 25 -f image2 -s $(width)x$(height) -i animazione/image%03d.png -vcodec libx264 -pix_fmt yuv420p spheres-perspective.mp4`)

#=

for angle in $(seq 0 359); do
    angleNNN=$(printf "%03d" $angle)
    ./main demo --per --width=640 --height=480 --alpha=$angle --set-png-name="animazione/image${angleNNN}.png"
done

# -r 25: Number of frames per second
ffmpeg -r 25 -f image2 -s 50x30 -i animazione/image%03d.png \
    -vcodec libx264 -pix_fmt yuv420p \
    spheres-perspective.mp4
=#