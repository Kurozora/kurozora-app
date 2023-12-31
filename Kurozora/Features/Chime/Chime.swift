//
//  Chime.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/12/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import AVFoundation

class Chime: NSObject {
	// MARK: Properties
	static let shared: Chime = Chime()

	/// List of available chime groups.
	var appChimeGroups: [AppChimeGroup] = []
	private var player: AVAudioPlayer?

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
				print("----- Error decoding plist: \(error.localizedDescription)")
			}
		}
	}

	/// Configures an audio session used when playing chimes.
	private func setupAudioSession() {
		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(.ambient, options: [.duckOthers])
			try audioSession.setActive(true)
		} catch {
			print("---------- Failed to set up chime session: \(error.localizedDescription)")
		}
	}

	/// Plays the specified chime file.
	///
	/// The user's selected chime is played when `nil` is given.
	///
	/// - Parameters:
	///    - chimeFile: The file to play as a chime.
	func play(_ chimeFile: String? = nil) {
		let selectedChime = UserSettings.selectedChime
		let chimeFileName = chimeFile ?? {
			if selectedChime.isEmpty {
				return self.appChimeGroups.first?.chimes.first?.file
			} else {
				return self.appChimeGroups
					.flatMap { $0.chimes }
					.first { $0.name == selectedChime }?.file
			}
		}()
		guard let chimeFileComponents = chimeFileName?.components(separatedBy: ".") else { return }
		guard let url = Bundle.main.url(forResource: chimeFileComponents.first, withExtension: chimeFileComponents.last) else { return }

		do {
			self.player = try AVAudioPlayer(contentsOf: url)
			self.player?.delegate = self
			self.player?.prepareToPlay()
			self.player?.play()
		} catch {
			print("----- Failed to play chime audio: \(error.localizedDescription)")
		}
	}

	/// Change the chime to the specified chime.
	///
	/// The default chime is selected when `nil` is given.
	///
	/// - Parameters:
	///   - chime: The chime to switch to.
	func changeChime(to chime: AppChimeElement?) {
		let chime = chime ?? self.appChimeGroups.first?.chimes.first

		// Save the chime selection
		UserSettings.set(chime?.name, forKey: .selectedChime)
	}
}

// MARK: - AVAudioPlayerDelegate
extension Chime: AVAudioPlayerDelegate {
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		do {
			try AVAudioSession.sharedInstance().setActive(false)
		} catch {
			print("----- Failed to end chime session: \(error.localizedDescription)")
		}
	}
}
