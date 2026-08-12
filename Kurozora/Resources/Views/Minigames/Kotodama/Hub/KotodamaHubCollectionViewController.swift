//
//  KotodamaHubCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/07/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class KotodamaHubCollectionViewController: KCollectionViewController {
	// MARK: - Views
	/// The bar button item presenting the how-to-play screen.
	private var helpBarButtonItem: UIBarButtonItem!

	// MARK: - Properties
	/// The number of fastest solves handed to the game screen.
	static let peekLimit = 3

	/// Today's puzzle, the player's game for it, and their record.
	var daily: KotodamaDaily?

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	/// The calendar day the hub's data was last fetched for.
	private var fetchedDay: Date?

	/// The token observing app-wide significant time changes, used to refetch across a day rollover.
	private var significantTimeChangeObserver: NSObjectProtocol?

	private var _prefersActivityIndicatorHidden = false {
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

		self.title = L10n.kotodama
		self.configureNavigationItems()
		self.configureDataSource()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.reload),
			name: .KKotodamaGameDidFinish,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.reload),
			name: .KKotodamaNextDailyDidUnlock,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(self.reload),
			name: .KUserIsSignedInDidChange,
			object: nil
		)
		self.significantTimeChangeObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.significantTimeChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.reloadIfDayChanged()
		}

		self.reload()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.reloadIfDayChanged()
	}

	deinit {
		if let significantTimeChangeObserver {
			NotificationCenter.default.removeObserver(significantTimeChangeObserver)
		}
	}

	// MARK: - Functions
	/// Configures the navigation items.
	private func configureNavigationItems() {
		self.helpBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "questionmark.circle"),
			primaryAction: UIAction { [weak self] _ in
				guard let self = self else { return }
				self.presentHowToPlay()
			}
		)
		self.helpBarButtonItem.accessibilityLabel = L10n.kotodamaHowToPlay

		self.navigationItem.rightBarButtonItem = self.helpBarButtonItem
	}

	/// Presents the how-to-play screen modally.
	private func presentHowToPlay() {
		let howToPlayViewController = KotodamaHowToPlayViewController()
		self.present(KNavigationController(rootViewController: howToPlayViewController), animated: true)
	}

	override func configureEmptyDataView() {
		self.collectionView.backgroundView?.alpha = 0

		if let image = UIImage(systemName: "square.grid.3x3.fill") {
			self.emptyBackgroundView.configureImageView(image: image)
		}
		self.emptyBackgroundView.configureLabels(
			title: L10n.kotodamaSignInRequired,
			detail: L10n.kotodamaSignInRequiredDescription
		)
	}

	override func handleRefreshControl() {
		self.reload()
	}

	/// Fades the empty data view in or out according to the number of items.
	func toggleEmptyDataView() {
		if self.daily == nil {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Opens the screen behind the given mode.
	///
	/// - Parameter mode: The mode to open.
	func open(mode: KotodamaMode) {
		switch mode {
		case .unlimited:
			self.playUnlimited()
		case .archive:
			Task { [weak self] in
				guard let self = self else { return }
				guard await WorkflowController.shared.isProOrSubscribed(on: self) else { return }

				self.show(KotodamaArchiveCollectionViewController(), sender: nil)
			}
		case .leaderboards:
			self.show(KotodamaLeaderboardsTableViewController(), sender: nil)
		case .stats:
			self.show(KotodamaStatsCollectionViewController(), sender: nil)
		}
	}

	/// Opens today's puzzle.
	func playDaily() {
		guard let daily = self.daily, let game = daily.game else { return }

		self.show(
			KotodamaGameViewController(puzzle: .game(game), stats: daily.stats, topEntries: daily.topEntries),
			sender: nil
		)
	}

	/// Refetches the hub's data when the calendar day has rolled over since the last fetch.
	private func reloadIfDayChanged() {
		guard let fetchedDay = self.fetchedDay, !Calendar.current.isDateInToday(fetchedDay) else { return }

		self.reload()
	}

	/// Fetches everything the hub shows before drawing any of it.
	@objc private func reload() {
		guard User.isSignedIn else {
			self.daily = nil
			self._prefersActivityIndicatorHidden = true
			self.configureEmptyDataView()
			self.updateDataSource()
			return
		}

		Task { [weak self] in
			guard let self = self else { return }

			await self.fetchDaily()

			self._prefersActivityIndicatorHidden = true
			self.configureEmptyDataView()
			self.updateDataSource()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}

	/// Fetches today's puzzle, the player's record and the fastest solves together.
	private func fetchDaily() async {
		async let puzzleResponse = try? await KService.kotodamaDaily().response()
		async let statsResponse = try? await KService.myKotodamaStats().response()
		async let leaderboardResponse = try? await KService
			.kotodamaDailyLeaderboard(limit: Self.peekLimit)
			.response()

		let game = await puzzleResponse?.data.first
		let stats = await statsResponse
		let leaderboard = await leaderboardResponse

		guard let game = game else {
			self.daily = nil
			return
		}

		self.daily = KotodamaDaily(
			puzzle: game.dailyPuzzle,
			game: game,
			stats: stats?.data.first,
			topEntries: leaderboard?.data ?? []
		)
		self.fetchedDay = Date()
	}

	/// Starts a practice game.
	private func playUnlimited() {
		self.show(KotodamaGameViewController(puzzle: .unlimited), sender: nil)
	}
}
