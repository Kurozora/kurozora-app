//
//  SplashscreenView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import AVFoundation

protocol SplashscreenViewDelegate: AnyObject {
//    func handleButtonPress()
}

final class SplashscreenView: UIView {
	// MARK: - IBOutlets
    @IBOutlet private weak var logoImageView: UIImageView!

	// MARK: - Properties
	public weak var viewDelegate: SplashscreenViewDelegate?
	private var player: AVAudioPlayer?

	// MARK: - XIB loaded
	override func awakeFromNib() {
		super.awakeFromNib()
		self.setup()
	}

	// MARK: - Display
    func setData() {
		self.playLaunchAudio()
	}

	// MARK: - Functions
	func playLaunchAudio() {
		guard let url = Bundle.main.url(forResource: "shop_door_bell", withExtension: "m4a") else { return }

		do {
			self.player = try AVAudioPlayer(contentsOf: url)
			self.player?.prepareToPlay()
			self.player?.play()
		} catch {
			print("----- Failed to play launch audio: \(error.localizedDescription)")
		}
	}
}

// MARK: - Setup
private extension SplashscreenView {
	func setup() {
		self.setupViews()
	}

	// MARK: - View setup
	func setupViews() {
		self.setupView()
		self.setupLogoImageView()
		self.setupAudio()
	}

	func setupView() {
		self.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
	}

	func setupLogoImageView() {
//		self.logoImageView.theme_tintColor = KThemePicker.tintColor.rawValue
	}

	func setupAudio() {
		let audioSession = AVAudioSession.sharedInstance()

		do {
			try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
			try audioSession.setActive(true)
		} catch {
			print("---------- Failed to set up audio session: \(error.localizedDescription)")
		}
	}
}
