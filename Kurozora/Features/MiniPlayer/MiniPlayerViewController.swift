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
	private lazy var overlayBlurContainerViews: [UIView] = self.artworkBlurSteps.map { _ in
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.clipsToBounds = true
		return view
	}

	/// The blurred copies of the artwork, one per step.
	private lazy var overlayBlurImageViews: [UIImageView] = self.artworkBlurSteps.map { step in
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
	private lazy var overlayBlurMaskViews: [GradientMaskView] = self.artworkBlurSteps.map { step in
		.topFade(clearUntil: step.from / self.overlayHeight, solidFrom: step.to / self.overlayHeight)
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
	/// The region of the window the player's body occupies, inside the margins the pull tab grows
	/// into.
	private let contentGuide = UILayoutGuide()

	/// The blur veiling the window as the pointer carries it toward a side edge.
	private let edgeBlurView: UIVisualEffectView = {
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.alpha = 0
		return view
	}()

	/// The clips holding each margin's artwork to the margin it belongs to.
	private lazy var marginArtworkContainerViews: [UIView] = (0..<2).map { _ in
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		view.clipsToBounds = true
		return view
	}

	/// The artwork carried out into the margins, giving the pull tab its color.
	private lazy var marginArtworkImageViews: [UIImageView] = (0..<2).map { _ in
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.isUserInteractionEnabled = false
		imageView.image = .Placeholders.musicAlbum
		if let blurFilter = GaussianBlur.filter(radius: self.marginArtworkBlurRadius, normalizesEdges: true) {
			imageView.layer.filters = [blurFilter]
		}
		return imageView
	}

	/// The mask carrying the window's silhouette.
	private let dockMaskView = UIView()

	/// The fill giving the mask its shape.
	private let dockMaskShapeLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.fillColor = UIColor.white.cgColor
		return layer
	}()

	/// The chevron pointing back toward the screen.
	private let dockTabImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .center
		imageView.tintColor = .white
		return imageView
	}()

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
	private let barHeight: CGFloat = 146

	/// The edge length the window opens at when it has no saved frame.
	private let defaultSquareSize: CGFloat = 320

	/// The window height below which the layout is the compact bar.
	private let barCeilingHeight: CGFloat = 250

	/// The smallest lyrics pane height that justifies the expanded regime.
	private let lyricsMinimumHeight: CGFloat = 200

	/// The lyrics pane height requested the first time the lyrics button expands the window.
	private let expandedLyricsHeight: CGFloat = 331

	/// How long the pointer may sit still before the hover chrome settles back out.
	private let hoverIdleTimeout: TimeInterval = 3

	/// The shortest gap between two runs of the same view option.
	private let viewOptionRepeatInterval: TimeInterval = 0.4

	/// How long a new song holds the metadata on screen before it settles back out.
	private let songChangeRevealDuration: TimeInterval = 4

	/// How long the artwork takes to crossfade to a new song, matching the image loader's fade.
	private let artworkCrossfadeDuration: TimeInterval = 0.2

	/// The height of the hover scrim over the artwork's bottom edge.
	private let overlayHeight: CGFloat = 195

	/// The height of the controls cluster within the hover scrim.
	private let overlayControlsHeight: CGFloat = 170

	/// The steps of the artwork's progressive blur.
	///
	/// Each step names a radius and the depths into the overlay where that radius begins and
	/// finishes appearing. Steps overlap, so the sharp artwork never meets a fully blurred copy.
	private let artworkBlurSteps: [(radius: CGFloat, from: CGFloat, to: CGFloat)] = [
		(2, 4, 16),
		(5, 14, 30),
		(10, 28, 50),
		(16, 46, 90),
	]

	/// The blur radius of the artwork carried into the margins.
	private let marginArtworkBlurRadius: CGFloat = 24

	/// The MiniPlayer currently on screen.
	private(set) static weak var current: MiniPlayerViewController?

	/// The bounds of the player's body, inside the margin the pull tab grows into.
	private var contentBounds: CGRect {
		var bounds = self.view.bounds

		switch self.tabMarginSide {
		case .left:
			bounds.origin.x += Self.dockTabReach
			bounds.size.width -= Self.dockTabReach
		case .right:
			bounds.size.width -= Self.dockTabReach
		case nil:
			break
		}

		return bounds
	}

	/// Whether a MiniPlayer is floating above other apps on the active Space.
	///
	/// Other self-presenting windows should stand down while this is `true`.
	static var isFloatingOnActiveSpace: Bool {
		#if targetEnvironment(macCatalyst)
		guard UserSettings.miniPlayerStaysOnTop, let current = Self.current else { return false }
		return current.windowBridge.isVisibleOnActiveSpace
		#else
		return false
		#endif
	}

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
	private var lyricsRestorePaneHeight: CGFloat? {
		get {
			let height = UserSettings.miniPlayerLyricsPaneHeight
			return height > 0 ? CGFloat(height) : nil
		}
		set {
			UserSettings.set(Int((newValue ?? 0).rounded()), forKey: .miniPlayerLyricsPaneHeight)
		}
	}

	/// The regime the layout currently reflects.
	private var appliedRegime: Regime?

	/// The constraint set of the applied regime.
	private var regimeConstraints: [NSLayoutConstraint] = []

	/// Whether the view has fully appeared.
	private var hasAppeared = false

	/// Whether the hover-revealed overlays are showing.
	private var overlaysVisible = false

	/// Whether a song change is currently holding the metadata on screen.
	private var isRevealingForSongChange = false

	/// The pending end of the song change reveal.
	private var songChangeRevealWorkItem: DispatchWorkItem?

	/// Whether the lyrics pane is presented by the lyrics button.
	private var isLyricsPresented = false

	/// When a view option last ran.
	private var lastViewOptionToggle: TimeInterval = 0

	/// Whether the presented lyrics pane extends the compact bar rather than the artwork card.
	private var lyricsBaseIsBar = false

	#if targetEnvironment(macCatalyst)
	/// The transparent margin the window carries on either side of its body, which the pull tab
	/// grows into.
	static let dockTabReach: CGFloat = 24

	/// How much of the window is left on screen once it parks.
	///
	/// Slightly less than the tab's reach, so the body clears the edge completely.
	static let dockedVisibleWidth: CGFloat = 20

	/// The width of the pull tab.
	///
	/// The tab is wider than it ever stands out, so the part still behind the body keeps its corners
	/// out of sight.
	private let dockTabWidth: CGFloat = 44

	/// The height of the pull tab, independent of the window's own height.
	private let dockTabHeight: CGFloat = 96

	/// The corner radius of the pull tab.
	private let dockTabCornerRadius: CGFloat = 11

	/// The radius of the fillet where the pull tab meets the window body.
	private let dockJunctionRadius: CGFloat = 3

	/// How long the window takes to narrow into the pull tab, and to grow back out of it.
	private let dockMorphDuration: TimeInterval = 0.25

	/// The constraint pinning the dock tab to the window's leading edge.
	private var dockTabLeadingConstraint: NSLayoutConstraint?

	/// The constraint pinning the dock tab to the window's trailing edge.
	private var dockTabTrailingConstraint: NSLayoutConstraint?

	/// Whether the pull tab currently stands in for the window.
	private var isPullTabPresented = false

	/// Whether the pull tab has grown out to its full reach.
	private var isTabGrown = false

	/// The edge the window is docked against.
	private var dockedEdge: DockEdge?

	/// The side of the body the pull tab's margin lies on.
	private var tabMarginSide: DockEdge?

	/// The constraint holding the body clear of the leading margin.
	private var contentLeadingConstraint: NSLayoutConstraint?

	/// The constraint holding the body clear of the trailing margin.
	private var contentTrailingConstraint: NSLayoutConstraint?

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

		// Bring the masked views current before their masks take the same size.
		self.artworkOverlayView.layoutIfNeeded()
		self.lyricsContainerView.layoutIfNeeded()

		if self.lyricsEdgeMaskView.frame != self.lyricsContainerView.bounds {
			self.lyricsEdgeMaskView.frame = self.lyricsContainerView.bounds
		}

		#if targetEnvironment(macCatalyst)
		// The mask carries the window's shape, so it follows every resize.
		if self.windowBridge.isAttached {
			self.updateDockMaskFrame(tabReach: self.isTabGrown ? Self.dockTabReach : 0)
		}
		#endif

		for (index, maskView) in self.overlayBlurMaskViews.enumerated() where maskView.frame != self.overlayBlurContainerViews[index].bounds {
			maskView.frame = self.overlayBlurContainerViews[index].bounds
		}

		if self.overlayScrimMaskView.frame != self.overlayScrimView.bounds {
			self.overlayScrimMaskView.frame = self.overlayScrimView.bounds
		}

		if self.isLyricsCollapsing {
			let baseHeight = self.lyricsBaseIsBar ? self.barHeight : self.contentBounds.width
			if self.contentBounds.height <= baseHeight + 1 {
				self.isLyricsCollapsing = false
				self.isLyricsPresented = false
			}
		}

		let regime = self.resolveRegime()
		if regime != self.appliedRegime {
			#if targetEnvironment(macCatalyst)
			let bothBarAndSquare = (regime == .bar || regime == .square) && (self.appliedRegime == .bar || self.appliedRegime == .square)
			// A docked window keeps its regime.
			if !(bothBarAndSquare && self.windowBridge.isInLiveResize), self.dockedEdge == nil {
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

		#if targetEnvironment(macCatalyst)
		for (index, containerView) in self.marginArtworkContainerViews.enumerated() {
			containerView.addSubview(self.marginArtworkImageViews[index])
			self.view.insertSubview(containerView, at: 0)
		}

		self.view.addSubview(self.edgeBlurView)
		self.view.addSubview(self.dockTabImageView)
		self.dockMaskView.layer.addSublayer(self.dockMaskShapeLayer)
		#endif
	}

	/// Activates the constraints shared by every regime.
	private func configureViewConstraints() {
		self.view.addLayoutGuide(self.contentGuide)

		let contentLeadingConstraint = self.contentGuide.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
		let contentTrailingConstraint = self.contentGuide.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		self.contentLeadingConstraint = contentLeadingConstraint
		self.contentTrailingConstraint = contentTrailingConstraint

		var constraints = [
			self.contentGuide.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.contentGuide.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			contentLeadingConstraint,
			contentTrailingConstraint,
		] + [
			self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.backgroundView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
			self.backgroundView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),

			self.artworkOverlayView.leadingAnchor.constraint(equalTo: self.artworkImageView.leadingAnchor),
			self.artworkOverlayView.trailingAnchor.constraint(equalTo: self.artworkImageView.trailingAnchor),
			self.artworkOverlayView.heightAnchor.constraint(equalToConstant: self.overlayHeight),

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
			self.pillContainerView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor, constant: -16),
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
		// The tab reaches past the screen edge, so the chevron centers on the half still visible.
		let exposedCenter = MiniPlayerWindowBridge.dockedTabWidth / 2
		self.dockTabLeadingConstraint = self.dockTabImageView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: exposedCenter)
		self.dockTabTrailingConstraint = self.dockTabImageView.centerXAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -exposedCenter)

		for (index, containerView) in self.marginArtworkContainerViews.enumerated() {
			let imageView = self.marginArtworkImageViews[index]
			let isLeading = index == 0

			constraints += [
				containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
				containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
				containerView.leadingAnchor.constraint(equalTo: isLeading ? self.view.leadingAnchor : self.contentGuide.trailingAnchor),
				containerView.trailingAnchor.constraint(equalTo: isLeading ? self.contentGuide.leadingAnchor : self.view.trailingAnchor),

				// The copy spans the whole window, so each margin continues the artwork beside it.
				imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
				imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
				imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			]
		}

		constraints += [
			self.lyricsControl.widthAnchor.constraint(equalToConstant: 38),
			self.lyricsControl.heightAnchor.constraint(equalToConstant: 36),

			self.edgeBlurView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.edgeBlurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.edgeBlurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.edgeBlurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),

			self.dockTabImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
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

		self.windowBridge.onEdgeOverflowChange = { [weak self] edge, fraction in
			self?.applyEdgeOverflow(edge, fraction)
		}

		self.windowBridge.onDockArmChange = { [weak self] edge in
			self?.applyDockArm(edge)
		}

		self.windowBridge.onDockedEdgeChange = { [weak self] edge in
			self?.applyDockedEdge(edge)
		}

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

		// The window holds the artwork card's square shape through a resize.
		self.windowBridge.holdsSquarePlayer = { [weak self] in
			return self?.appliedRegime == .square
		}

		self.windowBridge.onHoverChange = { [weak self] hovering in
			guard let self = self else { return }

			// A dragged window reports spurious pointer exits; ignore them while the press holds.
			guard hovering || !self.windowBridge.isPointerDown else { return }

			self.setOverlaysVisible(hovering)
		}

		// Closing the window puts the MiniPlayer away; quitting with it open does not.
		self.windowBridge.onClosePress = {
			UserSettings.set(false, forKey: .miniPlayerIsShowing)
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
				guard let self = self else { return }
				self.loadArtwork(for: song)

				guard self.hasAppeared, song != nil else { return }
				self.revealForSongChange()
			}
			.store(in: &self.subscriptions)

		NotificationCenter.default.publisher(for: .KSMiniPlayerSettingsDidChange)
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.applyMiniPlayerSettings()
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

	/// Loads the artwork for the given song.
	///
	/// - Parameter song: The song whose artwork to show.
	private func loadArtwork(for song: MKSong?) {
		guard let artworkURL = song?.song.artwork?.url(width: 1024, height: 1024)?.absoluteString else {
			self.artworkImageView.image = .Placeholders.musicAlbum
			self.setOverlayBlurImage(.Placeholders.musicAlbum)
			return
		}

		self.artworkImageView.setImage(with: artworkURL, placeholder: .Placeholders.musicAlbum) { [weak self] image in
			self?.setOverlayBlurImage(image)
		}
	}

	/// Crossfades the artwork's blurred copies to a new image.
	///
	/// The crossfade matches the artwork's own loading fade.
	///
	/// - Parameter image: The artwork to blur.
	private func setOverlayBlurImage(_ image: UIImage) {
		guard !UIAccessibility.isReduceMotionEnabled else {
			self.blurredArtworkImageViews.forEach { $0.image = image }
			return
		}

		for imageView in self.blurredArtworkImageViews {
			UIView.transition(with: imageView, duration: self.artworkCrossfadeDuration, options: [.transitionCrossDissolve, .allowUserInteraction]) {
				imageView.image = image
			}
		}
	}

	/// Every blurred copy of the artwork, in the overlay and in the margins alike.
	private var blurredArtworkImageViews: [UIImageView] {
		#if targetEnvironment(macCatalyst)
		return self.overlayBlurImageViews + self.marginArtworkImageViews
		#else
		return self.overlayBlurImageViews
		#endif
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

		let point = CGPoint(x: location.x, y: self.contentBounds.height - location.y)
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

		// The overlay's fade follows the morph rather than waiting for the regime to change.
		if self.appliedRegime == .bar, self.chromeVisible {
			self.artworkOverlayView.alpha = progress
		}
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
			let height = self.contentBounds.height
			return max(0, min(1, (height - self.barHeight) / (self.barCeilingHeight - self.barHeight)))
		}
	}

	/// Returns the regime for the current bounds.
	private func resolveRegime() -> Regime {
		let size = self.contentBounds.size

		if self.isLyricsPresented {
			return self.lyricsBaseIsBar ? .barExpanded : .expanded
		}

		if size.height < self.barCeilingHeight {
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
				self.artworkImageView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
				self.artworkImageView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),
				self.artworkImageView.heightAnchor.constraint(equalTo: self.artworkImageView.widthAnchor),

				self.controlsView.topAnchor.constraint(equalTo: self.view.topAnchor),
				self.controlsView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
				self.controlsView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),
			]

			if regime == .barExpanded {
				self.regimeConstraints += [
					self.controlsView.heightAnchor.constraint(equalToConstant: self.barHeight),

					self.lyricsContainerView.topAnchor.constraint(equalTo: self.controlsView.bottomAnchor),
					self.lyricsContainerView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
					self.lyricsContainerView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),
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
				self.artworkImageView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
				self.artworkImageView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),
				self.artworkImageView.heightAnchor.constraint(equalTo: self.artworkImageView.widthAnchor),

				self.controlsView.leadingAnchor.constraint(equalTo: self.artworkOverlayView.leadingAnchor),
				self.controlsView.trailingAnchor.constraint(equalTo: self.artworkOverlayView.trailingAnchor),
				self.controlsView.bottomAnchor.constraint(equalTo: self.artworkOverlayView.bottomAnchor),
				self.controlsView.heightAnchor.constraint(equalToConstant: self.overlayControlsHeight),

				self.lyricsContainerView.topAnchor.constraint(equalTo: self.artworkImageView.bottomAnchor),
				self.lyricsContainerView.leadingAnchor.constraint(equalTo: self.contentGuide.leadingAnchor),
				self.lyricsContainerView.trailingAnchor.constraint(equalTo: self.contentGuide.trailingAnchor),
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
		DispatchQueue.main.asyncAfter(deadline: .now() + self.hoverIdleTimeout, execute: workItem)
	}
	#endif

	/// Shows or hides the hover chrome.
	///
	/// - Parameter visible: Whether the overlays are showing.
	private func setOverlaysVisible(_ visible: Bool) {
		#if targetEnvironment(macCatalyst)
		// A docked window shows nothing but its tab, traffic lights included.
		if visible, self.isPullTabPresented {
			return
		}
		#endif

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

	/// Whether the chrome shows, resolving the pointer and the song change reveal against the
	/// user's visibility preference.
	private var chromeVisible: Bool {
		switch UserSettings.miniPlayerChromeVisibility {
		case .always:
			return true
		case .never:
			return false
		case .onHover:
			return self.overlaysVisible || self.isRevealingForSongChange
		}
	}

	/// Adopts the user's MiniPlayer preferences.
	private func applyMiniPlayerSettings() {
		if UserSettings.miniPlayerChromeVisibility != .onHover {
			self.songChangeRevealWorkItem?.cancel()
			self.isRevealingForSongChange = false
		}

		#if targetEnvironment(macCatalyst)
		self.attachWindowBridge()
		self.windowBridge.applyWindowBehavior()
		#endif

		self.reconcileOverlays(animated: true)
	}

	/// Reveals the chrome briefly when a new song starts while the pointer is elsewhere.
	private func revealForSongChange() {
		guard
			UserSettings.miniPlayerRevealsOnSongChange,
			UserSettings.miniPlayerChromeVisibility == .onHover,
			!self.overlaysVisible
		else { return }

		self.songChangeRevealWorkItem?.cancel()
		self.isRevealingForSongChange = true
		self.reconcileOverlays(animated: true)

		let workItem = DispatchWorkItem { [weak self] in
			guard let self = self else { return }
			self.isRevealingForSongChange = false
			self.reconcileOverlays(animated: true)
		}
		self.songChangeRevealWorkItem = workItem
		DispatchQueue.main.asyncAfter(deadline: .now() + self.songChangeRevealDuration, execute: workItem)
	}

	/// Applies the hover chrome's visibility for the current regime.
	///
	/// - Parameter animated: Whether to animate the fades.
	private func reconcileOverlays(animated: Bool) {
		let visible = self.chromeVisible
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
	// MARK: Dock
	/// Veils the window as the pointer carries it toward a side edge.
	///
	/// - Parameters:
	///    - edge: The edge the pointer is heading for.
	///    - progress: How far the veil has come in.
	private func applyEdgeOverflow(_ edge: DockEdge?, _ progress: CGFloat) {
		// A window pulled off its parked place drops the veil in one animated step.
		guard progress == 0, self.edgeBlurView.alpha > 0, !UIAccessibility.isReduceMotionEnabled else {
			self.edgeBlurView.layer.removeAllAnimations()
			self.edgeBlurView.alpha = progress
			return
		}

		UIView.animate(withDuration: self.dockMorphDuration, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
			self.edgeBlurView.alpha = 0
		}
	}

	/// Slides the pull tab out of the window once the pointer reaches a side edge of the screen.
	///
	/// The tab travels its full reach in one movement, and retracts the same way.
	///
	/// - Parameter edge: The edge the pointer is holding the window against.
	private func applyDockArm(_ edge: DockEdge?) {
		let shouldStandOut = edge != nil
		guard shouldStandOut != self.isTabGrown else { return }
		self.isTabGrown = shouldStandOut

		if let edge = edge {
			self.prepareDockTab(for: edge)

			// Seat the tab behind the body's edge, so the slide starts from there.
			self.setDockTabReach(0)
		}

		let duration = UIAccessibility.isReduceMotionEnabled ? 0 : self.dockMorphDuration
		UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut, .beginFromCurrentState]) {
			self.setDockTabReach(shouldStandOut ? Self.dockTabReach : 0)
		} completion: { _ in
			self.forgetRetractedDockTab()
		}
	}

	/// Stands the pull tab out of the body, carrying the chevron with it.
	///
	/// - Parameter tabReach: How far the tab stands out of the body.
	private func setDockTabReach(_ tabReach: CGFloat) {
		self.updateDockMaskFrame(tabReach: tabReach)

		// The chevron holds its place on the tab, fading in as the tab comes out.
		let behind = Self.dockTabReach - tabReach
		self.dockTabImageView.transform = CGAffineTransform(translationX: self.dockedEdge == .left ? -behind : behind, y: 0)
		self.dockTabImageView.alpha = tabReach / Self.dockTabReach
	}

	/// Drops the pull tab from the silhouette once it has finished retracting.
	private func forgetRetractedDockTab() {
		guard !self.isTabGrown, !self.isPullTabPresented, self.dockedEdge != nil else { return }

		self.dockedEdge = nil
		self.setTabMargin(on: nil)
		self.updateDockMaskFrame(tabReach: 0)
	}

	/// Points the chevron at the screen and parks it on the edge the window is leaving by.
	///
	/// - Parameter edge: The edge the window is crossing.
	private func prepareDockTab(for edge: DockEdge?) {
		guard let edge = edge, edge != self.dockedEdge else { return }
		self.dockedEdge = edge

		// The tab protrudes from the side that faces the screen.
		self.setTabMargin(on: edge == .right ? .left : .right)

		self.dockTabLeadingConstraint?.isActive = edge == .right
		self.dockTabTrailingConstraint?.isActive = edge == .left

		let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
		let symbolName = edge == .right ? "chevron.compact.left" : "chevron.compact.right"
		self.dockTabImageView.image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
	}

	/// Makes room for the pull tab on the given side of the body, or takes the room back.
	///
	/// The window carries the margin, so the body holds its place on screen either way.
	///
	/// - Parameter side: The side of the body the tab protrudes from.
	private func setTabMargin(on side: DockEdge?) {
		guard side != self.tabMarginSide else { return }
		self.tabMarginSide = side

		self.contentLeadingConstraint?.constant = side == .left ? Self.dockTabReach : 0
		self.contentTrailingConstraint?.constant = side == .right ? -Self.dockTabReach : 0
		self.windowBridge.setTabMargin(on: side)
		self.view.layoutIfNeeded()
	}

	/// Shows the pull tab in place of the window.
	///
	/// - Parameters:
	///    - presented: Whether the tab stands in for the window.
	///    - edge: The edge the tab sits against.
	private func setPullTabPresented(_ presented: Bool, at edge: DockEdge?) {
		guard self.isPullTabPresented != presented else { return }
		self.isPullTabPresented = presented

		let duration = UIAccessibility.isReduceMotionEnabled ? 0 : self.dockMorphDuration

		guard presented else {
			self.isTabGrown = false
			UIView.animate(withDuration: duration) {
				self.setDockTabReach(0)
			} completion: { _ in
				self.forgetRetractedDockTab()
			}
			return
		}

		self.prepareDockTab(for: edge)
		self.setOverlaysVisible(false)

		self.windowBridge.setTrafficLightsHidden(true)

		guard !self.isTabGrown else { return }
		self.isTabGrown = true

		UIView.animate(withDuration: duration) {
			self.setDockTabReach(Self.dockTabReach)
		}
	}

	/// Lays out the docked silhouette: the window body, and the tab hanging off its inner edge.
	///
	/// - Parameter tabReach: How far the tab currently stands out of the body.
	private func updateDockMaskFrame(tabReach: CGFloat) {
		let bounds = self.view.bounds
		self.dockMaskView.frame = bounds

		let path = self.silhouettePath(body: self.contentBounds, tabEdge: self.dockedEdge, tabCenterY: bounds.midY, tabReach: tabReach)

		// Animating during a live resize would trail the pointer, so only the tab's morph is carried.
		let duration = self.windowBridge.isInLiveResize ? 0 : UIView.inheritedAnimationDuration

		CATransaction.begin()
		CATransaction.setDisableActions(true)

		self.dockMaskShapeLayer.frame = bounds
		MiniPlayerWindowBridge.setSilhouette(path, in: self.dockMaskShapeLayer, duration: duration)

		// The material carries the border and the shadow, so it takes the same silhouette.
		self.windowBridge.setSilhouette(path, duration: duration)

		CATransaction.commit()
	}

	/// Returns the outline of the player's body and pull tab.
	///
	/// The tab slides out from behind the body at a fixed size, and a fillet at each junction joins
	/// the two into one shape.
	///
	/// - Parameters:
	///    - body: The player's rect, in the window's coordinates.
	///    - tabEdge: The screen edge the window docks against.
	///    - tabCenterY: The vertical center of the pull tab.
	///    - tabReach: How far the tab stands out of the body.
	///
	/// - Returns: The outline of the body and the tab together.
	private func silhouettePath(body: CGRect, tabEdge: DockEdge?, tabCenterY: CGFloat, tabReach: CGFloat) -> CGPath {
		let path = CGMutablePath()
		let bodyRadius = min(MiniPlayerWindowBridge.windowCornerRadius, min(body.width, body.height) / 2)
		path.addRoundedRect(in: body, cornerWidth: bodyRadius, cornerHeight: bodyRadius)

		guard let tabEdge = tabEdge else { return path }

		let junctionRadius = max(min(self.dockJunctionRadius, tabReach - self.dockTabCornerRadius), 0.01)
		let tabHeight = min(self.dockTabHeight, max(body.height - 2 * (bodyRadius + junctionRadius), 2 * self.dockTabCornerRadius))
		let tabTop = tabCenterY - tabHeight / 2
		let tabBottom = tabCenterY + tabHeight / 2

		let bodyEdgeX = tabEdge == .right ? body.minX : body.maxX
		let inward: CGFloat = tabEdge == .right ? 1 : -1
		let tabOriginX = tabEdge == .right ? bodyEdgeX - tabReach : bodyEdgeX + tabReach - self.dockTabWidth

		let tab = CGRect(x: tabOriginX, y: tabTop, width: self.dockTabWidth, height: tabHeight)
		path.addRoundedRect(in: tab, cornerWidth: self.dockTabCornerRadius, cornerHeight: self.dockTabCornerRadius)

		for (edgeY, away) in [(tabTop, CGFloat(-1)), (tabBottom, CGFloat(1))] {
			let center = CGPoint(x: bodyEdgeX - inward * junctionRadius, y: edgeY + away * junctionRadius)
			let start = CGPoint(x: center.x, y: edgeY)

			path.move(to: start)
			path.addArc(
				center: center,
				radius: junctionRadius,
				startAngle: atan2(start.y - center.y, start.x - center.x),
				endAngle: atan2(0, inward),
				clockwise: away * inward < 0
			)
			path.addLine(to: CGPoint(x: bodyEdgeX, y: edgeY))
			path.closeSubpath()
		}

		return path
	}

	/// Reacts to the window docking against a side edge or returning to the screen.
	///
	/// - Parameter edge: The edge the window is docked against.
	private func applyDockedEdge(_ edge: DockEdge?) {
		self.setPullTabPresented(edge != nil, at: edge)
	}

	// MARK: Window
	/// Hands the window's chrome over to the AppKit bridge.
	private func attachWindowBridge() {
		guard !self.windowBridge.isAttached else { return }

		self.windowBridge.attach(to: self.view.window)
		guard self.windowBridge.isAttached else { return }

		self.backgroundView.effect = nil
		self.view.backgroundColor = .clear
		self.view.window?.backgroundColor = .clear

		// The mask shapes the window; a corner radius on the view would round the margins too.
		self.updateDockMaskFrame(tabReach: 0)
		self.view.mask = self.dockMaskView

		if !self.windowBridge.hasRestoredFrame, !self.didApplyDefaultSize {
			self.didApplyDefaultSize = true
			self.requestWindowSize(CGSize(width: self.defaultSquareSize, height: self.defaultSquareSize), animated: false)
		}
	}

	/// Snaps the window onto the nearest regime's height.
	private func snapWindowToRegime() {
		let size = self.contentBounds.size

		if self.isLyricsPresented {
			let baseHeight = self.lyricsBaseIsBar ? self.barHeight : size.width
			if size.height - baseHeight < self.lyricsMinimumHeight {
				self.isLyricsCollapsing = true
				self.view.setNeedsLayout()
				self.requestWindowSize(CGSize(width: size.width, height: baseHeight), animated: true)
			} else {
				self.lyricsRestorePaneHeight = size.height - baseHeight
			}
			return
		}

		var targetHeight = size.height
		if size.height < self.barCeilingHeight {
			targetHeight = self.barHeight
		} else if size.height < size.width + self.lyricsMinimumHeight {
			targetHeight = size.width
		} else {
			self.lyricsRestorePaneHeight = size.height - size.width
		}

		if abs(targetHeight - size.height) > 1 {
			self.requestWindowSize(CGSize(width: size.width, height: targetHeight), animated: true)
		}
	}

	/// Returns whether a view option may run now.
	///
	/// - Returns: Whether the toggle should run.
	private func acceptsViewOptionToggle() -> Bool {
		let now = CACurrentMediaTime()
		guard now - self.lastViewOptionToggle > self.viewOptionRepeatInterval else { return false }

		self.lastViewOptionToggle = now
		return true
	}

	/// Toggles the window between the artwork card and the compact bar.
	@objc private func toggleLargeArtwork() {
		guard self.acceptsViewOptionToggle() else { return }

		let width = self.contentBounds.width
		let showsArtwork = !(self.appliedRegime == .bar || self.appliedRegime == .barExpanded)
		let paneHeight = max(0, self.contentBounds.height - (showsArtwork ? width : self.barHeight))

		self.lyricsBaseIsBar = showsArtwork
		if paneHeight > 0 {
			self.isLyricsPresented = true
			self.lyricsRestorePaneHeight = paneHeight
		}

		let baseHeight = showsArtwork ? self.barHeight : width
		self.requestWindowSize(CGSize(width: width, height: baseHeight + paneHeight), animated: true)
		self.view.setNeedsLayout()
	}

	/// Toggles the lyrics pane.
	@objc private func toggleLyricsRegime() {
		guard self.acceptsViewOptionToggle() else { return }

		let width = self.contentBounds.width
		let baseHeight = self.lyricsBaseIsBar ? self.barHeight : width
		let paneHeight = self.lyricsRestorePaneHeight ?? self.expandedLyricsHeight

		if self.isLyricsCollapsing {
			self.isLyricsCollapsing = false
			self.requestWindowSize(CGSize(width: width, height: baseHeight + paneHeight), animated: true)
		} else if self.isLyricsPresented {
			self.lyricsRestorePaneHeight = self.contentBounds.height - baseHeight
			self.isLyricsCollapsing = true
			self.requestWindowSize(CGSize(width: width, height: baseHeight), animated: true)
		} else if self.appliedRegime == .expanded {
			self.lyricsRestorePaneHeight = self.contentBounds.height - width
			self.requestWindowSize(CGSize(width: width, height: width), animated: true)
		} else {
			self.lyricsBaseIsBar = self.appliedRegime == .bar
			self.isLyricsPresented = true
			let newBaseHeight = self.lyricsBaseIsBar ? self.barHeight : width
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
		// Callers size the player; the window also carries the pull tab's margin while it is out.
		var size = size
		if self.tabMarginSide != nil {
			size.width += Self.dockTabReach
		}

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
