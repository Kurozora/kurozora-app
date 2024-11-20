//
//  ReCapCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import KurozoraKit
import Alamofire
import AVFoundation

struct RecapTabItem {
	let year: Int
	let month: Month?
}

class ReCapCollectionViewController: KCollectionViewController {
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

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()
	var currentTopContentInset: CGFloat = 0

	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

	var shows: [IndexPath: Show] = [:]
	var literatures: [IndexPath: Literature] = [:]
	var games: [IndexPath: Game] = [:]
	var genres: [IndexPath: Genre] = [:]
	var themes: [IndexPath: Theme] = [:]

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

		self.title = "\(Trans.reCAP)’\(self.year % 100)"

		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureDataSource()

		// Fetch ReCap details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchMonths()
			let index = self.recapTabItems.firstIndex { recapTabItem in
				recapTabItem.month?.rawValue == self.month
			} ?? 0
			self.bar(self.tabBarView, didRequestScrollTo: index)
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

	func configureTabBarView() {
		self.tabBarView.delegate = self
		self.tabBarView.dataSource = self
		self.updateBar(to: 0.0, animated: false, direction: .none)
		self.styleTabBarView()
	}

	func updateBar(to position: CGFloat?, animated: Bool, direction: TMBarUpdateDirection) {
		let animation = TMAnimation(isEnabled: animated, duration: 0.25)
		self.tabBarView.update(for: position ?? 0.0, capacity: self.recapTabItems.count, direction: .forward, animation: animation)
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
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
		self.toolbar.setItems([UIBarButtonItem(customView: self.tabBarView)], animated: true)
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

	func fetchMonths() async {
		do {
			let recapResponse = try await KService.getRecaps().value
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
			let recapResponse = try await KService.getRecap(for: "\(self.year)", month: "\(self.month)").value
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
	}

	// MARK: - IBActions
	@IBAction func shareBarButtonItemPressed(_ sender: UIBarButtonItem) {
		// Share Re:CAP view as screenshot.
		self.toggleScreenshotState(isScreenshotting: true)
		guard let image = self.collectionView.screenshot(fullScreen: true) else {
			self.toggleScreenshotState(isScreenshotting: false)
			return
		}
		self.toggleScreenshotState(isScreenshotting: false)

		let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		activityViewController.popoverPresentationController?.barButtonItem = sender
		self.present(activityViewController, animated: true)
	}
}

// MARK: - TMBarDataSource
extension ReCapCollectionViewController: TMBarDataSource {
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

		self.tabBarView.reloadData(at: 0...self.recapTabItems.count - 1, context: .full)
	}

	func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
		guard let recapTabItem = self.recapTabItems[safe: index] else {
			return TMBarItem(title: "")
		}
		let title = recapTabItem.month?.name ?? "\(recapTabItem.year)"
		return TMBarItem(title: title)
	}
}

// MARK: - TMBarDelegate
extension ReCapCollectionViewController: TMBarDelegate {
	func bar(_ bar: Tabman.TMBar, didRequestScrollTo index: Int) {
		let direction = TMBarUpdateDirection.forPage(index, previousPage: self.month - 1)
		self.updateBar(to: CGFloat(index), animated: true, direction: direction)

		guard let recapTabItem = self.recapTabItems[safe: index] else { return }
		self.month = recapTabItem.month?.rawValue ?? 0

		self.handleRefreshControl()
	}
}

// MARK: - UIScreenshotServiceDelegate
extension ReCapCollectionViewController: UIScreenshotServiceDelegate {
	func screenshotServiceGeneratePDFRepresentation(_ screenshotService: UIScreenshotService) async -> (Data?, Int, CGRect) {
		self.toggleScreenshotState(isScreenshotting: true)
		let data = self.collectionView.screenshot(fullScreen: true, format: .pdf)
		self.toggleScreenshotState(isScreenshotting: false)

		let y = self.collectionView.contentSize.height - self.collectionView.contentOffset.y - self.collectionView.frame.height

		return (data, 0, .init(origin: CGPoint(x: 0, y: y), size: self.view.frame.size))
	}
}

// MARK: - UIToolbarDelegate
extension ReCapCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - SectionLayoutKind
extension ReCapCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
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

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .header(let title):
				hasher.combine(title)
			case .topShows(let recapItem):
				hasher.combine(recapItem)
			case .topLiteratures(let recapItem):
				hasher.combine(recapItem)
			case .topGames(let recapItem):
				hasher.combine(recapItem)
			case .topGenres(let recapItem):
				hasher.combine(recapItem)
			case .topThemes(let recapItem):
				hasher.combine(recapItem)
			case .milestones(let isFullSection):
				hasher.combine(isFullSection)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.header(let title1), .header(let title2)):
				return title1 == title2
			case (.topShows(let recapItem1), .topShows(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topLiteratures(let recapItem1), .topLiteratures(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topGames(let recapItem1), .topGames(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topGenres(let recapItem1), .topGenres(let recapItem2)):
				return recapItem1 == recapItem2
			case (.topThemes(let recapItem1), .topThemes(let recapItem2)):
				return recapItem1 == recapItem2
			case (.milestones(let isFullSection1), .milestones(let isFullSection2)):
				return isFullSection1 == isFullSection2
			default: return false
			}
		}
	}
}

// MARK: - ItemKind
extension ReCapCollectionViewController {
	/// List of available Item Kind types.
	enum ItemKind: Hashable {
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

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .string(let string, let section):
				hasher.combine(string)
				hasher.combine(section)
			case .showIdentity(let showIdentity, let section):
				hasher.combine(showIdentity)
				hasher.combine(section)
			case .literatureIdentity(let literatureIdentity, let section):
				hasher.combine(literatureIdentity)
				hasher.combine(section)
			case .gameIdentity(let gameIdentity, let section):
				hasher.combine(gameIdentity)
				hasher.combine(section)
			case .genreIdentity(let genreIdentity, let section):
				hasher.combine(genreIdentity)
				hasher.combine(section)
			case .themeIdentity(let themeIdentity, let section):
				hasher.combine(themeIdentity)
				hasher.combine(section)
			case .recapItem(let recapItem, let milestoneKind):
				hasher.combine(recapItem)
				hasher.combine(milestoneKind)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.string(let string1, let section1), .string(let string2, let section2)):
				return string1 == string2 && section1 == section2
			case (.showIdentity(let showIdentity1, let section1), .showIdentity(let showIdentity2, let section2)):
				return showIdentity1 == showIdentity2 && section1 == section2
			case (.literatureIdentity(let literatureIdentity1, let section1), .literatureIdentity(let literatureIdentity2, let section2)):
				return literatureIdentity1 == literatureIdentity2 && section1 == section2
			case (.gameIdentity(let gameIdentity1, let section1), .gameIdentity(let gameIdentity2, let section2)):
				return gameIdentity1 == gameIdentity2 && section1 == section2
			case (.genreIdentity(let genreIdentity1, let section1), .genreIdentity(let genreIdentity2, let section2)):
				return genreIdentity1 == genreIdentity2 && section1 == section2
			case (.themeIdentity(let themeIdentity1, let section1), .themeIdentity(let themeIdentity2, let section2)):
				return themeIdentity1 == themeIdentity2 && section1 == section2
			case (.recapItem(let recapItem1, let milestoneKind1), .recapItem(let recapItem2, let milestoneKind2)):
				return recapItem1 == recapItem2 && milestoneKind1 == milestoneKind2
			default:
				return false
			}
		}
	}
}
