# OffTopicRequestClassifier

A Core ML text classifier that detects when a post is asking *where to watch* or *where to read* anime/manga — a recurring off-topic pattern in apps that track media without hosting it.

The classifier is multilingual: a single model handles English, Spanish, Portuguese, Indonesian, French, and German via Apple's BERT-multilingual feature extractor. All inference runs on-device.

## What it produces

A binary text classifier (`OffTopicRequestClassifier.mlpackage`) with two labels:

- **`off_topic_source_seeking`** — posts asking for streaming or reading sources, e.g. *"where can I watch Bleach?"*, *"any site to read manga?"*, *"link to stream the new season?"*.
- **`other`** — everything else: reviews, discussion, past-tense statements, anticipation, app bug reports, recommendations.

The Kurozora app loads the model at runtime and uses its predictions as a soft pre-submission warning. People can still post; the warning just nudges them to consider whether the question fits the venue.

## Requirements

- macOS 14 or later
- Xcode 15 or later (for `CreateML` with BERT-multilingual transfer learning)
- Swift 5.9 or later

## How to train

```bash
cd CreateML/OffTopicRequestClassifier
swift train.swift
```

The script:

1. Loads `training_data.json`.
2. Performs a stratified 85/15 train-validation split with a fixed random seed.
3. Trains a Core ML text classifier using Transfer Learning over Apple's multilingual BERT embedding.
4. Prints metrics and evaluates against the held-out split.
5. Writes the model into `Kurozora/ML Models/OffTopicRequestClassifier.mlpackage` so the next Xcode build picks it up.

## Acceptance gates

The script enforces minimum quality before declaring a model shippable:

- **Precision ≥ 0.92** on the positive class — guards against over-flagging legitimate posts.
- **Recall ≥ 0.75** on the positive class — catches at least three quarters of true off-topic posts.

If either gate fails, the script exits with a non-zero status and prints which gate missed. The model file is still written for inspection, but should not ship as-is. Diagnosing:

- **Low precision** -> too many false positives. Add more **negative** examples that resemble what's being mis-flagged. The confusion matrix shows which phrasings are tripping the model up.
- **Low recall** -> too many missed positives. Add more **positive** examples, especially phrasings that aren't yet represented.

## Training data

`training_data.json` is a single JSON array. Each entry:

```json
{ "text": "where can I watch Bleach?", "label": "off_topic_source_seeking" }
```

Current size:

| Label | Count |
|---|---|
| `off_topic_source_seeking` | 428 |
| `other` | 1,294 |

The negative class is intentionally larger (≈ 3 : 1) because the real-world distribution is roughly 5 % off-topic. Oversampling positives would push the model to over-flag.

The negative class deliberately emphasizes three categories that are easy to confuse with positives:

1. **Past-tense uses of *watched* / *read*** — *"watched this last week"*, *"read the manga already"*.
2. **Anticipation phrasings** — *"can't wait to watch the next episode"*, *"so ready to binge the finale"*.
3. **App bug reports** — *"why can't I watch in the app?"*, *"the app won't play anything"*. These are complaints about playback, not requests for external sources.

### Hardest negatives to keep around

These look structurally like positives but are legitimate. Keep a healthy bank of them so the model doesn't drift toward flagging them:

- *"why can't I watch this in the app"*
- *"the app doesn't play anything"*
- *"can I watch inside the app?"*
- *"watched this last week and loved it"*
- *"can't wait to watch the finale"*
- *"read the whole manga in two days"*

If the model starts flagging these, the answer is more of them — not a different threshold.

## Why Transfer Learning + multilingual BERT

- **One model, every supported language.** No per-language routing or detection step.
- **Pre-trained.** A few hundred labeled examples produces a working classifier; training from scratch would need orders of magnitude more.
- **Small and fast.** Tens of MB of weights, millisecond inference — fits a "user just tapped Post" hot path.

## Shipping the model

1. Train until the acceptance gates pass.
2. The trainer writes `OffTopicRequestClassifier.mlpackage` directly into `Kurozora/ML Models/`. That directory is part of an Xcode synchronized file group, so the package is picked up on the next build with no project-file edits.
3. Xcode compiles `.mlpackage` -> `.mlmodelc` at build time.
4. The app loads the compiled model by resource name at runtime.

If the model is missing from the bundle for any reason, the consuming code is designed to fail open — posts are never blocked because the classifier couldn't load.

## Files

| File | Purpose |
|---|---|
| `train.swift` | Standalone Swift CLI script. Loads training data, trains, evaluates, writes the `.mlpackage`. |
| `training_data.json` | Labeled training data. JSON array of `{ "text": ..., "label": ... }` objects. |
| `README.md` | This file. |

## Troubleshooting

- **`swift train.swift` can't find CreateML.** Ensure macOS 14+ with Xcode 15+ and that `xcode-select -p` points at a full Xcode install (not just Command Line Tools).
- **CreateML API errors.** The transfer-learning enum has shifted across Xcode versions. The concept (BERT-multilingual transfer learning) is the same — only the spelling of the case may need adjusting.
- **One language consistently underperforms.** Add ≈ 30 more positive examples in that language and retrain. Lowering the consumer's confidence threshold is a last resort and trades precision away.

## Contributing

Pull requests adding training examples, language coverage, or test phrasings are welcome.

When adding examples to `training_data.json`:

- **Valid JSON.** Single array, no trailing commas — the parser is strict.
- **Append, don't reorder.** Adding rows at the end keeps the train/validation split stable across runs (the seed is fixed).
- **Keep the class balance.** Roughly three negatives for every positive. Adding 50 positives? Add ≈ 150 negatives alongside.
- **Spread positives across languages.** A corpus that's 80 % English positives produces a model that's worse at the other languages.
- **Keep native casing and diacritics.** BERT embeddings need unaltered input — don't lowercase or strip accents.
- **Write your own examples.** Don't paste posts copied from real users on any platform. Generic phrasings you've composed yourself, or phrasings paraphrased through a separate language model and reviewed, are the goal.

If you find a phrasing that's clearly off-topic but slips past the deployed model — or one that's clearly fine but gets flagged — opening an issue with the specific text is one of the most useful contributions possible.

## License

See the repository [LICENSE](LICENSE).
