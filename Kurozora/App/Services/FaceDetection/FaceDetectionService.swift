//
//  FaceDetectionService.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

#if DEBUG
import KurozoraKit
import UIKit

/// Coordinates DEBUG-only client-driven face detection on Person and Character images.
///
/// Holds an in-memory queue of detection results and flushes the queue to the server when it reaches the threshold, the periodic timer fires, or the scene enters the background. Persists a dedup set to `UserSettings` so the same `(mediaID, detectorIdentifier)` pair is never re-submitted.
final class FaceDetectionService {
	// MARK: - Properties
	/// Returns the singleton `FaceDetectionService` instance.
	static let shared = FaceDetectionService()

	private static let flushThreshold = 50
	private static let flushInterval: TimeInterval = 300
	private static let endpointPath = "face-detections/batch"
	private static let sentinelDetectorIdentifier = "none"

	/// The User-Agent string the Kurozora API validates against the registered iOS app client.
	private static let userAgent: String = {
		let info = Bundle.main.infoDictionary
		let executable = info?["CFBundleExecutable"] as? String ?? "Unknown"
		let bundle = info?["CFBundleIdentifier"] as? String ?? "Unknown"
		let appVersion = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
		let appBuild = info?["CFBundleVersion"] as? String ?? "Unknown"
		let version = ProcessInfo.processInfo.operatingSystemVersion
		let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		#if targetEnvironment(macCatalyst)
		let osNameVersion = "macOS(Catalyst) \(versionString)"
		#else
		let osNameVersion = "iOS \(versionString)"
		#endif
		return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) FaceDetection/1.0.0"
	}()

	private let stateQueue = DispatchQueue(label: "app.kurozora.face-detection.state")
	private var pendingEntries: [FaceDetectionEntry] = []
	private var flushTimer: Timer?
	private var isFlushing = false

	// MARK: - Initializers
	private init() {}

	// MARK: - Activation
	/// Starts the periodic flush timer. Idempotent.
	func activate() {
		DispatchQueue.main.async {
			guard self.flushTimer == nil else {
				return
			}

			self.flushTimer = Timer.scheduledTimer(
				withTimeInterval: Self.flushInterval,
				repeats: true
			) { [weak self] _ in
				self?.triggerFlush()
			}
		}
	}

	// MARK: - Submission Pipeline
	/// Submits an image to the appropriate detector chain and stages the result for batch upload.
	///
	/// - Parameters:
	///   - image: The image to inspect.
	///   - mediaURL: The CDN URL the image was loaded from.
	///   - kind: The kind of media entity the image represents.
	func process(image: UIImage, mediaURL: URL, kind: FaceDetectionEntityKind) {
		guard let mediaID = mediaURL.kurozoraMediaID else {
			print("----- FaceDetection: cannot extract media ID from URL", mediaURL.absoluteString)
			return
		}

		let detector = FaceDetectorRegistry.detector(for: kind)
		let dedupKey = "\(mediaID):\(detector.primaryIdentifier)"

		guard !UserSettings.faceDetectionSubmitted.contains(dedupKey) else {
			return
		}

		Task.detached(priority: .utility) { [weak self] in
			guard let self else { return }

			let result = await detector.detect(in: image)

			self.appendResult(result, mediaID: mediaID, dedupKey: dedupKey)
		}
	}

	// MARK: - Background Flush
	/// Forces an immediate flush of the queue, wrapping the request in a background task assertion so it survives suspension.
	func flushOnBackground() {
		let snapshot: [FaceDetectionEntry] = self.stateQueue.sync {
			let entries = self.pendingEntries
			self.pendingEntries.removeAll(keepingCapacity: true)
			return entries
		}

		guard !snapshot.isEmpty else {
			return
		}

		let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "FaceDetectionFlush") {}

		Task.detached(priority: .utility) {
			await self.submit(entries: snapshot)

			await MainActor.run {
				UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
			}
		}
	}

	// MARK: - Queue Management
	private func appendResult(_ result: FaceDetectionResult?, mediaID: Int, dedupKey: String) {
		let entry: FaceDetectionEntry
		if let result = result {
			entry = FaceDetectionEntry(
				mediaID: mediaID,
				focalX: Double(result.focalPoint.x),
				focalY: Double(result.focalPoint.y),
				detectorID: result.detectorIdentifier
			)
		} else {
			entry = FaceDetectionEntry(
				mediaID: mediaID,
				focalX: nil,
				focalY: nil,
				detectorID: Self.sentinelDetectorIdentifier
			)
		}

		var submitted = UserSettings.faceDetectionSubmitted
		submitted.insert(dedupKey)
		UserSettings.set(Array(submitted), forKey: .faceDetectionSubmitted)

		let queueCount: Int = self.stateQueue.sync {
			self.pendingEntries.append(entry)
			return self.pendingEntries.count
		}

		if queueCount >= Self.flushThreshold {
			self.triggerFlush()
		}
	}

	private func triggerFlush() {
		let snapshot: [FaceDetectionEntry]? = self.stateQueue.sync {
			guard !self.isFlushing, !self.pendingEntries.isEmpty else {
				return nil
			}

			self.isFlushing = true
			let entries = self.pendingEntries
			self.pendingEntries.removeAll(keepingCapacity: true)
			return entries
		}

		guard let entries = snapshot else {
			return
		}

		Task.detached(priority: .utility) {
			await self.submit(entries: entries)

			self.stateQueue.sync {
				self.isFlushing = false
			}
		}
	}

	// MARK: - Networking
	private func submit(entries: [FaceDetectionEntry]) async {
		guard !entries.isEmpty else {
			return
		}

		let baseURL = KService.apiEndpoint.baseURL

		guard let endpointURL = URL(string: baseURL + Self.endpointPath) else {
			print("----- FaceDetection: invalid endpoint URL from base", baseURL)
			return
		}

		var request = URLRequest(url: endpointURL)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("application/json", forHTTPHeaderField: "Accept")
		request.setValue(KService.apiKey, forHTTPHeaderField: "X-API-Key")
		request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

		let token = KService.authenticationKey

		if !token.isEmpty {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		do {
			let payload = FaceDetectionBatchPayload(data: entries)
			request.httpBody = try JSONEncoder().encode(payload)
			_ = try await URLSession.shared.data(for: request)
		} catch {
			print("----- FaceDetection: submit failed:", error.localizedDescription)
		}
	}
}
#endif
