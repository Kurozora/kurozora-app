//
//  LibrarySyncScenarioRunner.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import CoreData
import KurozoraKit
import os.log

private nonisolated let scenarioLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibrarySyncScenario")

enum LibrarySyncScenarioRunner: String, CaseIterable, Sendable {
	// MARK: - Cases
	/// Favorites the first five shows.
	case favoriteFirstFive

	/// Flips the reminder on the first three shows.
	case reminderFirstThree

	/// Moves the first three shows to another status.
	case cycleStatusFirstThree

	/// Flips the hidden flag on the first three shows.
	case hideFirstThree

	/// Raises the rewatch count on the first three shows.
	case rewatchFirstThree

	/// Changes the score on the first three shows.
	case rateFirstThree

	/// Removes and re-adds the first two shows.
	case removeThenReAddFirstTwo

	/// Moves the first literature and the first game to another status.
	case crossKindStatus

	/// Queues mutations offline, then reconnects.
	case offlineQueueThenReconnect

	/// Changes a show on the server, then syncs.
	case remoteChangeThenSync

	/// Syncs with an expired cursor.
	case expiredCursorRestart

	// MARK: - Types
	/// A target's fields before the scenario runs.
	private struct TargetBaseline {
		let trackableID: String
		let status: LibraryStatus
		let isFavorited: Bool
		let isReminded: Bool
		let isHidden: Bool
		let rewatchCount: Int
		let reviewScore: Double?
		let reviewText: String?

		init(_ entry: LocalLibraryEntry) {
			self.trackableID = entry.trackableID
			self.status = entry.libraryStatus
			self.isFavorited = entry.isFavorited
			self.isReminded = entry.isReminded
			self.isHidden = entry.isHidden
			self.rewatchCount = Int(entry.rewatchCount)
			self.reviewScore = entry.review?.score?.doubleValue
			self.reviewText = entry.review?.text
		}

		/// The status the scenario moves the entry to.
		var cycledStatus: LibraryStatus {
			return self.status == .completed ? .onHold : .completed
		}

		/// The score the scenario rates the entry with.
		var cycledScore: Double {
			return self.reviewScore == 4.0 ? 3.5 : 4.0
		}
	}

	/// The age of an expired cursor, in days.
	private static let expiredCursorAgeInDays = 100.0

	/// The most throttle windows a step waits out.
	private static let maximumThrottleWaits = 3

	/// The throttle wait when the server names none.
	private static let defaultThrottleInterval: TimeInterval = 60

	// MARK: - Properties
	/// The scenario's display name.
	var name: String {
		return self.rawValue
	}

	// MARK: - Functions
	/// Runs the scenario for the given account.
	///
	/// - Parameter userSlug: The user's account slug.
	///
	/// - Returns: The scenario's report.
	func run(forUserSlug userSlug: String) async -> LibrarySyncScenarioReport {
		var report = LibrarySyncScenarioReport(scenario: self.name)
		scenarioLogger.notice("SCENARIO \(self.name, privacy: .public) START")

		switch self {
		case .favoriteFirstFive:
			await self.runFavoriteFirstFive(forUserSlug: userSlug, report: &report)
		case .reminderFirstThree:
			await self.runReminderFirstThree(forUserSlug: userSlug, report: &report)
		case .cycleStatusFirstThree:
			await self.runCycleStatusFirstThree(forUserSlug: userSlug, report: &report)
		case .hideFirstThree:
			await self.runHideFirstThree(forUserSlug: userSlug, report: &report)
		case .rewatchFirstThree:
			await self.runRewatchFirstThree(forUserSlug: userSlug, report: &report)
		case .rateFirstThree:
			await self.runRateFirstThree(forUserSlug: userSlug, report: &report)
		case .removeThenReAddFirstTwo:
			await self.runRemoveThenReAddFirstTwo(forUserSlug: userSlug, report: &report)
		case .crossKindStatus:
			await self.runCrossKindStatus(forUserSlug: userSlug, report: &report)
		case .offlineQueueThenReconnect:
			await self.runOfflineQueueThenReconnect(forUserSlug: userSlug, report: &report)
		case .remoteChangeThenSync:
			await self.runRemoteChangeThenSync(forUserSlug: userSlug, report: &report)
		case .expiredCursorRestart:
			await self.runExpiredCursorRestart(forUserSlug: userSlug, report: &report)
		}

		let result = report.passed ? "PASS" : "FAIL"
		scenarioLogger.notice("SCENARIO \(self.name, privacy: .public) RESULT \(result, privacy: .public) \(report.summary, privacy: .public)")
		return report
	}

	// MARK: - Scenarios
	private func runFavoriteFirstFive(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 5, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetFavorite(!baseline.isFavorited, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-flip", kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetFavorite(!baseline.isFavorited, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-repeat", kinds: [.shows], userSlug: userSlug, report: &report)

		let keptCount = baselines.filter { baseline in
			LibraryStore.shared.entry(forTrackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)?.isFavorited == !baseline.isFavorited
		}.count
		report.record("repeat-kept-state", passed: keptCount == baselines.count, detail: "\(keptCount)/\(baselines.count) kept the requested state, fails while the server still toggles")

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runReminderFirstThree(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetReminder(!baseline.isReminded, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-flip", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runCycleStatusFirstThree(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetStatus(baseline.cycledStatus, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows, seed: nil)
		}
		await self.syncAndVerify("after-status", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runHideFirstThree(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetHidden(!baseline.isHidden, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-flip", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runRewatchFirstThree(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetRewatchCount(baseline.rewatchCount + 1, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-increment", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runRateFirstThree(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueRate(score: baseline.cycledScore, description: baseline.reviewText, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-rate", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runRemoveThenReAddFirstTwo(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 2, report: &report) else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueRemove(trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)
		}
		await self.syncAndVerify("after-remove", kinds: [.shows], userSlug: userSlug, report: &report)

		for baseline in baselines {
			await LibraryOutbox.shared.enqueueSetStatus(baseline.status, trackableID: baseline.trackableID, userSlug: userSlug, kind: .shows, seed: nil)
		}
		await self.syncAndVerify("after-readd", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runCrossKindStatus(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		for kind in [LibraryKind.literatures, LibraryKind.games] {
			let entries = LibraryStore.shared.entries(forUserSlug: userSlug, kind: kind)
			guard let baseline = Self.sortedByTrackableID(entries).first.map(TargetBaseline.init) else {
				report.record("targets-\(kind.rawValue)", passed: true, detail: "skipped, no \(kind.stringValue) in library")
				continue
			}
			await self.verifyBaseline("baseline-\(kind.rawValue)", kinds: [kind], userSlug: userSlug, report: &report)

			await LibraryOutbox.shared.enqueueSetStatus(baseline.cycledStatus, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind, seed: nil)
			await self.syncAndVerify("after-status-\(kind.rawValue)", kinds: [kind], userSlug: userSlug, report: &report)

			await self.restore([baseline], kind: kind, userSlug: userSlug)
			await self.syncAndVerify("after-restore-\(kind.rawValue)", kinds: [kind], userSlug: userSlug, report: &report)
		}
	}

	private func runOfflineQueueThenReconnect(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baselines = self.baselines(forUserSlug: userSlug, kind: .shows, count: 3, report: &report), baselines.count == 3 else {
			report.record("targets", passed: false, detail: "needs three shows in the library")
			return
		}
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		await LibraryOutbox.shared.setSimulatesOffline(true)
		await LibraryOutbox.shared.enqueueSetStatus(baselines[0].cycledStatus, trackableID: baselines[0].trackableID, userSlug: userSlug, kind: .shows, seed: nil)
		await LibraryOutbox.shared.enqueueSetFavorite(!baselines[1].isFavorited, trackableID: baselines[1].trackableID, userSlug: userSlug, kind: .shows)
		await LibraryOutbox.shared.enqueueSetHidden(!baselines[2].isHidden, trackableID: baselines[2].trackableID, userSlug: userSlug, kind: .shows)
		await LibraryOutbox.shared.flush(force: true)

		let isQueued = await LibraryOutbox.shared.hasPendingOperations(forUserSlug: userSlug, kind: .shows)
		report.record("queued-offline", passed: isQueued, detail: isQueued ? "three operations held in the outbox" : "outbox drained while offline")

		do {
			let verdict = try await LibrarySyncVerifier.verify(.shows, forUserSlug: userSlug)
			let expectedDifferenceCount = 3
			report.record("server-untouched", passed: verdict.differences.count == expectedDifferenceCount, detail: "expected \(expectedDifferenceCount) local-only differences, \(verdict.summary)")
		} catch {
			report.record("server-untouched", passed: false, detail: "verify failed: \(error.localizedDescription)")
		}

		await LibraryOutbox.shared.setSimulatesOffline(false)
		await self.syncAndVerify("after-reconnect", kinds: [.shows], userSlug: userSlug, report: &report)

		await self.restore(baselines, kind: .shows, userSlug: userSlug)
		await self.syncAndVerify("after-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runRemoteChangeThenSync(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard let baseline = self.baselines(forUserSlug: userSlug, kind: .shows, count: 1, report: &report)?.first else { return }
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)

		let itemIDs = [KurozoraItemID(baseline.trackableID)]
		do {
			_ = try await KService.updateInLibrary(.shows, itemIDs: itemIDs).hidden(!baseline.isHidden).response()
			report.record("remote-change", passed: true, detail: "hidden set to \(!baseline.isHidden) on the server directly")
		} catch {
			report.record("remote-change", passed: false, detail: Self.describe(error))
			return
		}

		await self.sync(.shows, userSlug: userSlug)
		let localIsHidden = LibraryStore.shared.entry(forTrackableID: baseline.trackableID, userSlug: userSlug, kind: .shows)?.isHidden
		report.record("delta-applied", passed: localIsHidden == !baseline.isHidden, detail: "local hidden=\(String(describing: localIsHidden))")
		await self.verify("after-remote-change", kinds: [.shows], userSlug: userSlug, report: &report)

		do {
			_ = try await KService.updateInLibrary(.shows, itemIDs: itemIDs).hidden(baseline.isHidden).response()
		} catch {
			report.record("remote-restore", passed: false, detail: Self.describe(error))
		}
		await self.sync(.shows, userSlug: userSlug)
		await self.verify("after-remote-restore", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	private func runExpiredCursorRestart(forUserSlug userSlug: String, report: inout LibrarySyncScenarioReport) async {
		await self.verifyBaseline(kinds: [.shows], userSlug: userSlug, report: &report)
		let countBefore = LibraryStore.shared.count(forUserSlug: userSlug, kind: .shows, status: .none)

		let isAged = await Self.ageCursor(forUserSlug: userSlug, kind: .shows)
		report.record("age-cursor", passed: isAged, detail: isAged ? "syncedAt pushed \(Int(Self.expiredCursorAgeInDays)) days back" : "no shows cursor to age")
		guard isAged else { return }

		await self.sync(.shows, userSlug: userSlug)

		let countAfter = LibraryStore.shared.count(forUserSlug: userSlug, kind: .shows, status: .none)
		report.record("no-wipe", passed: countAfter == countBefore, detail: "before=\(countBefore) after=\(countAfter)")
		await self.verify("after-restart", kinds: [.shows], userSlug: userSlug, report: &report)
	}

	// MARK: - Steps
	/// Syncs and verifies the given kinds.
	private func syncAndVerify(_ name: String, kinds: [LibraryKind], userSlug: String, report: inout LibrarySyncScenarioReport) async {
		await self.flushWaitingOutThrottle(userSlug: userSlug)
		for kind in kinds {
			await self.sync(kind, userSlug: userSlug)
		}
		await self.verify(name, kinds: kinds, userSlug: userSlug, report: &report)
	}

	/// Verifies the given kinds.
	///
	/// - Returns: Whether every kind passed.
	@discardableResult
	private func verify(_ name: String, kinds: [LibraryKind], userSlug: String, report: inout LibrarySyncScenarioReport) async -> Bool {
		var allPassed = true

		for kind in kinds {
			do {
				let verdict = try await self.verdict(for: kind, userSlug: userSlug)
				report.record(name, passed: verdict.passed, detail: verdict.summary)
				allPassed = allPassed && verdict.passed
			} catch {
				report.record(name, passed: false, detail: "verify failed: \(Self.describe(error))")
				allPassed = false
			}
		}

		return allPassed
	}

	/// Verifies the starting state of the given kinds.
	private func verifyBaseline(_ name: String = "baseline", kinds: [LibraryKind], userSlug: String, report: inout LibrarySyncScenarioReport) async {
		guard await !self.verify(name, kinds: kinds, userSlug: userSlug, report: &report) else { return }

		for kind in kinds {
			try? await LibrarySyncEngine.shared.reconcile(kind, forUserSlug: userSlug)
		}
		await self.verify("\(name)-healed", kinds: kinds, userSlug: userSlug, report: &report)
	}

	/// Flushes the outbox.
	private func flushWaitingOutThrottle(userSlug: String) async {
		for _ in 0 ..< Self.maximumThrottleWaits {
			await LibraryOutbox.shared.flush(force: true)

			let remaining = await LibraryOutbox.shared.throttleRemaining(forUserSlug: userSlug)
			guard remaining > 0 else { return }
			await Self.wait(remaining, reason: "outbox throttled")
		}
	}

	/// Runs the kind's delta sync, retrying once after a throttle window.
	private func sync(_ kind: LibraryKind, userSlug: String) async {
		do {
			try await LibrarySyncEngine.shared.sync(kind, forUserSlug: userSlug)
		} catch let error as APIError where error.statusCode == 429 {
			await Self.wait(Self.retryAfterInterval(from: error), reason: "sync throttled")
			try? await LibrarySyncEngine.shared.sync(kind, forUserSlug: userSlug)
		} catch {
			scenarioLogger.error("sync kind=\(kind.rawValue) failed: \(Self.describe(error), privacy: .public)")
		}
	}

	/// Verifies the kind.
	private func verdict(for kind: LibraryKind, userSlug: String) async throws -> LibrarySyncVerifier.Verdict {
		do {
			return try await LibrarySyncVerifier.verify(kind, forUserSlug: userSlug)
		} catch let error as APIError where error.statusCode == 429 {
			await Self.wait(Self.retryAfterInterval(from: error), reason: "verify throttled")
			return try await LibrarySyncVerifier.verify(kind, forUserSlug: userSlug)
		}
	}

	/// Waits out the given interval.
	private static func wait(_ interval: TimeInterval, reason: String) async {
		scenarioLogger.notice("WAIT \(reason, privacy: .public) \(Int(interval.rounded(.up)))s")
		try? await Task.sleep(nanoseconds: UInt64((interval + 1) * 1_000_000_000))
	}

	/// Reads the `Retry-After` header, falling back to the default window.
	private static func retryAfterInterval(from error: APIError) -> TimeInterval {
		guard let value = error.response?.value(forHTTPHeaderField: "Retry-After"),
		      let seconds = TimeInterval(value.trimmingCharacters(in: .whitespaces)) else {
			return Self.defaultThrottleInterval
		}
		return seconds
	}

	/// Names a failure by its HTTP status when the server answered, and by the transport error otherwise.
	private static func describe(_ error: Error) -> String {
		if let apiError = error as? APIError, let statusCode = apiError.statusCode {
			return "HTTP \(statusCode) \(apiError.message)"
		}
		return error.localizedDescription
	}

	/// Restores the targets.
	private func restore(_ baselines: [TargetBaseline], kind: LibraryKind, userSlug: String) async {
		for baseline in baselines {
			let current = LibraryStore.shared.entry(forTrackableID: baseline.trackableID, userSlug: userSlug, kind: kind)

			if current?.libraryStatus != baseline.status {
				await LibraryOutbox.shared.enqueueSetStatus(baseline.status, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind, seed: nil)
			}
			if current?.isFavorited != baseline.isFavorited {
				await LibraryOutbox.shared.enqueueSetFavorite(baseline.isFavorited, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
			}
			if current?.isReminded != baseline.isReminded {
				await LibraryOutbox.shared.enqueueSetReminder(baseline.isReminded, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
			}
			if current?.isHidden != baseline.isHidden {
				await LibraryOutbox.shared.enqueueSetHidden(baseline.isHidden, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
			}
			if current.map({ Int($0.rewatchCount) }) != baseline.rewatchCount {
				await LibraryOutbox.shared.enqueueSetRewatchCount(baseline.rewatchCount, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
			}

			let currentScore = current?.review?.score?.doubleValue
			if currentScore != baseline.reviewScore {
				if let score = baseline.reviewScore {
					await LibraryOutbox.shared.enqueueRate(score: score, description: baseline.reviewText, trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
				} else {
					await LibraryOutbox.shared.enqueueDeleteRating(trackableID: baseline.trackableID, userSlug: userSlug, kind: kind)
				}
			}
		}
	}

	// MARK: - Targets
	/// The first `count` entries of the kind.
	private func baselines(forUserSlug userSlug: String, kind: LibraryKind, count: Int, report: inout LibrarySyncScenarioReport) -> [TargetBaseline]? {
		let entries = LibraryStore.shared.entries(forUserSlug: userSlug, kind: kind)
		let baselines = Self.sortedByTrackableID(entries).prefix(count).map(TargetBaseline.init)

		guard !baselines.isEmpty else {
			report.record("targets", passed: false, detail: "no \(kind.stringValue) in library")
			return nil
		}

		report.record("targets", passed: true, detail: baselines.map(\.trackableID).joined(separator: ","))
		return Array(baselines)
	}

	/// Orders entries by trackable identifier.
	private static func sortedByTrackableID(_ entries: [LocalLibraryEntry]) -> [LocalLibraryEntry] {
		return entries.sorted { lhs, rhs in
			if let lhsValue = Int(lhs.trackableID), let rhsValue = Int(rhs.trackableID) {
				return lhsValue < rhsValue
			}
			return lhs.trackableID < rhs.trackableID
		}
	}

	/// Expires the kind's sync cursor.
	private static func ageCursor(forUserSlug userSlug: String, kind: LibraryKind) async -> Bool {
		let context = PersistenceController.shared.container.newBackgroundContext()
		context.automaticallyMergesChangesFromParent = true
		let agedSyncedAt = Date().addingTimeInterval(-Self.expiredCursorAgeInDays * 24 * 60 * 60)

		return await context.perform {
			guard let cursor = LocalSyncCursor.fetch(forUserSlug: userSlug, kind: kind, in: context), cursor.cursorUpdatedAt != nil else { return false }
			cursor.syncedAt = agedSyncedAt

			do {
				try context.save()
				return true
			} catch {
				return false
			}
		}
	}
}
#endif
