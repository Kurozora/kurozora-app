//
//  MusicPlaybackControlView.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import CoreImage
import UIKit

@available(iOS 26.0, *)
final class MusicPlaybackControlView: UIView {
	// MARK: - Views
	private let artworkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 8
		imageView.image = .Placeholders.musicAlbum
		imageView.isUserInteractionEnabled = true
		return imageView
	}()

	private let artworkOverlayView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black.withAlphaComponent(0.45)
		view.alpha = 0
		return view
	}()

	private let expandImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		imageView.tintColor = .white
		imageView.image = UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
		return imageView
	}()

	private let airPlayView: AirPlayControl = {
		let view = AirPlayControl()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let volumeControl: VolumeControl = {
		let control = VolumeControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.tintColor = .label
		return control
	}()

	private let titleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption1).bold
		return label
	}()

	private let subtitleLabel: KMarqueeLabel = {
		let label = KMarqueeLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption2)
		return label
	}()

	private let playPauseButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium)
		button.symbolImage = UIImage(systemName: "play.fill", withConfiguration: config)
		return button
	}()

	private let shuffleButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
		button.symbolImage = UIImage(systemName: "shuffle", withConfiguration: config)
		button.restingThemeColor = .subTextColor
		return button
	}()

	private let skipBackButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configureSkip(direction: .backward)
		return button
	}()

	private let skipForwardButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.configureSkip(direction: .forward)
		return button
	}()

	private let repeatButton: TransportButton = {
		let button = TransportButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
		button.symbolImage = UIImage(systemName: "repeat", withConfiguration: config)
		button.restingThemeColor = .subTextColor
		return button
	}()

	private let menuButton: MenuControl = {
		let control = MenuControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.fixedHighlightDiameter = 38
		let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
		control.symbolImage = UIImage(systemName: "ellipsis", withConfiguration: config)
		return control
	}()

	private let lyricsButton: IconPressControl = {
		let control = IconPressControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.fixedHighlightDiameter = 38
		let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
		control.symbolImage = UIImage(systemName: "quote.bubble", withConfiguration: config)
		return control
	}()

	private let labelStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.spacing = 2
		return stack
	}()

	/// The container holding the artwork and labels, scaled and blurred as one unit.
	private let metadataContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let leadingStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 4
		return stack
	}()

	private let trailingStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .center
		stack.spacing = 0
		return stack
	}()

	private let progressView: PlaybackProgressView = {
		let view = PlaybackProgressView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	// MARK: - Properties
	/// The playback controller that drives this view.
	weak var playbackController: MediaPlaybackControlling? {
		didSet { self.bind() }
	}

	/// The set of subscriptions for the playback controller's publishers.
	private var subscriptions = Set<AnyCancellable>()

	/// The Kurozora song model for the currently playing song.
	private var currentKKSong: KKSong?

	/// The play/pause state currently reflected by the button's symbol.
	private var displayedIsPlaying = false

	/// The point size of the play/pause symbol, smaller in the compact form.
	private var playSymbolPointSize: CGFloat = 25

	/// The most recently applied layout, used to avoid redundant layout passes.
	private var lastAppliedLayout: MusicAccessoryLayout?

	/// The number of seconds each scan step seeks while a skip button is held.
	private let scanStepSeconds: TimeInterval = 5

	/// The repeating timer that seeks within the song while a skip button is held.
	private var scanTimer: Timer?

	private lazy var skipForwardWidthConstraint = self.skipForwardButton.widthAnchor.constraint(equalToConstant: 24)

	private lazy var trailingStackTrailingConstraint = self.trailingStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)

	private lazy var metadataTopConstraint = self.metadataContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 10)

	private lazy var metadataBottomConstraint = self.metadataContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)

	private lazy var leadingStackLeadingConstraint = self.leadingStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)

	#if targetEnvironment(macCatalyst)
	/// The height forced on the bottom accessory.
	private let accessoryHeight: CGFloat = 54.0
	#else
	/// The reused context for rendering blurred snapshots.
	private let blurContext = CIContext()

	/// The padding, in points, added around a snapshot so its blur can feather beyond the source bounds.
	private let blurInset: CGFloat = 30

	/// The blurred snapshots overlaid on de-emphasized views, keyed by the source view.
	private var blurOverlays: [UIView: UIImageView] = [:]

	/// The original alpha of each content subview hidden behind a blur overlay, keyed by the source view.
	private var blurHiddenContent: [UIView: [(view: UIView, alpha: CGFloat)]] = [:]
	#endif

	/// The context-menu interaction used for long-press and right-click anywhere on the accessory.
	private lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)

	/// The context-menu user info for the currently playing song.
	private var currentSongUserInfo: [AnyHashable: Any]? {
		guard let mkSong = self.playbackController?.currentSong else { return nil }
		return ["song": mkSong]
	}

	/// The subviews that handle their own touches, so the accessory's gestures and context menu defer to them.
	private var interactiveViews: [UIView] {
		[self.playPauseButton, self.shuffleButton, self.skipBackButton, self.skipForwardButton, self.repeatButton, self.menuButton, self.lyricsButton, self.airPlayView, self.volumeControl, self.progressView]
	}

	/// Returns whether the given point, in this view's coordinate space, falls on an interactive subview.
	///
	/// - Parameter point: The point to test.
	///
	/// - Returns: Whether an interactive subview contains the point.
	private func hitsInteractiveView(at point: CGPoint) -> Bool {
		return self.interactiveViews.contains { !$0.isHidden && $0.bounds.contains($0.convert(point, from: self)) }
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		self.scanTimer?.invalidate()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateLayout()
		self.updateVolumeSliderExtent()
		self.enforceAccessoryHeight()
	}

	// MARK: - Functions
	/// Forces the bottom accessory to ``accessoryHeight``.
	private func enforceAccessoryHeight() {
		#if targetEnvironment(macCatalyst)
		guard let accessoryView = self.superview else { return }

		let delta = accessoryView.bounds.height - self.accessoryHeight
		guard abs(delta) > 0.5 else { return }

		var frame = accessoryView.frame
		frame.origin.y += delta
		frame.size.height = self.accessoryHeight
		accessoryView.frame = frame
		#endif
	}

	private func sharedInit() {
		self.configureView()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		self.registerForTraitChanges([UITraitHorizontalSizeClass.self, UITraitTabAccessoryEnvironment.self]) { (view: MusicPlaybackControlView, _: UITraitCollection) in
			view.updateLayout()
		}
	}

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

		self.lyricsButton.addAction(UIAction { [weak self] _ in
			self?.presentLyrics()
		}, for: .touchUpInside)

		self.menuButton.menuProvider = { [weak self] in
			self?.makeSongMenu()
		}

		self.progressView.onExpansionChange = { [weak self] expanded in
			self?.setMetadataDeEmphasized(expanded)
		}

		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
		tapGestureRecognizer.delegate = self
		self.addGestureRecognizer(tapGestureRecognizer)

		let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(self.handleArtworkHover(_:)))
		self.artworkImageView.addGestureRecognizer(hoverGestureRecognizer)

		let skipBackwardHold = UILongPressGestureRecognizer(target: self, action: #selector(self.handleSkipBackwardHold(_:)))
		self.skipBackButton.addGestureRecognizer(skipBackwardHold)

		let skipForwardHold = UILongPressGestureRecognizer(target: self, action: #selector(self.handleSkipForwardHold(_:)))
		self.skipForwardButton.addGestureRecognizer(skipForwardHold)

		self.addInteraction(self.contextMenuInteraction)
	}

	private func configureViewHierarchy() {
		self.labelStack.addArrangedSubview(self.titleLabel)
		self.labelStack.addArrangedSubview(self.subtitleLabel)

		self.artworkImageView.addSubview(self.artworkOverlayView)
		self.artworkOverlayView.addSubview(self.expandImageView)

		self.metadataContainer.addSubview(self.artworkImageView)
		self.metadataContainer.addSubview(self.labelStack)

		self.addSubview(self.leadingStack)
		self.addSubview(self.metadataContainer)
		self.addSubview(self.trailingStack)
		self.addSubview(self.progressView)
	}

	private func configureViewConstraints() {
		let leadingStackCollapse = self.leadingStack.widthAnchor.constraint(equalToConstant: 0)
		leadingStackCollapse.priority = .defaultHigh

		NSLayoutConstraint.activate([
			self.leadingStackLeadingConstraint,
			self.leadingStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
			leadingStackCollapse,

			self.metadataTopConstraint,
			self.metadataBottomConstraint,
			self.metadataContainer.leadingAnchor.constraint(equalTo: self.leadingStack.trailingAnchor, constant: 8),
			self.metadataContainer.trailingAnchor.constraint(equalTo: self.trailingStack.leadingAnchor, constant: -8),

			self.artworkImageView.topAnchor.constraint(equalTo: self.metadataContainer.topAnchor),
			self.artworkImageView.bottomAnchor.constraint(equalTo: self.metadataContainer.bottomAnchor),
			self.artworkImageView.leadingAnchor.constraint(equalTo: self.metadataContainer.leadingAnchor),
			self.artworkImageView.widthAnchor.constraint(equalTo: self.artworkImageView.heightAnchor),

			self.labelStack.leadingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor, constant: 0),
			self.labelStack.centerYAnchor.constraint(equalTo: self.metadataContainer.centerYAnchor),
			self.labelStack.trailingAnchor.constraint(equalTo: self.metadataContainer.trailingAnchor),

			self.trailingStackTrailingConstraint,
			self.trailingStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),

			self.playPauseButton.widthAnchor.constraint(equalToConstant: 30),
			self.playPauseButton.heightAnchor.constraint(equalToConstant: 44),
			self.menuButton.widthAnchor.constraint(equalToConstant: 44),
			self.menuButton.heightAnchor.constraint(equalToConstant: 44),
			self.lyricsButton.widthAnchor.constraint(equalToConstant: 44),
			self.lyricsButton.heightAnchor.constraint(equalToConstant: 44),
			self.airPlayView.widthAnchor.constraint(equalToConstant: 44),
			self.airPlayView.heightAnchor.constraint(equalToConstant: 44),
			self.volumeControl.widthAnchor.constraint(equalToConstant: 44),
			self.volumeControl.heightAnchor.constraint(equalToConstant: 44),
			self.shuffleButton.widthAnchor.constraint(equalToConstant: 20),
			self.shuffleButton.heightAnchor.constraint(equalToConstant: 44),
			self.skipBackButton.widthAnchor.constraint(equalToConstant: 24),
			self.skipBackButton.heightAnchor.constraint(equalToConstant: 44),
			self.skipForwardWidthConstraint,
			self.skipForwardButton.heightAnchor.constraint(equalToConstant: 44),
			self.repeatButton.widthAnchor.constraint(equalToConstant: 20),
			self.repeatButton.heightAnchor.constraint(equalToConstant: 44),

			self.artworkOverlayView.topAnchor.constraint(equalTo: self.artworkImageView.topAnchor),
			self.artworkOverlayView.bottomAnchor.constraint(equalTo: self.artworkImageView.bottomAnchor),
			self.artworkOverlayView.leadingAnchor.constraint(equalTo: self.artworkImageView.leadingAnchor),
			self.artworkOverlayView.trailingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor),

			self.expandImageView.centerXAnchor.constraint(equalTo: self.artworkOverlayView.centerXAnchor),
			self.expandImageView.centerYAnchor.constraint(equalTo: self.artworkOverlayView.centerYAnchor),

			self.progressView.leadingAnchor.constraint(equalTo: self.artworkImageView.leadingAnchor),
			self.progressView.trailingAnchor.constraint(equalTo: self.trailingStack.leadingAnchor, constant: 44),
			self.progressView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
		])

		self.titleLabel.setContentHuggingPriority(.defaultHigh + 1, for: .vertical)
		self.subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
		self.labelStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
		self.labelStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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
				self.subtitleLabel.text = song?.song.artistName
				self.loadArtwork(for: song)
			}
			.store(in: &self.subscriptions)

		controller.currentKKSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] kkSong in
				self?.currentKKSong = kkSong
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
				let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
				let symbolName = mode == .one ? "repeat.1" : "repeat"
				if let image = UIImage(systemName: symbolName, withConfiguration: config) {
					self.repeatButton.setSymbolImage(image, replace: false)
				}
				self.repeatButton.isActive = mode != .off
			}
			.store(in: &self.subscriptions)
	}

	/// Sizes the volume slider so it stops just before the context-menu button.
	private func updateVolumeSliderExtent() {
		guard !self.volumeControl.isHidden, !self.menuButton.isHidden else { return }
		guard let menuSuperview = self.menuButton.superview, let volumeSuperview = self.volumeControl.superview else { return }

		let menuFrame = menuSuperview.convert(self.menuButton.frame, to: self)
		let volumeFrame = volumeSuperview.convert(self.volumeControl.frame, to: self)
		let extent = max(40, volumeFrame.minX - menuFrame.maxX - 6)

		if abs(extent - self.volumeControl.sliderExtent) > 0.5 {
			self.volumeControl.sliderExtent = extent
		}
	}

	/// Resolves and applies the layout for the current environment and width.
	private func updateLayout() {
		let width = self.bounds.width
		guard width > 0 else { return }

		let layout = MusicAccessoryLayout.layout(for: self.traitCollection.tabAccessoryEnvironment, width: width)
		guard layout != self.lastAppliedLayout else { return }

		self.lastAppliedLayout = layout
		self.menuButton.isHidden = !layout.showsContextMenuButton
		self.lyricsButton.isHidden = !layout.showsLyricsButton
		self.progressView.isHidden = !layout.showsProgressBar
		self.airPlayView.isHidden = !layout.showsAirPlayButton
		self.volumeControl.isHidden = !layout.showsVolumeControl
		self.skipForwardButton.isHidden = !layout.showsSkipForward

		let leadingViews: [UIView] = layout.playPauseIsLeading
			? [self.shuffleButton, self.skipBackButton, self.playPauseButton, self.skipForwardButton, self.repeatButton]
			: []

		var trailingViews: [UIView] = [self.menuButton, self.lyricsButton, self.airPlayView, self.volumeControl]
		if !layout.playPauseIsLeading {
			trailingViews.append(self.playPauseButton)
			trailingViews.append(self.skipForwardButton)
		}

		self.setArrangedViews(leadingViews, in: self.leadingStack)
		self.setArrangedViews(trailingViews, in: self.trailingStack)

		self.trailingStack.setCustomSpacing(8, after: self.menuButton)
		self.trailingStack.setCustomSpacing(16, after: self.playPauseButton)

		let compactForm = !layout.playPauseIsLeading
		self.skipForwardWidthConstraint.constant = compactForm ? 30 : 24
		self.skipForwardButton.setSkipMetrics(pointSize: compactForm ? 17 : 13, spacing: compactForm ? 11 : 9)
		self.trailingStackTrailingConstraint.constant = compactForm ? -16 : -4
		self.leadingStackLeadingConstraint.constant = compactForm ? 8 : 12
		self.metadataTopConstraint.constant = compactForm ? 6 : 10
		self.metadataBottomConstraint.constant = compactForm ? -8 : -10

		let playSize: CGFloat = compactForm ? 22 : 25
		if playSize != self.playSymbolPointSize {
			self.playSymbolPointSize = playSize
			self.updatePlayPauseSymbol(replace: false)
		}
	}

	/// Reconciles a stack's arranged subviews to exactly the given views, in order.
	///
	/// - Parameters:
	///    - views: The views the stack should arrange, in order.
	///    - stack: The stack to update.
	private func setArrangedViews(_ views: [UIView], in stack: UIStackView) {
		guard stack.arrangedSubviews != views else { return }

		for view in stack.arrangedSubviews {
			stack.removeArrangedSubview(view)
			view.removeFromSuperview()
		}
		for view in views {
			stack.addArrangedSubview(view)
		}
	}

	/// Loads the artwork image for the given song.
	private func loadArtwork(for song: MKSong?) {
		guard let artworkURL = song?.song.artwork?.url(width: 96, height: 96)?.absoluteString else {
			self.artworkImageView.image = .Placeholders.musicAlbum
			return
		}
		self.artworkImageView.setImage(with: artworkURL, placeholder: .Placeholders.musicAlbum)
	}

	/// Builds the context menu for the currently playing song.
	private func makeSongMenu() -> UIMenu? {
		guard
			let kkSong = self.currentKKSong,
			let viewController = UIApplication.topViewController
		else { return nil }

		return kkSong.makeContextMenu(in: viewController, userInfo: self.currentSongUserInfo, sourceView: self.menuButton, barButtonItem: nil)
	}

	private func playPauseTapped() {
		let willPlay = !(self.playbackController?.isPlaying ?? false)
		self.applyPlayPauseSymbol(isPlaying: willPlay)
		self.playbackController?.togglePlayPause()
	}

	/// Updates the play/pause symbol with a replace transition, skipping redundant changes.
	///
	/// - Parameter isPlaying: Whether playback is active.
	private func applyPlayPauseSymbol(isPlaying: Bool) {
		guard self.displayedIsPlaying != isPlaying else { return }
		self.displayedIsPlaying = isPlaying
		self.updatePlayPauseSymbol(replace: true)
	}

	/// Renders the play/pause symbol at the current point size.
	///
	/// - Parameter replace: Whether to animate the change with a replace transition.
	private func updatePlayPauseSymbol(replace: Bool) {
		let config = UIImage.SymbolConfiguration(pointSize: self.playSymbolPointSize, weight: .medium)
		let symbolName = self.displayedIsPlaying ? "pause.fill" : "play.fill"
		guard let image = UIImage(systemName: symbolName, withConfiguration: config) else { return }
		self.playPauseButton.setSymbolImage(image, replace: replace)
	}

	@objc private func handleTap() {
		self.presentLyrics()
	}

	/// Shows or hides the artwork's expand overlay as a pointer enters or leaves it.
	///
	/// - Parameter gestureRecognizer: The hover gesture recognizer reporting the pointer state.
	@objc private func handleArtworkHover(_ gestureRecognizer: UIHoverGestureRecognizer) {
		let isHovering = gestureRecognizer.state == .began || gestureRecognizer.state == .changed

		let animations = { [weak self] in
			guard let self = self else { return }
			self.artworkOverlayView.alpha = isHovering ? 1 : 0
		}

		if UIAccessibility.isReduceMotionEnabled {
			animations()
		} else {
			UIView.animate(withDuration: 0.2, animations: animations)
		}
	}

	@objc private func handleSkipBackwardHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
		self.handleScanGesture(gestureRecognizer, button: self.skipBackButton, step: -self.scanStepSeconds)
	}

	@objc private func handleSkipForwardHold(_ gestureRecognizer: UILongPressGestureRecognizer) {
		self.handleScanGesture(gestureRecognizer, button: self.skipForwardButton, step: self.scanStepSeconds)
	}

	/// Starts or stops a repeating within-song seek as a skip button is held and released.
	///
	/// - Parameters:
	///    - gestureRecognizer: The long-press recognizer reporting the hold state.
	///    - button: The skip button whose chevron signals each scan step.
	///    - step: The signed number of seconds to seek per step.
	private func handleScanGesture(_ gestureRecognizer: UILongPressGestureRecognizer, button: TransportButton, step: TimeInterval) {
		switch gestureRecognizer.state {
		case .began:
			self.startScanning(button: button, step: step)
		case .ended, .cancelled, .failed:
			self.stopScanning()
		default:
			break
		}
	}

	/// Begins repeatedly seeking within the song.
	///
	/// - Parameters:
	///    - button: The skip button whose chevron signals each scan step.
	///    - step: The signed number of seconds to seek per step.
	private func startScanning(button: TransportButton, step: TimeInterval) {
		self.stopScanning()

		let scan: () -> Void = { [weak self, weak button] in
			self?.playbackController?.seek(bySeconds: step)
			button?.animateSkip()
		}

		scan()
		self.scanTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
			scan()
		}
	}

	/// Stops the repeating within-song seek.
	private func stopScanning() {
		self.scanTimer?.invalidate()
		self.scanTimer = nil
	}

	/// Scales down and blurs the metadata while the scrubber is expanded.
	///
	/// - Parameter deEmphasized: Whether the metadata should recede.
	private func setMetadataDeEmphasized(_ deEmphasized: Bool) {
		let animations = { [weak self] in
			guard let self = self else { return }
			let transform: CGAffineTransform = deEmphasized ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
			self.metadataContainer.transform = transform
			self.menuButton.transform = transform
		}

		if UIAccessibility.isReduceMotionEnabled {
			animations()
		} else {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: animations)
		}

		#if targetEnvironment(macCatalyst)
		let radius: CGFloat = deEmphasized ? 8 : 0
		self.animateBlur(on: self.metadataContainer.layer, to: radius)
		self.animateBlur(on: self.menuButton.layer, to: radius)
		#else
		self.setContentBlur(on: self.metadataContainer, deEmphasized: deEmphasized)
		self.setContentBlur(on: self.menuButton, deEmphasized: deEmphasized)
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// Animates a Gaussian blur on the given layer's content.
	///
	/// - Parameters:
	///    - layer: The layer to blur.
	///    - radius: The target blur radius.
	private func animateBlur(on layer: CALayer, to radius: CGFloat) {
		let keyPath = "filters.CIGaussianBlur.inputRadius"

		if layer.filters == nil {
			guard let filter = CIFilter(name: "CIGaussianBlur", parameters: [kCIInputRadiusKey: 0]) else { return }
			layer.filters = [filter]
		}

		let current = (layer.value(forKeyPath: keyPath) as? CGFloat) ?? 0
		let animation = CABasicAnimation(keyPath: keyPath)
		animation.fromValue = current
		animation.toValue = radius
		animation.duration = 0.25
		animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		layer.add(animation, forKey: "metadataBlur")
		layer.setValue(radius, forKeyPath: keyPath)
	}
	#else
	/// Cross-fades a Gaussian blurred snapshot over the given view to emulate a content blur.
	///
	/// - Parameters:
	///    - view: The view to blur.
	///    - deEmphasized: Whether the blurred snapshot should be shown.
	private func setContentBlur(on view: UIView, deEmphasized: Bool) {
		if deEmphasized {
			guard self.blurOverlays[view] == nil, let image = self.blurredImage(of: view) else { return }

			let hiddenContent = view.subviews.map { (view: $0, alpha: $0.alpha) }
			let overlay = UIImageView(image: image)
			overlay.frame = view.bounds.insetBy(dx: -self.blurInset, dy: -self.blurInset)
			overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			overlay.alpha = 0
			view.addSubview(overlay)
			self.blurOverlays[view] = overlay
			self.blurHiddenContent[view] = hiddenContent

			let reveal = {
				overlay.alpha = 1
				hiddenContent.forEach { $0.view.alpha = 0 }
			}
			if UIAccessibility.isReduceMotionEnabled {
				reveal()
			} else {
				UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: reveal)
			}
		} else {
			guard let overlay = self.blurOverlays.removeValue(forKey: view) else { return }
			let hiddenContent = self.blurHiddenContent.removeValue(forKey: view) ?? []

			let restore = {
				overlay.alpha = 0
				hiddenContent.forEach { $0.view.alpha = $0.alpha }
			}
			let removal: (Bool) -> Void = { _ in overlay.removeFromSuperview() }
			if UIAccessibility.isReduceMotionEnabled {
				restore()
				removal(true)
			} else {
				UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState], animations: restore, completion: removal)
			}
		}
	}

	/// Renders a Gaussian blurred image of the given view's current content.
	///
	/// - Parameter view: The view to snapshot.
	///
	/// - Returns: The blurred image.
	private func blurredImage(of view: UIView) -> UIImage? {
		guard view.bounds.width > 0, view.bounds.height > 0 else { return nil }

		let paddedSize = CGSize(width: view.bounds.width + self.blurInset * 2, height: view.bounds.height + self.blurInset * 2)
		let renderer = UIGraphicsImageRenderer(size: paddedSize)
		let snapshot = renderer.image { context in
			context.cgContext.translateBy(x: self.blurInset, y: self.blurInset)
			view.layer.render(in: context.cgContext)
		}

		guard let inputImage = CIImage(image: snapshot) else { return nil }
		let blurred = inputImage.applyingGaussianBlur(sigma: 8 * snapshot.scale)

		guard let cgImage = self.blurContext.createCGImage(blurred, from: inputImage.extent) else { return nil }
		return UIImage(cgImage: cgImage, scale: snapshot.scale, orientation: .up)
	}
	#endif

	/// Presents the current song's lyrics as a sheet.
	private func presentLyrics() {
		guard let songID = self.currentKKSong?.id, let viewController = UIApplication.topViewController else { return }

		let lyricsViewController = LyricsViewController(songID: songID)
		let navigationController = KNavigationController(rootViewController: lyricsViewController)
		navigationController.modalPresentationStyle = .pageSheet
		viewController.present(navigationController, animated: true)
	}
}

// MARK: - UIGestureRecognizerDelegate
@available(iOS 26.0, *)
extension MusicPlaybackControlView: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return !self.hitsInteractiveView(at: touch.location(in: self))
	}
}

// MARK: - UIContextMenuInteractionDelegate
@available(iOS 26.0, *)
extension MusicPlaybackControlView: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		guard
			!self.hitsInteractiveView(at: location),
			let kkSong = self.currentKKSong,
			let viewController = UIApplication.topViewController
		else { return nil }

		return kkSong.contextMenuConfiguration(
			in: viewController,
			userInfo: self.currentSongUserInfo,
			sourceView: self,
			barButtonItem: nil
		)
	}

	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let previewVC = animator.previewViewController else { return }

		animator.addCompletion {
			guard let viewController = UIApplication.topViewController else { return }
			viewController.show(previewVC, sender: self)
		}
	}
}
