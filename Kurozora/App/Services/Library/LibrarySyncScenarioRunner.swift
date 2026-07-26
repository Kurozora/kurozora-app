//
//  LibrarySyncScenarioRunner.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import KurozoraKit

/// A fixed, deterministic library-mutation sequence used to fingerprint sync state across two devices.
enum LibrarySyncScenarioRunner: String, CaseIterable, Sendable {
	// MARK: - Cases
	/// Favorites the first five shows, then syncs.
	case favoriteFirstFive

	/// Marks the first three shows completed, then syncs.
	case cycleStatusFirstThree

	/// Hides the first three shows, then syncs.
	case hideFirstThree

	/// Removes the first two shows, syncs, re-adds them to planning, then syncs again.
	case removeThenReAddFirstTwo

	/// Sets a reminder on the first three shows, then syncs.
	case reminderFirstThree

	// MARK: - Properties
	/// The number of deterministic targets a single-step scenario selects, at most.
	private static let defaultTargetCount = 3

	/// The scenario's display name, also used as its diagnostics label prefix.
	var name: String {
		return self.rawValue
	}

	// MARK: - Functions
	/// Runs the scenario's fixed mutation sequence against the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	func run(forUserSlug userSlug: String) async {
		switch self {
		case .favoriteFirstFive:
			await self.runFavoriteFirstFive(forUserSlug: userSlug)
		case .cycleStatusFirstThree:
			await self.runCycleStatusFirstThree(forUserSlug: userSlug)
		case .hideFirstThree:
			await self.runHideFirstThree(forUserSlug: userSlug)
		case .removeThenReAddFirstTwo:
			await self.runRemoveThenReAddFirstTwo(forUserSlug: userSlug)
		case .reminderFirstThree:
			await self.runReminderFirstThree(forUserSlug: userSlug)
		}
	}

	// MARK: - Scenarios
	private func runFavoriteFirstFive(forUserSlug userSlug: String) async {
		await self.logState(forUserSlug: userSlug, step: "baseline")

		let trackableIDs = await Self.targetTrackableIDs(forUserSlug: userSlug, count: 5)
		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueSetFavorite(true, trackableID: trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.logState(forUserSlug: userSlug, step: "after-enqueue")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync")
	}

	private func runCycleStatusFirstThree(forUserSlug userSlug: String) async {
		await self.logState(forUserSlug: userSlug, step: "baseline")

		let trackableIDs = await Self.targetTrackableIDs(forUserSlug: userSlug, count: Self.defaultTargetCount)
		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueSetStatus(.completed, trackableID: trackableID, userSlug: userSlug, kind: .shows, seed: nil)
		}
		await self.logState(forUserSlug: userSlug, step: "after-enqueue")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync")
	}

	private func runHideFirstThree(forUserSlug userSlug: String) async {
		await self.logState(forUserSlug: userSlug, step: "baseline")

		let trackableIDs = await Self.targetTrackableIDs(forUserSlug: userSlug, count: Self.defaultTargetCount)
		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueSetHidden(true, trackableID: trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.logState(forUserSlug: userSlug, step: "after-enqueue")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync")
	}

	private func runRemoveThenReAddFirstTwo(forUserSlug userSlug: String) async {
		await self.logState(forUserSlug: userSlug, step: "baseline")

		let trackableIDs = await Self.targetTrackableIDs(forUserSlug: userSlug, count: 2)
		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueRemove(trackableID: trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.logState(forUserSlug: userSlug, step: "after-remove")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync-1")

		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueSetStatus(.planning, trackableID: trackableID, userSlug: userSlug, kind: .shows, seed: nil)
		}
		await self.logState(forUserSlug: userSlug, step: "after-readd")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync-2")
	}

	private func runReminderFirstThree(forUserSlug userSlug: String) async {
		await self.logState(forUserSlug: userSlug, step: "baseline")

		let trackableIDs = await Self.targetTrackableIDs(forUserSlug: userSlug, count: Self.defaultTargetCount)
		for trackableID in trackableIDs {
			await LibraryOutbox.shared.enqueueSetReminder(true, trackableID: trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.logState(forUserSlug: userSlug, step: "after-enqueue")

		await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
		await self.logState(forUserSlug: userSlug, step: "after-sync")
	}

	// MARK: - Diagnostics
	/// Records a `"<name>-<step>"` labeled fingerprint of the local library state.
	private func logState(forUserSlug userSlug: String, step: String) async {
		await LibrarySyncDiagnostics.logState(forUserSlug: userSlug, reason: "\(self.name)-\(step)")
	}

	// MARK: - Target selection
	/// Returns up to `count` show trackable identifiers, numerically sorted ascending so both
	/// devices operate on the same titles.
	@MainActor
	private static func targetTrackableIDs(forUserSlug userSlug: String, count: Int) -> [String] {
		let entries = LibraryStore.shared.entries(forUserSlug: userSlug, kind: .shows)
		let sortedTrackableIDs = entries.map(\.trackableID).sorted { lhsTrackableID, rhsTrackableID in
			if let lhsValue = Int(lhsTrackableID), let rhsValue = Int(rhsTrackableID) {
				return lhsValue < rhsValue
			}
			return lhsTrackableID < rhsTrackableID
		}
		return Array(sortedTrackableIDs.prefix(count))
	}
}
#endif
