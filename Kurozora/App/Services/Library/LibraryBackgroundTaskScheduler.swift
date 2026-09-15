//
//  LibraryBackgroundTaskScheduler.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
import BackgroundTasks
import KurozoraKit
import os.log
import UIKit

private nonisolated let backgroundTaskLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LibraryBackgroundTask")

final class LibraryBackgroundTaskScheduler {
	// MARK: - Properties
	/// The shared `LibraryBackgroundTaskScheduler` instance.
	static let shared = LibraryBackgroundTaskScheduler()

	/// The identifier of the outbox drain task.
	static let outboxFlushIdentifier = "app.kurozora.tracker.outbox-flush"

	/// The identifier of the library refresh task.
	static let refreshIdentifier = "app.kurozora.tracker.refresh"

	/// The delay before a submitted drain may run.
	private let flushDelay: TimeInterval = 60

	/// The delay before a submitted refresh may run.
	private let refreshDelay: TimeInterval = 4 * 60 * 60

	#if DEBUG
	/// The defaults key holding the recorded launches.
	private static let launchHistoryKey = "libraryBackgroundTaskLaunches"

	/// The most recent launches, newest first.
	static var launchHistory: String {
		let entries = UserDefaults.standard.stringArray(forKey: Self.launchHistoryKey) ?? []
		return entries.isEmpty ? "no background task has run yet" : entries.joined(separator: " | ")
	}

	/// Records a launch of the given task.
	private static func recordLaunch(of identifier: String) {
		let state = UIApplication.shared.applicationState == .active ? "foreground" : "background"
		let stamp = ISO8601DateFormatter().string(from: Date())
		let entry = "\(stamp) \(identifier.replacingOccurrences(of: "app.kurozora.tracker.", with: "")) \(state)"

		var entries = UserDefaults.standard.stringArray(forKey: Self.launchHistoryKey) ?? []
		entries.insert(entry, at: 0)
		UserDefaults.standard.set(Array(entries.prefix(10)), forKey: Self.launchHistoryKey)
	}
	#endif

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Registers the launch handlers.
	func registerHandlers() {
		#if DEBUG
		backgroundTaskLogger.notice("HISTORY \(Self.launchHistory, privacy: .public)")
		#endif

		BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.outboxFlushIdentifier, using: .main) { task in
			MainActor.assumeIsolated {
				LibraryBackgroundTaskScheduler.shared.handleOutboxFlush(task)
			}
		}

		BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshIdentifier, using: .main) { task in
			MainActor.assumeIsolated {
				LibraryBackgroundTaskScheduler.shared.handleRefresh(task)
			}
		}
	}

	/// Submits a drain task when the outbox holds operations.
	func scheduleOutboxFlushIfNeeded() async {
		let assertion = UIApplication.shared.beginBackgroundTask(withName: Self.outboxFlushIdentifier)

		defer {
			if assertion != .invalid {
				UIApplication.shared.endBackgroundTask(assertion)
			}
		}

		guard let userSlug = User.current?.attributes.slug else { return }
		guard await LibraryOutbox.shared.hasPendingOperations(forUserSlug: userSlug) else { return }

		let request = BGProcessingTaskRequest(identifier: Self.outboxFlushIdentifier)
		request.requiresNetworkConnectivity = true
		request.requiresExternalPower = false
		request.earliestBeginDate = Date(timeIntervalSinceNow: self.flushDelay)

		self.submit(request)
	}

	/// Submits a library refresh task.
	func scheduleRefresh() {
		guard User.isSignedIn else { return }

		let request = BGAppRefreshTaskRequest(identifier: Self.refreshIdentifier)
		request.earliestBeginDate = Date(timeIntervalSinceNow: self.refreshDelay)

		self.submit(request)
	}

	private func submit(_ request: BGTaskRequest) {
		do {
			try BGTaskScheduler.shared.submit(request)
			backgroundTaskLogger.info("SUBMIT \(request.identifier, privacy: .public)")
		} catch {
			backgroundTaskLogger.error("SUBMIT \(request.identifier, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
		}
	}

	private func handleOutboxFlush(_ task: BGTask) {
		backgroundTaskLogger.info("RUN \(Self.outboxFlushIdentifier, privacy: .public)")
		#if DEBUG
		Self.recordLaunch(of: Self.outboxFlushIdentifier)
		#endif

		let work = Task {
			await LibraryOutbox.shared.flush(force: true)

			guard !Task.isCancelled else {
				task.setTaskCompleted(success: false)
				return
			}

			await self.scheduleOutboxFlushIfNeeded()
			task.setTaskCompleted(success: true)
		}

		task.expirationHandler = {
			backgroundTaskLogger.notice("EXPIRED \(Self.outboxFlushIdentifier, privacy: .public)")
			work.cancel()
		}
	}

	private func handleRefresh(_ task: BGTask) {
		backgroundTaskLogger.info("RUN \(Self.refreshIdentifier, privacy: .public)")
		#if DEBUG
		Self.recordLaunch(of: Self.refreshIdentifier)
		#endif
		self.scheduleRefresh()

		let work = Task {
			guard let userSlug = User.current?.attributes.slug else {
				task.setTaskCompleted(success: false)
				return
			}

			await LibrarySyncEngine.shared.syncAll(forUserSlug: userSlug)
			task.setTaskCompleted(success: !Task.isCancelled)
		}

		task.expirationHandler = {
			backgroundTaskLogger.notice("EXPIRED \(Self.refreshIdentifier, privacy: .public)")
			work.cancel()
		}
	}
}
#endif
