//
//  SeasonalCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import Tabman
import UIKit

class SeasonalCollectionViewController: KCollectionViewController, SectionFetchable, ProfileNavigable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
	}

	/// The earliest browsable year offered by the picker.
	private static let minYear = 1917

	// MARK: - Views
	var profileBarButtonItem: ProfileBarButtonItem?
	private var seasonPickerBarButtonItem: UIBarButtonItem!
	private var shareBarButtonItem: UIBarButtonItem!

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()

	// MARK: - Properties
	var kind: BrowseSeasonType = .shows
	var year: Int = Calendar.current.component(.year, from: Date())
	var season: SeasonOfYear = SeasonOfYear(from: Date())
	var browseSeasons: [BrowseSeason] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// `0` represents the All chip; values `1...N` map to `browseSeasons[index - 1]`.
	var selectedChipIndex: Int = 0

	var currentTopContentInset: CGFloat = 0

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
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

	/// The visible browse seasons after applying the chip filter.
	var filteredBrowseSeasons: [BrowseSeason] {
		guard self.selectedChipIndex > 0 else {
			return self.browseSeasons
		}
		guard let target = self.browseSeasons[safe: self.selectedChipIndex - 1] else {
			return []
		}
		return [target]
	}

	/// The shareable URL for the active season and year combination.
	private var shareURL: URL? {
		return URL(string: "https://kurozora.app/\(self.kind.pathPrefix)/seasons/\(self.year)/\(self.season.name)")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureUserDetails()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureView()
		self.configureDataSource()
		self.configureNavigationItems()
		self.observeLibraryChanges()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.view.window?.windowScene?.screenshotService?.delegate = self
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, userSlug: entry.userSlug, kind: entry.kind, isRemoval: false)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, userSlug: removed.userSlug, kind: removed.kind, isRemoval: true)
			}
		)
	}

	/// Updates every item whose embedded show/literature/game matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, isRemoval: Bool) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			switch (item, kind) {
			case (.show(let show, _), .shows) where show.id.rawValue == trackableID:
				matchedItems.append(item)
			case (.literature(let literature, _), .literatures) where literature.id.rawValue == trackableID:
				matchedItems.append(item)
			case (.game(let game, _), .games) where game.id.rawValue == trackableID:
				matchedItems.append(item)
			default:
				break
			}
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	/// Configures the profile bar button item.
	private func configureProfileBarButtonItem() {
		self.profileBarButtonItem = ProfileBarButtonItem(primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			Task {
				await self.segueToProfile()
			}
		})

		if !UIDevice.isPhone, let profileBarButtonItem = self.profileBarButtonItem {
			self.navigationItem.rightBarButtonItems?.insert(profileBarButtonItem, at: 0)
		}

		self.configureUserDetails()
	}

	/// Configures the navigation items.
	fileprivate func configureNavigationItems() {
		self.seasonPickerBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: nil, action: nil)
		self.seasonPickerBarButtonItem.accessibilityLabel = L10n.seasonPicker
		self.seasonPickerBarButtonItem.menu = self.makeJumpToMenu()

		self.shareBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.presentShareSheet()
		})
		self.shareBarButtonItem.accessibilityLabel = L10n.share

		self.navigationItem.rightBarButtonItems = [self.seasonPickerBarButtonItem, self.shareBarButtonItem]

		self.configureProfileBarButtonItem()
		self.updateNavigationTitle()
	}

	func configureView() {
		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		let tabBarBarButtonItem = UIBarButtonItem(customView: self.tabBarView)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			tabBarBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([tabBarBarButtonItem], animated: true)
	}

	func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.updateBar(to: 0.0, animated: false, direction: .none)
		self.styleTabBarView()
	}

	func updateBar(to position: CGFloat?, animated: Bool, direction: TMBarUpdateDirection) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position ?? 0.0, capacity: self.browseSeasons.count + 1, direction: .forward, animation: animation)
	}

	fileprivate func styleTabBarView() {
		self.tabBarView.backgroundView.style = .clear
		self.tabBarView.indicator.layout(in: self.tabBarView)
		self.tabBarView.scrollMode = .interactive

		self.tabBarView.buttons.customize { button in
			button.contentInset = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
			button.selectedTintColor = KThemePicker.textColor.colorValue
			button.tintColor = button.selectedTintColor.withAlphaComponent(0.50)
		}

		self.tabBarView.layout.contentInset = UIEdgeInsets(top: 0.0, left: 0.2, bottom: 0.0, right: 0.0)
		self.tabBarView.layout.interButtonSpacing = 0.0
		self.tabBarView.layout.contentMode = .intrinsic

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

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.toolbar.heightAnchor.constraint(equalToConstant: 49.0)
		])

		self.tabBarView.fillToSuperview()
	}

	func setShowToolbar(_ show: Bool) {
		if show {
			self.currentTopContentInset = self.collectionView.contentInset.top
		}

		self.collectionView.contentInset.top = show ? 49.0 : self.currentTopContentInset
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.toolbar.isHidden = !show
	}

	/// Updates the native title and back-button title to match the current season and year.
	private func updateNavigationTitle() {
		let title = "\(self.season.name) \(self.year)"
		self.title = title
		self.navigationItem.backButtonTitle = title
	}

	/// Returns the jump-to menu used by the season picker.
	///
	/// - Returns: A menu of seasons containing decade and year submenus, scoped so selection indicators
	///   only appear on the active season's branch.
	private func makeJumpToMenu() -> UIMenu {
		let now = Date()
		let actualYear = Calendar.current.component(.year, from: now)
		let actualSeason = SeasonOfYear(from: now)
		let maxYear = actualYear + 2
		let years = Array(Self.minYear...maxYear)
		let decadesByStart = Dictionary(grouping: years, by: { ($0 / 10) * 10 })
		let sortedDecadeStarts = decadesByStart.keys.sorted(by: >)
		let selectedDecadeStart = (self.year / 10) * 10

		let seasonMenus: [UIMenuElement] = SeasonOfYear.allCases.map { season in
			let isCurrentSeason = season == self.season

			let decadeMenus: [UIMenuElement] = sortedDecadeStarts.map { decadeStart in
				let isCurrentDecade = isCurrentSeason && decadeStart == selectedDecadeStart
				let yearsInDecade = (decadesByStart[decadeStart] ?? []).sorted(by: >)

				let yearActions: [UIAction] = yearsInDecade.map { year in
					let isCurrentYear = isCurrentSeason && year == self.year
					return UIAction(title: "\(year)", state: isCurrentYear ? .on : .off) { [weak self] _ in
						guard let self = self else { return }
						self.year = year
						self.season = season
						self.applyNavigationChange()
					}
				}

				return UIMenu(
					title: "\(decadeStart)s",
					subtitle: isCurrentDecade ? "\(self.year)" : nil,
					children: yearActions
				)
			}

			return UIMenu(
				title: season.name,
				subtitle: isCurrentSeason ? "\(self.year)" : nil,
				image: season.image,
				children: decadeMenus
			)
		}

		let isViewingCurrent = (self.year == actualYear && self.season == actualSeason)
		var topItems: [UIMenuElement] = seasonMenus

		if !isViewingCurrent {
			let currentSeasonAction = UIAction(
				title: L10n.currentSeason,
				subtitle: "\(actualSeason.name) \(actualYear)",
				image: UIImage(systemName: "calendar.badge.clock")
			) { [weak self] _ in
				guard let self = self else { return }
				self.year = actualYear
				self.season = actualSeason
				self.applyNavigationChange()
			}
			topItems.insert(currentSeasonAction, at: 0)
		}

		return UIMenu(title: "", children: topItems)
	}

	/// Resets the view state and refetches details after the season or year changes via the picker.
	private func applyNavigationChange() {
		self.selectedChipIndex = 0
		self.updateNavigationTitle()
		self.seasonPickerBarButtonItem.menu = self.makeJumpToMenu()

		self.cache = [:]
		self.browseSeasons = []
		self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
		self.dataSource.apply(self.snapshot, animatingDifferences: true)
		self.setShowToolbar(false)
		self._prefersActivityIndicatorHidden = false

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	/// Presents the system share sheet for the active season's shareable URL.
	private func presentShareSheet() {
		guard let url = self.shareURL else { return }

		let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
		self.present(activityViewController, animated: true)
	}

	/// Toggles the view between a state ready for screenshotting and the default state.
	///
	/// - Parameter isScreenshotting: A boolean value indicating whether the view is in screenshotting state.
	private func toggleScreenshotState(isScreenshotting: Bool) {
		self.collectionView.backgroundColor = isScreenshotting ? KThemePicker.backgroundColor.colorValue : nil
		self.collectionView.showsVerticalScrollIndicator = !isScreenshotting
		self.setShowToolbar(!isScreenshotting)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.collectionView.topEdgeEffect.isHidden = isScreenshotting
			self.collectionView.bottomEdgeEffect.isHidden = isScreenshotting
		}
	}

	func fetchDetails() async {
		do {
			let response = try await KService.browseSeason(self.kind, year: self.year, season: self.season).response()
			self.browseSeasons = response.data
			self.reloadView()
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.configure(for: User.current)
	}

	/// Returns the item count carried by the given browse season group.
	///
	/// - Parameter browseSeason: The browse season group whose items should be counted.
	///
	/// - Returns: The number of items in the group.
	func itemCount(in browseSeason: BrowseSeason) -> Int {
		return browseSeason.relationships.shows?.data.count
			?? browseSeason.relationships.literatures?.data.count
			?? browseSeason.relationships.games?.data.count
			?? 0
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .game, .literature, .show: return nil
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

		switch identifier {
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .gameDetailsSegue:
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		}
	}
}

// MARK: - TMBarDataSource
extension SeasonalCollectionViewController: TMBarDataSource {
	func reloadView() {
		guard !self.browseSeasons.isEmpty else {
			self.setShowToolbar(false)
			return
		}
		self.setShowToolbar(true)

		self.tabBarView.reloadData(at: 0...self.browseSeasons.count, context: .full)
	}

	func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
		if index == 0 {
			return TMBarItem(title: L10n.all)
		}

		guard let browseSeason = self.browseSeasons[safe: index - 1] else {
			return TMBarItem(title: "")
		}

		return TMBarItem(title: browseSeason.attributes.type.name)
	}
}

// MARK: - TMBarDelegate
extension SeasonalCollectionViewController: TMBarDelegate {
	func bar(_ bar: Tabman.TMBar, didRequestScrollTo index: Int) {
		let direction = TMBarUpdateDirection.forPage(index, previousPage: self.selectedChipIndex)
		self.updateBar(to: CGFloat(index), animated: true, direction: direction)

		self.selectedChipIndex = index
		self.updateDataSource()
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension SeasonalCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let browseSeason = self.filteredBrowseSeasons[safe: indexPath.section] else { return }
		let target: any Libraryable

		switch cell.libraryKind {
		case .shows:
			guard let show = browseSeason.relationships.shows?.data[safe: indexPath.item] else { return }
			target = show
		case .literatures:
			guard let literature = browseSeason.relationships.literatures?.data[safe: indexPath.item] else { return }
			target = literature
		case .games:
			guard let game = browseSeason.relationships.games?.data[safe: indexPath.item] else { return }
			target = game
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await target.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive, handler: { _ in
				Task {
					await target.removeFromLibrary()
					cell.libraryStatus = .none
					button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
				}
			}))
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let browseSeason = self.filteredBrowseSeasons[safe: indexPath.section] else { return }
		guard let show = browseSeason.relationships.shows?.data[safe: indexPath.item] as? Show else { return }

		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}

// MARK: - UIScreenshotServiceDelegate
extension SeasonalCollectionViewController: UIScreenshotServiceDelegate {
	func screenshotServiceGeneratePDFRepresentation(_ screenshotService: UIScreenshotService) async -> (Data?, Int, CGRect) {
		self.toggleScreenshotState(isScreenshotting: true)
		defer { self.toggleScreenshotState(isScreenshotting: false) }

		let savedContentOffset = self.collectionView.contentOffset
		let contentSize = self.collectionView.contentSize
		let viewport = self.collectionView.bounds.size

		guard viewport.height > 0, contentSize.height > 0 else {
			return (nil, 0, .zero)
		}

		let pageWidth = viewport.width
		let chunkHeight = viewport.height
		let totalHeight = max(contentSize.height, chunkHeight)
		let chunkCount = max(1, Int(ceil(totalHeight / chunkHeight)))
		let maxYOffset = max(0, contentSize.height - chunkHeight)

		// Warm cell layout and image caches by walking the visible window through each chunk.
		for chunkIndex in 0..<chunkCount {
			let yOffset = chunkIndex == chunkCount - 1 ? maxYOffset : min(CGFloat(chunkIndex) * chunkHeight, maxYOffset)
			self.collectionView.contentOffset = CGPoint(x: 0, y: yOffset)
			self.collectionView.layoutIfNeeded()
			try? await Task.sleep(nanoseconds: 120_000_000)
		}

		let pdfBounds = CGRect(origin: .zero, size: CGSize(width: pageWidth, height: totalHeight))
		let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds)
		let data = renderer.pdfData { context in
			context.beginPage()

			for chunkIndex in 0..<chunkCount {
				let yOffset = chunkIndex == chunkCount - 1 ? maxYOffset : min(CGFloat(chunkIndex) * chunkHeight, maxYOffset)
				self.collectionView.contentOffset = CGPoint(x: 0, y: yOffset)
				self.collectionView.layoutIfNeeded()

				let destinationRect = CGRect(x: 0, y: yOffset, width: pageWidth, height: chunkHeight)
				self.collectionView.drawHierarchy(in: destinationRect, afterScreenUpdates: true)
			}
		}

		self.collectionView.contentOffset = savedContentOffset

		let visibleRect = CGRect(x: 0, y: savedContentOffset.y, width: pageWidth, height: chunkHeight)
		return (data, 0, visibleRect)
	}
}

// MARK: - UIToolbarDelegate
extension SeasonalCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - Cell Configuration
extension SeasonalCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .show(let show, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literature(let literature, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .game(let game, _):
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension SeasonalCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a browse season section layout type.
		case browseSeason(_: BrowseSeason)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .browseSeason(let browseSeason):
				hasher.combine(browseSeason)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.browseSeason(let browseSeason1), .browseSeason(let browseSeason2)):
				return browseSeason1 == browseSeason2
			}
		}
	}
}

// MARK: - ItemKind
extension SeasonalCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show, section: SectionLayoutKind)

		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature, section: SectionLayoutKind)

		/// Indicates the item kind contains a `Game` object.
		case game(_: Game, section: SectionLayoutKind)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let section):
				hasher.combine(show)
				hasher.combine(section)
			case .literature(let literature, let section):
				hasher.combine(literature)
				hasher.combine(section)
			case .game(let game, let section):
				hasher.combine(game)
				hasher.combine(section)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let section1), .show(let show2, let section2)):
				return show1 == show2 && section1 == section2
			case (.literature(let literature1, let section1), .literature(let literature2, let section2)):
				return literature1 == literature2 && section1 == section2
			case (.game(let game1, let section1), .game(let game2, let section2)):
				return game1 == game2 && section1 == section2
			default:
				return false
			}
		}
	}
}
