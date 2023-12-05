#!/bin/bash
# Usage: ./colordelay.sh input.mp4 2 output.mp4
# Delays the red, green and blue channels of a video by a specified number of frames
# The first argument is the path to the video to extract motion from
# The second, third and fourth arguments are the number of frames to delay the red, green and blue channels respectively (optional, defaults 0, 2, 4)
# The fifth argument is the output video (optional, default output.mp4)

input_video=$1
red_frames_offset=${2:-2}
green_frames_offset=${3:-2}
blue_frames_offset=${4:-2}
target_video=${5:-output.mp4}

temp_dir=$(mktemp -d)
# make grayscale
ffmpeg -i $input_video -vf "format=gray" $temp_dir/grayscale.mp4

# split RGB channels into 3 separate grayscale videos
ffmpeg -i $temp_dir/grayscale.mp4 -filter_complex "[0:v]format=rgb24,split=3[r][g][b];[r]extractplanes=r[red];[g]extractplanes=g[green];[b]extractplanes=b[blue]" -map "[red]" $temp_dir/red.mp4 -map "[green]" $temp_dir/green.mp4 -map "[blue]" $temp_dir/blue.mp4

ffmpeg -i $temp_dir/red.mp4 -vf trim=start_frame=$red_frames_offset,setpts=PTS-STARTPTS $temp_dir/red_shifted.mp4
ffmpeg -i $temp_dir/green.mp4 -vf trim=start_frame=$green_frames_offset,setpts=PTS-STARTPTS $temp_dir/green_shifted.mp4
ffmpeg -i $temp_dir/blue.mp4 -vf trim=start_frame=$blue_frames_offset,setpts=PTS-STARTPTS $temp_dir/blue_shifted.mp4

# merge the shifted videos into GBRP format
ffmpeg -i $temp_dir/green_shifted.mp4 -i $temp_dir/blue_shifted.mp4 -i $temp_dir/red_shifted.mp4 -filter_complex "[0:v][1:v][2:v]mergeplanes=0x001020:gbrp" $temp_dir/gbrp_video.mp4

# convert the GBRP video to RGB format
ffmpeg -i $temp_dir/gbrp_video.mp4 -i $input_video -vf "format=rgb24" -c:v libx264 -preset ultrafast -c:a copy $target_video
