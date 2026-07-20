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
	/// The progress of a single kind's sync round.
	struct RoundProgress {
		/// The number of rows applied so far in the round.
		var appliedCount: Int

		/// The number of rows the round is expected to apply.
		var expectedCount: Int?
	}

	// MARK: - Properties
	/// Returns the singleton `LibrarySyncProgress` instance.
	static let shared = LibrarySyncProgress()

	/// The in-flight sync rounds, keyed by library kind.
	private(set) var activeRounds: [LibraryKind: RoundProgress] = [:]

	/// Whether any sync round is in flight.
	var isSyncing: Bool {
		return !self.activeRounds.isEmpty
	}

	/// The number of rows applied across all in-flight rounds.
	var appliedCount: Int {
		return self.activeRounds.values.reduce(0) { $0 + $1.appliedCount }
	}

	/// The number of rows expected across all in-flight rounds, or `nil` when unknown.
	var expectedCount: Int? {
		let expectedCounts = self.activeRounds.values.compactMap(\.expectedCount)
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
	/// Marks the start of a sync round for the given kind.
	func begin(_ kind: LibraryKind) {
		self.activeRounds[kind] = RoundProgress(appliedCount: 0, expectedCount: nil)
		self.notify()
	}

	/// Records progress for the given kind's in-flight round.
	func update(_ kind: LibraryKind, appliedCount: Int, expectedCount: Int?) {
		self.activeRounds[kind] = RoundProgress(appliedCount: appliedCount, expectedCount: expectedCount)
		self.notify()
	}

	/// Marks the end of the given kind's sync round.
	func end(_ kind: LibraryKind) {
		self.activeRounds[kind] = nil
		self.notify()
	}

	private func notify() {
		NotificationCenter.default.post(name: .KLibrarySyncProgressDidChange, object: nil)
	}
}
