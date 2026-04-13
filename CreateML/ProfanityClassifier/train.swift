#!/usr/bin/env swift
//
//  train.swift
//  Kurozora CreateML — ProfanityClassifier
//
//  Created by Khoren Katklian on 14/03/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//
//  Developer tool
//  Trains a Core ML text classifier for profanity detection on short (1-3 char)
//  inputs. Uses character n-gram features (max-entropy algorithm) — appropriate
//  for the very short, often obfuscated strings this classifier sees.
//
//  Usage:
//    swift train.swift
//
//  Requires macOS 12+ with Xcode / Create ML frameworks available.

import CreateML
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
let outputModelURL = outputDir.appendingPathComponent("ProfanityClassifier.mlpackage")

// MARK: - Training
print("Loading training data from: \(trainingDataURL.path)")

let jsonData = try Data(contentsOf: trainingDataURL)
let entries = try JSONSerialization.jsonObject(with: jsonData) as! [[String: String]]

// Separate classes
let offensiveEntries = entries.filter { $0["label"] == "offensive" }
let safeEntries = entries.filter { $0["label"] == "safe" }
print("Raw counts — Offensive: \(offensiveEntries.count), Safe: \(safeEntries.count)")

// Oversample offensive class to match safe count for balanced training
var balanced = safeEntries
let repeats = min(5, max(1, safeEntries.count / max(1, offensiveEntries.count)))
for _ in 0..<repeats {
	balanced.append(contentsOf: offensiveEntries)
}
print("After oversampling — Offensive: \(repeats * offensiveEntries.count), Safe: \(safeEntries.count), Total: \(balanced.count)")

// Convert back to MLDataTable
let balancedJSON = try JSONSerialization.data(withJSONObject: balanced)
let tempURL = scriptDir.appendingPathComponent("_balanced_temp.json")
try balancedJSON.write(to: tempURL)
let trainingData = try MLDataTable(contentsOf: tempURL)
try? FileManager.default.removeItem(at: tempURL)

print("Training text classifier with character n-gram features...")

let classifier = try MLTextClassifier(
	trainingData: trainingData,
	textColumn: "text",
	labelColumn: "label",
	parameters: MLTextClassifier.ModelParameters(
		algorithm: .maxEnt(revision: 1)
	)
)

// MARK: - Evaluation
let trainingMetrics = classifier.trainingMetrics
print("Training accuracy: \(trainingMetrics.classificationError)")

// MARK: - Export
let metadata = MLModelMetadata(
	author: "Khoren Katklian",
	shortDescription: "Binary text classifier for profanity detection on short monogram inputs (1-3 characters).",
	version: "1.0"
)

try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
try classifier.write(to: outputModelURL, metadata: metadata)
print("Model exported to: \(outputModelURL.path)")
