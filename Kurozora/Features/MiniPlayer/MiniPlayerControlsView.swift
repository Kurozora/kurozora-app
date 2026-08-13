//
//  MiniPlayerControlsView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import UIKit

/// The MiniPlayer's metadata, progress, and transport cluster.
@available(iOS 17.0, *)
final class MiniPlayerControlsView: PassthroughView {
	// MARK: - Enums
	/// The arrangement of the cluster.
	enum Form {
		/// The arrangement filling the compact bar.
		case bar

		/// The arrangement overlaying the artwork card.
		case overlay
	}

	// MARK: - Views
	/// The artwork thumbnail shown in the compact bar.
	private let artworkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 8
		imageView.image = .Placeholders.musicAlbum
		return imageView
	}()

	/// The app's mark.
	private let idleMarkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.image = .kurozoraIconMonotone
		imageView.tintColor = .systemGray
		imageView.isHidden = true
		return imageView
	}()

	/// The song's title.
	private let titleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 17, weight: .medium)
		label.textColor = .label
		label.leadingInset = 0
		return label
	}()

	/// The song's artist and album.
	private let subtitleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 15)
		label.textColor = .secondaryLabel
		label.leadingInset = 0
		return label
	}()

	/// The stack carrying the title and subtitle.
	private let labelStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.alignment = .fill
		stack.spacing = 0
		stack.isUserInteractionEnabled = false
		return stack
	}()

	/// The row carrying the artwork, labels, and song menu.
	private let metadataRow: PassthroughView = {
		let view = PassthroughView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The background behind the song menu's chip.
	private lazy var menuBackgroundView: UIVisualEffectView = MiniPlayerControlsView.makeGlassBackgroundView(cornerRadius: self.menuChipDiameter / 2)

	/// The song menu.
	private lazy var menuControl: MenuControl = {
		let control = MenuControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.fixedHighlightDiameter = self.menuChipDiameter
		let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
		control.symbolImage = UIImage(systemName: "ellipsis", withConfiguration: config)
		return control
	}()

	/// The playback scrubber and its time labels.
	private let progressView: PlaybackProgressView = {
		let view = PlaybackProgressView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.prefersPersistentLabels = true
		return view
	}()

	/// The play and pause button.
	private let playPauseButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
		button.symbolImage = UIImage(systemName: "play.fill", withConfiguration: config)
		return button
	}()

	/// The shuffle button.
	private let shuffleButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.activeHighlightStyle = .monochrome
		button.fixedHighlightDiameter = 32
		let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
		button.symbolImage = UIImage(systemName: "shuffle", withConfiguration: config)
		button.restingThemeColor = .textColor
		return button
	}()

	/// The skip backward button.
	private let skipBackButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configureSkip(direction: .backward)
		return button
	}()

	/// The skip forward button.
	private let skipForwardButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configureSkip(direction: .forward)
		return button
	}()

	/// The repeat button.
	private let repeatButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.activeHighlightStyle = .monochrome
		button.fixedHighlightDiameter = 32
		let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
		button.symbolImage = UIImage(systemName: "repeat", withConfiguration: config)
		button.restingThemeColor = .textColor
		return button
	}()

	// MARK: - Properties
	/// The metadata row's distance from the bottom edge in each arrangement.
	private let metadataBottomInset: (bar: CGFloat, overlay: CGFloat) = (88, 111)

	/// The progress row's distance from the bottom edge in each arrangement.
	private let progressBottomInset: (bar: CGFloat, overlay: CGFloat) = (48, 66)

	/// The transport row's distance from the bottom edge in each arrangement.
	private let transportBottomInset: (bar: CGFloat, overlay: CGFloat) = (11, 12.5)

	/// The diameter of the song menu's chip over the artwork.
	private let menuChipDiameter: CGFloat = 27

	/// The gap between that chip and the window's trailing edge.
	private let menuChipTrailingInset: CGFloat = 15

	/// The playback controller that drives this view.
	weak var playbackController: MediaPlaybackControlling? {
		didSet { self.bind() }
	}

	/// The arrangement of the cluster.
	var form: Form = .bar {
		didSet {
			guard oldValue != self.form else { return }
			self.applyForm()
		}
	}

	/// Builds the song menu.
	var menuProvider: (() -> UIMenu?)? {
		didSet { self.menuControl.menuProvider = self.menuProvider }
	}

	/// Called with the position the user is dragging the scrubber to, and with `nil` once the drag ends.
	var onScrubPreview: ((TimeInterval?) -> Void)? {
		didSet { self.progressView.onScrubPreview = self.onScrubPreview }
	}

	/// The set of subscriptions for the playback controller's publishers.
	private var subscriptions = Set<AnyCancellable>()

	/// The play/pause state currently reflected by the button's symbol.
	private var displayedIsPlaying = false

	/// The constraints of the compact bar arrangement.
	private var barConstraints: [NSLayoutConstraint] = []

	/// The constraints of the artwork overlay arrangement.
	private var overlayConstraints: [NSLayoutConstraint] = []

	/// The metadata row's height.
	private var metadataRowHeightConstraint: NSLayoutConstraint!

	/// The metadata row's distance from the bottom edge.
	private var metadataBottomConstraint: NSLayoutConstraint!

	/// The progress row's distance from the bottom edge.
	private var progressBottomConstraint: NSLayoutConstraint!

	/// The transport row's distance from the bottom edge.
	private var transportBottomConstraint: NSLayoutConstraint!

	/// How far the cluster has morphed from the bar's metrics towards the card's.
	private var morphProgress: CGFloat = 0

	/// Whether a song is loaded to play.
	private var hasPlayback = true

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Functions
	/// Returns a glass background for floating chrome.
	///
	/// - Parameter cornerRadius: The corner radius of the oval shape.
	///
	/// - Returns: The background view.
	static func makeGlassBackgroundView(cornerRadius: CGFloat) -> UIVisualEffectView {
		let view = UIVisualEffectView()
		if #available(iOS 26.0, *) {
			let glassEffect = UIGlassEffect()
			glassEffect.isInteractive = true
			view.effect = glassEffect
			view.cornerConfiguration = .capsule()
		} else {
			view.effect = UIBlurEffect(style: .systemUltraThinMaterial)
			view.clipsToBounds = true
			view.layer.cornerRadius = cornerRadius
			view.layer.cornerCurve = .continuous
		}
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		return view
	}

	/// Sets how far the cluster has morphed towards the artwork card.
	///
	/// - Parameter progress: `0` for the bar's metrics, `1` for the card's.
	func setMorphProgress(_ progress: CGFloat) {
		let clamped = max(0, min(1, progress))
		guard clamped != self.morphProgress else { return }
		self.morphProgress = clamped

		self.metadataBottomConstraint.constant = -Self.inset(self.metadataBottomInset, at: clamped)
		self.progressBottomConstraint.constant = -Self.inset(self.progressBottomInset, at: clamped)
		self.transportBottomConstraint.constant = -Self.inset(self.transportBottomInset, at: clamped)
	}

	/// Returns a row's distance from the bottom edge at the given morph progress.
	///
	/// - Parameters:
	///    - inset: The row's distance in each arrangement.
	///    - progress: How far the cluster has morphed towards the card.
	///
	/// - Returns: The interpolated distance.
	private static func inset(_ inset: (bar: CGFloat, overlay: CGFloat), at progress: CGFloat) -> CGFloat {
		return inset.bar + (inset.overlay - inset.bar) * progress
	}

	/// Shows or hides the metadata row.
	///
	/// - Parameters:
	///    - hidden: Whether the metadata row is hidden.
	///    - animated: Whether to animate the fade.
	func setMetadataHidden(_ hidden: Bool, animated: Bool) {
		let animations = { [weak self] in
			guard let self = self else { return }
			self.metadataRow.alpha = hidden ? 0 : 1
		}

		if animated, !UIAccessibility.isReduceMotionEnabled {
			UIView.animate(withDuration: 0.2, animations: animations)
		} else {
			animations()
		}
	}

	/// Performs the initialization shared by every initializer.
	private func sharedInit() {
		self.configureView()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.applyForm()
	}

	/// Configures the cluster's own appearance.
	private func configureView() {
		self.playPauseButton.addAction(UIAction { [weak self] _ in
			self?.playPauseTapped()
		}, for: .touchUpInside)

		self.shuffleButton.addAction(UIAction { [weak self] _ in
			self?.playbackController?.toggleShuffle()
		}, for: .touchUpInside)

		self.skipBackButton.addAction(UIAction { [weak self] _ in
			self?.playbackController?.skipBackward()
		}, for: .touchUpInside)

		self.skipForwardButton.addAction(UIAction { [weak self] _ in
			self?.playbackController?.skipForward()
		}, for: .touchUpInside)

		self.repeatButton.addAction(UIAction { [weak self] _ in
			self?.playbackController?.cycleRepeat()
		}, for: .touchUpInside)

		self.skipBackButton.setSkipMetrics(pointSize: 21, spacing: 15)
		self.skipForwardButton.setSkipMetrics(pointSize: 21, spacing: 15)
	}

	/// Builds the view hierarchy.
	private func configureViewHierarchy() {
		self.labelStack.addArrangedSubview(self.titleLabel)
		self.labelStack.addArrangedSubview(self.subtitleLabel)

		self.metadataRow.addSubview(self.artworkImageView)
		self.metadataRow.addSubview(self.labelStack)
		self.metadataRow.addSubview(self.idleMarkImageView)
		self.metadataRow.addSubview(self.menuBackgroundView)
		self.metadataRow.addSubview(self.menuControl)

		self.addSubview(self.metadataRow)
		self.addSubview(self.progressView)
		self.addSubview(self.shuffleButton)
		self.addSubview(self.skipBackButton)
		self.addSubview(self.playPauseButton)
		self.addSubview(self.skipForwardButton)
		self.addSubview(self.repeatButton)
	}

	/// Activates the constraints shared by both arrangements.
	private func configureViewConstraints() {
		self.metadataRowHeightConstraint = self.metadataRow.heightAnchor.constraint(equalToConstant: 42)
		self.metadataBottomConstraint = self.metadataRow.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.metadataBottomInset.bar)
		self.progressBottomConstraint = self.progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.progressBottomInset.bar)
		self.transportBottomConstraint = self.playPauseButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.transportBottomInset.bar)

		NSLayoutConstraint.activate([
			self.metadataBottomConstraint,
			self.progressBottomConstraint,
			self.transportBottomConstraint,

			self.metadataRow.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			self.metadataRow.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
			self.metadataRowHeightConstraint,

			self.idleMarkImageView.centerXAnchor.constraint(equalTo: self.metadataRow.centerXAnchor),
			self.idleMarkImageView.centerYAnchor.constraint(equalTo: self.metadataRow.centerYAnchor),
			self.idleMarkImageView.widthAnchor.constraint(equalToConstant: 32),
			self.idleMarkImageView.heightAnchor.constraint(equalTo: self.idleMarkImageView.widthAnchor),

			self.menuBackgroundView.centerXAnchor.constraint(equalTo: self.menuControl.centerXAnchor),
			self.menuBackgroundView.centerYAnchor.constraint(equalTo: self.menuControl.centerYAnchor),
			self.menuBackgroundView.widthAnchor.constraint(equalToConstant: self.menuChipDiameter),
			self.menuBackgroundView.heightAnchor.constraint(equalToConstant: self.menuChipDiameter),

			self.menuControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(self.menuChipTrailingInset - (44 - self.menuChipDiameter) / 2)),
			self.menuControl.centerYAnchor.constraint(equalTo: self.metadataRow.centerYAnchor),
			self.menuControl.widthAnchor.constraint(equalToConstant: 44),
			self.menuControl.heightAnchor.constraint(equalToConstant: 44),

			self.progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
			self.progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),

			self.shuffleButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 19),
			self.shuffleButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor, constant: 1),
			self.shuffleButton.widthAnchor.constraint(equalToConstant: 30),
			self.shuffleButton.heightAnchor.constraint(equalToConstant: 44),

			self.skipBackButton.trailingAnchor.constraint(equalTo: self.playPauseButton.leadingAnchor, constant: -16),
			self.skipBackButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor, constant: 1),
			self.skipBackButton.widthAnchor.constraint(equalToConstant: 44),
			self.skipBackButton.heightAnchor.constraint(equalToConstant: 44),

			self.playPauseButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
			self.playPauseButton.widthAnchor.constraint(equalToConstant: 40),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 44),

			self.skipForwardButton.leadingAnchor.constraint(equalTo: self.playPauseButton.trailingAnchor, constant: 15),
			self.skipForwardButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor, constant: 1),
			self.skipForwardButton.widthAnchor.constraint(equalToConstant: 44),
			self.skipForwardButton.heightAnchor.constraint(equalToConstant: 44),

			self.repeatButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -19),
			self.repeatButton.centerYAnchor.constraint(equalTo: self.playPauseButton.centerYAnchor, constant: 1),
			self.repeatButton.widthAnchor.constraint(equalToConstant: 30),
			self.repeatButton.heightAnchor.constraint(equalToConstant: 44),
		])

		self.barConstraints = [
			self.artworkImageView.leadingAnchor.constraint(equalTo: self.metadataRow.leadingAnchor),
			self.artworkImageView.centerYAnchor.constraint(equalTo: self.metadataRow.centerYAnchor),
			self.artworkImageView.widthAnchor.constraint(equalToConstant: 42),
			self.artworkImageView.heightAnchor.constraint(equalToConstant: 42),

			self.labelStack.topAnchor.constraint(equalTo: self.artworkImageView.topAnchor, constant: 1.5),
			self.labelStack.leadingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor, constant: 11.5),
			self.labelStack.trailingAnchor.constraint(equalTo: self.metadataRow.trailingAnchor),
		]

		self.overlayConstraints = [
			self.labelStack.centerYAnchor.constraint(equalTo: self.metadataRow.centerYAnchor),
			self.labelStack.leadingAnchor.constraint(equalTo: self.metadataRow.leadingAnchor),
			self.labelStack.trailingAnchor.constraint(equalTo: self.menuControl.leadingAnchor, constant: -8),
		]
	}

	/// Rearranges the cluster for the current form.
	private func applyForm() {
		let isBar = self.form == .bar

		NSLayoutConstraint.deactivate(isBar ? self.overlayConstraints : self.barConstraints)
		NSLayoutConstraint.activate(isBar ? self.barConstraints : self.overlayConstraints)

		self.menuControl.isHidden = isBar
		self.menuBackgroundView.isHidden = isBar
		self.updateMetadataPresentation()
	}

	/// Updates the metadata row for the current playback availability.
	private func updateMetadataPresentation() {
		let isBar = self.form == .bar
		let showsMark = isBar && !self.hasPlayback

		self.artworkImageView.isHidden = !isBar || showsMark
		self.labelStack.isHidden = showsMark
		self.idleMarkImageView.isHidden = !showsMark
	}

	/// Subscribes to the playback controller's publishers.
	private func bind() {
		self.subscriptions.removeAll()

		guard let controller = self.playbackController else { return }

		self.progressView.onSeek = { [weak self] seconds in
			self?.playbackController?.seek(toSeconds: seconds)
		}

		controller.currentSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] song in
				guard let self = self else { return }
				self.titleLabel.text = song?.song.title
				self.subtitleLabel.text = [song?.song.artistName, song?.song.albumTitle].compactMap { $0 }.joined(separator: " — ")
				self.loadArtwork(for: song)
				self.setPlaybackAvailable(song != nil)
			}
			.store(in: &self.subscriptions)

		controller.isPlayingPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] isPlaying in
				self?.applyPlayPauseSymbol(isPlaying: isPlaying)
			}
			.store(in: &self.subscriptions)

		controller.playbackProgressPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] progress in
				self?.progressView.configure(with: progress)
			}
			.store(in: &self.subscriptions)

		controller.shuffleEnabledPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] enabled in
				self?.shuffleButton.isActive = enabled
			}
			.store(in: &self.subscriptions)

		controller.repeatModePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] mode in
				guard let self = self else { return }
				// Point size must mirror the repeatButton declaration.
				let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
				let symbolName = mode == .one ? "repeat.1" : "repeat"
				if let image = UIImage(systemName: symbolName, withConfiguration: config) {
					self.repeatButton.setSymbolImage(image, replace: false)
				}
				self.repeatButton.isActive = mode != .off
			}
			.store(in: &self.subscriptions)
	}

	/// Sets whether a song is available to play.
	///
	/// - Parameter available: Whether a song is loaded.
	private func setPlaybackAvailable(_ available: Bool) {
		self.hasPlayback = available
		self.playPauseButton.isEnabled = available
		self.skipBackButton.isEnabled = available
		self.skipForwardButton.isEnabled = available
		self.progressView.hasContent = available
		self.updateMetadataPresentation()
	}

	/// Loads the artwork thumbnail for the given song.
	private func loadArtwork(for song: MKSong?) {
		guard let artworkURL = song?.song.artwork?.url(width: 96, height: 96)?.absoluteString else {
			self.artworkImageView.image = .Placeholders.musicAlbum
			return
		}
		self.artworkImageView.setImage(with: artworkURL, placeholder: .Placeholders.musicAlbum)
	}

	/// Toggles playback.
	private func playPauseTapped() {
		let willPlay = !(self.playbackController?.isPlaying ?? false)
		self.applyPlayPauseSymbol(isPlaying: willPlay)
		self.playbackController?.togglePlayPause()
	}

	/// Updates the play/pause symbol.
	///
	/// - Parameter isPlaying: Whether playback is active.
	private func applyPlayPauseSymbol(isPlaying: Bool) {
		guard self.displayedIsPlaying != isPlaying else { return }
		self.displayedIsPlaying = isPlaying

		// Point size must mirror the playPauseButton declaration.
		let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)
		let symbolName = isPlaying ? "pause.fill" : "play.fill"
		guard let image = UIImage(systemName: symbolName, withConfiguration: config) else { return }
		self.playPauseButton.setSymbolImage(image, replace: true)
	}
}
