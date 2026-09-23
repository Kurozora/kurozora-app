//
//  ReCapCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class ReCapCollectionViewController: KCollectionViewController, SectionFetchable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case genresSegue
		case themesSegue
		case studioDetailsSegue
		case characterDetailsSegue
		case personDetailsSegue
	}

	// MARK: - Views
	private var shareBarButtonItem: UIBarButtonItem!

	private let yearButton = UIButton(type: .system)

	/// The pills that switch the page between the year's periods.
	let periodPickerView = ReCapPeriodPickerView()

	/// The gradient glows drawn behind the page's content.
	let backdrop = ReCapBackdrop()

	/// The text shown while the page loads.
	private let loadingLabel = UILabel()

	// MARK: - Properties
	/// The year the page shows.
	var year: Int = 0

	/// The month the page opens on.
	var month: Int?

	/// The month of the period the page shows.
	private(set) var selectedMonth: Int = 0

	/// The periods of every recap of the user.
	var recaps: [Recap] = []

	/// The recaps of the selected period.
	var recapItems: [RecapItem] = []

	/// The recaps of the year before the selected yearly period.
	var previousRecapItems: [RecapItem] = []

	/// The top entry of each month of the selected yearly period keyed by type.
	var monthlyTopEntries: [RecapItemType: [(month: Int, recapEntry: RecapEntry)]] = [:]

	/// The stat cards of the selected period keyed by group.
	var statCards: [ReCapStatCard.Group: [ReCapStatCard]] = [:]

	/// The models the recaps refer to.
	var models = ReCapModels()

	/// The months of the selected year that can be shown.
	private(set) var periodMonths: [Int] = []

	var cache: [ItemKind: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	/// Observes local library mutations to refresh visible cells.
	private var libraryObserver: LocalLibraryEntryObserver?

	/// Observes the size and scroll position of the page's content.
	private var scrollObservations: [NSKeyValueObservation] = []

	/// The fetch of the selected period.
	private var fetchTask: Task<Void, Never>?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	override var prefersActivityIndicatorHidden: Bool {
		return true
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.title = L10n.reCAP

		self.configureView()
		self.configureDataSource()
		self.observeLibraryChanges()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchPeriods()
			self.selectPeriod(month: self.month ?? self.defaultMonth())
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.view.window?.windowScene?.screenshotService?.delegate = self
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.layoutBackdrop()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchDetails()
	}

	/// Subscribes to local library mutations affecting the visible cells.
	private func observeLibraryChanges() {
		guard let slug = User.current?.attributes.slug else { return }
		self.libraryObserver = LocalLibraryEntryObserver(
			matching: LocalLibraryEntryObserver.matches(userSlug: slug),
			onChange: { [weak self] entry in
				self?.applyLibraryEntryChange(forTrackableID: entry.trackableID, kind: entry.kind)
			},
			onRemove: { [weak self] removed in
				self?.applyLibraryEntryChange(forTrackableID: removed.trackableID, kind: removed.kind)
			}
		)
	}

	/// Redraws every title whose identity matches the given trackable identity.
	private func applyLibraryEntryChange(forTrackableID trackableID: String, kind: LibraryKind) {
		self.reconfigureItems { item in
			switch (item, kind) {
			case (.showIdentity(let identity, _, _), .shows):
				return identity.id.rawValue == trackableID
			case (.literatureIdentity(let identity, _, _), .literatures):
				return identity.id.rawValue == trackableID
			case (.gameIdentity(let identity, _, _), .games):
				return identity.id.rawValue == trackableID
			default:
				return false
			}
		}
	}

	func configureView() {
		self.configureShareBarButtonItem()
		self.configureYearBarButtonItem()
		self.configurePeriodPickerView()
		self.configureBackdropView()
		self.configureLoadingLabel()
	}

	/// Configures the share bar button item.
	private func configureShareBarButtonItem() {
		self.shareBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.shareBarButtonItemPressed()
		})
	}

	/// Configures the button that switches the page between years.
	private func configureYearBarButtonItem() {
		var configuration = UIButton.Configuration.plain()
		configuration.image = UIImage(systemName: "chevron.up.chevron.down")
		configuration.imagePlacement = .trailing
		configuration.imagePadding = 4.0
		configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 11.0, weight: .semibold)
		self.yearButton.configuration = configuration
		self.yearButton.showsMenuAsPrimaryAction = true
		self.yearButton.accessibilityHint = L10n.recapSelectYear

		let yearBarButtonItem = UIBarButtonItem(customView: self.yearButton)

		if #available(iOS 26.0, macCatalyst 26.0, *) {
			yearBarButtonItem.sharesBackground = false
			self.shareBarButtonItem.sharesBackground = false
		}

		self.navigationItem.rightBarButtonItems = [self.shareBarButtonItem, yearBarButtonItem]
		self.configureYearMenu()
	}

	/// Lists the years of the user's recaps in the year menu.
	private func configureYearMenu() {
		let years = Array(Set(self.recaps.map(\.attributes.year))).sorted(by: >)

		self.yearButton.configuration?.attributedTitle = AttributedString(String(self.year), attributes: AttributeContainer([.font: UIFont.preferredFont(forTextStyle: .headline)]))
		self.yearButton.isHidden = years.isEmpty
		self.yearButton.menu = UIMenu(children: years.map { year in
			UIAction(title: String(year), state: year == self.year ? .on : .off) { [weak self] _ in
				self?.selectYear(year)
			}
		})
	}

	/// Configures the pills that switch the page between periods.
	private func configurePeriodPickerView() {
		self.periodPickerView.periodSelectedHandler = { [weak self] month in
			self?.selectPeriod(month: month)
		}
	}

	/// Places the backdrop behind the page's content.
	private func configureBackdropView() {
		self.backdrop.colors = self.recapColors
		self.backdrop.install(in: self.collectionView)
		self.scrollObservations = [
			self.collectionView.observe(\.contentSize, options: [.new]) { [weak self] _, _ in
				MainActor.assumeIsolated {
					self?.layoutBackdrop()
				}
			},
			self.collectionView.observe(\.contentOffset, options: [.new]) { [weak self] _, _ in
				MainActor.assumeIsolated {
					self?.layoutBackdrop()
				}
			},
		]
	}

	/// Configures the text shown while the page loads.
	private func configureLoadingLabel() {
		self.loadingLabel.text = L10n.recapThisIsYourRecap
		self.loadingLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
		self.loadingLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.loadingLabel.textAlignment = .center
		self.loadingLabel.numberOfLines = 0
		self.loadingLabel.isHidden = true
		self.loadingLabel.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.loadingLabel)

		NSLayoutConstraint.activate([
			self.loadingLabel.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor),
			self.loadingLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0),
			self.loadingLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0),
		])
	}

	/// Positions the glows for the page's current scroll position.
	private func layoutBackdrop() {
		self.backdrop.layout(in: self.collectionView)
	}

	/// Shows or hides the loading text.
	///
	/// - Parameter isLoading: Whether the page is loading.
	private func setLoading(_ isLoading: Bool) {
		self.loadingLabel.layer.removeAllAnimations()
		self.loadingLabel.isHidden = !isLoading
		self.loadingLabel.alpha = 1.0

		if isLoading, self.snapshot?.numberOfItems != 0 {
			self.snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
			self.dataSource.apply(self.snapshot, animatingDifferences: false)
		}

		guard isLoading, !UIAccessibility.isReduceMotionEnabled else { return }

		UIView.animate(withDuration: 1.0, delay: 0.0, options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction]) {
			self.loadingLabel.alpha = 0.5
		}
	}

	func setShowToolbar(_ show: Bool) {
		self.navigationItem.setBottomPalette(contentView: show ? self.periodPickerView : nil, height: KChipsView.paletteHeight)
	}

	/// Returns the month the selected year opens on.
	///
	/// - Returns: The month of the default period.
	func defaultMonth() -> Int {
		let months = self.recaps.filter { $0.attributes.year == self.year }.map(\.attributes.month)
		let now = Date.now.components

		if self.year == now.year, let currentMonth = now.month {
			if currentMonth != 1, months.contains(currentMonth - 1) {
				return currentMonth - 1
			}

			return months.filter { $0 != 0 }.max() ?? currentMonth
		}

		if months.contains(0) {
			return 0
		}

		return months.max() ?? 0
	}

	/// Switches the page to the given year.
	///
	/// - Parameter year: The year to show.
	func selectYear(_ year: Int) {
		guard year != self.year else { return }

		self.year = year
		self.configureYearMenu()
		self.selectPeriod(month: self.defaultMonth())
	}

	/// Switches the page to the period of the given month.
	///
	/// - Parameter month: The month of the period to show.
	func selectPeriod(month: Int) {
		self.selectedMonth = month
		self.backdrop.colors = self.recapColors
		self.reloadPeriods()
		self.fetchDetails()
	}

	/// Fetches the periods of every recap of the user.
	func fetchPeriods() async {
		do {
			let recapResponse = try await KService.recaps().response()
			self.recaps = recapResponse.data
			self.backdrop.colors = self.recapColors		} catch {
			print("----- Failed fetching recaps: \(error.localizedDescription)")
		}

		self.configureYearMenu()
	}

	/// Fetches the recaps of the selected period and the models they refer to.
	func fetchDetails() {
		let year = self.year
		let month = self.selectedMonth

		self.fetchTask?.cancel()
		self.setLoading(true)
		self.fetchTask = Task { [weak self] in
			guard let self = self else { return }

			let period = await self.fetchPeriod(year: year, month: month)
			guard !Task.isCancelled, year == self.year, month == self.selectedMonth else { return }

			self.recapItems = period.recapItems
			self.previousRecapItems = period.previousRecapItems
			self.monthlyTopEntries = period.monthlyTopEntries
			self.models = period.models
			self.statCards = ReCapStatCard.cards(from: period.recapStats, shows: period.models.shows)
			self.backdrop.colors = self.recapColors
			self.updateDataSource()
			self.collectionView.layoutIfNeeded()
			self.collectionView.setContentOffset(CGPoint(x: 0.0, y: -self.collectionView.adjustedContentInset.top), animated: false)
			self.setLoading(false)

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

	/// Returns the recaps, stats and models of the given period.
	///
	/// - Parameters:
	///    - year: The year of the period.
	///    - month: The month of the period.
	///
	/// - Returns: The content of the period.
	private func fetchPeriod(year: Int, month: Int) async -> (recapItems: [RecapItem], previousRecapItems: [RecapItem], monthlyTopEntries: [RecapItemType: [(month: Int, recapEntry: RecapEntry)]], recapStats: [RecapStat], models: ReCapModels) {
		let hasPreviousYearlyRecap = month == 0 && self.recaps.contains { $0.attributes.year == year - 1 && $0.attributes.month == 0 }
		let recapMonths = month == 0 ? Array(Set(self.recaps.filter { $0.attributes.year == year && $0.attributes.month != 0 }.map(\.attributes.month))).sorted() : []

		async let recapItems = self.fetchRecapItems(year: year, month: month)
		async let recapStats = self.fetchRecapStats(year: year, month: month)
		async let previousRecapItems = hasPreviousYearlyRecap ? self.fetchRecapItems(year: year - 1, month: 0) : []
		async let monthlyTopEntries = self.fetchMonthlyTopEntries(year: year, months: recapMonths)

		let content = await (recapItems: recapItems, previousRecapItems: previousRecapItems, monthlyTopEntries: monthlyTopEntries, recapStats: recapStats)
		let additionalEntries = content.monthlyTopEntries.values.flatMap { $0.map(\.recapEntry) }
		let models = await ReCapModels.fetch(for: content.recapItems, previousRecapItems: content.previousRecapItems, recapStats: content.recapStats, additionalEntries: additionalEntries)

		return (content.recapItems, content.previousRecapItems, content.monthlyTopEntries, content.recapStats, models)
	}

	/// Returns the top entry of each of the given months keyed by type.
	///
	/// - Parameters:
	///    - year: The year of the months.
	///    - months: The months with a recap.
	///
	/// - Returns: The top entries sorted by month.
	private func fetchMonthlyTopEntries(year: Int, months: [Int]) async -> [RecapItemType: [(month: Int, recapEntry: RecapEntry)]] {
		guard !months.isEmpty else { return [:] }

		let monthlyRecapItems = await withTaskGroup(of: (Int, [RecapItem]).self) { taskGroup in
			for month in months {
				taskGroup.addTask {
					(month, await self.fetchRecapItems(year: year, month: month))
				}
			}

			var monthlyRecapItems: [(Int, [RecapItem])] = []
			for await result in taskGroup {
				monthlyRecapItems.append(result)
			}
			return monthlyRecapItems.sorted { $0.0 < $1.0 }
		}

		var topEntries: [RecapItemType: [(month: Int, recapEntry: RecapEntry)]] = [:]

		for (month, recapItems) in monthlyRecapItems {
			for recapItem in recapItems {
				let recapItemType = recapItem.attributes.recapItemType
				guard
					[.shows, .literatures, .games].contains(recapItemType),
					let recapEntry = self.recapEntries(of: recapItem).first
				else { continue }

				topEntries[recapItemType, default: []].append((month, recapEntry))
			}
		}

		return topEntries
	}

	/// Returns the recaps of the given period.
	private func fetchRecapItems(year: Int, month: Int) async -> [RecapItem] {
		do {
			return try await KService.recap(year: "\(year)", month: "\(month)").response().data
		} catch {
			print("----- Failed fetching recap \(year)/\(month): \(error.localizedDescription)")
			return []
		}
	}

	/// Returns the stats of the given period.
	private func fetchRecapStats(year: Int, month: Int) async -> [RecapStat] {
		do {
			return try await KService.recapStats(year: "\(year)", month: "\(month)").response().data
		} catch {
			print("----- Failed fetching recap stats \(year)/\(month): \(error.localizedDescription)")
			return []
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
	/// Leads back to the Explore tab.
	func keepTrackingButtonPressed() {
		self.navigationController?.popToRootViewController(animated: true)
		NavigationManager.shared.selectedDestination = Scheme.home.urlValue
	}

	func shareBarButtonItemPressed() {
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
		case .showIdentity(let id, _, _): return id as? Element
		case .literatureIdentity(let id, _, _): return id as? Element
		case .gameIdentity(let id, _, _): return id as? Element
		case .studioIdentity(let id, _, _): return id as? Element
		case .characterIdentity(let id, _): return id as? Element
		case .personIdentity(let id, _, _): return id as? Element
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
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
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
		case .genresSegue:
			guard let homeCollectionViewController = destination as? HomeCollectionViewController else { return }
			guard let genre = sender as? Genre else { return }
			homeCollectionViewController.genre = genre
		case .themesSegue:
			guard let homeCollectionViewController = destination as? HomeCollectionViewController else { return }
			guard let theme = sender as? Theme else { return }
			homeCollectionViewController.theme = theme
		case .studioDetailsSegue:
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .personDetailsSegue:
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		}
	}

	/// Shows the details of the given model.
	///
	/// - Parameter model: The model to show.
	func showDetails(of model: KurozoraItem) {
		switch model {
		case let show as Show:
			self.show(SegueIdentifiers.showDetailsSegue, sender: show)
		case let literature as Literature:
			self.show(SegueIdentifiers.literatureDetailsSegue, sender: literature)
		case let game as Game:
			self.show(SegueIdentifiers.gameDetailsSegue, sender: game)
		case let genre as Genre:
			self.show(SegueIdentifiers.genresSegue, sender: genre)
		case let theme as Theme:
			self.show(SegueIdentifiers.themesSegue, sender: theme)
		case let studio as Studio:
			self.show(SegueIdentifiers.studioDetailsSegue, sender: studio)
		case let character as Character:
			self.show(SegueIdentifiers.characterDetailsSegue, sender: character)
		case let person as Person:
			self.show(SegueIdentifiers.personDetailsSegue, sender: person)
		default:
			break
		}
	}
}

// MARK: - Periods
extension ReCapCollectionViewController {
	/// Lists the periods of the selected year in the period picker.
	func reloadPeriods() {
		let yearRecaps = self.recaps.filter { $0.attributes.year == self.year }
		let hasYearlyRecap = yearRecaps.contains { $0.attributes.month == 0 }
		var months = Set(yearRecaps.map(\.attributes.month).filter { $0 != 0 })
		let now = Date.now.components

		if self.year == now.year, let currentMonth = now.month {
			months.insert(currentMonth)
		}

		self.periodMonths = months.sorted()

		guard hasYearlyRecap || !self.periodMonths.isEmpty else {
			self.setShowToolbar(false)
			return
		}

		self.setShowToolbar(true)
		self.periodPickerView.configure(year: self.year, hasYearlyRecap: hasYearlyRecap, months: self.periodMonths, selectedMonth: self.selectedMonth)
	}

	/// The recap colors of the selected year.
	var recapColors: [UIColor] {
		let recap = self.recaps.first { $0.attributes.year == self.year }
		let colors = [recap?.attributes.backgroundColor1, recap?.attributes.backgroundColor2].compactMap { $0.flatMap { UIColor(hexString: $0) } }
		return colors.count == 2 ? colors : [Self.spectrumColor(forYear: self.year), Self.spectrumColor(forYear: self.year - 1)]
	}

	/// Returns the recap color of the given year.
	///
	/// - Parameter year: The year whose color to return.
	///
	/// - Returns: The recap color of the year.
	static func spectrumColor(forYear year: Int) -> UIColor {
		let hue = (150.0 + CGFloat(2026 - year) * 38.0).truncatingRemainder(dividingBy: 360.0)
		return UIColor(hue: (hue + 360.0).truncatingRemainder(dividingBy: 360.0) / 360.0, saturation: 0.68, brightness: 0.82, alpha: 1.0)
	}

	/// The name of the selected period.
	var periodName: String {
		return Month(rawValue: self.selectedMonth)?.name ?? String(self.year)
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
		case header(_: String, rollingText: String?)

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

		/// Indicates a top studios section layout type.
		case topStudios(_: RecapItem)

		/// Indicates a top characters section layout type.
		case topCharacters(_: RecapItem)

		/// Indicates a top voices section layout type.
		case topVoices(_: RecapItem)

		/// Indicates a top creators section layout type.
		case topCreators(_: RecapItem)

		/// Indicates a top titles by month section layout type.
		case topByMonth(_: RecapItemType)

		/// Indicates a stats section layout type.
		case stats(_: ReCapStatCard.Group)

		/// Indicates a comparisons section layout type.
		case comparisons

		/// Indicates a milestones section layout type.
		case milestones(_ isFullSection: Bool)

		/// Indicates a keep tracking section layout type.
		case keepTracking
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
		case showIdentity(_: ShowIdentity, detail: String?, section: SectionLayoutKind)

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, detail: String?, section: SectionLayoutKind)

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, detail: String?, section: SectionLayoutKind)

		/// Indicates the item kind contains the top genres or themes of a recap.
		case genreCard(_: RecapItem)

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, detail: String?, section: SectionLayoutKind)

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, section: SectionLayoutKind)

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, detail: String?, section: SectionLayoutKind)

		/// Indicates the item kind contains the top title of a month.
		case monthlyTitle(_: RecapItemType, month: Int, id: KurozoraItemID)

		/// Indicates the item kind contains a stat card.
		case statCard(_: ReCapStatCard)

		/// Indicates the item kind contains the comparison of a recap type.
		case comparison(_: RecapItemType)

		/// Indicates the item kind contains a `RecapItem` object.
		case recapItem(_: RecapItem, milestoneKind: MilestoneKind)

		/// Indicates the item kind contains the keep tracking button.
		case keepTracking
	}
}
