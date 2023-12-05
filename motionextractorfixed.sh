#!/bin/bash
# Usage: ./motionextractorfixed.sh input.mp4 1 output.mp4
# Extracts motion from a video using the method described by Posy in https://www.youtube.com/watch?v=NSS6yAMZF78
# The first argument is the path to the video to extract motion from
# The second argument is the fixed frame number to compare to to detect motion (1 is the first frame, not 0) (optional, default 1)
# The third argument is the output video (optional, default output.mp4)

input_video=$1
comparison_frame=${2:-1}
target_video=${3:-output.mp4}
temp_dir=$(mktemp -d)

# separate the input video into frames
ffmpeg -i $input_video -vcodec png $temp_dir/input_%06d.png
# create a video with the same frames but with half opacity and inverted colors
ffmpeg -i $input_video -vf "negate,format=rgba,colorchannelmixer=aa=0.5" -vcodec png $temp_dir/inverted_halfopacity_%06d.png
# overlay the inverted half opacity video on top of the fixed frame
ffmpeg -i $temp_dir/input_$(printf "%06d" $comparison_frame).png -i $temp_dir/inverted_halfopacity_%06d.png -i $input_video -filter_complex "[0:v][1:v] overlay=0:0" -c:v libx264 -preset ultrafast -c:a copy $target_video
