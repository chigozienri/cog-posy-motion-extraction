#!/bin/bash
# Usage: ./motionextractor.sh input.mp4 2 output.mp4
# Extracts motion from a video using the method described by Posy in https://www.youtube.com/watch?v=NSS6yAMZF78
# The first argument is the path to the video to extract motion from
# The second argument is the number of frames to shift the video by to detect motion (optional, default 2)
# The third argument is the output video (optional, default output.mp4)

input_video=$1
frames_offset=${2:-2}
target_video=${3:-output.mp4}
temp_dir=$(mktemp -d)
ffmpeg -i $input_video -vcodec png $temp_dir/input_%03d.png
ffmpeg -i $input_video -vf "negate,format=rgba,colorchannelmixer=aa=0.5" -vcodec png $temp_dir/inverted_halfopacity_%03d.png
ffmpeg -i $temp_dir/input_%03d.png -start_number $frames_offset -i $temp_dir/inverted_halfopacity_%03d.png -i $input_video -filter_complex "[0:v][1:v] overlay=0:0" -c:v libx264 -preset ultrafast -c:a copy $target_video
