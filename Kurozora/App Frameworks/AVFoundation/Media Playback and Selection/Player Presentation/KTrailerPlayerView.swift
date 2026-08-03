//
//  KTrailerPlayerView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import AVFoundation
import UIKit

/// A view that plays a looping, muted YouTube trailer with an optional sound toggle.
///
/// Assign a YouTube URL with ``loadTrailer(fromURL:)``. The view resolves the URL into
/// a native stream through ``YouTubeStreamResolver``, fades in once the first frame is
/// ready for display, and loops indefinitely. When resolution fails the view stays
/// invisible so the content behind it remains in place.
///
/// The view ignores touches outside its own controls, so gestures attached to views
/// behind it keep working while a trailer plays.
class KTrailerPlayerView: UIView {
	// Make AVPlayerLayer the view's backing layer.
	override static var layerClass: AnyClass { AVPlayerLayer.self }

	// MARK: - Views
	/// The button that toggles the trailer's sound.
	private let muteToggleButton: UIButton = {
		var configuration = UIButton.Configuration.filled()
		configuration.baseBackgroundColor = UIColor.black.withAlphaComponent(0.6)
		configuration.baseForegroundColor = .white
		configuration.cornerStyle = .capsule
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12.0, weight: .semibold)

		let button = UIButton(configuration: configuration)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()

	// MARK: - Properties
	/// A Boolean value indicating whether the sound toggle is shown while the trailer plays.
	var showsMuteToggle = false

	/// The YouTube URL of the trailer currently loaded.
	private(set) var trailerURLString: String?

	/// The player that plays the trailer.
	private let queuePlayer = AVQueuePlayer()

	/// The looper that keeps the trailer repeating.
	private var playerLooper: AVPlayerLooper?

	/// The in-flight trailer resolution and preparation task.
	private var loadTask: Task<Void, Never>?

	/// Observes the player layer to fade the view in once the first frame is ready.
	private var readyForDisplayObservation: NSKeyValueObservation?

	// The associated player layer object.
	var playerLayer: AVPlayerLayer {
		guard let layer = self.layer as? AVPlayerLayer else {
			fatalError("Layer is not of expected type AVPlayerLayer.")
		}
		return layer
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	/// The shared settings used to initialize the view.
	private func sharedInit() {
		self.alpha = 0.0
		self.playerLayer.player = self.queuePlayer
		self.playerLayer.videoGravity = .resizeAspectFill
		self.queuePlayer.isMuted = true
		self.queuePlayer.preventsDisplaySleepDuringVideoPlayback = false

		self.configureMuteToggleButton()

		NotificationCenter.default.addObserver(self, selector: #selector(self.handleApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	// MARK: - View
	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window == nil {
			self.queuePlayer.pause()
		} else if self.playerLooper != nil {
			self.queuePlayer.play()
		}
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		return hitView === self ? nil : hitView
	}

	// MARK: - Functions
	/// Loads and plays the trailer at the given YouTube URL.
	///
	/// The trailer plays muted and loops until ``stopTrailer()`` is called.
	/// Passing the URL that is already loaded is a no-op; passing `nil` stops playback.
	///
	/// - Parameter urlString: The YouTube URL of the trailer.
	func loadTrailer(fromURL urlString: String?) {
		print("----- [Trailer] loadTrailer called with: \(urlString ?? "nil")")
		guard let urlString = urlString, !urlString.isEmpty else {
			self.stopTrailer()
			return
		}
		guard urlString != self.trailerURLString else { return }

		self.stopTrailer()
		self.trailerURLString = urlString

		self.loadTask = Task { @MainActor [weak self] in
			guard let self = self else { return }

			do {
				let streamURL = try await YouTubeStreamResolver.shared.streamURL(forVideoURL: urlString)
				guard !Task.isCancelled else { return }
				print("----- [Trailer] resolved stream: \(streamURL.absoluteString.prefix(120))")

				let avURLAsset = AVURLAsset(url: streamURL, options: [AVURLAssetAllowsCellularAccessKey: false])
				let isPlayable = try await avURLAsset.load(.isPlayable)
				print("----- [Trailer] asset isPlayable: \(isPlayable), cancelled: \(Task.isCancelled)")
				guard isPlayable, !Task.isCancelled else { return }

				self.startPlayback(with: AVPlayerItem(asset: avURLAsset))
			} catch {
				print("----- [Trailer] FAILED to load: \(String(describing: error))")
			}
		}
	}

	/// Stops playback, resets the sound state, and hides the view.
	func stopTrailer() {
		self.loadTask?.cancel()
		self.loadTask = nil
		self.readyForDisplayObservation = nil

		self.playerLooper = nil
		self.queuePlayer.pause()
		self.queuePlayer.removeAllItems()
		self.trailerURLString = nil

		if !self.queuePlayer.isMuted {
			self.setMuted(true)
		}

		self.layer.removeAllAnimations()
		self.alpha = 0.0
		self.muteToggleButton.isHidden = true
	}

	/// Starts looping playback and fades the view in once the first frame is ready.
	///
	/// - Parameter playerItem: The item to loop.
	private func startPlayback(with playerItem: AVPlayerItem) {
		print("----- [Trailer] startPlayback — bounds: \(self.bounds), window: \(self.window != nil)")
		self.playerLooper = AVPlayerLooper(player: self.queuePlayer, templateItem: playerItem)

		self.readyForDisplayObservation = self.playerLayer.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] playerLayer, _ in
			guard playerLayer.isReadyForDisplay else { return }

			DispatchQueue.main.async {
				guard let self = self, self.playerLooper != nil else { return }
				print("----- [Trailer] isReadyForDisplay — fading in")
				self.readyForDisplayObservation = nil
				self.muteToggleButton.isHidden = !self.showsMuteToggle

				UIView.animate(withDuration: 0.5) {
					self.alpha = 1.0
				}
			}
		}

		self.queuePlayer.play()
	}

	/// Configures the sound toggle button.
	private func configureMuteToggleButton() {
		self.muteToggleButton.addAction(UIAction { [weak self] _ in
			guard let self = self else { return }
			self.setMuted(!self.queuePlayer.isMuted)
		}, for: .primaryActionTriggered)
		self.updateMuteToggleButton()

		self.addSubview(self.muteToggleButton)
		NSLayoutConstraint.activate([
			self.muteToggleButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12.0),
			self.muteToggleButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12.0),
			self.muteToggleButton.widthAnchor.constraint(equalToConstant: 34.0),
			self.muteToggleButton.heightAnchor.constraint(equalToConstant: 34.0)
		])
	}

	/// Mutes or unmutes the trailer and updates the audio session accordingly.
	///
	/// Muted playback uses the ambient category so the user's music keeps playing;
	/// unmuting claims the session so the trailer's audio is heard.
	///
	/// - Parameter isMuted: Whether the trailer's sound is off.
	private func setMuted(_ isMuted: Bool) {
		self.queuePlayer.isMuted = isMuted
		self.updateMuteToggleButton()

		do {
			if isMuted {
				try AVAudioSession.sharedInstance().setCategory(.ambient)
				try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
			} else {
				try AVAudioSession.sharedInstance().setCategory(.playback)
				try AVAudioSession.sharedInstance().setActive(true)
			}
		} catch {
			print("----- Failed to update trailer audio session: \(error.localizedDescription)")
		}
	}

	/// Updates the sound toggle button's glyph and accessibility label for the current sound state.
	private func updateMuteToggleButton() {
		let isMuted = self.queuePlayer.isMuted
		self.muteToggleButton.configuration?.image = UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
		self.muteToggleButton.accessibilityLabel = isMuted ? L10n.unmute : L10n.mute
	}

	/// Resumes playback when the app returns to the foreground.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc private func handleApplicationDidBecomeActive(_ notification: Notification) {
		guard self.window != nil, self.playerLooper != nil else { return }
		self.queuePlayer.play()
	}
}
