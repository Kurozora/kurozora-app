//
//  ScheduleCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ScheduleCollectionViewController: KCollectionViewController, SectionFetchable, ProfileNavigable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
	}

	// MARK: - Views
	var profileBarButtonItem: ProfileBarButtonItem?
	var todayBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	var week: Int = 0
	var schedules: [Schedule] = [] {
		didSet {
			self.reloadView()

			self._prefersActivityIndicatorHidden = true

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// The chips that switch the page between the week's days.
	let chipsView = KChipsView()

	/// The day the list is scrolling to, held until it lands on the section's real top.
	private var pendingDayScrollIndex: Int?

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
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureUserDetails()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.schedule

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureView()
		self.configureDataSource()
		self.configureNavigationItems()
		self.observeLibraryChanges()

		// Fetch schedule details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
			self.scrollToToday(animated: false)
		}
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
		self.configureProfileBarButtonItem()
	}

	func configureView() {
		self.configureNavBarButtons()
		self.configureChipsView()
	}

	func configureNavBarButtons() {
		self.todayBarButtonItem = UIBarButtonItem(title: L10n.today, style: .plain, target: self, action: #selector(self.handleTodayButtonPressed))
		self.navigationItem.rightBarButtonItem = self.todayBarButtonItem
	}

	func configureChipsView() {
		self.chipsView.chipSelectedHandler = { [weak self] index in
			guard let self = self else { return }
			self.scrollToDay(at: index, animated: true)
		}
	}

	func setShowToolbar(_ show: Bool) {
		self.navigationItem.setBottomPalette(contentView: show ? self.chipsView : nil, height: KChipsView.paletteHeight)
	}

	func fetchDetails() async {
		do {
			let scheduleResponse = try await KService.schedule(for: .shows, in: Date.now).response()
			self.schedules = scheduleResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.configure(for: User.current)
	}

	/// Scroll to today's schedule section.
	///
	/// - Parameter animated: Specify [`true`](https://developer.apple.com/documentation/swift/true) to animate the scrolling behavior or [`false`](https://developer.apple.com/documentation/swift/false) to adjust the scroll view’s visible content immediately.
	func scrollToToday(animated: Bool) {
		let todayIndex = self.schedules.firstIndex { schedule in
			Calendar.current.isDateInToday(schedule.attributes.date)
		} ?? 1

		self.scrollToDay(at: todayIndex, animated: animated)
	}

	/// Scrolls the day at the given index to the top.
	///
	/// - Parameters:
	///    - index: The index of the day to reveal.
	///    - animated: Whether the scroll animates.
	func scrollToDay(at index: Int, animated: Bool) {
		guard self.schedules.indices.contains(index) else { return }

		self.chipsView.selectChip(at: index, animated: animated)
		self.pendingDayScrollIndex = index
		self.collectionView.scrollToSection(index, animated: animated)

		guard !animated else { return }
		self.settleDayScroll()
	}

	/// Lands the pending scroll on the section's real top.
	func settleDayScroll() {
		// Sections the list has not reached yet are measured from an estimate, so the first pass stops short.
		guard let index = self.pendingDayScrollIndex else { return }
		self.pendingDayScrollIndex = nil

		self.collectionView.layoutIfNeeded()
		self.collectionView.scrollToSection(index, animated: false)
	}

	/// Hands scrolling back to the user, so the chips follow the list again.
	func endScrollingToDay() {
		self.pendingDayScrollIndex = nil
	}

	/// Reflects the day at the top of the list on the chips.
	func syncSelectedDay() {
		guard self.pendingDayScrollIndex == nil else { return }
		guard !self.schedules.isEmpty else { return }

		let topY = self.collectionView.contentOffset.y + self.collectionView.adjustedContentInset.top
		var visibleIndex = 0

		for section in self.schedules.indices {
			let indexPath = IndexPath(item: 0, section: section)
			guard let headerAttributes = self.collectionView.collectionViewLayout.layoutAttributesForSupplementaryView(
				ofKind: UICollectionView.elementKindSectionHeader,
				at: indexPath
			) else { continue }

			guard headerAttributes.frame.minY <= topY + 1.0 else { break }
			visibleIndex = section
		}

		guard visibleIndex != self.chipsView.selectedIndex else { return }
		self.chipsView.selectChip(at: visibleIndex, animated: true)
	}

	/// Handles today button pressed.
	@objc func handleTodayButtonPressed() {
		Task { @MainActor in
			self.scrollToToday(animated: true)
		}
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
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		}
	}
}

// MARK: - Chips
extension ScheduleCollectionViewController {
	func reloadView() {
		guard self.schedules.count > 0 else {
			self.setShowToolbar(false)
			return
		}
		self.setShowToolbar(true)

		self.chipsView.titles = self.schedules.map { schedule in
			let weekday = (schedule.attributes.date.components.weekday ?? 1) - 1
			return DayOfWeek(rawValue: weekday)?.name ?? schedule.attributes.date.formatted(.dateTime.weekday(.wide))
		}

		let todayIndex = self.schedules.firstIndex { schedule in
			Calendar.current.isDateInToday(schedule.attributes.date)
		}
		self.chipsView.selectChip(at: todayIndex ?? 0, animated: false)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension ScheduleCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let schedule = self.schedules[indexPath.section]
		let target: any Libraryable

		switch cell.libraryKind {
		case .shows:
			guard let show = schedule.relationships.shows?.data[safe: indexPath.item] else { return }
			target = show
		case .literatures:
			guard let literature = schedule.relationships.literatures?.data[safe: indexPath.item] else { return }
			target = literature
		case .games:
			guard let game = schedule.relationships.games?.data[safe: indexPath.item] else { return }
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
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let schedule = self.schedules[indexPath.section]
		guard let show = schedule.relationships.shows?.data[safe: indexPath.item] as? Show else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.libraryAttributes?.reminderStatus)
	}
}

// MARK: - SectionLayoutKind
extension ScheduleCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates a schedule section layout type.
		case schedule(_: Schedule)
	}
}

// MARK: - ItemKind
extension ScheduleCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: nonisolated Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show, section: SectionLayoutKind)

		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature, section: SectionLayoutKind)

		/// Indicates the item kind contains a `Game` object.
		case game(_: Game, section: SectionLayoutKind)
	}
}

// MARK: - Cell Configuration
extension ScheduleCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .show(let show, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show, scheduleIsShown: true)
			case .literature(let literature, _):
				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature, scheduleIsShown: true)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			switch itemKind {
			case .game(let game, _):
				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game, scheduleIsShown: true)
			default: break
			}
		}
	}
}
