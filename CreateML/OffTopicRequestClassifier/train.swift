#!/usr/bin/env swift
//
//  train.swift
//  Kurozora CreateML — OffTopicRequestClassifier
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//
//  Developer tool
//  Trains a Core ML text classifier that flags posts asking for external
//  streaming or reading sources — the "where can I watch this?" pattern that
//  is off-topic for a tracker-only app.
//
//  Multilingual: uses Transfer Learning over Apple's BERT-multilingual
//  embedding, so a single model handles every supported language without
//  per-language routing.
//
//  Usage:
//    swift train.swift
//
//  Acceptance gates (script exits non-zero if either fails):
//    - Precision ≥ 0.92 on the off_topic_source_seeking class.
//    - Recall    ≥ 0.75 on the off_topic_source_seeking class.
//
//  Requires macOS 14+ with Xcode 15+ / Create ML frameworks available.

import CreateML
import CoreML
import Foundation

// MARK: - Configuration
let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent()
let trainingDataURL = scriptDir.appendingPathComponent("training_data.json")
// CreateML/<Classifier>/ -> CreateML/ -> repo root -> Kurozora/ML Models/
let outputDir = scriptDir.deletingLastPathComponent()
	.deletingLastPathComponent()
	.appendingPathComponent("Kurozora")
	.appendingPathComponent("ML Models")
// Use the `.mlpackage` bundle format to match the existing tracked artifact.
let outputModelURL = outputDir.appendingPathComponent("OffTopicRequestClassifier.mlpackage")

let validationFraction = 0.15
let randomSeed: Int = 42
let positiveLabel = "off_topic_source_seeking"
let minPrecision = 0.92
let minRecall = 0.75

// MARK: - Load corpus
print("Loading training data from: \(trainingDataURL.path)")
let trainingData: MLDataTable
do {
	trainingData = try MLDataTable(contentsOf: trainingDataURL)
} catch {
	fatalError("Failed to load corpus: \(error)")
}
print("Loaded \(trainingData.rows.count) rows.")

// MARK: - Stratified split
let (trainTable, validationTable) = trainingData.randomSplit(by: 1.0 - validationFraction, seed: randomSeed)
print("Train rows: \(trainTable.rows.count), validation rows: \(validationTable.rows.count)")

// MARK: - Train
let parameters = MLTextClassifier.ModelParameters(
	validation: .table(validationTable, textColumn: "text", labelColumn: "label"),
	algorithm: .transferLearning(.bertEmbedding, revision: nil)
)

print("Training with Transfer Learning (BERT-multilingual)...")
let classifier: MLTextClassifier
do {
	classifier = try MLTextClassifier(
		trainingData: trainTable,
		textColumn: "text",
		labelColumn: "label",
		parameters: parameters
	)
} catch {
	fatalError("Training failed: \(error)")
}

// MARK: - Evaluation
print("\n=== Training metrics ===")
print("Training accuracy:   \((1.0 - classifier.trainingMetrics.classificationError) * 100.0)%")
print("Validation accuracy: \((1.0 - classifier.validationMetrics.classificationError) * 100.0)%")

let evaluation = classifier.evaluation(on: validationTable, textColumn: "text", labelColumn: "label")
print("\n=== Held-out evaluation ===")
print("Confusion matrix:\n\(evaluation.confusion)")
print("Precision/Recall table:\n\(evaluation.precisionRecall)")

// MARK: - Acceptance gate
let prTable = evaluation.precisionRecall
var positivePrecision: Double = .nan
var positiveRecall: Double = .nan

for row in prTable.rows {
	guard let label = row["class"]?.stringValue, label == positiveLabel else { continue }
	if let precision = row["precision"]?.doubleValue { positivePrecision = precision }
	if let recall = row["recall"]?.doubleValue { positiveRecall = recall }
}

print("\n=== Positive-class gates (\(positiveLabel)) ===")
print("Precision: \(positivePrecision) (required ≥ \(minPrecision))")
print("Recall:    \(positiveRecall) (required ≥ \(minRecall))")

let precisionPass = positivePrecision >= minPrecision
let recallPass = positiveRecall >= minRecall
if !precisionPass || !recallPass {
	print("\n⚠️  Acceptance gate NOT met. Model written for inspection but is not shippable.")
	print("   Iterate the corpus (more negatives if precision is low, more positives if recall is low) and retrain.")
} else {
	print("\n✅ Acceptance gate met.")
}

// MARK: - Export
let metadata = MLModelMetadata(
	author: "Khoren Katklian",
	shortDescription: "Detects whether text reads as a 'where to watch/read' request that is off-topic for a media-tracking app. Multilingual.",
	version: "1.0"
)

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
try classifier.write(to: outputModelURL, metadata: metadata)
print("\nModel exported to: \(outputModelURL.path)")

if !precisionPass || !recallPass {
	exit(1)
}
