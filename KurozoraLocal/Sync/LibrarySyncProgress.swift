//
//  LibrarySyncProgress.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

/// Publishes library sync progress for UI observers.
@MainActor
final class LibrarySyncProgress {
	// MARK: - Types
	/// The progress of a single sync round.
	struct RoundProgress {
		/// The number of rows applied so far in the round.
		var appliedCount: Int

		/// The number of rows the round is expected to apply.
		var expectedCount: Int?
	}

	// MARK: - Properties
	/// Returns the singleton `LibrarySyncProgress` instance.
	static let shared = LibrarySyncProgress()

	/// The in-flight sync round.
	private(set) var activeRound: RoundProgress?

	/// The import's progress.
	private(set) var importProgress: RoundProgress?

	/// The work in flight.
	private var activeWork: [RoundProgress] {
		return [self.activeRound, self.importProgress].compactMap(\.self)
	}

	/// Whether any work is in flight.
	var isSyncing: Bool {
		return !self.activeWork.isEmpty
	}

	/// The number of rows applied across all in-flight work.
	var appliedCount: Int {
		return self.activeWork.reduce(0) { $0 + $1.appliedCount }
	}

	/// The number of rows expected across all in-flight work.
	var expectedCount: Int? {
		let expectedCounts = self.activeWork.compactMap(\.expectedCount)
		guard !expectedCounts.isEmpty else { return nil }
		return expectedCounts.reduce(0, +)
	}

	/// The completed fraction across all in-flight rounds, or `nil` when unknown.
	var fractionCompleted: Double? {
		guard let expectedCount = self.expectedCount, expectedCount > 0 else { return nil }
		return min(1.0, Double(self.appliedCount) / Double(expectedCount))
	}

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Marks the start of a sync round.
	func begin() {
		self.activeRound = RoundProgress(appliedCount: 0, expectedCount: nil)
		self.notify()
	}

	/// Records progress for the in-flight round.
	func update(appliedCount: Int, expectedCount: Int?) {
		self.activeRound = RoundProgress(appliedCount: appliedCount, expectedCount: expectedCount)
		self.notify()
	}

	/// Marks the end of the sync round.
	func end() {
		self.activeRound = nil
		self.notify()
	}

	/// Records the import's progress.
	func updateImport(processedCount: Int, totalCount: Int) {
		self.importProgress = RoundProgress(appliedCount: processedCount, expectedCount: totalCount)
		self.notify()
	}

	/// Marks the import as finished.
	func endImport() {
		guard self.importProgress != nil else { return }
		self.importProgress = nil
		self.notify()
	}

	private func notify() {
		NotificationCenter.default.post(name: .KLibrarySyncProgressDidChange, object: nil)
	}
}
