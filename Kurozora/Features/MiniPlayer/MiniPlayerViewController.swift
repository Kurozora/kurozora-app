//
//  MiniPlayerViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Combine
import KurozoraKit
import UIKit

/// The MiniPlayer window's content.
@available(iOS 17.0, *)
final class MiniPlayerViewController: UIViewController {
	// MARK: - Enums
	/// The size regime the window is currently in.
	private enum Regime {
		/// The compact bar with inline metadata and transport controls.
		case bar

		/// The compact bar with a lyrics pane beneath it.
		case barExpanded

		/// The square artwork card with hover-revealed controls.
		case square

		/// The artwork card with a lyrics pane beneath it.
		case expanded
	}

	// MARK: - Views
	/// The window's fallback background.
	private let backgroundView: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The artwork filling the window.
	private let artworkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.image = .Placeholders.musicAlbum
		imageView.isUserInteractionEnabled = true
		return imageView
	}()

	/// The hover-revealed backdrop carrying the controls over the artwork.
	private let artworkOverlayView: PassthroughView = {
		let view = PassthroughView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.overrideUserInterfaceStyle = .dark
		view.alpha = 0
		return view
	}()

	/// The group carrying the artwork's blur steps.
	private let overlayBlurGroupView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		return view
	}()

	/// The clips bounding each blur step to the overlay.
	private let overlayBlurContainerViews: [UIView] = MiniPlayerViewController.artworkBlurSteps.map { _ in
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.clipsToBounds = true
		return view
	}

	/// The blurred copies of the artwork, one per step.
	private let overlayBlurImageViews: [UIImageView] = MiniPlayerViewController.artworkBlurSteps.map { step in
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.image = .Placeholders.musicAlbum
		if let blurFilter = GaussianBlur.filter(radius: step.radius, normalizesEdges: true) {
			imageView.layer.filters = [blurFilter]
		}
		return imageView
	}

	/// The masks bringing each blur step in over its own band.
	private let overlayBlurMaskViews: [GradientMaskView] = MiniPlayerViewController.artworkBlurSteps.map { step in
		.topFade(clearUntil: step.from / MiniPlayerViewController.overlayHeight, solidFrom: step.to / MiniPlayerViewController.overlayHeight)
	}

	/// The scrim darkening the blurred artwork.
	private let overlayScrimView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.backgroundColor = .black.withAlphaComponent(0.35)
		return view
	}()

	/// The alpha mask ramping the scrim in across the overlay.
	private let overlayScrimMaskView: GradientMaskView = .easedTopFade(midpointOpacity: 0.65, solidFrom: 0.86)

	/// The metadata, progress, and transport cluster.
	private let controlsView: MiniPlayerControlsView = {
		let view = MiniPlayerControlsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The container holding the lyrics pane.
	private let lyricsContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		return view
	}()

	/// The stand-in shown in the lyrics pane while nothing is playing.
	private let lyricsPlaceholderLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 12)
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.numberOfLines = 0
		label.text = L10n.playASongToSeeLyrics
		label.isHidden = true
		return label
	}()

	/// The lyrics pane's chrome, outside its edge fade.
	private let lyricsChromeView: PassthroughView = {
		let view = PassthroughView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.clipsToBounds = true
		return view
	}()

	/// The alpha mask fading the lyrics pane out at its top and bottom edges.
	private let lyricsEdgeMaskView: GradientMaskView = .verticalEdgeFade(topSolidFrom: 0.12, bottomSolidUntil: 0.52)

	/// The background behind the bar's song menu.
	private let barMenuBackgroundView: UIVisualEffectView = {
		let view = MiniPlayerControlsView.makeGlassBackgroundView(cornerRadius: 18)
		view.alpha = 0
		return view
	}()

	/// The song menu shown over the bar.
	private let barMenuControl: MenuControl = {
		let control = MenuControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.fixedHighlightDiameter = 36
		let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
		control.symbolImage = UIImage(systemName: "ellipsis", withConfiguration: config)
		control.alpha = 0
		return control
	}()

	/// The container carrying the hover pill.
	private let pillContainerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.alpha = 0
		return view
	}()

	/// The background behind the hover pill.
	private let pillBackgroundView: UIVisualEffectView = MiniPlayerControlsView.makeGlassBackgroundView(cornerRadius: 18)

	/// The stack of controls in the hover pill.
	private let pillStack: UIStackView = {
		let stack = UIStackView()
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .horizontal
		stack.alignment = .center
		return stack
	}()

	/// The volume control in the hover pill.
	private let volumeControl: VolumeControl = {
		let control = VolumeControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.tintColor = .label
		control.sliderExtent = 79
		control.presentsSliderOnTap = true
		return control
	}()

	/// The AirPlay control in the hover pill.
	private let airPlayControl: AirPlayControl = {
		let control = AirPlayControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()

	#if targetEnvironment(macCatalyst)
	/// The lyrics control in the hover pill.
	private let lyricsControl: TransportButton = {
		let control = TransportButton()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.fixedHighlightSize = CGSize(width: 38, height: 28)
		control.activeHighlightStyle = .solidTint
		let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
		control.symbolImage = UIImage(systemName: "quote.bubble", withConfiguration: config)
		return control
	}()
	#endif

	// MARK: - Properties
	/// The smallest window size.
	static let minimumWindowSize = CGSize(width: 320, height: 146)

	/// The widest the window is allowed to grow.
	static let maximumWindowWidth: CGFloat = 600

	/// The height of the compact bar.
	private static let barHeight: CGFloat = 146

	/// The edge length the window opens at when it has no saved frame.
	private static let defaultSquareSize: CGFloat = 320

	/// The window height below which the layout is the compact bar.
	private static let barCeilingHeight: CGFloat = 250

	/// The smallest lyrics pane height that justifies the expanded regime.
	private static let lyricsMinimumHeight: CGFloat = 200

	/// The lyrics pane height requested the first time the lyrics button expands the window.
	private static let expandedLyricsHeight: CGFloat = 331

	/// The width of the window's resize border.
	private static let resizeBorderWidth: CGFloat = 6

	/// How long the pointer may sit still before the hover chrome settles back out.
	private static let hoverIdleTimeout: TimeInterval = 3

	/// The shortest gap between two runs of the same view option.
	private static let viewOptionRepeatInterval: TimeInterval = 0.4

	/// The height of the hover scrim over the artwork's bottom edge.
	private static let overlayHeight: CGFloat = 195

	/// The height of the controls cluster within the hover scrim.
	private static let overlayControlsHeight: CGFloat = 170

	/// The steps of the artwork's progressive blur.
	///
	/// Each step names a radius and the depths into the overlay where that radius begins and
	/// finishes appearing. Steps overlap, so the sharp artwork never meets a fully blurred copy.
	private static let artworkBlurSteps: [(radius: CGFloat, from: CGFloat, to: CGFloat)] = [
		(2, 4, 16),
		(5, 14, 30),
		(10, 28, 50),
		(16, 46, 90),
	]

	/// The MiniPlayer currently on screen.
	private(set) static weak var current: MiniPlayerViewController?

	/// Whether the lyrics pane is showing.
	var showsLyricsPane: Bool {
		return self.appliedRegime == .expanded || self.appliedRegime == .barExpanded
	}

	/// Whether the artwork card is showing rather than the compact bar.
	var showsArtworkCard: Bool {
		return !(self.appliedRegime == .bar || self.appliedRegime == .barExpanded)
	}

	/// The playback controller that drives this window.
	private let playbackController: MediaPlaybackControlling = MusicManager.shared

	/// The set of subscriptions for the playback controller's publishers.
	private var subscriptions = Set<AnyCancellable>()

	/// The Kurozora song model for the currently playing song.
	private var currentKKSong: KKSong?

	/// The embedded lyrics pane for the current song.
	private var lyricsViewController: LyricsViewController?

	/// The song the embedded lyrics pane belongs to.
	private var embeddedLyricsSongID: KurozoraItemID?

	/// Whether the lyrics pane's view is installed in its container.
	private var isLyricsViewAttached = false

	/// Whether the window is animating down to dismiss the lyrics pane.
	private var isLyricsCollapsing = false

	/// The height the lyrics pane last occupied.
	private var lyricsRestorePaneHeight: CGFloat?

	/// The regime the layout currently reflects.
	private var appliedRegime: Regime?

	/// The constraint set of the applied regime.
	private var regimeConstraints: [NSLayoutConstraint] = []

	/// Whether the view has fully appeared.
	private var hasAppeared = false

	/// Whether the hover-revealed overlays are showing.
	private var overlaysVisible = false

	/// Whether the lyrics pane is presented by the lyrics button.
	private var isLyricsPresented = false

	/// When a view option last ran.
	private var lastViewOptionToggle: TimeInterval = 0

	/// Whether the presented lyrics pane extends the compact bar rather than the artwork card.
	private var lyricsBaseIsBar = false

	#if targetEnvironment(macCatalyst)
	/// The bridge styling the AppKit window.
	private let windowBridge = MiniPlayerWindowBridge()

	/// Whether the first-launch default size has been applied.
	private var didApplyDefaultSize = false

	/// The pending settle-out of the hover chrome.
	private var hoverIdleWorkItem: DispatchWorkItem?
	#endif

	/// The context menu user info for the currently playing song.
	private var currentSongUserInfo: [AnyHashable: Any]? {
		guard let mkSong = self.playbackController.currentSong else { return nil }
		return ["song": mkSong]
	}

	/// The view options' shortcuts.
	override var keyCommands: [UIKeyCommand]? {
		return self.makeViewOptionsMenu().children.compactMap { $0 as? UIKeyCommand }
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.backgroundColor = .systemBackground

		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureInteractions()
		self.bind()

		self.controlsView.playbackController = self.playbackController
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if self.lyricsEdgeMaskView.frame != self.lyricsContainerView.bounds {
			self.lyricsEdgeMaskView.frame = self.lyricsContainerView.bounds
		}

		for (index, maskView) in self.overlayBlurMaskViews.enumerated() where maskView.frame != self.overlayBlurContainerViews[index].bounds {
			maskView.frame = self.overlayBlurContainerViews[index].bounds
		}

		if self.overlayScrimMaskView.frame != self.overlayScrimView.bounds {
			self.overlayScrimMaskView.frame = self.overlayScrimView.bounds
		}

		if self.isLyricsCollapsing {
			let baseHeight = self.lyricsBaseIsBar ? Self.barHeight : self.view.bounds.width
			if self.view.bounds.height <= baseHeight + 1 {
				self.isLyricsCollapsing = false
				self.isLyricsPresented = false
			}
		}

		let regime = self.resolveRegime()
		if regime != self.appliedRegime {
			#if targetEnvironment(macCatalyst)
			let bothBarAndSquare = (regime == .bar || regime == .square) && (self.appliedRegime == .bar || self.appliedRegime == .square)
			if !(bothBarAndSquare && self.windowBridge.isInLiveResize) {
				self.applyRegime(regime)
			}
			#else
			self.applyRegime(regime)
			#endif
		}

		self.updateMorph()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.hasAppeared = true
		Self.current = self
		self.becomeFirstResponder()
		self.prepareLyricsIfNeeded()
		self.attachLyricsViewIfNeeded()

		#if targetEnvironment(macCatalyst)
		self.attachWindowBridge()
		#endif

		self.view.window?.alpha = 1
	}

	// MARK: - Functions
	/// Builds the view hierarchy.
	private func configureViewHierarchy() {
		#if targetEnvironment(macCatalyst)
		self.pillStack.addArrangedSubview(self.lyricsControl)
		#endif
		self.pillStack.addArrangedSubview(self.airPlayControl)
		self.pillStack.addArrangedSubview(self.volumeControl)

		self.pillContainerView.addSubview(self.pillBackgroundView)
		self.pillContainerView.addSubview(self.pillStack)

		for (index, containerView) in self.overlayBlurContainerViews.enumerated() {
			containerView.addSubview(self.overlayBlurImageViews[index])
			containerView.mask = self.overlayBlurMaskViews[index]
			self.overlayBlurGroupView.addSubview(containerView)
		}
		self.artworkOverlayView.addSubview(self.overlayBlurGroupView)
		self.artworkOverlayView.addSubview(self.overlayScrimView)
		self.overlayScrimView.mask = self.overlayScrimMaskView
		self.lyricsContainerView.mask = self.lyricsEdgeMaskView

		self.view.addSubview(self.backgroundView)
		self.view.addSubview(self.lyricsContainerView)
		self.view.addSubview(self.lyricsChromeView)
		self.lyricsChromeView.addSubview(self.lyricsPlaceholderLabel)
		self.view.addSubview(self.artworkImageView)
		self.view.addSubview(self.artworkOverlayView)
		self.view.addSubview(self.barMenuBackgroundView)
		self.view.addSubview(self.barMenuControl)
		self.view.addSubview(self.pillContainerView)
	}

	/// Activates the constraints shared by every regime.
	private func configureViewConstraints() {
		var constraints = [
			self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

			self.artworkOverlayView.leadingAnchor.constraint(equalTo: self.artworkImageView.leadingAnchor),
			self.artworkOverlayView.trailingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor),
			self.artworkOverlayView.heightAnchor.constraint(equalToConstant: Self.overlayHeight),

			self.artworkOverlayView.bottomAnchor.constraint(lessThanOrEqualTo: self.artworkImageView.bottomAnchor),
			self.artworkOverlayView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor),
			{
				let constraint = self.artworkOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
				constraint.priority = .defaultHigh
				return constraint
			}(),

			self.overlayBlurGroupView.topAnchor.constraint(equalTo: self.artworkOverlayView.topAnchor),
			self.overlayBlurGroupView.bottomAnchor.constraint(equalTo: self.artworkOverlayView.bottomAnchor),
			self.overlayBlurGroupView.leadingAnchor.constraint(equalTo: self.artworkOverlayView.leadingAnchor),
			self.overlayBlurGroupView.trailingAnchor.constraint(equalTo: self.artworkOverlayView.trailingAnchor),

			self.overlayScrimView.topAnchor.constraint(equalTo: self.artworkOverlayView.topAnchor),
			self.overlayScrimView.bottomAnchor.constraint(equalTo: self.artworkOverlayView.bottomAnchor),
			self.overlayScrimView.leadingAnchor.constraint(equalTo: self.artworkOverlayView.leadingAnchor),
			self.overlayScrimView.trailingAnchor.constraint(equalTo: self.artworkOverlayView.trailingAnchor),

			self.lyricsChromeView.topAnchor.constraint(equalTo: self.lyricsContainerView.topAnchor),
			self.lyricsChromeView.bottomAnchor.constraint(equalTo: self.lyricsContainerView.bottomAnchor),
			self.lyricsChromeView.leadingAnchor.constraint(equalTo: self.lyricsContainerView.leadingAnchor),
			self.lyricsChromeView.trailingAnchor.constraint(equalTo: self.lyricsContainerView.trailingAnchor),

			self.lyricsPlaceholderLabel.centerXAnchor.constraint(equalTo: self.lyricsChromeView.centerXAnchor),
			self.lyricsPlaceholderLabel.centerYAnchor.constraint(equalTo: self.lyricsChromeView.centerYAnchor),
			self.lyricsPlaceholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.lyricsChromeView.leadingAnchor, constant: 16),
			self.lyricsPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.lyricsChromeView.trailingAnchor, constant: -16),

			self.barMenuBackgroundView.centerXAnchor.constraint(equalTo: self.barMenuControl.centerXAnchor),
			self.barMenuBackgroundView.centerYAnchor.constraint(equalTo: self.barMenuControl.centerYAnchor),
			self.barMenuBackgroundView.widthAnchor.constraint(equalToConstant: 36),
			self.barMenuBackgroundView.heightAnchor.constraint(equalToConstant: 36),

			self.barMenuControl.trailingAnchor.constraint(equalTo: self.pillContainerView.leadingAnchor, constant: -6),
			self.barMenuControl.centerYAnchor.constraint(equalTo: self.pillContainerView.centerYAnchor),
			self.barMenuControl.widthAnchor.constraint(equalToConstant: 44),
			self.barMenuControl.heightAnchor.constraint(equalToConstant: 44),

			self.pillContainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
			self.pillContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
			self.pillContainerView.heightAnchor.constraint(equalToConstant: 36),

			self.pillBackgroundView.topAnchor.constraint(equalTo: self.pillContainerView.topAnchor),
			self.pillBackgroundView.bottomAnchor.constraint(equalTo: self.pillContainerView.bottomAnchor),
			self.pillBackgroundView.leadingAnchor.constraint(equalTo: self.pillContainerView.leadingAnchor),
			self.pillBackgroundView.trailingAnchor.constraint(equalTo: self.pillContainerView.trailingAnchor),

			self.pillStack.leadingAnchor.constraint(equalTo: self.pillContainerView.leadingAnchor, constant: 3),
			self.pillStack.topAnchor.constraint(equalTo: self.pillContainerView.topAnchor),
			self.pillStack.bottomAnchor.constraint(equalTo: self.pillContainerView.bottomAnchor),
			self.pillStack.trailingAnchor.constraint(equalTo: self.pillContainerView.trailingAnchor, constant: -3),

			self.airPlayControl.widthAnchor.constraint(equalToConstant: 38),
			self.airPlayControl.heightAnchor.constraint(equalToConstant: 36),
			self.volumeControl.widthAnchor.constraint(equalToConstant: 38),
			self.volumeControl.heightAnchor.constraint(equalToConstant: 36),
		]

		for (index, containerView) in self.overlayBlurContainerViews.enumerated() {
			let imageView = self.overlayBlurImageViews[index]
			constraints += [
				containerView.topAnchor.constraint(equalTo: self.overlayBlurGroupView.topAnchor),
				containerView.bottomAnchor.constraint(equalTo: self.overlayBlurGroupView.bottomAnchor),
				containerView.leadingAnchor.constraint(equalTo: self.overlayBlurGroupView.leadingAnchor),
				containerView.trailingAnchor.constraint(equalTo: self.overlayBlurGroupView.trailingAnchor),

				imageView.topAnchor.constraint(equalTo: self.artworkImageView.topAnchor),
				imageView.bottomAnchor.constraint(equalTo: self.artworkImageView.bottomAnchor),
				imageView.leadingAnchor.constraint(equalTo: self.artworkImageView.leadingAnchor),
				imageView.trailingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor),
			]
		}

		#if targetEnvironment(macCatalyst)
		constraints += [
			self.lyricsControl.widthAnchor.constraint(equalToConstant: 38),
			self.lyricsControl.heightAnchor.constraint(equalToConstant: 36),
		]
		#endif

		NSLayoutConstraint.activate(constraints)
	}

	/// Wires up the gestures and the window bridge's callbacks.
	private func configureInteractions() {
		#if !targetEnvironment(macCatalyst)
		let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(self.handleRootHover(_:)))
		hoverGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(hoverGestureRecognizer)
		#endif

		#if !targetEnvironment(macCatalyst)
		self.backgroundView.addInteraction(UIWindowSceneDragInteraction())
		self.artworkImageView.addInteraction(UIWindowSceneDragInteraction())
		#endif

		self.controlsView.onScrubPreview = { [weak self] seconds in
			self?.lyricsViewController?.setPreviewPosition(seconds)
		}

		let menuProvider = { [weak self] in
			self?.makeSongMenu()
		}
		self.controlsView.menuProvider = menuProvider
		self.barMenuControl.menuProvider = menuProvider

		self.volumeControl.onSliderPresentationChange = { [weak self] revealed in
			self?.setPillSliderRevealed(revealed)
		}

		#if targetEnvironment(macCatalyst)
		self.lyricsControl.addAction(UIAction { [weak self] _ in
			self?.toggleLyricsRegime()
		}, for: .touchUpInside)

		self.windowBridge.onLiveResizeStart = { [weak self] in
			self?.setOverlaysVisible(true)
		}

		self.windowBridge.onLiveResizeEnd = { [weak self] in
			guard let self = self else { return }
			self.snapWindowToRegime()
			self.setOverlaysVisible(self.windowBridge.isPointerInsideWindow)
			self.view.setNeedsLayout()
		}

		self.windowBridge.onScrollWheel = { [weak self] locationInWindow, deltaY in
			return self?.scrollLyrics(atWindowLocation: locationInWindow, deltaY: deltaY) ?? false
		}

		self.windowBridge.shouldDragWindow = { [weak self] locationInWindow in
			return self?.dragsWindow(fromWindowLocation: locationInWindow) ?? false
		}

		self.windowBridge.onHoverChange = { [weak self] hovering in
			self?.setOverlaysVisible(hovering)
		}

		self.windowBridge.onPointerActivity = { [weak self] in
			guard let self = self else { return }
			// A key window receives moves from anywhere on screen.
			guard self.windowBridge.isPointerInsideWindow else { return }

			self.setOverlaysVisible(true)
			self.restartHoverIdleTimer()
		}
		#endif
	}

	/// Subscribes to the playback controller's publishers.
	private func bind() {
		self.playbackController.currentSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] song in
				self?.loadArtwork(for: song)
			}
			.store(in: &self.subscriptions)

		self.playbackController.currentKKSongPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] kkSong in
				guard let self = self else { return }
				self.currentKKSong = kkSong
				self.lyricsPlaceholderLabel.isHidden = kkSong != nil
				self.prepareLyricsIfNeeded()
			}
			.store(in: &self.subscriptions)
	}

	/// Loads the artwork card for the given song.
	private func loadArtwork(for song: MKSong?) {
		guard let artworkURL = song?.song.artwork?.url(width: 1024, height: 1024)?.absoluteString else {
			self.artworkImageView.image = .Placeholders.musicAlbum
			self.overlayBlurImageViews.forEach { $0.image = .Placeholders.musicAlbum }
			return
		}

		self.artworkImageView.setImage(with: artworkURL, placeholder: .Placeholders.musicAlbum) { [weak self] image in
			self?.overlayBlurImageViews.forEach { $0.image = image }
		}
	}

	/// Reveals or hides the volume slider in the pill.
	///
	/// - Parameter revealed: Whether the slider takes the pill over.
	private func setPillSliderRevealed(_ revealed: Bool) {
		#if targetEnvironment(macCatalyst)
		self.lyricsControl.isUserInteractionEnabled = !revealed
		self.windowBridge.setWindowMovable(!revealed)
		#endif
		self.backgroundView.isUserInteractionEnabled = !revealed
		self.airPlayControl.isUserInteractionEnabled = !revealed

		let animations = { [weak self] in
			guard let self = self else { return }
			#if targetEnvironment(macCatalyst)
			self.lyricsControl.alpha = revealed ? 0 : 1
			#endif
			self.airPlayControl.alpha = revealed ? 0 : 1
		}

		if UIAccessibility.isReduceMotionEnabled {
			animations()
		} else {
			UIView.animate(withDuration: 0.2, animations: animations)
		}
	}

	/// Scrolls the lyrics pane for a window level wheel event.
	///
	/// - Parameters:
	///    - location: The event location in the window's bottom-left based coordinates.
	///    - deltaY: The scrolling delta.
	///
	/// - Returns: Whether the event was consumed.
	private func scrollLyrics(atWindowLocation location: CGPoint, deltaY: CGFloat) -> Bool {
		guard self.isLyricsViewAttached, !self.lyricsContainerView.isHidden, let tableView = self.lyricsViewController?.tableView else { return false }

		let point = CGPoint(x: location.x, y: self.view.bounds.height - location.y)
		guard self.lyricsContainerView.frame.contains(point) else { return false }

		let minY = -tableView.adjustedContentInset.top
		let maxY = max(minY, tableView.contentSize.height - tableView.bounds.height + tableView.adjustedContentInset.bottom)
		let targetY = min(max(tableView.contentOffset.y - deltaY, minY), maxY)
		tableView.contentOffset = CGPoint(x: 0, y: targetY)
		return true
	}

	/// Whether a press at the given point drags the window rather than reaching the content.
	///
	/// - Parameter location: The press location in the window's bottom-left based coordinates.
	///
	/// - Returns: Whether the press starts a window drag.
	private func dragsWindow(fromWindowLocation location: CGPoint) -> Bool {
		let point = CGPoint(x: location.x, y: self.view.bounds.height - location.y)
		guard self.view.bounds.insetBy(dx: Self.resizeBorderWidth, dy: Self.resizeBorderWidth).contains(point) else { return false }

		guard let hitView = self.view.hitTest(point, with: nil) else { return true }
		if hitView === self.view || hitView === self.backgroundView || hitView === self.artworkImageView {
			return true
		}

		var candidate: UIView? = hitView
		while let view = candidate {
			if view is UIControl || view is UITableViewCell {
				return false
			}
			if view === self.lyricsContainerView {
				return true
			}
			candidate = view.superview
		}

		return false
	}

	// MARK: Regimes
	/// Updates the layout for the current window size.
	private func updateMorph() {
		let progress = self.morphProgress()
		self.artworkImageView.alpha = progress
		self.overlayBlurGroupView.alpha = progress
		self.controlsView.setMorphProgress(progress)
	}

	/// How far the layout has morphed from the compact bar towards the artwork card.
	///
	/// - Returns: `0` for the bar's metrics, `1` for the card's.
	private func morphProgress() -> CGFloat {
		switch self.appliedRegime {
		case .barExpanded:
			return 0
		case .expanded:
			return 1
		default:
			let height = self.view.bounds.height
			return max(0, min(1, (height - Self.barHeight) / (Self.barCeilingHeight - Self.barHeight)))
		}
	}

	/// Returns the regime for the current bounds.
	private func resolveRegime() -> Regime {
		let size = self.view.bounds.size

		if self.isLyricsPresented {
			return self.lyricsBaseIsBar ? .barExpanded : .expanded
		}

		if size.height < Self.barCeilingHeight {
			return .bar
		}
		if size.height <= size.width {
			return .square
		}
		return .expanded
	}

	/// Rebuilds the layout for the given regime.
	///
	/// - Parameter regime: The regime to apply.
	private func applyRegime(_ regime: Regime) {
		let previousRegime = self.appliedRegime
		self.appliedRegime = regime

		NSLayoutConstraint.deactivate(self.regimeConstraints)

		switch regime {
		case .bar, .barExpanded:
			self.view.addSubview(self.controlsView)
			self.regimeConstraints = [
				self.artworkImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.artworkImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				self.artworkImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				self.artworkImageView.heightAnchor.constraint(equalTo: self.artworkImageView.widthAnchor),

				self.controlsView.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.controlsView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				self.controlsView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			]

			if regime == .barExpanded {
				self.regimeConstraints += [
					self.controlsView.heightAnchor.constraint(equalToConstant: Self.barHeight),

					self.lyricsContainerView.topAnchor.constraint(equalTo: self.controlsView.bottomAnchor),
					self.lyricsContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
					self.lyricsContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
					self.lyricsContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
				]
			} else {
				self.regimeConstraints.append(self.controlsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor))
			}
			self.controlsView.form = .bar
		case .square, .expanded:
			self.artworkOverlayView.addSubview(self.controlsView)
			self.regimeConstraints = [
				self.artworkImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.artworkImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				self.artworkImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				self.artworkImageView.heightAnchor.constraint(equalTo: self.artworkImageView.widthAnchor),

				self.controlsView.leadingAnchor.constraint(equalTo: self.artworkOverlayView.leadingAnchor),
				self.controlsView.trailingAnchor.constraint(equalTo: self.artworkOverlayView.trailingAnchor),
				self.controlsView.bottomAnchor.constraint(equalTo: self.artworkOverlayView.bottomAnchor),
				self.controlsView.heightAnchor.constraint(equalToConstant: Self.overlayControlsHeight),

				self.lyricsContainerView.topAnchor.constraint(equalTo: self.artworkImageView.bottomAnchor),
				self.lyricsContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				self.lyricsContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				self.lyricsContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			]
			self.controlsView.form = .overlay
		}

		NSLayoutConstraint.activate(self.regimeConstraints)

		let showsLyrics = regime == .expanded || regime == .barExpanded
		self.artworkImageView.isHidden = regime == .barExpanded
		self.lyricsContainerView.isHidden = !showsLyrics
		self.lyricsChromeView.isHidden = !showsLyrics
		self.reconcileOverlays(animated: previousRegime != nil)

		if showsLyrics {
			self.attachLyricsViewIfNeeded()
		} else {
			self.detachLyricsView()
		}

		#if targetEnvironment(macCatalyst)
		self.lyricsControl.isActive = showsLyrics
		UIMenuSystem.main.setNeedsRebuild()
		#endif
	}

	// MARK: Hover
	#if !targetEnvironment(macCatalyst)
	/// Updates the hover state from the pointer.
	///
	/// - Parameter gestureRecognizer: The hover gesture recognizer reporting the pointer state.
	@objc private func handleRootHover(_ gestureRecognizer: UIHoverGestureRecognizer) {
		let isHovering = gestureRecognizer.state == .began || gestureRecognizer.state == .changed
		self.setOverlaysVisible(isHovering)
	}
	#endif

	#if targetEnvironment(macCatalyst)
	/// Restarts the hover chrome's idle countdown.
	private func restartHoverIdleTimer() {
		self.hoverIdleWorkItem?.cancel()

		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }

			guard !self.windowBridge.isPointerDown, !self.windowBridge.isInLiveResize else {
				self.restartHoverIdleTimer()
				return
			}
			self.setOverlaysVisible(false)
		}
		self.hoverIdleWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + Self.hoverIdleTimeout, execute: workItem)
	}
	#endif

	/// Shows or hides the hover chrome.
	///
	/// - Parameter visible: Whether the overlays are showing.
	private func setOverlaysVisible(_ visible: Bool) {
		guard self.overlaysVisible != visible else { return }
		self.overlaysVisible = visible

		if !visible {
			#if targetEnvironment(macCatalyst)
			self.hoverIdleWorkItem?.cancel()
			#endif
			self.volumeControl.dismissSlider()
		}

		#if targetEnvironment(macCatalyst)
		self.attachWindowBridge()
		self.windowBridge.setTrafficLightsHidden(!visible)
		#endif

		self.reconcileOverlays(animated: true)
	}

	/// Applies the hover chrome's visibility for the current regime.
	///
	/// - Parameter animated: Whether to animate the fades.
	private func reconcileOverlays(animated: Bool) {
		let visible = self.overlaysVisible
		let isBar = self.appliedRegime == .bar || self.appliedRegime == .barExpanded

		self.controlsView.setMetadataHidden(isBar && visible, animated: animated)

		let animations = { [weak self] in
			guard let self = self else { return }
			self.pillContainerView.alpha = visible ? 1 : 0
			self.barMenuControl.alpha = (isBar && visible) ? 1 : 0
			self.barMenuBackgroundView.alpha = (isBar && visible) ? 1 : 0
			self.artworkOverlayView.alpha = (!isBar && visible) ? 1 : 0
		}

		if animated, !UIAccessibility.isReduceMotionEnabled {
			UIView.animate(withDuration: 0.2, animations: animations)
		} else {
			animations()
		}
	}

	// MARK: Lyrics
	/// Prepares the lyrics pane for the current song.
	private func prepareLyricsIfNeeded() {
		let songID = self.currentKKSong?.id
		guard self.embeddedLyricsSongID != songID else { return }

		self.destroyLyrics()

		guard let songID = songID else { return }

		let lyricsViewController = LyricsViewController(songID: songID)
		lyricsViewController.isEmbeddedPresentation = true
		lyricsViewController.onScrollInteractionChange = { [weak self] suppressed in
			self?.setLyricsEdgeFadeReduced(suppressed)
		}

		self.addChild(lyricsViewController)
		lyricsViewController.loadViewIfNeeded()
		lyricsViewController.didMove(toParent: self)

		self.lyricsViewController = lyricsViewController
		self.embeddedLyricsSongID = songID

		self.attachLyricsViewIfNeeded()
	}

	/// Adds the lyrics pane to its container.
	///
	/// Forwards the appearance transitions itself, which UIKit skips for a child added to a visible parent.
	private func attachLyricsViewIfNeeded() {
		guard self.appliedRegime == .expanded || self.appliedRegime == .barExpanded, self.hasAppeared else { return }
		guard let lyricsViewController = self.lyricsViewController, !self.isLyricsViewAttached else { return }

		lyricsViewController.view.translatesAutoresizingMaskIntoConstraints = false
		lyricsViewController.beginAppearanceTransition(true, animated: false)
		self.lyricsContainerView.addSubview(lyricsViewController.view)
		NSLayoutConstraint.activate([
			lyricsViewController.view.topAnchor.constraint(equalTo: self.lyricsContainerView.topAnchor),
			lyricsViewController.view.bottomAnchor.constraint(equalTo: self.lyricsContainerView.bottomAnchor),
			lyricsViewController.view.leadingAnchor.constraint(equalTo: self.lyricsContainerView.leadingAnchor),
			lyricsViewController.view.trailingAnchor.constraint(equalTo: self.lyricsContainerView.trailingAnchor),
		])
		lyricsViewController.endAppearanceTransition()

		let optionsButton = lyricsViewController.translationOptionsButton
		self.lyricsChromeView.addSubview(optionsButton)
		NSLayoutConstraint.activate([
			optionsButton.trailingAnchor.constraint(equalTo: self.lyricsChromeView.trailingAnchor, constant: -12),
			optionsButton.bottomAnchor.constraint(equalTo: self.lyricsChromeView.bottomAnchor, constant: -12),
		])

		self.isLyricsViewAttached = true

		lyricsViewController.resyncToCurrentPosition()
	}

	/// Removes the lyrics pane from its container.
	private func detachLyricsView() {
		guard let lyricsViewController = self.lyricsViewController, self.isLyricsViewAttached else { return }

		lyricsViewController.translationOptionsButton.removeFromSuperview()
		lyricsViewController.beginAppearanceTransition(false, animated: false)
		lyricsViewController.view.removeFromSuperview()
		lyricsViewController.endAppearanceTransition()

		self.isLyricsViewAttached = false
	}

	/// Sets whether the lyrics pane's bottom fade is reduced.
	///
	/// - Parameter reduced: Whether the fade pulls back for manual scrolling.
	private func setLyricsEdgeFadeReduced(_ reduced: Bool) {
		let locations: [NSNumber] = reduced ? [0.0, 0.08, 0.95, 1.0] : [0.0, 0.08, 0.7, 1.0]

		CATransaction.begin()
		CATransaction.setAnimationDuration(0.3)
		self.lyricsEdgeMaskView.gradientLayer?.locations = locations
		CATransaction.commit()
	}

	/// Discards the lyrics pane.
	private func destroyLyrics() {
		self.detachLyricsView()

		guard let lyricsViewController = self.lyricsViewController else { return }

		lyricsViewController.willMove(toParent: nil)
		lyricsViewController.removeFromParent()

		self.lyricsViewController = nil
		self.embeddedLyricsSongID = nil
	}

	// MARK: Menu
	/// Builds the context menu for the current song.
	private func makeSongMenu() -> UIMenu? {
		let viewOptions = self.makeViewOptionsMenu()
		guard let kkSong = self.currentKKSong else { return viewOptions }

		let songMenu = kkSong.makeContextMenu(in: self, userInfo: self.currentSongUserInfo, sourceView: self.barMenuControl, barButtonItem: nil)
		return UIMenu(children: songMenu.children + [viewOptions])
	}

	/// Builds the window's view options.
	///
	/// - Returns: The grouped options.
	private func makeViewOptionsMenu() -> UIMenu {
		return UIMenu(options: .displayInline, children: Self.viewOptionCommands())
	}

	/// The window's view options.
	///
	/// - Returns: The commands.
	static func viewOptionCommands() -> [UIKeyCommand] {
		#if targetEnvironment(macCatalyst)
		let showsLyrics = Self.current?.showsLyricsPane ?? false
		let showsArtwork = Self.current?.showsArtworkCard ?? false

		return [
			UIKeyCommand(
				title: showsArtwork ? L10n.hideLargeArtwork : L10n.showLargeArtwork,
				image: UIImage(systemName: "photo"),
				action: #selector(MiniPlayerViewController.toggleLargeArtwork),
				input: "A",
				modifierFlags: [.alternate, .command]
			),
			UIKeyCommand(
				title: showsLyrics ? L10n.hideLyrics : L10n.showLyrics,
				image: UIImage(systemName: "quote.bubble"),
				action: #selector(MiniPlayerViewController.toggleLyricsRegime),
				input: "U",
				modifierFlags: [.control, .command]
			),
		]
		#else
		return []
		#endif
	}

	#if targetEnvironment(macCatalyst)
	// MARK: Window
	/// Hands the window's chrome over to the AppKit bridge.
	private func attachWindowBridge() {
		guard !self.windowBridge.isAttached else { return }

		self.windowBridge.attach(to: self.view.window)
		guard self.windowBridge.isAttached else { return }

		self.backgroundView.effect = nil
		self.view.backgroundColor = .clear
		self.view.window?.backgroundColor = .clear
		self.view.layer.cornerRadius = MiniPlayerWindowBridge.windowCornerRadius
		self.view.layer.cornerCurve = .continuous
		self.view.layer.masksToBounds = true

		if !self.windowBridge.hasRestoredFrame, !self.didApplyDefaultSize {
			self.didApplyDefaultSize = true
			self.requestWindowSize(CGSize(width: Self.defaultSquareSize, height: Self.defaultSquareSize), animated: false)
		}
	}

	/// Snaps the window onto the nearest regime's height.
	private func snapWindowToRegime() {
		let size = self.view.bounds.size

		if self.isLyricsPresented {
			let baseHeight = self.lyricsBaseIsBar ? Self.barHeight : size.width
			if size.height - baseHeight < Self.lyricsMinimumHeight {
				self.isLyricsCollapsing = true
				self.view.setNeedsLayout()
				self.requestWindowSize(CGSize(width: size.width, height: baseHeight), animated: true)
			} else {
				self.lyricsRestorePaneHeight = size.height - baseHeight
			}
			return
		}

		var targetHeight = size.height
		if size.height < Self.barCeilingHeight {
			targetHeight = Self.barHeight
		} else if size.height < size.width + Self.lyricsMinimumHeight {
			targetHeight = size.width
		} else {
			self.lyricsRestorePaneHeight = size.height - size.width
		}

		if abs(targetHeight - size.height) > 1 {
			self.requestWindowSize(CGSize(width: size.width, height: targetHeight), animated: true)
		}
	}

	/// Whether a view option may run now.
	///
	/// - Returns: Whether the toggle should run.
	private func acceptsViewOptionToggle() -> Bool {
		let now = CACurrentMediaTime()
		guard now - self.lastViewOptionToggle > Self.viewOptionRepeatInterval else { return false }

		self.lastViewOptionToggle = now
		return true
	}

	/// Toggles the window between the artwork card and the compact bar.
	@objc private func toggleLargeArtwork() {
		guard self.acceptsViewOptionToggle() else { return }

		let width = self.view.bounds.width
		let showsArtwork = !(self.appliedRegime == .bar || self.appliedRegime == .barExpanded)
		let paneHeight = max(0, self.view.bounds.height - (showsArtwork ? width : Self.barHeight))

		self.lyricsBaseIsBar = showsArtwork
		if paneHeight > 0 {
			self.isLyricsPresented = true
			self.lyricsRestorePaneHeight = paneHeight
		}

		let baseHeight = showsArtwork ? Self.barHeight : width
		self.requestWindowSize(CGSize(width: width, height: baseHeight + paneHeight), animated: true)
		self.view.setNeedsLayout()
	}

	/// Toggles the lyrics pane.
	@objc private func toggleLyricsRegime() {
		guard self.acceptsViewOptionToggle() else { return }

		let width = self.view.bounds.width
		let baseHeight = self.lyricsBaseIsBar ? Self.barHeight : width
		let paneHeight = self.lyricsRestorePaneHeight ?? Self.expandedLyricsHeight

		if self.isLyricsCollapsing {
			self.isLyricsCollapsing = false
			self.requestWindowSize(CGSize(width: width, height: baseHeight + paneHeight), animated: true)
		} else if self.isLyricsPresented {
			self.lyricsRestorePaneHeight = self.view.bounds.height - baseHeight
			self.isLyricsCollapsing = true
			self.requestWindowSize(CGSize(width: width, height: baseHeight), animated: true)
		} else if self.appliedRegime == .expanded {
			self.lyricsRestorePaneHeight = self.view.bounds.height - width
			self.requestWindowSize(CGSize(width: width, height: width), animated: true)
		} else {
			self.lyricsBaseIsBar = self.appliedRegime == .bar
			self.isLyricsPresented = true
			let newBaseHeight = self.lyricsBaseIsBar ? Self.barHeight : width
			self.requestWindowSize(CGSize(width: width, height: newBaseHeight + paneHeight), animated: true)
		}

		self.view.setNeedsLayout()
	}

	/// Resizes the window, keeping its top edge fixed.
	///
	/// - Parameters:
	///    - size: The window size to request.
	///    - animated: Whether the window animates to the new size.
	private func requestWindowSize(_ size: CGSize, animated: Bool) {
		if self.windowBridge.isAttached {
			self.windowBridge.setWindowSize(size, animated: animated)
			return
		}

		guard let windowScene = self.view.window?.windowScene else { return }

		var systemFrame = windowScene.effectiveGeometry.systemFrame
		systemFrame.size = size
		windowScene.requestGeometryUpdate(.Mac(systemFrame: systemFrame))
	}
	#endif
}

#if !targetEnvironment(macCatalyst)
// MARK: - UIGestureRecognizerDelegate
@available(iOS 17.0, *)
extension MiniPlayerViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}
#endif
