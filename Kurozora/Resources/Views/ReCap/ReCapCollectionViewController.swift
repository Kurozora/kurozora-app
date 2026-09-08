//
//  ReCapCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import AVFoundation
import KurozoraKit
import UIKit

struct RecapTabItem {
	let year: Int
	let month: Month?
}

class ReCapCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case genresSegue
		case themesSegue
	}

	// MARK: - Views
	private var shareBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var year: Int = 0
	var month: Int = 0
	var recaps: [Recap] = [] {
		didSet {
			self.reloadView()
		}
	}

	var recapItems: [RecapItem] = [] {
		didSet {
			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	var recapTabItems: [RecapTabItem] = []

	/// The chips that switch the page between the year's months.
	let chipsView = KChipsView()

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

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.title = "\(L10n.reCAP)’\(self.year % 100)"

		self.configureView()
		self.configureDataSource()
		self.observeLibraryChanges()

		// Fetch ReCap details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchMonths()
			let index = self.recapTabItems.firstIndex { recapTabItem in
				recapTabItem.month?.rawValue == self.month
			} ?? 0
			self.selectMonth(at: index)
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

	/// Updates every cached show/literature/game whose identity matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, userSlug: String, kind: LibraryKind, isRemoval: Bool) {
		var matchedItems: [ItemKind] = []
		let currentSnapshot = self.dataSource.snapshot()

		for item in currentSnapshot.itemIdentifiers {
			let matches: Bool
			switch (item, kind) {
			case (.showIdentity(let identity, _), .shows):
				matches = identity.id.rawValue == trackableID
			case (.literatureIdentity(let identity, _), .literatures):
				matches = identity.id.rawValue == trackableID
			case (.gameIdentity(let identity, _), .games):
				matches = identity.id.rawValue == trackableID
			default:
				matches = false
			}
			guard matches else { continue }

			guard let indexPath = self.dataSource.indexPath(for: item) else { continue }
			switch kind {
			case .shows:
				guard self.cache[indexPath] is Show else { continue }
			case .literatures:
				guard self.cache[indexPath] is Literature else { continue }
			case .games:
				guard self.cache[indexPath] is Game else { continue }
			}
			matchedItems.append(item)
		}

		guard !matchedItems.isEmpty else { return }
		var snapshot = currentSnapshot
		snapshot.reconfigureItems(matchedItems)
		self.dataSource.apply(snapshot, animatingDifferences: false)
	}

	func configureView() {
		self.configureShareBarButtonItem()
		self.configureChipsView()
	}

	/// Configures the share bar button item.
	private func configureShareBarButtonItem() {
		self.shareBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.shareBarButtonItemPressed()
		})
		self.navigationItem.rightBarButtonItem = self.shareBarButtonItem
	}

	func configureChipsView() {
		self.chipsView.chipSelectedHandler = { [weak self] index in
			guard let self = self else { return }
			self.selectMonth(at: index)
		}
	}

	/// Switches the page to the month at the given index.
	///
	/// - Parameter index: The index of the month to show.
	func selectMonth(at index: Int) {
		guard let recapTabItem = self.recapTabItems[safe: index] else { return }

		self.chipsView.selectChip(at: index, animated: true)
		self.month = recapTabItem.month?.rawValue ?? 0
		self.handleRefreshControl()
	}

	func setShowToolbar(_ show: Bool) {
		self.navigationItem.setBottomPalette(contentView: show ? self.chipsView : nil, height: KChipsView.paletteHeight)
	}

	func fetchMonths() async {
		do {
			let recapResponse = try await KService.recaps().response()
			self.recaps = recapResponse.data
			self.reloadView()
		} catch {
			print(error.localizedDescription)
		}
	}

	func fetchDetails() async {
		if self.month == 0 {
			self.month = self.recapTabItems.first?.month?.rawValue ?? 0
		}

		do {
			let recapResponse = try await KService.recap(year: "\(self.year)", month: "\(self.month)").response()
			self.recapItems = recapResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Toggles the view between a state ready for screenshotting and the default state.
	///
	/// - Parameters:
	///    - isScreenshotting: A boolean value indicating whether the view is in screenshotting state.
	private func toggleScreenshotState(isScreenshotting: Bool) {
		self.collectionView.backgroundColor = isScreenshotting ? KThemePicker.backgroundColor.colorValue : nil
		self.collectionView.showsVerticalScrollIndicator = !isScreenshotting
		self.setShowToolbar(!isScreenshotting)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.collectionView.topEdgeEffect.isHidden = isScreenshotting
			self.collectionView.bottomEdgeEffect.isHidden = isScreenshotting
		}
	}

	// MARK: - IBActions
	func shareBarButtonItemPressed() {
		// Share Re:CAP view as screenshot.
		self.toggleScreenshotState(isScreenshotting: true)
		guard let image = self.collectionView.screenshot(fullScreen: true) else {
			self.toggleScreenshotState(isScreenshotting: false)
			return
		}
		self.toggleScreenshotState(isScreenshotting: false)

		let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		activityViewController.popoverPresentationController?.barButtonItem = self.shareBarButtonItem
		self.present(activityViewController, animated: true)
	}

	// MARK: - SectionFetchable
	func extractIdentity<Element>(from item: ItemKind) -> Element? where Element: KurozoraItem {
		switch item {
		case .gameIdentity(let id, _): return id as? Element
		case .literatureIdentity(let id, _): return id as? Element
		case .showIdentity(let id, _): return id as? Element
		case .genreIdentity(let id, _): return id as? Element
		case .themeIdentity(let id, _): return id as? Element
		default: return nil
		}
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .genresSegue, .themesSegue: return HomeCollectionViewController()
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .genresSegue:
			guard let homeCollectionViewController = destination as? HomeCollectionViewController else { return }
			guard let genre = sender as? Genre else { return }
			homeCollectionViewController.genre = genre
		case .themesSegue:
			guard let homeCollectionViewController = destination as? HomeCollectionViewController else { return }
			guard let theme = sender as? Theme else { return }
			homeCollectionViewController.theme = theme
		}
	}
}

// MARK: - Chips
extension ReCapCollectionViewController {
	func reloadView() {
		self.recapTabItems = self.recaps.filter { recap in
			recap.attributes.year == self.year
		}.sorted { recap1, recap2 in
			recap1.attributes.month < recap2.attributes.month
		}.map { recap in
			RecapTabItem(
				year: recap.attributes.year,
				month: Month(rawValue: recap.attributes.month)
			)
		}

		guard self.recapTabItems.count > 0 else {
			self.setShowToolbar(false)
			return
		}
		self.setShowToolbar(true)

		self.chipsView.titles = self.recapTabItems.map { recapTabItem in
			recapTabItem.month?.name ?? "\(recapTabItem.year)"
		}

		let selectedIndex = self.recapTabItems.firstIndex { recapTabItem in
			recapTabItem.month?.rawValue == self.month
		}
		self.chipsView.selectChip(at: selectedIndex ?? 0, animated: false)
	}
}

// MARK: BaseLockupCollectionViewCellDelegate
extension ReCapCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard signedIn else { return }
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let target = self.cache[indexPath] as? Libraryable
		else { return }

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				await target.addToLibrary(status: value)
				cell.libraryStatus = value
				button.setTitle("\(title) ▾", for: .normal)
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive) { _ in
				Task {
					await target.removeFromLibrary()
					cell.libraryStatus = .none
					button.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
				}
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let show = self.cache[indexPath] as? Show
		else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}

// MARK: - UIScreenshotServiceDelegate
extension ReCapCollectionViewController: UIScreenshotServiceDelegate {
	func screenshotServiceGeneratePDFRepresentation(_ screenshotService: UIScreenshotService) async -> (Data?, Int, CGRect) {
		self.toggleScreenshotState(isScreenshotting: true)
		defer { self.toggleScreenshotState(isScreenshotting: false) }

		let savedContentOffset = self.collectionView.contentOffset
		let savedFrame = self.collectionView.frame
		let contentSize = self.collectionView.contentSize

		self.collectionView.contentOffset = .zero
		self.collectionView.frame = CGRect(origin: .zero, size: contentSize)
		self.collectionView.layoutIfNeeded()

		let pdfBounds = CGRect(origin: .zero, size: contentSize)
		let renderer = UIGraphicsPDFRenderer(bounds: pdfBounds)
		let data = renderer.pdfData { context in
			context.beginPage()
			self.collectionView.drawHierarchy(in: pdfBounds, afterScreenUpdates: true)
		}

		self.collectionView.frame = savedFrame
		self.collectionView.contentOffset = savedContentOffset

		let visibleHeight = savedFrame.height
		let y = contentSize.height - savedContentOffset.y - visibleHeight
		let visibleRect = CGRect(x: 0, y: y, width: savedFrame.width, height: visibleHeight)

		return (data, 0, visibleRect)
	}
}

// MARK: - SectionLayoutKind
extension ReCapCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header(_: String)

		/// Indicates a top shows section layout type.
		case topShows(_: RecapItem)

		/// Indicates a top literatures section layout type.
		case topLiteratures(_: RecapItem)

		/// Indicates a top games section layout type.
		case topGames(_: RecapItem)

		/// Indicates a top genres section layout type.
		case topGenres(_: RecapItem)

		/// Indicates a top themes section layout type.
		case topThemes(_: RecapItem)

		/// Indicates a milestones section layout type.
		case milestones(_ isFullSection: Bool)
	}
}

// MARK: - ItemKind
extension ReCapCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `String` object.
		case string(_: String, section: SectionLayoutKind)

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `GenreIdentity` object.
		case genreIdentity(_: GenreIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `ThemeIdentity` object.
		case themeIdentity(_: ThemeIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `RecapItem` object.
		case recapItem(_: RecapItem, milestoneKind: MilestoneKind)
	}
}

// MARK: - Cell Configuration
extension ReCapCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show, rank: indexPath.item + 1)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature, rank: indexPath.item + 1)
			default: break
			}
		}
	}

	func getConfiguredHeaderCell() -> UICollectionView.CellRegistration<ReCapHeaderCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapHeaderCollectionViewCell, ItemKind>(cellNib: ReCapHeaderCollectionViewCell.nib) { reCapHeaderCollectionViewCell, _, itemKind in
			switch itemKind {
			case .string(let title, _):
				reCapHeaderCollectionViewCell.configure(using: title)
			default: break
			}
		}
	}

	func getConfiguredMilestoneCell() -> UICollectionView.CellRegistration<ReCapMilestoneCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<ReCapMilestoneCollectionViewCell, ItemKind>(cellNib: ReCapMilestoneCollectionViewCell.nib) { reCapMilestoneCollectionViewCell, _, itemKind in
			switch itemKind {
			case .recapItem(let recapItem, let milestoneKind):
				reCapMilestoneCollectionViewCell.configure(using: recapItem, milestoneKind: milestoneKind)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game, rank: indexPath.item + 1)
			default: break
			}
		}
	}

	func getConfiguredMediumCell() -> UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<MediumLockupCollectionViewCell, ItemKind>(cellNib: MediumLockupCollectionViewCell.nib) { [weak self] mediumLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .genreIdentity:
				let genre: Genre? = self.fetchModel(at: indexPath)

				if genre == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Genre>.self, GenreIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				mediumLockupCollectionViewCell.configure(using: genre, rank: indexPath.item + 1)
			case .themeIdentity:
				let theme: Theme? = self.fetchModel(at: indexPath)

				if theme == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Theme>.self, ThemeIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				mediumLockupCollectionViewCell.configure(using: theme, rank: indexPath.item + 1)
			default: break
			}
		}
	}
}
