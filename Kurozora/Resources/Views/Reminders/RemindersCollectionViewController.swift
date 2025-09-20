//
//  RemindersCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class RemindersCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = []
	var literatures: [Literature] = []
	var games: [Game] = []
	var nextPageURL: String?
	var libraryKind: KKLibrary.Kind = .shows

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Views
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Observe NotificationCenter for an update.
		NotificationCenter.default.addObserver(self, selector: #selector(self.fetchRemindersList), name: .KReminderModelsListDidChange, object: nil)

		self.collectionView.contentInset.top = 20
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchRemindersList()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh reminders list!")
		#endif
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchRemindersList()
		}
	}

	override func configureEmptyDataView() {
		var detailString: String

		switch self.libraryKind {
		case .shows:
			detailString = "Reminded shows will show up on this page!"
		case .literatures:
			detailString = "Reminded literatures will show up on this page!"
		case .games:
			detailString = "Reminded games will show up on this page!"
		}

		self.emptyBackgroundView.configureImageView(image: R.image.empty.reminders()!)
		self.emptyBackgroundView.configureLabels(title: "No Reminders", detail: detailString)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.snapshot.itemIdentifiers.isEmpty {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches the user's reminder list.
	var fetchInProgress: Bool = false
	@objc func fetchRemindersList() async {
		if self.fetchInProgress {
			return
		}
		self.fetchInProgress = true

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.collectionView.backgroundView?.alpha = 0

			self._prefersActivityIndicatorHidden = false

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing reminders list...")
			#endif
		}

		do {
			let reminderLibraryResponse = try await KService.getReminders(for: self.libraryKind, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.shows = []
				self.literatures = []
				self.games = []
			}

			// Save next page url and append new data
			self.nextPageURL = reminderLibraryResponse.next
			if let shows = reminderLibraryResponse.data.shows {
				self.shows.append(contentsOf: shows)
			}
			if let literatures = reminderLibraryResponse.data.literatures {
				self.literatures.append(contentsOf: literatures)
			}
			if let games = reminderLibraryResponse.data.games {
				self.games.append(contentsOf: games)
			}
		} catch {
			print("-----", error.localizedDescription)
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh reminders list!")
		#endif

		self.fetchInProgress = false
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.remindersCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.remindersCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.remindersCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		default: break
		}
	}
}

// MARK: - SectionLayoutKind
extension RemindersCollectionViewController {
	/// List of  reminders section layout kind.
	///
	/// ```swift
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show)

		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature)

		/// Indicates the item kind contains a `Game` object.
		case game(_: Game)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show):
				hasher.combine(show)
			case .literature(let literature):
				hasher.combine(literature)
			case .game(let game):
				hasher.combine(game)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1), .show(let show2)):
				return show1 == show2
			case (.literature(let literature1), .literature(let literature2)):
				return literature1 == literature2
			case (.game(let game1), .game(let game2)):
				return game1 == game2
			default:
				return false
			}
		}
	}
}
