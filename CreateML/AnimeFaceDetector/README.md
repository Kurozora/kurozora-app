# AnimeFaceDetector

A Core ML face detector for anime and manga faces, converted from `deepghs/anime_face_detection` (v1.4_s) on Hugging Face.

The Kurozora iOS app loads the compiled model in DEBUG builds and uses it to compute focal points for Person and Character profile images. The app batches the focal points, submits them to `kurozora-web`, and stores them on the corresponding media rows. All clients then read the focal point from the API and crop the avatar so the face stays inside the circle.

## Overview

The model takes a 640 by 640 RGB image and produces a tensor with shape `[1, 5, N]`. Each anchor channel holds `[centerX, centerY, width, height, confidence]` in the input pixel space.

`AnimeFaceDetector.swift` runs the request through `VNCoreMLModel` and forwards the output to `YOLOv8OutputDecoder`. The decoder thresholds the confidence column, applies non-maximum suppression, and returns the highest-confidence box's center as a normalized focal point.

The detector runs only in DEBUG builds. Release builds read the focal point from `Media.focalX` and `Media.focalY` on the API response, so production traffic never invokes the model. You can drop the `.mlpackage` from the Release target if you want a smaller binary.

## Requirements

To convert the model, you need:

- macOS 14 or later
- Python 3.10 or later
- `coremltools` 7.0 or later
- `onnx`
- `huggingface_hub`

Install the Python dependencies once:

```bash
pip3 install --upgrade coremltools onnx huggingface_hub
```

## Convert the model

From this directory:

```bash
python3 convert.py
```

The script downloads `face_detect_v1.4_s/model.onnx` from `deepghs/anime_face_detection`, runs it through `coremltools`, and writes the result to `Kurozora/ML Models/AnimeFaceDetector.mlpackage`. That directory is part of an Xcode synchronized file group, so the next build picks up the change without any project file edits.

## Update the bundled model

When `deepghs/anime_face_detection` publishes a newer revision:

1. Update `MODEL_REVISION` (and `MODEL_FILE` if needed) at the top of `convert.py`.
2. Run the conversion again.
3. Bump the `identifier` constant in `Kurozora/App/Services/FaceDetection/FaceDetectorRegistry.swift`. The identifier is stored alongside detection results on the server, so changing it tells the iOS client to re-detect images that were last processed by the previous model.

## Files

| File | Purpose |
| ---- | ------- |
| `convert.py` | Downloads the upstream ONNX model, converts it to Core ML, and writes the `.mlpackage`. |
| `README.md` | This document. |

## License

The upstream model is MIT licensed. See the [model card](https://huggingface.co/deepghs/anime_face_detection) for the full text. The Swift wrapper code follows the repository [LICENSE](../../LICENSE).
