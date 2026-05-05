#!/usr/bin/env python3
"""Download and convert the deepghs/anime_face_detection v1.4_s YOLOv8 ONNX model to Core ML.

Run from the repository root or this directory:

    python3 convert.py

The output `.mlpackage` is written to `Kurozora/ML Models/AnimeFaceDetector.mlpackage` so the next Xcode build picks it up via the synchronized file group.

Author: Khoren Katklian
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import coremltools as ct
    from huggingface_hub import hf_hub_download
except ImportError as error:
    sys.stderr.write(
        f"Missing dependency: {error.name}.\n"
        "Install with: pip3 install --upgrade coremltools onnx huggingface_hub\n"
    )
    sys.exit(1)


MODEL_REPO = "deepghs/anime_face_detection"
MODEL_REVISION = "main"
MODEL_FILE = "face_detect_v1.4_s/model.onnx"
MODEL_IDENTIFIER = "deepghs-anime-v1.4-s"
INPUT_SIZE = 640


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def output_path() -> Path:
    return repo_root() / "Kurozora" / "ML Models" / "AnimeFaceDetector.mlpackage"


def download_onnx() -> Path:
    return Path(
        hf_hub_download(
            repo_id=MODEL_REPO,
            filename=MODEL_FILE,
            revision=MODEL_REVISION,
        )
    )


def convert(onnx_path: Path) -> ct.models.MLModel:
    model = ct.converters.onnx.convert(
        model=str(onnx_path),
        minimum_ios_deployment_target="15",
    )

    model.short_description = (
        f"YOLOv8-small anime face detector ({MODEL_IDENTIFIER}). "
        f"Input: {INPUT_SIZE}x{INPUT_SIZE} RGB. Output: [1, 5, N] tensor "
        "with per-anchor [cx, cy, w, h, confidence] in input pixel space."
    )
    model.author = "deepghs (upstream); Khoren Katklian (Core ML wrapper)"
    model.license = "MIT"
    model.version = MODEL_IDENTIFIER

    return model


def main() -> int:
    destination = output_path()
    destination.parent.mkdir(parents=True, exist_ok=True)

    print(f"Downloading {MODEL_FILE} from {MODEL_REPO}@{MODEL_REVISION}...")
    onnx_path = download_onnx()
    print(f"  -> {onnx_path}")

    print("Converting ONNX to Core ML...")
    model = convert(onnx_path)

    print(f"Writing {destination}")
    model.save(str(destination))

    print("Done.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
