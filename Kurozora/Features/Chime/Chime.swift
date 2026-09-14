//
//  Chime.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import AVFoundation

final class Chime: NSObject {
	// MARK: Properties
	/// The shared instance of `Chime`.
	static let shared: Chime = Chime()

	/// List of available chime groups.
	var appChimeGroups: [AppChimeGroup] = []
	private let chimePlayer: ChimePlayer = ChimePlayer()

	// MARK: Initializers
	private override init() {
		super.init()

		self.sharedInit()
		self.setupAudioSession()
	}

	// MARK: Functions
	/// The shared settings used to initialize the `Chime` object.
	private func sharedInit() {
		if let path = Bundle.main.path(forResource: "App Chimes", ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			do {
				let decoder = PropertyListDecoder()
				self.appChimeGroups = try decoder.decode([AppChimeGroup].self, from: plist)
			} catch {
				print("----- Error decoding plist: \(String(describing: error))")
			}
		}
	}

	/// Configures an audio session used when playing chimes.
	private func setupAudioSession() {
		AudioSessionManager.shared.setCategory(.ambient, options: [.duckOthers])
	}

	/// Plays the specified chime file.
	///
	/// - Parameters:
	///    - chimeFile: The file to play as a chime.
	func play(_ chimeFile: String? = nil) {
		guard let url = self.url(for: chimeFile) else { return }

		AudioSessionManager.shared.setActive(true) { [weak self] in
			guard let self = self else { return }

			Task {
				await self.chimePlayer.loadAndStart(for: url, delegate: self)
			}
		}
	}

	/// Loads the specified chime file for playback.
	///
	/// - Parameters:
	///    - chimeFile: The file to load as a chime.
	///
	/// - Returns: The loaded chime's duration.
	func prepare(_ chimeFile: String? = nil) async -> TimeInterval {
		guard let url = self.url(for: chimeFile) else { return 0.0 }

		return await self.chimePlayer.load(for: url, delegate: self)
	}

	/// Starts playback of the loaded chime.
	func playPrepared() {
		AudioSessionManager.shared.setActive(true) { [weak self] in
			guard let self = self else { return }

			Task {
				await self.chimePlayer.start()
			}
		}
	}

	/// Returns the location of the specified chime file.
	///
	/// - Parameters:
	///    - chimeFile: The file to resolve.
	///
	/// - Returns: The chime's location in the bundle.
	private func url(for chimeFile: String?) -> URL? {
		let selectedChime = UserSettings.selectedChime
		let chimeFileName = chimeFile ?? {
			if selectedChime.isEmpty {
				return self.appChimeGroups.first?.chimes.first?.first?.file
			} else {
				return self.appChimeGroups
					.flatMap { $0.chimes }
					.flatMap { $0 }
					.first { $0.name == selectedChime }?.file
					?? self.appChimeGroups.first?.chimes.first?.first?.file
			}
		}()

		guard let chimeFileComponents = chimeFileName?.components(separatedBy: ".") else { return nil }

		return Bundle.main.url(forResource: chimeFileComponents.first, withExtension: chimeFileComponents.last)
	}

	/// Change the chime to the specified chime.
	///
	/// The default chime is selected when `nil` is given.
	///
	/// - Parameters:
	///   - chime: The chime to switch to.
	func changeChime(to chime: AppChimeElement?) {
		let chime = chime ?? self.appChimeGroups.first?.chimes.first?.first

		UserSettings.set(chime?.name, forKey: .selectedChime)
	}
}

// MARK: - AVAudioPlayerDelegate
extension Chime: AVAudioPlayerDelegate {
	nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		AudioSessionManager.shared.setActive(false, options: [.notifyOthersOnDeactivation])
	}
}
