//
//  KotodamaLeaderboardsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaLeaderboardsTableViewController: KTableViewController {
	// MARK: - Enums
	/// The set of available leaderboards.
	private enum Board: Int, CaseIterable {
		/// The fastest solves of today's puzzle.
		case today

		/// The longest streaks of all time.
		case streaks

		/// The title of the leaderboard.
		var stringValue: String {
			switch self {
			case .today:
				return L10n.today
			case .streaks:
				return L10n.kotodamaLeaderboardStreaks
			}
		}
	}

	// MARK: - Views
	private let segmentedControl = UISegmentedControl()
	private let toolbar = UIToolbar()

	// MARK: - Properties
	/// The leaderboard being shown.
	private var board: Board = .today

	/// The fastest solves of today's puzzle.
	private var dailyEntries: [KotodamaLeaderboardEntry] = []

	/// The longest streaks of all time.
	private var streakEntries: [KotodamaStreakEntry] = []

	/// The number of rows on the visible leaderboard.
	private var entryCount: Int {
		switch self.board {
		case .today:
			return self.dailyEntries.count
		case .streaks:
			return self.streakEntries.count
		}
	}

	private var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = L10n.kotodamaLeaderboards
		self.configureView()

		self.tableView.register(
			KotodamaLeaderboardCell.self,
			forCellReuseIdentifier: KotodamaLeaderboardCell.reuseIdentifier
		)
		self.tableView.rowHeight = UITableView.automaticDimension

		// Configured once, since `configureEmptyDataView()` runs on every reload and
		// `configureButton(title:handler:)` adds a target each time it is called.
		self.emptyBackgroundView.configureButton(title: L10n.kotodamaPlayToday) { [weak self] in
			self?.openDaily()
		}

		Task { [weak self] in
			await self?.fetchEntries()
		}
	}

	// MARK: - Functions
	/// Lays out the segmented control below the navigation bar.
	private func configureView() {
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.tableView.contentInset.top = 54
		} else {
			self.tableView.contentInset.top = 50
		}
		self.tableView.scrollIndicatorInsets = self.tableView.contentInset

		self.configureSegmentedControl()
		self.configureToolbar()
		self.configureViewHierarchy()
		self.configureViewConstraints()

		let segmentedControlBarButtonItem = UIBarButtonItem(customView: self.segmentedControl)
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			segmentedControlBarButtonItem.hidesSharedBackground = true
		}
		self.toolbar.setItems([segmentedControlBarButtonItem], animated: true)
	}

	/// Configures the toolbar hosting the segmented control.
	private func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}

	/// Adds the toolbar to the view hierarchy.
	private func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
	}

	/// Pins the toolbar below the navigation bar.
	private func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
		])
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: .Empty.rosetteStar)

		switch self.board {
		case .today:
			self.emptyBackgroundView.configureLabels(
				title: L10n.kotodamaNoSolves,
				detail: L10n.kotodamaNoSolvesDescription
			)
		case .streaks:
			self.emptyBackgroundView.configureLabels(
				title: L10n.kotodamaNoStreaks,
				detail: L10n.kotodamaNoStreaksDescription
			)
		}

		self.tableView.backgroundView?.alpha = 0
	}

	/// Opens today's puzzle.
	private func openDaily() {
		self.show(KotodamaGameViewController(puzzle: .daily), sender: nil)
	}

	/// Fades the empty data view in or out according to the number of rows.
	private func toggleEmptyDataView() {
		if self.entryCount == 0 {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	override func handleRefreshControl() {
		Task { [weak self] in
			await self?.fetchEntries()
		}
	}

	/// Builds the control that switches between leaderboards.
	private func configureSegmentedControl() {
		for board in Board.allCases {
			self.segmentedControl.insertSegment(withTitle: board.stringValue, at: board.rawValue, animated: false)
		}

		self.segmentedControl.selectedSegmentIndex = self.board.rawValue
		self.segmentedControl.addTarget(self, action: #selector(self.boardDidChange), for: .valueChanged)
	}

	/// Fetches the entries of the visible leaderboard.
	private func fetchEntries() async {
		do {
			switch self.board {
			case .today:
				let response = try await KService.kotodamaDailyLeaderboard().response()
				self.dailyEntries = response.data
			case .streaks:
				let response = try await KService.kotodamaStreakLeaderboard().response()
				self.streakEntries = response.data
			}
		} catch {
			switch self.board {
			case .today:
				self.dailyEntries = []
			case .streaks:
				self.streakEntries = []
			}
		}

		self._prefersActivityIndicatorHidden = true
		self.configureEmptyDataView()
		self.tableView.reloadData()
		self.toggleEmptyDataView()

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		#endif
	}

	/// Switches to the selected leaderboard.
	@objc private func boardDidChange() {
		guard let board = Board(rawValue: self.segmentedControl.selectedSegmentIndex) else { return }

		self.board = board
		self.tableView.backgroundView?.alpha = 0
		self._prefersActivityIndicatorHidden = false
		self.tableView.reloadData()

		Task { [weak self] in
			await self?.fetchEntries()
		}
	}
}

// MARK: - UIToolbarDelegate
extension KotodamaLeaderboardsTableViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - UITableViewDataSource
extension KotodamaLeaderboardsTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.board {
		case .today:
			return self.dailyEntries.count
		case .streaks:
			return self.streakEntries.count
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(
			withIdentifier: KotodamaLeaderboardCell.reuseIdentifier,
			for: indexPath
		) as? KotodamaLeaderboardCell else {
			return UITableViewCell()
		}

		switch self.board {
		case .today:
			cell.configure(using: self.dailyEntries[indexPath.row])
		case .streaks:
			cell.configure(using: self.streakEntries[indexPath.row])
		}

		return cell
	}
}

// MARK: - UITableViewDelegate
extension KotodamaLeaderboardsTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		let userID: KurozoraItemID?

		switch self.board {
		case .today:
			userID = self.dailyEntries[indexPath.row].user?.id
		case .streaks:
			userID = self.streakEntries[indexPath.row].user?.id
		}

		guard let userID = userID, !userID.rawValue.isEmpty else { return }

		self.show(ProfileTableViewController()(with: userID), sender: nil)
	}

	// MARK: - Managing Context Menus
	override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		let userID: KurozoraItemID?

		switch self.board {
		case .today:
			userID = self.dailyEntries[indexPath.row].user?.id
		case .streaks:
			userID = self.streakEntries[indexPath.row].user?.id
		}

		guard let userID = userID, !userID.rawValue.isEmpty else { return nil }

		return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
			ProfileTableViewController()(with: userID)
		})
	}

	override func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: tableViewCell, parameters: parameters)
	}

	override func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let indexPath = configuration.identifier as? IndexPath, let tableViewCell = tableView.cellForRow(at: indexPath), tableViewCell.window != nil else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear
		return UITargetedPreview(view: tableViewCell, parameters: parameters)
	}

	override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let previewViewController = animator.previewViewController else { return }

		animator.addCompletion { [weak self] in
			self?.show(previewViewController, sender: self)
		}
	}
}
