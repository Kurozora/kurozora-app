//
//  AudioSessionManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import AVFoundation

nonisolated final class AudioSessionManager: Sendable {
	// MARK: - Properties
	/// Returns the singleton `AudioSessionManager` instance.
	static let shared = AudioSessionManager()

	private let sessionQueue = DispatchQueue(label: "app.kurozora.audio-session", qos: .userInitiated)

	// MARK: - Initializers
	private init() {}

	// MARK: - Functions
	/// Applies the given category to the shared audio session.
	///
	/// - Parameters:
	///    - category: The category describing how the app uses audio.
	///    - mode: The mode describing the intended use of the category.
	///    - options: The behaviours the category is allowed to take on.
	func setCategory(_ category: AVAudioSession.Category, mode: AVAudioSession.Mode = .default, options: AVAudioSession.CategoryOptions = []) {
		self.sessionQueue.async {
			do {
				try AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: options)
			} catch {
				print("----- Failed to set the audio session category: \(error.localizedDescription)")
			}
		}
	}

	/// Changes the activation state of the shared audio session.
	///
	/// - Parameters:
	///    - isActive: Whether the audio session should be active.
	///    - options: The behaviours applied while the activation state changes.
	///    - completion: The closure called on the main queue once the change has been attempted.
	func setActive(_ isActive: Bool, options: AVAudioSession.SetActiveOptions = [], completion: (@MainActor @Sendable () -> Void)? = nil) {
		self.sessionQueue.async {
			do {
				try AVAudioSession.sharedInstance().setActive(isActive, options: options)
			} catch {
				print("----- Failed to change the audio session activation state: \(error.localizedDescription)")
			}

			guard let completion = completion else { return }

			DispatchQueue.main.async(execute: completion)
		}
	}
}
