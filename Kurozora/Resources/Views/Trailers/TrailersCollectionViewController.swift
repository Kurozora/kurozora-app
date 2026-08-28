//
//  TrailersCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

/// A collection of the titles that have a trailer, switchable between anime and games.
class TrailersCollectionViewController: ListCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case gameDetailsSegue
	}

	/// The kinds of titles the collection lists.
	enum Kind: Int, CaseIterable {
		case shows
		case games

		/// The localized title of the kind.
		var title: String {
			switch self {
			case .shows: return L10n.shows
			case .games: return L10n.games
			}
		}
	}

	/// The section identifier.
	enum SectionLayoutKind: Int, CaseIterable {
		case featured = 0
		case main = 1
	}

	/// An item displayed in the collection.
	enum ItemKind: Hashable {
		case featured
		case showIdentity(_: ShowIdentity)
		case gameIdentity(_: GameIdentity)

		/// The identifier the item stands for.
		var identityID: KurozoraItemID? {
			switch self {
			case .featured: return nil
			case .showIdentity(let identity): return identity.id
			case .gameIdentity(let identity): return identity.id
			}
		}
	}

	// MARK: - Views
	/// The height of the tab bar toolbar.
	private static let toolbarHeight: CGFloat = 49.0

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()

	/// The player that plays the featured trailer, moved between the featured cell and the floating window.
	private let featuredPlayerView: KTrailerPlayerView = {
		let playerView = KTrailerPlayerView()
		playerView.translatesAutoresizingMaskIntoConstraints = false
		playerView.showsMuteToggle = true
		playerView.showsCompactControls = true
		playerView.loopsPlayback = false
		playerView.reportsNowPlaying = true
		playerView.layerCornerRadius = 16.0
		playerView.layer.masksToBounds = true
		return playerView
	}()

	/// The window that keeps the featured trailer playing in the corner while the reader scrolls.
	private let floatingWindowView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layerCornerRadius = 12.0
		view.applyShadow()
		view.isHidden = true
		return view
	}()

	/// The clipped content of the floating window.
	private let floatingContentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layerCornerRadius = 12.0
		view.layer.masksToBounds = true
		return view
	}()

	/// The control that returns the reader to the featured player.
	private let floatingReturnControl: UIControl = {
		let control = UIControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()

	/// The button that dismisses the floating window.
	private let floatingCloseButton: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 11.0, weight: .bold), forImageIn: .normal)
		button.tintColor = .white
		button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		button.layerCornerRadius = 13.0
		button.accessibilityLabel = L10n.dismiss
		return button
	}()

	/// The bar button item presenting the sort order.
	private var sortBarButtonItem: UIBarButtonItem!

	/// The bar button item that dims titles already in the user's library.
	private var dimLibraryBarButtonItem: UIBarButtonItem!

	/// The interaction blurring the collection under the toolbar's edge.
	private var topScrollEdgeInteraction: UIInteraction?

	// MARK: - Properties
	/// The kind currently shown.
	private var kind: Kind = .shows

	/// The trailer the feed picked for each title, keyed by the title's identifier.
	private var trailerURLs: [KurozoraItemID: String] = [:]

	/// The identifier of the featured title.
	private var featuredIdentityID: KurozoraItemID?

	/// A Boolean value indicating whether the player is in the floating window.
	private var isPlayerFloating = false

	/// A Boolean value indicating whether the reader dismissed the floating window for the current scroll.
	private var isFloatingDismissed = false

	/// The order the trailers are listed in.
	private var sort: TrailerSort = .justAdded

	var showIdentities: [ShowIdentity] = []
	var gameIdentities: [GameIdentity] = []

	// MARK: - SectionFetchable
	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Whether titles already in the user's library are dimmed.
	private var dimsLibraryEntries = false

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	override var emptyStateImage: UIImage? { self.kind == .games ? .Empty.libraryGame : .Empty.libraryAnime }
	override var emptyStateTitle: String { L10n.noItemsTitle(L10n.trailers) }
	override var emptyStateDetail: String { L10n.noTrailersDetail }

	override var hasLoadedInitialData: Bool {
		!self.showIdentities.isEmpty || !self.gameIdentities.isEmpty
	}

	/// The index path of the featured cell.
	private var featuredIndexPath: IndexPath {
		IndexPath(item: 0, section: SectionLayoutKind.featured.rawValue)
	}

	/// The items shown for the current kind.
	private var currentItems: [ItemKind] {
		switch self.kind {
		case .shows: return self.showIdentities.map { .showIdentity($0) }
		case .games: return self.gameIdentities.map { .gameIdentity($0) }
		}
	}

	/// Returns the cached model for the given identifier.
	///
	/// - Parameter id: The identifier of the model.
	///
	/// - Returns: The cached model.
	private func cachedModel(withID id: KurozoraItemID) -> KurozoraItem? {
		return self.cache.values.first { $0.id == id }
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.styleTabBarView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// The playback menu commands resolve through the responder chain.
		self.becomeFirstResponder()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.trailers
		self.navigationItem.largeTitleDisplayMode = .never

		self.configureView()
		self.configureNavBarButtons()
		self.observeLibraryChanges()

		self.featuredPlayerView.onPlaybackStateChange = { [weak self] _ in
			guard let self = self else { return }
			self.refreshGlyph(forID: self.featuredIdentityID)
		}

		self.featuredPlayerView.onPlaybackEnded = { [weak self] in
			guard let self = self else { return }
			self.featureNextItem()
		}

		self.featuredPlayerView.onPictureVisibilityChanged = { [weak self] in
			guard let self = self else { return }
			self.refreshPlayerSkeleton()
		}

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.handleUserSignedInDidChange),
			name: .KUserIsSignedInDidChange,
			object: nil
		)
	}

	// MARK: - Functions
	private func configureView() {
		self.collectionView.contentInset.top = Self.toolbarHeight
		self.collectionView.verticalScrollIndicatorInsets.top = Self.toolbarHeight

		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		let tabBarBarButtonItem = UIBarButtonItem(customView: self.tabBarView)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			tabBarBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([tabBarBarButtonItem], animated: false)
	}

	private func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.tabBarView.reloadData(at: 0 ... Kind.allCases.count - 1, context: .full)
		self.updateBar(to: CGFloat(self.kind.rawValue), animated: false)
		self.styleTabBarView()
	}

	private func updateBar(to position: CGFloat, animated: Bool) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position, capacity: Kind.allCases.count, direction: .forward, animation: animation)
	}

	private func styleTabBarView() {
		self.tabBarView.backgroundView.style = .clear
		self.tabBarView.indicator.layout(in: self.tabBarView)
		self.tabBarView.scrollMode = .interactive
		self.tabBarView.buttons.customize { button in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.textColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.50)
		}
		self.tabBarView.layout.interButtonSpacing = 0.0
		self.tabBarView.layout.contentMode = .intrinsic
		self.tabBarView.fadesContentEdges = true
	}

	private func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			let interaction = UIScrollEdgeElementContainerInteraction()
			interaction.scrollView = self.collectionView
			interaction.edge = .top
			self.toolbar.addInteraction(interaction)
			self.topScrollEdgeInteraction = interaction
		}
	}

	private func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)

		self.floatingWindowView.addSubview(self.floatingContentView)
		self.floatingWindowView.addSubview(self.floatingReturnControl)
		self.floatingWindowView.addSubview(self.floatingCloseButton)
		self.view.addSubview(self.floatingWindowView)

		self.floatingReturnControl.addTarget(self, action: #selector(self.handleFloatingReturn), for: .touchUpInside)
		self.floatingCloseButton.addTarget(self, action: #selector(self.handleFloatingClose), for: .touchUpInside)
	}

	private func configureViewConstraints() {
		let floatingWidth: CGFloat = 360.0

		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: Self.toolbarHeight),

			self.floatingWindowView.topAnchor.constraint(equalTo: self.toolbar.bottomAnchor, constant: 12.0),
			self.floatingWindowView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
			self.floatingWindowView.widthAnchor.constraint(equalToConstant: floatingWidth),
			self.floatingWindowView.heightAnchor.constraint(equalTo: self.floatingWindowView.widthAnchor, multiplier: 9.0 / 16.0),

			self.floatingContentView.topAnchor.constraint(equalTo: self.floatingWindowView.topAnchor),
			self.floatingContentView.leadingAnchor.constraint(equalTo: self.floatingWindowView.leadingAnchor),
			self.floatingContentView.trailingAnchor.constraint(equalTo: self.floatingWindowView.trailingAnchor),
			self.floatingContentView.bottomAnchor.constraint(equalTo: self.floatingWindowView.bottomAnchor),

			self.floatingReturnControl.topAnchor.constraint(equalTo: self.floatingContentView.topAnchor),
			self.floatingReturnControl.leadingAnchor.constraint(equalTo: self.floatingContentView.leadingAnchor),
			self.floatingReturnControl.trailingAnchor.constraint(equalTo: self.floatingContentView.trailingAnchor),
			self.floatingReturnControl.bottomAnchor.constraint(equalTo: self.floatingContentView.bottomAnchor),

			self.floatingCloseButton.topAnchor.constraint(equalTo: self.floatingWindowView.topAnchor, constant: 6.0),
			self.floatingCloseButton.trailingAnchor.constraint(equalTo: self.floatingWindowView.trailingAnchor, constant: -6.0),
			self.floatingCloseButton.widthAnchor.constraint(equalToConstant: 26.0),
			self.floatingCloseButton.heightAnchor.constraint(equalToConstant: 26.0),
		])

		self.tabBarView.fillToSuperview()
	}

	/// Configures the sort and dim library bar button items.
	private func configureNavBarButtons() {
		self.sortBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"))
		self.sortBarButtonItem.accessibilityLabel = L10n.sort
		self.rebuildSortMenu()

		self.dimLibraryBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "rectangle.stack.fill"),
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.handleDimLibraryButtonPressed()
			}
		)
		self.dimLibraryBarButtonItem.accessibilityLabel = L10n.dimLibrary
		self.dimLibraryBarButtonItem.accessibilityValue = L10n.off

		self.updateNavBarButtons()
	}

	/// Rebuilds the sort menu.
	private func rebuildSortMenu() {
		let actions = TrailerSort.allCases.map { sort in
			UIAction(title: sort.title, state: sort == self.sort ? .on : .off) { [weak self] _ in
				self?.handleSortSelected(sort)
			}
		}

		self.sortBarButtonItem.menu = UIMenu(title: L10n.sort, children: actions)
	}

	/// Shows the dim library button alongside the sort only while a user is signed in.
	private func updateNavBarButtons() {
		var barButtonItems: [UIBarButtonItem] = [self.sortBarButtonItem]

		if User.isSignedIn {
			barButtonItems.append(self.dimLibraryBarButtonItem)
		}

		self.navigationItem.rightBarButtonItems = barButtonItems
	}

	/// Reloads the collection under the newly selected order.
	///
	/// - Parameter sort: The order the user picked.
	private func handleSortSelected(_ sort: TrailerSort) {
		guard sort != self.sort else { return }
		self.sort = sort
		self.rebuildSortMenu()
		self.reloadForQueryChange()
	}

	/// Clears the loaded titles and reloads from the first page.
	private func reloadForQueryChange() {
		self.nextPageCursor = nil
		self.showIdentities = []
		self.gameIdentities = []
		self.cache = [:]
		self.featuredIdentityID = nil
		self.dismissFloatingWindow()
		self.featuredPlayerView.stopTrailer()
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = false

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchItems()
		}
	}

	override func handleRefreshControl() {
		self.reloadForQueryChange()
	}

	/// The number of loaded identities for the current kind.
	private var loadedCount: Int {
		switch self.kind {
		case .shows: return self.showIdentities.count
		case .games: return self.gameIdentities.count
		}
	}

	override func fetchItems() async {
		guard !self.isRequestInProgress else { return }
		self.isRequestInProgress = true

		defer { self.endFetch() }

		do {
			switch self.kind {
			case .shows:
				let response = try await KService.showTrailers(sortedBy: self.sort).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.showIdentities = []
					self.trailerURLs = [:]
				}

				self.nextPageCursor = response.nextCursor
				self.absorb(response.data)
				self.showIdentities.append(contentsOf: response.data.compactMap(\.parent))
				self.showIdentities.removeDuplicates()
			case .games:
				let response = try await KService.gameTrailers(sortedBy: self.sort).cursor(self.nextPageCursor).limit(self.nextPageCursor != nil ? 100 : 25).response()

				if self.nextPageCursor == nil {
					self.gameIdentities = []
					self.trailerURLs = [:]
				}

				self.nextPageCursor = response.nextCursor
				self.absorb(response.data)
				self.gameIdentities.append(contentsOf: response.data.compactMap(\.parent))
				self.gameIdentities.removeDuplicates()
			}

			self.featureFirstItemIfNeeded()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Remembers which trailer the feed picked for each title.
	///
	/// - Parameter trailers: The trailers the feed returned.
	private func absorb<Parent: KurozoraItem & Codable & Hashable>(_ trailers: [Trailer<Parent>]) {
		for trailer in trailers {
			guard let parent = trailer.parent else { continue }
			self.trailerURLs[parent.id] = trailer.attributes.url
		}
	}

	// MARK: - Featured player
	override var canBecomeFirstResponder: Bool {
		return true
	}

	/// Plays or pauses the featured trailer in response to the playback command.
	@objc func togglePlayPause() {
		if self.featuredPlayerView.isTrailerPlaying {
			self.featuredPlayerView.pauseByReader()
		} else {
			self.featuredPlayerView.playByReader()
		}
	}

	/// Opens the featured trailer fullscreen in response to the fullscreen command.
	@objc func toggleTrailerFullscreen() {
		self.featuredPlayerView.enterFullscreenByReader()
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		switch action {
		case #selector(self.togglePlayPause), #selector(self.toggleTrailerFullscreen):
			return self.featuredPlayerView.hasLoadedTrailer && self.featuredPlayerView.showsControls
		default:
			return super.canPerformAction(action, withSender: sender)
		}
	}

	/// Features the first title when nothing is featured yet.
	private func featureFirstItemIfNeeded() {
		guard self.featuredIdentityID == nil, let first = self.currentItems.first, let identityID = first.identityID, let trailerURL = self.trailerURLs[identityID] else { return }

		self.featuredIdentityID = identityID
		self.updateDataSource()
		self.featuredPlayerView.loadTrailer(fromURL: trailerURL)
	}

	/// Features the given item, playing its trailer in place.
	///
	/// - Parameters:
	///    - item: The item to feature.
	///    - byReader: Whether the reader asked for the trailer.
	private func feature(_ item: ItemKind, byReader: Bool) {
		guard let identityID = item.identityID, let trailerURL = self.trailerURLs[identityID] else { return }

		if identityID == self.featuredIdentityID {
			guard byReader else { return }

			if self.featuredPlayerView.isTrailerPlaying {
				self.featuredPlayerView.pauseByReader()
			} else {
				self.featuredPlayerView.playByReader()
			}

			return
		}

		let previousIdentityID = self.featuredIdentityID
		self.featuredIdentityID = identityID
		self.featuredPlayerView.loadTrailer(fromURL: trailerURL)
		self.refreshFeaturedHeader()
		self.refreshGlyph(forID: previousIdentityID)
		self.refreshGlyph(forID: identityID)

		if byReader {
			self.featuredPlayerView.playByReader()
		}
	}

	/// Features the item after the current one, wrapping back to the first.
	private func featureNextItem() {
		guard let featuredIdentityID = self.featuredIdentityID else { return }
		let items = self.currentItems
		guard let currentIndex = items.firstIndex(where: { $0.identityID == featuredIdentityID }) else { return }

		let nextItem = items[(currentIndex + 1) % items.count]
		guard nextItem.identityID != featuredIdentityID else { return }

		self.feature(nextItem, byReader: false)
		self.featuredPlayerView.playByReader()
	}

	/// Reconfigures the featured header with the current featured title, re-measuring its height.
	private func refreshFeaturedHeader() {
		var snapshot = self.dataSource.snapshot()
		guard snapshot.itemIdentifiers.contains(.featured) else { return }

		snapshot.reconfigureItems([.featured])
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Updates the play glyph of the list cell for the given identifier.
	///
	/// - Parameter id: The identifier of the cell to update.
	private func refreshGlyph(forID id: KurozoraItemID?) {
		guard let id, let item = self.currentItems.first(where: { $0.identityID == id }), let indexPath = self.dataSource.indexPath(for: item), let cell = self.collectionView.cellForItem(at: indexPath) as? TrailerLockupCollectionViewCell else { return }
		cell.setPlaying(id == self.featuredIdentityID && self.featuredPlayerView.isTrailerPlaying)
	}

	/// Configures the featured header cell with the featured title.
	///
	/// - Parameter cell: The cell to configure.
	private func configureFeaturedCell(_ cell: TrailerFeaturedCollectionViewCell) {
		cell.delegate = self

		let model = self.featuredIdentityID.flatMap { self.cachedModel(withID: $0) }
		switch self.kind {
		case .shows:
			let show = model as? Show
			cell.configure(using: show)
			self.featuredPlayerView.shareHandler = show.map { show in
				{ sourceView in show.openShareSheet(sourceView: sourceView, barButtonItem: nil) }
			}
			self.featuredPlayerView.streamMetadata = show.map { show in
				TrailerStreamMetadata(title: show.attributes.title, synopsis: show.attributes.synopsis, artworkURL: show.attributes.poster?.url)
			}
		case .games:
			let game = model as? Game
			cell.configure(using: game)
			self.featuredPlayerView.shareHandler = game.map { game in
				{ sourceView in game.openShareSheet(sourceView: sourceView, barButtonItem: nil) }
			}
			self.featuredPlayerView.streamMetadata = game.map { game in
				TrailerStreamMetadata(title: game.attributes.title, synopsis: game.attributes.synopsis, artworkURL: game.attributes.poster?.url)
			}
		}

		// The feed's models carry no library state, which lives in the local store.
		if let model = model {
			let status = LibraryStore.shared.effectiveLibrary(forTrackableID: model.id.rawValue, kind: cell.libraryKind)?.status ?? .none
			cell.updateLibraryButton(status: status)
		} else {
			self.fetchFeaturedModelIfNeeded()
		}

		cell.setPlayerSkeletonVisible(!self.featuredPlayerView.isShowingPicture && !self.featuredPlayerView.isHoldingLastFrame)

		if !self.isPlayerFloating {
			self.attachFeaturedPlayer(to: cell.playerContainer)
		}
	}

	/// Fetches the featured title's details without waiting for its list cell to come on screen.
	private func fetchFeaturedModelIfNeeded() {
		guard
			let featuredIdentityID = self.featuredIdentityID,
			let item = self.currentItems.first(where: { $0.identityID == featuredIdentityID }),
			let indexPath = self.dataSource.indexPath(for: item),
			let section = self.snapshot.sectionIdentifier(containingItem: item)
		else { return }

		Task { [weak self] in
			guard let self = self else { return }

			switch item {
			case .showIdentity:
				await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: item)
			case .gameIdentity:
				await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: item)
			case .featured:
				return
			}

			// A fetch someone else started returns straight away, so its cache fill is waited out.
			while self.cachedModel(withID: featuredIdentityID) == nil, self.isFetchingSection.contains(section) {
				try? await Task.sleep(nanoseconds: 200_000_000)
			}

			guard self.featuredIdentityID == featuredIdentityID else { return }
			self.refreshFeaturedHeader()
		}
	}

	/// Hides the featured player's placeholder once its picture is up.
	private func refreshPlayerSkeleton() {
		guard let cell = self.collectionView.cellForItem(at: self.featuredIndexPath) as? TrailerFeaturedCollectionViewCell else { return }
		cell.setPlayerSkeletonVisible(!self.featuredPlayerView.isShowingPicture && !self.featuredPlayerView.isHoldingLastFrame)
	}

	/// Places the featured player in the given container.
	///
	/// - Parameter container: The view to host the player.
	private func attachFeaturedPlayer(to container: UIView) {
		guard self.featuredPlayerView.superview !== container else { return }

		self.featuredPlayerView.removeFromSuperview()
		container.addSubview(self.featuredPlayerView)

		NSLayoutConstraint.activate([
			self.featuredPlayerView.topAnchor.constraint(equalTo: container.topAnchor),
			self.featuredPlayerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			self.featuredPlayerView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			self.featuredPlayerView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
		])
	}

	/// Moves the featured player into the floating window.
	private func floatPlayer() {
		guard !self.isPlayerFloating else { return }
		self.isPlayerFloating = true

		self.featuredPlayerView.showsControls = false
		self.attachFeaturedPlayer(to: self.floatingContentView)
		self.floatingWindowView.isHidden = false
	}

	/// Moves the featured player back into the featured cell.
	private func unfloatPlayer() {
		guard self.isPlayerFloating else { return }
		self.isPlayerFloating = false

		self.floatingWindowView.isHidden = true
		self.featuredPlayerView.showsControls = true

		if let featuredCell = self.collectionView.cellForItem(at: self.featuredIndexPath) as? TrailerFeaturedCollectionViewCell {
			self.attachFeaturedPlayer(to: featuredCell.playerContainer)
		}
	}

	/// Hides the floating window without re-arming it for the current scroll.
	private func dismissFloatingWindow() {
		self.unfloatPlayer()
		self.isFloatingDismissed = false
	}

	/// The height the featured player occupies inline.
	private var featuredPlayerHeight: CGFloat {
		let wideLayoutMinimumWidth: CGFloat = 1200.0
		let contentWidth = self.collectionView.bounds.width - 20.0
		let isWide = contentWidth >= wideLayoutMinimumWidth
		let playerWidth = isWide ? contentWidth * 0.6 : contentWidth
		return playerWidth * 9.0 / 16.0
	}

	/// Floats or restores the player as the featured cell scrolls past the top.
	private func updateFloatingWindow() {
		guard let featuredIdentityID = self.featuredIdentityID, self.trailerURLs[featuredIdentityID] != nil else { return }
		guard let attributes = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: self.featuredIndexPath) else { return }

		let playerTopOnScreen = attributes.frame.minY - self.collectionView.contentOffset.y
		let visibleTop = self.collectionView.adjustedContentInset.top
		let hiddenAmount = visibleTop - playerTopOnScreen

		if hiddenAmount >= self.featuredPlayerHeight * (2.0 / 3.0) {
			if !self.isFloatingDismissed {
				self.floatPlayer()
			}
		} else {
			self.isFloatingDismissed = false
			self.unfloatPlayer()
		}
	}

	/// Scrolls the collection to the top.
	private func scrollToTop() {
		let topOffset = CGPoint(x: 0, y: -self.collectionView.adjustedContentInset.top)
		self.collectionView.setContentOffset(topOffset, animated: true)
	}

	/// Returns the reader to the featured player.
	@objc private func handleFloatingReturn() {
		self.scrollToTop()
	}

	/// Dismisses the floating window for the current scroll.
	@objc private func handleFloatingClose() {
		self.isFloatingDismissed = true
		self.unfloatPlayer()
	}

	// MARK: - Library
	/// Presents the library action sheet for the given title.
	///
	/// - Parameters:
	///    - target: The title to update.
	///    - kind: The kind of library the title belongs to.
	///    - status: The title's current library status.
	///    - sourceView: The view the sheet points at.
	///    - onChange: A closure receiving the chosen status.
	private func presentLibraryActionSheet(for target: Libraryable, kind: LibraryKind, status: LibraryStatus, sourceView: UIView, onChange: @escaping (LibraryStatus) -> Void) {
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: kind), currentSelection: status, action: { _, value in
			Task { @MainActor in
				await target.addToLibrary(status: value)
				onChange(value)
			}
		})

		if status != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task { @MainActor in
					await target.removeFromLibrary()
					onChange(.none)
				}
			})
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = sourceView
			popoverController.sourceRect = sourceView.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	// MARK: - Library dimming
	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else {
			self.libraryObserver = nil
			return
		}
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID)
			}
		)
	}

	/// Reconfigures the items showing the given title after its library entry changes.
	///
	/// - Parameter trackableID: The identifier of the title whose entry changed.
	private func applyLibraryEntryChange(forTrackableID trackableID: String) {
		var snapshot = self.dataSource.snapshot()
		var matchedItems = snapshot.itemIdentifiers.filter { $0.identityID?.rawValue == trackableID }

		if self.featuredIdentityID?.rawValue == trackableID, snapshot.itemIdentifiers.contains(.featured) {
			matchedItems.append(.featured)
		}

		guard !matchedItems.isEmpty else { return }
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Handles dim library button pressed.
	private func handleDimLibraryButtonPressed() {
		self.dimsLibraryEntries.toggle()
		self.dimLibraryBarButtonItem.image = UIImage(systemName: self.dimsLibraryEntries ? "rectangle.stack.slash.fill" : "rectangle.stack.fill")
		self.dimLibraryBarButtonItem.accessibilityValue = self.dimsLibraryEntries ? L10n.on : L10n.off
		self.refreshVisibleDimming()
	}

	/// Whether the cell at the given index path should be dimmed.
	///
	/// - Parameter indexPath: The index path of the cell.
	///
	/// - Returns: `true` when dimming is on and the underlying title is in the user's library.
	private func isDimmed(at indexPath: IndexPath) -> Bool {
		guard self.dimsLibraryEntries else { return false }

		let libraryKind: LibraryKind = self.kind == .games ? .games : .shows
		guard let trackable = self.cachedModel(at: indexPath) else { return false }
		let libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: trackable.id.rawValue, kind: libraryKind)?.status ?? .none
		return libraryStatus != .none
	}

	/// Re-applies dimming to the visible cells.
	private func refreshVisibleDimming() {
		for indexPath in self.collectionView.indexPathsForVisibleItems {
			guard let cell = self.collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell else { continue }
			cell.setDimmed(self.isDimmed(at: indexPath))
		}
	}

	/// Handles the user's sign-in state changing.
	@objc private func handleUserSignedInDidChange() {
		self.updateNavBarButtons()
		self.observeLibraryChanges()

		if !User.isSignedIn, self.dimsLibraryEntries {
			self.dimsLibraryEntries = false
			self.dimLibraryBarButtonItem.image = UIImage(systemName: "rectangle.stack.fill")
			self.dimLibraryBarButtonItem.accessibilityValue = L10n.off
			self.refreshVisibleDimming()
		}
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .featured: return nil
		case .showIdentity(let id): return id as? Element
		case .gameIdentity(let id): return id as? Element
		}
	}

	/// Returns the cached model at the given index path.
	///
	/// - Parameter indexPath: The index path of the item.
	///
	/// - Returns: The cached model.
	private func cachedModel(at indexPath: IndexPath) -> KurozoraItem? {
		guard let model = self.cache[indexPath] else { return nil }
		guard model.id == self.dataSource.itemIdentifier(for: indexPath)?.identityID else {
			self.cache[indexPath] = nil
			return nil
		}
		return model
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let destination = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			destination.show = show
		case .gameDetailsSegue:
			guard let destination = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			destination.game = game
		}
	}
}

// MARK: - KCollectionViewDataSource
extension TrailersCollectionViewController {
	override func configureDataSource() {
		let featuredCellRegistration = self.getConfiguredFeaturedCell()
		let lockupCellRegistration = self.getConfiguredLockupCell()

		self.dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(collectionView: collectionView) { collectionView, indexPath, itemKind in
			if SectionLayoutKind(rawValue: indexPath.section) == .featured {
				return collectionView.dequeueConfiguredReusableCell(using: featuredCellRegistration, for: indexPath, item: itemKind)
			}

			return collectionView.dequeueConfiguredReusableCell(using: lockupCellRegistration, for: indexPath, item: itemKind)
		}

		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.featured, .main])
		self.dataSource.apply(self.snapshot)
	}

	override func updateDataSource() {
		self.updateSnapshot()
		self.dataSource.apply(self.snapshot)
		self.collectionView.collectionViewLayout.invalidateLayout()
	}

	/// Rebuilds the snapshot from the loaded identities.
	private func updateSnapshot() {
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.snapshot.appendSections([.featured, .main])

		if self.featuredIdentityID != nil {
			self.snapshot.appendItems([.featured], toSection: .featured)
		}

		self.snapshot.appendItems(self.currentItems, toSection: .main)
	}

	/// Resolves the title an item stands for.
	///
	/// - Parameters:
	///    - itemKind: The item being configured.
	///    - indexPath: The index path of the item.
	///
	/// - Returns: The title the item stands for.
	private func resolve(_ itemKind: ItemKind, at indexPath: IndexPath) -> (show: Show?, game: Game?) {
		switch itemKind {
		case .featured:
			return (nil, nil)
		case .showIdentity:
			let show = self.cachedModel(at: indexPath) as? Show

			if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			return (show, nil)
		case .gameIdentity:
			let game = self.cachedModel(at: indexPath) as? Game

			if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
				Task {
					await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
				}
			}

			return (nil, game)
		}
	}

	private func getConfiguredFeaturedCell() -> UICollectionView.CellRegistration<TrailerFeaturedCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<TrailerFeaturedCollectionViewCell, ItemKind> { [weak self] cell, _, _ in
			guard let self = self else { return }
			self.configureFeaturedCell(cell)
		}
	}

	private func getConfiguredLockupCell() -> UICollectionView.CellRegistration<TrailerLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<TrailerLockupCollectionViewCell, ItemKind> { [weak self] cell, indexPath, itemKind in
			guard let self = self else { return }
			let resolved = self.resolve(itemKind, at: indexPath)

			cell.delegate = self
			cell.trailerDelegate = self

			if case .gameIdentity = itemKind {
				cell.configure(using: resolved.game)
			} else {
				cell.configure(using: resolved.show)
			}

			cell.setDimmed(self.isDimmed(at: indexPath))
			cell.setPlaying(itemKind.identityID == self.featuredIdentityID && self.featuredPlayerView.isTrailerPlaying)

			if itemKind.identityID == self.featuredIdentityID, resolved.show != nil || resolved.game != nil {
				// The refresh applies a snapshot, which must not land inside this configuration pass.
				DispatchQueue.main.async {
					self.refreshFeaturedHeader()
				}
			}
		}
	}
}

// MARK: - KCollectionViewDelegateLayout
extension TrailersCollectionViewController {
	override func columnCount(forSection section: Int, layout layoutEnvironment: NSCollectionLayoutEnvironment) -> Int {
		let width = layoutEnvironment.container.effectiveContentSize.width
		let columnCount = Int(width >= 414 ? (width / 384).rounded() : (width / 284).rounded())
		return columnCount > 0 ? columnCount : 1
	}

	override func createLayout() -> UICollectionViewLayout? {
		return UICollectionViewCompositionalLayout { [weak self] section, layoutEnvironment in
			guard let self = self else { return nil }

			if SectionLayoutKind(rawValue: section) == .featured {
				return Layouts.fullSection(section, columns: 1, layoutEnvironment: layoutEnvironment)
			}

			let columns = self.columnCount(forSection: section, layout: layoutEnvironment)
			return Layouts.videoSection(section, columns: columns, layoutEnvironment: layoutEnvironment, isHorizontal: false)
		}
	}
}

// MARK: - UICollectionViewDelegate
extension TrailersCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let model: KurozoraItem?
		if SectionLayoutKind(rawValue: indexPath.section) == .featured {
			model = self.featuredIdentityID.flatMap { self.cachedModel(withID: $0) }
		} else {
			model = self.cachedModel(at: indexPath)
		}

		switch self.kind {
		case .shows:
			guard let show = model as? Show else { return }
			self.show(.showDetailsSegue, sender: show)
		case .games:
			guard let game = model as? Game else { return }
			self.show(.gameDetailsSegue, sender: game)
		}
	}

	override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard SectionLayoutKind(rawValue: indexPath.section) == .main else { return }
		self.paginateIfNeeded(at: indexPath, totalItems: self.loadedCount)
	}

	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch self.kind {
		case .shows:
			guard let show = self.cachedModel(at: indexPath) as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games:
			guard let game = self.cachedModel(at: indexPath) as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		}
	}
}

// MARK: - UIScrollViewDelegate
extension TrailersCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		self.updateFloatingWindow()
	}
}

// MARK: - TMBarDataSource
extension TrailersCollectionViewController: TMBarDataSource {
	func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
		guard let kind = Kind(rawValue: index) else { return TMBarItem(title: "") }
		return TMBarItem(title: kind.title)
	}
}

// MARK: - TMBarDelegate
extension TrailersCollectionViewController: TMBarDelegate {
	func bar(_ bar: TMBar, didRequestScrollTo index: Int) {
		guard let kind = Kind(rawValue: index), kind != self.kind else { return }

		self.updateBar(to: CGFloat(index), animated: true)
		self.kind = kind
		self.configureEmptyDataView()
		self.reloadForQueryChange()
	}
}

// MARK: - UIToolbarDelegate
extension TrailersCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - TrailerLockupCollectionViewCellDelegate
extension TrailersCollectionViewController: TrailerLockupCollectionViewCellDelegate {
	func trailerLockupCollectionViewCellDidSelectTrailer(_ cell: TrailerLockupCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell), let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { return }
		self.feature(itemKind, byReader: true)
	}
}

// MARK: - TrailerFeaturedCollectionViewCellDelegate
extension TrailersCollectionViewController: TrailerFeaturedCollectionViewCellDelegate {
	func trailerFeaturedCollectionViewCell(_ cell: TrailerFeaturedCollectionViewCell, didPressAdd button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let featuredIdentityID = self.featuredIdentityID, let model = self.cachedModel(withID: featuredIdentityID), let target = model as? Libraryable else { return }

		let status = LibraryStore.shared.effectiveLibrary(forTrackableID: model.id.rawValue, kind: cell.libraryKind)?.status ?? .none
		self.presentLibraryActionSheet(for: target, kind: cell.libraryKind, status: status, sourceView: button) { [weak cell] newStatus in
			cell?.updateLibraryButton(status: newStatus)
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension TrailersCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard let indexPath = self.collectionView.indexPath(for: cell), let target = self.cachedModel(at: indexPath) as? Libraryable else { return }

		self.presentLibraryActionSheet(for: target, kind: cell.libraryKind, status: cell.libraryStatus, sourceView: button) { [weak cell] newStatus in
			cell?.libraryStatus = newStatus
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell), let show = self.cachedModel(at: indexPath) as? Show else { return }

		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}
