//
//  AppBootstrap.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// The result of the app's one-time process bootstrap.
enum BootstrapOutcome {
	/// Startup completed and the app's services are initialized.
	case ready

	/// Startup is blocked by a server-side condition the user must resolve first.
	case blocked(WarningType)
}

/// Runs the app's process-level bootstrap exactly once, regardless of how many scenes connect.
actor AppBootstrap {
	// MARK: - Properties
	/// Returns the singleton `AppBootstrap` instance.
	static let shared = AppBootstrap()

	/// The in-flight or completed bootstrap task. Remains `nil` until the first `run(_:)`.
	private var task: Task<BootstrapOutcome, Never>?

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Starts the bootstrap closure once.
	///
	/// - Parameter bootstrap: The process-level work to perform exactly once.
	///
	/// - Returns: Whether this call started the bootstrap, and the task carrying its outcome.
	func begin(_ bootstrap: @escaping @Sendable () async -> BootstrapOutcome) -> (isColdLaunch: Bool, task: Task<BootstrapOutcome, Never>) {
		if let task = self.task {
			return (false, task)
		}

		let task = Task {
			await bootstrap()
		}
		self.task = task

		return (true, task)
	}

	/// Clears a blocked bootstrap so the next `begin(_:)` retries it.
	///
	/// A `ready` outcome is kept for the life of the process and is never cleared.
	func resetIfBlocked() async {
		guard let task = self.task else { return }

		switch await task.value {
		case .blocked:
			self.task = nil
		case .ready:
			break
		}
	}
}
