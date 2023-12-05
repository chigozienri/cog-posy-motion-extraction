# Prediction interface for Cog ⚙️
# https://github.com/replicate/cog/blob/main/docs/python.md

import os
import shutil
import subprocess
import tempfile

from cog import BasePredictor, Input, Path


class Predictor(BasePredictor):
    def setup(self) -> None:
        """Load the model into memory to make running multiple predictions efficient"""
        pass

    def predict(
        self,
        input_video: Path = Input(description="Input video"),
        frames_offset: int = Input(
            description="Frames to offset video by for motion extraction. Don't see any motion? Try increasing the number of frames.",
            default=2,
        ),
        color_delay_mode: bool = Input(
            description="Enable color delay mode. Will ignore frames_offset, and use red_offset, green_offset, and blue_offset instead",
            default=False,
        ),
        red_offset: int = Input(
            description="Number of frames to delay red channel", default=0
        ),
        green_offset: int = Input(
            description="Number of frames to delay green channel", default=5
        ),
        blue_offset: int = Input(
            description="Number of frames to delay blue channel", default=10
        ),
    ) -> Path:
        """Run a single prediction on the model"""
        # Remove for safety
        temp_dir = tempfile.mkdtemp()
        in_path = os.path.join(temp_dir, os.path.basename(input_video))
        extension = os.path.splitext(input_video)[1]
        if extension == "":
            extension = ".mp4"
        out_filename = "output" + extension
        out_path = os.path.join(temp_dir, out_filename)
        shutil.copyfile(input_video, in_path)
        if color_delay_mode:
            subprocess.run(
                [
                    "./colordelay.sh",
                    in_path,
                    str(red_offset),
                    str(green_offset),
                    str(blue_offset),
                    out_path,
                ]
            )
        else:
            subprocess.run(
                ["./motionextractor.sh", in_path, str(frames_offset), out_path]
            )
        # Remove for safety
        if os.path.exists(out_filename):
            os.remove(out_filename)
        return Path(out_path)
