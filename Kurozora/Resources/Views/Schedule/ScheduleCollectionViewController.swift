//
//  ScheduleCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import Tabman
import KurozoraKit

class ScheduleCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var week: Int = 0
	var schedules: [Schedule] = [] {
		didSet {
			self.reloadView()
		}
	}

	let toolbar = UIToolbar()
	let tabBarView = TMBar.KBar()
	var currentTopContentInset: CGFloat = 0

	var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

	var shows: [IndexPath: Show] = [:]
	var literatures: [IndexPath: Literature] = [:]
	var games: [IndexPath: Game] = [:]

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

		self.configureTabBarView()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureDataSource()

		// Fetch schedule details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
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
		self.tabBarView.update(for: position ?? 0.0, capacity: self.schedules.count, direction: .forward, animation: animation)
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

	func fetchDetails() async {
		do {
			let scheduleResponse = try await KService.getSchedule(for: .shows, in: Date.now).value
			self.schedules = scheduleResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}
}

// MARK: - TMBarDataSource
extension ScheduleCollectionViewController: TMBarDataSource {
	func reloadView() {
		guard self.schedules.count > 0 else {
			self.setShowToolbar(false)
			return
		}
		self.setShowToolbar(true)

		self.tabBarView.reloadData(at: 0...self.schedules.count - 1, context: .full)
	}

	func barItem(for bar: Tabman.TMBar, at index: Int) -> Tabman.TMBarItemable {
		guard let date = self.schedules[safe: index]?.attributes.date else { return TMBarItem(title: "") }

		let title = DayOfWeek(rawValue: date.weekday)?.name ?? "N/A"
		return TMBarItem(title: title)
	}
}

// MARK: - TMBarDelegate
extension ScheduleCollectionViewController: TMBarDelegate {
	func bar(_ bar: Tabman.TMBar, didRequestScrollTo index: Int) {
		let direction = TMBarUpdateDirection.forPage(index, previousPage: self.week - 1)
		self.updateBar(to: CGFloat(index), animated: true, direction: direction)

		guard let recapTabItem = self.schedules[safe: index] else { return }
		self.week = recapTabItem.attributes.date.weekday

		self.handleRefreshControl()
	}
}

// MARK: - UIToolbarDelegate
extension ScheduleCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - SectionLayoutKind
extension ScheduleCollectionViewController {
	/// List of available Section Layout Kind types.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a schedule section layout type.
		case schedule(_: Schedule)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .schedule(let schedule):
				hasher.combine(schedule)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.schedule(let schedule1), .schedule(let schedule2)):
				return schedule1 == schedule2
			}
		}
	}
}

// MARK: - ItemKind
extension ScheduleCollectionViewController {
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
