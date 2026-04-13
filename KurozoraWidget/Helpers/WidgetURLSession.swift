//
//  WidgetURLSession.swift
//  KurozoraWidgetExtension
//
//  Created by Khoren Katklian on 13/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation

/// A shared `URLSession` tuned for the widget extension's tight time budget.
///
/// Widget extensions have a short execution window; hanging network calls against
/// an unresponsive server will exhaust that budget and cause the system to kill
/// the extension mid-flight. The session enforces aggressive per-request and
/// per-resource timeouts so every call resolves well inside the budget.
enum WidgetURLSession {
	/// Per-request timeout. Covers the time between packets once a connection is established.
	static let requestTimeout: TimeInterval = 15

	/// End-to-end resource timeout. Hard cap on the full request lifetime, including retries and redirects.
	static let resourceTimeout: TimeInterval = 20

	/// The shared bounded session.
	static let shared: URLSession = {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.timeoutIntervalForRequest = Self.requestTimeout
		configuration.timeoutIntervalForResource = Self.resourceTimeout
		configuration.waitsForConnectivity = false
		return URLSession(configuration: configuration)
	}()
}

/// Runs `operation` with a hard deadline. Throws `WidgetTimeoutError` if the deadline elapses first.
///
/// Uses a `TaskGroup` race between the operation and a sleep task; whichever finishes first
/// cancels the other. Useful for bounding `KService` calls that don't honour URLSession timeouts directly.
///
/// - Parameters:
///    - seconds: Maximum duration in seconds before the operation is cancelled.
///    - operation: The async operation to run.
///
/// - Returns: The operation's result if it finishes in time.
///
/// - Throws: ``WidgetTimeoutError`` if the deadline elapses, or any error thrown by `operation`.
func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @Sendable @escaping () async throws -> T) async throws -> T {
	return try await withThrowingTaskGroup(of: T.self) { group in
		group.addTask {
			return try await operation()
		}
		group.addTask {
			try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
			throw WidgetTimeoutError()
		}

		let result = try await group.next()!
		group.cancelAll()
		return result
	}
}

/// Thrown by ``withTimeout(seconds:operation:)`` when the deadline elapses before the operation finishes.
struct WidgetTimeoutError: Error, LocalizedError {
	var errorDescription: String? { "Operation timed out." }
}
