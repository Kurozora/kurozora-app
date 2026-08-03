//
//  MuseumCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

class MuseumCollectionViewController: KCollectionViewController, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
	}

	/// The layout metrics of the museum hall.
	enum Metrics {
		/// The width of a poster.
		static let itemWidth: CGFloat = 112.0

		/// The gap between posters and between columns.
		static let gap: CGFloat = 8.0

		/// The spacing between year sections.
		static let sectionSpacing: CGFloat = 40.0

		/// The leading inset of the hall.
		static let hallInset: CGFloat = 16.0

		/// The height of the tab bar toolbar.
		static let toolbarHeight: CGFloat = 49.0

		/// The height of the timeline scrubber.
		static let timelineHeight: CGFloat = 50.0

		/// The padding between the timeline and the bottom safe area.
		static let timelineBottomPadding: CGFloat = 12.0

		/// The breathing gap between the hall and the timeline.
		static let hallTimelineGap: CGFloat = 12.0

		/// The vertical clearance the hall reserves for the timeline.
		static let timelineClearance: CGFloat = timelineHeight + timelineBottomPadding + hallTimelineGap
	}

	/// The collection-scale caption display modes, mirroring the web implementation.
	enum ScaleMode {
		/// Indicates the caption spans the whole collection.
		case total

		/// Indicates the caption shows the active year.
		case year
	}

	// MARK: - Views
	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()

	/// The density timeline that scrubs the hall through its years.
	let timelineView = MuseumTimelineView()

	/// The navigation title view pairing the year picker with the collection scale.
	let museumTitleView = MuseumTitleView()

	/// The bar button item that recenters the hall on the current year.
	var nowBarButtonItem: UIBarButtonItem!

	/// The bar button item that dims entries already in the user's library.
	var dimLibraryBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var libraryKind: LibraryKind = .shows

	/// The year the hall centers on when first shown, set by deep links.
	var initialYear: Int?

	var museumYears: [MuseumYear] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true
		}
	}

	/// The fetched entries keyed by year.
	var entriesByYear: [Int: [MuseumEntry]] = [:]

	/// Years whose entries are fully fetched.
	var loadedYears: Set<Int> = []

	/// Years whose entries are currently being fetched.
	var inflightYears: Set<Int> = []

	/// Debounce tasks for years awaiting load, keyed by year.
	var pendingYearLoads: [Int: Task<Void, Never>] = [:]

	/// The year currently at the center of the hall.
	private(set) var activeYear: Int?

	/// Whether entries already in the user's library are dimmed.
	private(set) var dimsLibraryEntries = false

	/// Observes local library mutations affecting the visible posters.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// The current collection-scale caption mode.
	private var scaleMode: ScaleMode = .total

	/// The task that restores the total scale after scrolling stops.
	private var scaleRestoreTask: Task<Void, Never>?

	/// The task that marks the hall ready after its initial scroll.
	private var hallReadyTask: Task<Void, Never>?

	/// Whether the hall has settled after loading.
	private var isHallReady = false

	/// The fetch generation, bumped whenever the library kind changes.
	private var fetchGeneration = 0

	/// Whether the hall has centered on its initial year.
	private var hasPerformedInitialScroll = false

	/// Whether the hall is mid-rotation.
	private var isHallTransitioning = false

	/// The number of poster rows in every year column.
	private(set) var hallRowCount = 1

	/// The size of a poster in the hall.
	private(set) var hallItemSize = CGSize(width: Metrics.itemWidth, height: 160.0)

	/// The height of a poster for the current library kind.
	var posterHeight: CGFloat {
		return self.libraryKind == .games ? 112.0 : 160.0
	}

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Refresh control
	override var prefersRefreshControlDisabled: Bool {
		return true
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func themeWillReload() {
		super.themeWillReload()

		self.styleTabBarView()
		self.timelineView.restyle()
		self.museumTitleView.restyle()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.museum

		self.configureView()
		self.configureDataSource()
		self.configureNavBarButtons()
		self.observeLibraryChanges()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.handleUserSignedInDidChange),
			name: .KUserIsSignedInDidChange,
			object: nil
		)

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
			self.scrollToInitialYear(animated: false)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.navigationController?.interactivePopGestureRecognizer?.require(toFail: self.timelineView.scrubGestureRecognizer)

		if let kNavigationController = self.navigationController as? KNavigationController {
			kNavigationController.forwardNavigationCoordinator.panGestureRecognizer?.require(toFail: self.timelineView.scrubGestureRecognizer)
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		let yearToRestore = self.activeYear
		self.isHallTransitioning = true

		coordinator.animate(alongsideTransition: nil) { [weak self] _ in
			guard let self = self else { return }
			self.isHallTransitioning = false

			if let yearToRestore = yearToRestore {
				self.scrollToYear(yearToRestore, animated: false)
			}
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		self.updateHallInsets()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.updateHallInsets()
	}

	override func viewSafeAreaInsetsDidChange() {
		super.viewSafeAreaInsetsDidChange()

		self.updateHallInsets()
	}

	// MARK: - Functions
	/// Rebuilds the hall's layout when the number of rows that fit has changed.
	func updateHallRowsIfNeeded() {
		let availableHeight = max(1.0, self.availableHallHeight())
		let rows = max(1, Int(((availableHeight + Metrics.gap) / (self.posterHeight + Metrics.gap)).rounded(.down)))
		let itemHeight = (availableHeight + Metrics.gap) / CGFloat(rows) - Metrics.gap
		let itemWidth = (Metrics.itemWidth * itemHeight / self.posterHeight).rounded(.down)
		let itemSize = CGSize(width: itemWidth, height: itemHeight)

		guard rows != self.hallRowCount || itemSize != self.hallItemSize else { return }
		self.hallRowCount = rows
		self.hallItemSize = itemSize

		guard self.dataSource != nil else { return }
		if let layout = self.createLayout() {
			self.collectionView.setCollectionViewLayout(layout, animated: false)
		}

		if let activeYear = self.activeYear {
			self.scrollToYear(activeYear, animated: false)
		}

		self.reconfigureVisibleItems()
	}

	/// Reconfigures the visible posters.
	func reconfigureVisibleItems() {
		let visibleItemKinds = self.collectionView.indexPathsForVisibleItems.compactMap { indexPath in
			self.dataSource.itemIdentifier(for: indexPath)
		}
		guard !visibleItemKinds.isEmpty else { return }

		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems(visibleItemKinds)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	override func configureEmptyDataView() {
		let emptyStateImage: UIImage
		let detailString: String

		switch self.libraryKind {
		case .shows:
			emptyStateImage = .Empty.animeLibrary
			detailString = L10n.noItemsYet(L10n.museum.lowercased(with: .current), L10n.shows.lowercased(with: .current))
		case .literatures:
			emptyStateImage = .Empty.mangaLibrary
			detailString = L10n.noItemsYet(L10n.museum.lowercased(with: .current), L10n.literatures.lowercased(with: .current))
		case .games:
			emptyStateImage = .Empty.gameLibrary
			detailString = L10n.noItemsYet(L10n.museum.lowercased(with: .current), L10n.games.lowercased(with: .current))
		}

		self.emptyBackgroundView.configureImageView(image: emptyStateImage)
		self.emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.museum), detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of items.
	func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func configureView() {
		self.configureTabBarView()
		self.configureToolbar()
		self.configureTimelineView()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		self.collectionView.showsHorizontalScrollIndicator = false
		self.collectionView.contentInsetAdjustmentBehavior = .never
		self.collectionView.alwaysBounceVertical = false
		self.updateHallInsets()

		let tabBarBarButtonItem = UIBarButtonItem(customView: self.tabBarView)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			tabBarBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([tabBarBarButtonItem], animated: true)
	}

	func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.updateBar(to: CGFloat(self.libraryKind.rawValue), animated: false, direction: .none)
		self.styleTabBarView()
	}

	func updateBar(to position: CGFloat?, animated: Bool, direction: TMBarUpdateDirection) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position ?? 0.0, capacity: LibraryKind.allCases.count, direction: .forward, animation: animation)
	}

	fileprivate func styleTabBarView() {
		// Background view
		self.tabBarView.backgroundView.style = .clear

		// Indicator
		self.tabBarView.indicator.layout(in: self.tabBarView)

		// Scrolling
		self.tabBarView.scrollMode = .interactive

		// State
		self.tabBarView.buttons.customize { button in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.textColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.50)
		}

		// Layout
		self.tabBarView.layout.contentInset = UIEdgeInsets(top: 0.0, left: 0.2, bottom: 0.0, right: 0.0)
		self.tabBarView.layout.interButtonSpacing = 0.0
		self.tabBarView.layout.contentMode = .intrinsic

		// Style
		self.tabBarView.fadesContentEdges = true
	}

	func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isHidden = true
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
		}
	}

	/// Configures the timeline scrubber pinned to the bottom of the view.
	func configureTimelineView() {
		self.timelineView.translatesAutoresizingMaskIntoConstraints = false
		self.timelineView.isHidden = true
		self.timelineView.yearSelectedHandler = { [weak self] year in
			guard let self = self else { return }
			self.scrollToYear(year, animated: false)
		}
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
		self.view.addSubview(self.timelineView)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: Metrics.toolbarHeight),
			self.timelineView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: Metrics.hallInset),
			self.timelineView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -Metrics.hallInset),
			self.timelineView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -Metrics.timelineBottomPadding),
			self.timelineView.heightAnchor.constraint(equalToConstant: Metrics.timelineHeight),
		])

		self.tabBarView.fillToSuperview()
	}

	/// Configures the title view and the now and dim library bar button items.
	func configureNavBarButtons() {
		self.navigationItem.titleView = self.museumTitleView

		self.nowBarButtonItem = UIBarButtonItem(title: L10n.now, style: .plain, target: self, action: #selector(self.handleNowButtonPressed))

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

	/// Shows the dim library button only while a user is signed in.
	func updateNavBarButtons() {
		var barButtonItems: [UIBarButtonItem] = [self.nowBarButtonItem]

		if User.isSignedIn {
			barButtonItems.append(self.dimLibraryBarButtonItem)
		}

		self.navigationItem.rightBarButtonItems = barButtonItems
	}

	func setShowToolbar(_ show: Bool) {
		self.toolbar.isHidden = !show
		self.updateHallInsets()
	}

	/// Applies the hall's content insets and reflows the rows when needed.
	func updateHallInsets() {
		let safeAreaInsets = self.collectionView.safeAreaInsets
		var topChrome = safeAreaInsets.top

		if !self.toolbar.isHidden {
			topChrome = max(topChrome + Metrics.toolbarHeight, self.toolbar.frame.maxY) + Metrics.gap
		}

		let contentInset = UIEdgeInsets(
			top: topChrome,
			left: safeAreaInsets.left,
			bottom: safeAreaInsets.bottom + Metrics.timelineClearance,
			right: safeAreaInsets.right
		)

		if self.collectionView.contentInset != contentInset {
			let isAtRest = self.collectionView.contentOffset.y == -self.collectionView.contentInset.top
			self.collectionView.contentInset = contentInset
			self.collectionView.scrollIndicatorInsets = contentInset

			if isAtRest {
				self.collectionView.contentOffset.y = -contentInset.top
			}
		}

		self.updateHallRowsIfNeeded()
	}

	func fetchDetails() async {
		let fetchGeneration = self.fetchGeneration

		do {
			let museumYearResponse = try await KService.museum(for: self.libraryKind).response()
			guard fetchGeneration == self.fetchGeneration else { return }

			self.museumYears = museumYearResponse.data
			self.reloadView()
			self.updateDataSource()
			self.timelineView.configure(using: self.museumYears)
			self.rebuildYearMenu()

			if let totalScaleText = self.totalScaleText() {
				self.setScale(totalScaleText, mode: .total)
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Clears the hall's caches and pending work ahead of a fresh fetch.
	func resetHall() {
		self.fetchGeneration += 1

		for pendingYearLoad in self.pendingYearLoads.values {
			pendingYearLoad.cancel()
		}

		self.pendingYearLoads.removeAll()
		self.inflightYears.removeAll()
		self.loadedYears.removeAll()
		self.entriesByYear.removeAll()
		self.museumYears = []
		self.activeYear = nil
		self.hasPerformedInitialScroll = false
		self.isHallReady = false
		self.hallReadyTask?.cancel()
		self.scaleRestoreTask?.cancel()
		self.scaleMode = .total
		self.museumTitleView.setYear(nil)
		self.museumTitleView.setCaption("", crossFade: false)
	}

	/// The hall's available height between the toolbar and the timeline.
	func availableHallHeight() -> CGFloat {
		return self.collectionView.bounds.height
			- self.collectionView.contentInset.top
			- self.collectionView.contentInset.bottom
	}

	/// Schedules a year's entries to load.
	///
	/// - Parameter year: The year to load.
	func scheduleYearLoad(for year: Int) {
		guard !self.loadedYears.contains(year), !self.inflightYears.contains(year), self.pendingYearLoads[year] == nil else { return }

		self.pendingYearLoads[year] = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 150_000_000)
			} catch {
				return
			}

			guard let self = self else { return }
			self.pendingYearLoads[year] = nil
			await self.loadYear(year)
		}
	}

	/// Cancels a year's scheduled load.
	///
	/// - Parameter year: The year whose load to cancel.
	func cancelYearLoad(for year: Int) {
		self.pendingYearLoads[year]?.cancel()
		self.pendingYearLoads[year] = nil
	}

	/// Fetches a year's entries and hydrates its section.
	///
	/// - Parameter year: The year to load.
	func loadYear(_ year: Int) async {
		guard !self.loadedYears.contains(year), !self.inflightYears.contains(year) else { return }

		let fetchGeneration = self.fetchGeneration
		self.inflightYears.insert(year)
		defer { self.inflightYears.remove(year) }

		var museumEntries: [MuseumEntry] = []
		var nextPageCursor: PageCursor?

		do {
			repeat {
				let museumEntryResponse = try await KService.museum(for: self.libraryKind, in: year).cursor(nextPageCursor).limit(100).response()
				museumEntries.append(contentsOf: museumEntryResponse.data)
				museumEntries.removeDuplicates()
				nextPageCursor = museumEntryResponse.nextCursor

				guard fetchGeneration == self.fetchGeneration else { return }

				self.entriesByYear[year] = museumEntries
				self.hydrateSection(for: year, with: museumEntries, hasMorePages: nextPageCursor != nil)
			} while nextPageCursor != nil
		} catch {
			print(error.localizedDescription)
			return
		}

		guard fetchGeneration == self.fetchGeneration else { return }
		self.loadedYears.insert(year)
	}

	/// Scrolls the hall to the given year.
	///
	/// - Parameters:
	///    - year: The year to reveal.
	///    - animated: Specify [`true`](https://developer.apple.com/documentation/swift/true) to animate the scrolling behavior or [`false`](https://developer.apple.com/documentation/swift/false) to adjust the scroll view’s visible content immediately.
	func scrollToYear(_ year: Int, animated: Bool) {
		guard let sectionIndex = self.snapshot.sectionIdentifiers.firstIndex(where: { sectionLayoutKind in
			switch sectionLayoutKind {
			case .year(let museumYear):
				return museumYear.year == year
			}
		}) else { return }

		let indexPath = IndexPath(item: 0, section: sectionIndex)
		guard let layoutAttributes = self.collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return }

		let minimumOffsetX = -self.collectionView.adjustedContentInset.left
		let maximumOffsetX = max(minimumOffsetX, self.collectionView.contentSize.width - self.collectionView.bounds.width + self.collectionView.adjustedContentInset.right)
		let targetOffsetX = min(max(layoutAttributes.frame.minX - Metrics.hallInset, minimumOffsetX), maximumOffsetX)
		let restingOffsetY = -self.collectionView.adjustedContentInset.top

		self.collectionView.setContentOffset(CGPoint(x: targetOffsetX, y: restingOffsetY), animated: animated)
	}

	/// Centers the hall on the initial year, the current year, or the last year.
	///
	/// - Parameter animated: Specify [`true`](https://developer.apple.com/documentation/swift/true) to animate the scrolling behavior or [`false`](https://developer.apple.com/documentation/swift/false) to adjust the scroll view’s visible content immediately.
	func scrollToInitialYear(animated: Bool) {
		guard !self.hasPerformedInitialScroll, !self.museumYears.isEmpty else { return }
		self.hasPerformedInitialScroll = true

		let targetYear: Int

		if let initialYear = self.initialYear, self.museumYears.contains(where: { $0.year == initialYear }) {
			targetYear = initialYear
		} else {
			targetYear = self.currentOrLastYear() ?? self.museumYears[0].year
		}

		self.collectionView.layoutIfNeeded()
		self.scrollToYear(targetYear, animated: animated)
		self.syncActiveYear()

		self.hallReadyTask?.cancel()
		self.hallReadyTask = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 300_000_000)
			} catch {
				return
			}

			guard let self = self else { return }
			self.isHallReady = true
		}
	}

	/// The current year when present in the hall, or the last year otherwise.
	func currentOrLastYear() -> Int? {
		let currentYear = Calendar.current.component(.year, from: Date.now)
		let museumYear = self.museumYears.first { $0.year == currentYear } ?? self.museumYears.last
		return museumYear?.year
	}

	/// Reflects the centermost year on the title view and the timeline.
	func syncActiveYear() {
		guard !self.isHallTransitioning else { return }
		guard self.snapshot != nil, !self.snapshot.sectionIdentifiers.isEmpty else { return }

		let centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.width / 2.0
		var sectionMaxX: CGFloat = 0.0
		var centermostYear: MuseumYear?

		for (sectionIndex, sectionLayoutKind) in self.snapshot.sectionIdentifiers.enumerated() {
			let itemCount = self.snapshot.numberOfItems(inSection: sectionLayoutKind)
			let columns = CGFloat((itemCount + self.hallRowCount - 1) / self.hallRowCount)
			let columnWidth = self.hallItemSize.width + Metrics.gap
			let leadingInset = sectionIndex == 0 ? Metrics.hallInset : 0.0

			switch sectionLayoutKind {
			case .year(let museumYear):
				centermostYear = museumYear
			}

			sectionMaxX += leadingInset + columns * columnWidth - Metrics.gap + Metrics.sectionSpacing

			if centerX < sectionMaxX {
				break
			}
		}

		guard let museumYear = centermostYear, museumYear.year != self.activeYear else { return }
		self.activeYear = museumYear.year
		self.museumTitleView.setYear(museumYear.year)
		self.timelineView.setActiveYear(museumYear.year)
	}

	/// Rebuilds the year button's menu of decade submenus.
	func rebuildYearMenu() {
		let decadesByStart = Dictionary(grouping: self.museumYears) { museumYear in
			(museumYear.year / 10) * 10
		}

		let decadeMenus: [UIMenu] = decadesByStart.keys.sorted().map { decadeStart in
			let yearActions: [UIAction] = (decadesByStart[decadeStart] ?? [])
				.sorted { $0.year < $1.year }
				.map { museumYear in
					UIAction(title: String(museumYear.year)) { [weak self] _ in
						guard let self = self else { return }
						self.scrollToYear(museumYear.year, animated: true)
					}
				}

			return UIMenu(title: "\(decadeStart)s", children: yearActions)
		}

		self.museumTitleView.yearMenu = UIMenu(children: decadeMenus)
	}

	/// Handles now button pressed.
	@objc func handleNowButtonPressed() {
		guard let targetYear = self.currentOrLastYear() else { return }
		self.scrollToYear(targetYear, animated: true)
	}

	/// The idle caption spanning the whole collection.
	///
	/// - Returns: The caption, or `nil` when the hall is empty.
	func totalScaleText() -> String? {
		guard let firstYear = self.museumYears.first?.year, let lastYear = self.museumYears.last?.year else { return nil }

		let totalCount = self.museumYears.reduce(0) { partialCount, museumYear in
			partialCount + museumYear.count
		}

		return L10n.worksCountRange(totalCount.formatted(), firstYear, lastYear)
	}

	/// Sets the caption, cross-fading only when switching between total and year modes.
	///
	/// - Parameters:
	///    - text: The caption to show.
	///    - mode: The target scale mode.
	func setScale(_ text: String, mode: ScaleMode) {
		let crossFade = mode != self.scaleMode
		self.scaleMode = mode
		self.museumTitleView.setCaption(text, crossFade: crossFade)
	}

	/// Shows the active year's scale while scrolling, restoring the total scale on idle.
	func showScrollingScale() {
		guard self.isHallReady, let activeYear = self.activeYear else { return }
		guard let museumYear = self.museumYears.first(where: { $0.year == activeYear }) else { return }

		self.setScale(L10n.worksCountYear(museumYear.count.formatted(), activeYear), mode: .year)

		self.scaleRestoreTask?.cancel()
		self.scaleRestoreTask = Task { [weak self] in
			do {
				try await Task.sleep(nanoseconds: 500_000_000)
			} catch {
				return
			}

			guard let self = self else { return }
			guard let totalScaleText = self.totalScaleText() else { return }
			self.setScale(totalScaleText, mode: .total)
		}
	}

	/// Handles dim library button pressed.
	func handleDimLibraryButtonPressed() {
		self.dimsLibraryEntries.toggle()
		self.reflectDimLibraryState()
	}

	/// Reflects the dim library state on the button and the visible posters.
	func reflectDimLibraryState() {
		self.dimLibraryBarButtonItem.image = UIImage(systemName: self.dimsLibraryEntries ? "rectangle.stack.slash.fill" : "rectangle.stack.fill")
		self.dimLibraryBarButtonItem.accessibilityValue = self.dimsLibraryEntries ? L10n.on : L10n.off
		self.refreshVisibleDimming()
	}

	/// Whether the given entry is in the signed-in user's library.
	///
	/// - Parameter museumEntry: The entry to look up.
	///
	/// - Returns: `true` when the entry has a local library status.
	func isEntryInLibrary(_ museumEntry: MuseumEntry) -> Bool {
		let libraryStatus = LibraryStore.shared.effectiveLibrary(forTrackableID: museumEntry.id.rawValue, kind: self.libraryKind)?.status ?? .none
		return libraryStatus != .none
	}

	/// Re-applies dimming to the visible posters.
	func refreshVisibleDimming() {
		for indexPath in self.collectionView.indexPathsForVisibleItems {
			guard let itemKind = self.dataSource.itemIdentifier(for: indexPath) else { continue }
			guard let museumPosterCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as? MuseumPosterCollectionViewCell else { continue }

			switch itemKind {
			case .museumEntry(let museumEntry, _):
				museumPosterCollectionViewCell.setDimmed(self.dimsLibraryEntries && self.isEntryInLibrary(museumEntry))
			case .pending:
				museumPosterCollectionViewCell.setDimmed(false)
			}
		}
	}

	/// Subscribes to local library mutations affecting the visible posters.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else {
			self.libraryObserver = nil
			return
		}

		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] _ in
				self?.refreshVisibleDimming()
			},
			onRemove: { [weak self] _ in
				self?.refreshVisibleDimming()
			}
		)
	}

	/// Handles the user's sign-in state changing.
	@objc func handleUserSignedInDidChange() {
		self.updateNavBarButtons()
		self.observeLibraryChanges()

		if !User.isSignedIn, self.dimsLibraryEntries {
			self.dimsLibraryEntries = false
			self.reflectDimLibraryState()
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }
		guard let museumEntry = sender as? MuseumEntry else { return }

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			showDetailsCollectionViewController.showIdentity = ShowIdentity(id: museumEntry.id)
		case .literatureDetailsSegue:
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			literatureDetailsCollectionViewController.literatureIdentity = LiteratureIdentity(id: museumEntry.id)
		case .gameDetailsSegue:
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			gameDetailsCollectionViewController.gameIdentity = GameIdentity(id: museumEntry.id)
		}
	}
}

// MARK: - TMBarDataSource
extension MuseumCollectionViewController: TMBarDataSource {
	func reloadView() {
		guard !self.museumYears.isEmpty else {
			self.setShowToolbar(false)
			self.timelineView.isHidden = true
			return
		}
		self.setShowToolbar(true)
		self.timelineView.isHidden = false

		self.tabBarView.reloadData(at: 0 ... LibraryKind.allCases.count - 1, context: .full)
	}

	func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
		guard let libraryKind = LibraryKind(rawValue: index) else { return TMBarItem(title: "") }

		switch libraryKind {
		case .shows:
			return TMBarItem(title: L10n.shows)
		case .literatures:
			return TMBarItem(title: L10n.literatures)
		case .games:
			return TMBarItem(title: L10n.games)
		}
	}
}

// MARK: - TMBarDelegate
extension MuseumCollectionViewController: TMBarDelegate {
	func bar(_ bar: Tabman.TMBar, didRequestScrollTo index: Int) {
		guard let libraryKind = LibraryKind(rawValue: index) else { return }

		let direction = TMBarUpdateDirection.forPage(index, previousPage: self.libraryKind.rawValue)
		self.updateBar(to: CGFloat(index), animated: true, direction: direction)

		self.libraryKind = libraryKind

		self.resetHall()
		self.updateHallRowsIfNeeded()
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.dataSource.apply(self.snapshot, animatingDifferences: false)
		self.configureEmptyDataView()
		self._prefersActivityIndicatorHidden = false

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
			self.scrollToInitialYear(animated: false)
		}
	}
}

// MARK: - UIToolbarDelegate
extension MuseumCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - SectionLayoutKind
extension MuseumCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a year section layout type.
		case year(_: MuseumYear)
	}
}

// MARK: - ItemKind
extension MuseumCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `MuseumEntry` object.
		case museumEntry(_: MuseumEntry, year: Int)

		/// Indicates the item kind is a skeleton awaiting the year's entries.
		case pending(year: Int, index: Int)
	}
}

// MARK: - Cell Configuration
extension MuseumCollectionViewController {
	func getConfiguredMuseumPosterCell() -> UICollectionView.CellRegistration<MuseumPosterCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MuseumPosterCollectionViewCell, ItemKind> { [weak self] museumPosterCollectionViewCell, _, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .museumEntry(let museumEntry, _):
				let isDimmed = self.dimsLibraryEntries && self.isEntryInLibrary(museumEntry)
				museumPosterCollectionViewCell.configure(using: museumEntry, libraryKind: self.libraryKind, isDimmed: isDimmed)
			case .pending:
				museumPosterCollectionViewCell.configure(using: nil, libraryKind: self.libraryKind)
			}
		}
	}
}
