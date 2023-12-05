# Prediction interface for Cog ⚙️
# https://github.com/replicate/cog/blob/main/docs/python.md

from cog import BasePredictor, Input, Path
import subprocess
import shutil
import os
import tempfile


class Predictor(BasePredictor):
    def setup(self) -> None:
        """Load the model into memory to make running multiple predictions efficient"""
        pass

    def predict(
        self,
        input_video: Path = Input(description="Input video"),
        frames_offset: int = Input(
            description="Frames to offset video by for motion extraction. Don't see any motion? Try increasing the number of frames.", default=2
        ),
    ) -> Path:
        """Run a single prediction on the model"""
        # Remove for safety
        temp_dir = tempfile.mkdtemp()
        in_path = os.path.join(temp_dir, os.path.basename(input_video))
        extension = os.path.splitext(input_video)[1]
        if extension == "":
            extension = "mp4"
        out_filename = "output" + extension
        out_path = os.path.join(temp_dir, out_filename)
        shutil.copyfile(input_video, in_path)
        subprocess.run(["./motionextractor.sh", in_path, str(frames_offset), out_path])
        # Remove for safety
        if os.path.exists(out_filename):
            os.remove(out_filename)
        return Path(out_path)
