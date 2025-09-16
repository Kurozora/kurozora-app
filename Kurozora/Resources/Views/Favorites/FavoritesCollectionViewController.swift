//
//  FavoritesCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class FavoritesCollectionViewController: KCollectionViewController {
	var libraryKindSegmentedControl = UISegmentedControl()
	var toolbar = UIToolbar()

	// MARK: - Properties
	var shows: [Show] = []
	var literatures: [Literature] = []
	var games: [Game] = []
	var nextPageURL: String?
	var libraryKind: KKLibrary.Kind = UserSettings.libraryKind
	var user: User?
	private var viewedUser: User? {
		return self.user ?? User.current
	}

	var fetchInProgress: Bool = false

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

		if self.user == nil {
			self.handleRefreshControl()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Observe NotificationCenter for an update.
		if self.viewedUser?.id == User.current?.id {
			NotificationCenter.default.addObserver(self, selector: #selector(self.fetchFavoritesList), name: .KFavoriteModelsListDidChange, object: nil)
		}

		self.collectionView.contentInset.top = 50
		self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset

		self.configureLibraryKindSegmentedControl()
		self.configureToolbar()
		self.toolbar.setItems([UIBarButtonItem(customView: self.libraryKindSegmentedControl)], animated: true)

		self.configureViewHierarchy()
		self.configureViewConstraints()

		self.configureDataSource()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFavoritesList()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh favorites list!")
		#endif
	}

	// MARK: - Functions
	func configureLibraryKindSegmentedControl() {
		self.libraryKindSegmentedControl.segmentTitles = KKLibrary.Kind.allString
		self.libraryKindSegmentedControl.selectedSegmentIndex = self.libraryKind.rawValue
		self.libraryKindSegmentedControl.addTarget(self, action: #selector(self.libraryKindSegmentedControlDidChange(_:)), for: .valueChanged)
	}

	func configureToolbar() {
		self.toolbar.translatesAutoresizingMaskIntoConstraints = false
		self.toolbar.delegate = self
		self.toolbar.isTranslucent = false
		self.toolbar.backgroundColor = .clear
		self.toolbar.barStyle = .default
		self.toolbar.theme_tintColor = KThemePicker.tintColor.rawValue
		self.toolbar.theme_barTintColor = KThemePicker.barTintColor.rawValue
	}

	func configureViewHierarchy() {
		self.view.addSubview(self.toolbar)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			self.toolbar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.toolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.toolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
	}

	@objc
	func libraryKindSegmentedControlDidChange(_ sender: UISegmentedControl) {
		guard let libraryKind = KKLibrary.Kind(rawValue: sender.selectedSegmentIndex) else { return }
		self.libraryKind = libraryKind

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFavoritesList()
		}
	}

	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchFavoritesList()
		}
	}

	override func configureEmptyDataView() {
		var detailString: String

		if self.viewedUser?.id == User.current?.id {
			switch self.libraryKind {
			case .shows:
				detailString = "Favorited shows will show up on this page!"
			case .literatures:
				detailString = "Favorited literatures will show up on this page!"
			case .games:
				detailString = "Favorited games will show up on this page!"
			}
		} else {
			switch self.libraryKind {
			case .shows:
				detailString = "\(self.viewedUser?.attributes.username ?? "This user") hasn't favorited shows yet."
			case .literatures:
				detailString = "\(self.viewedUser?.attributes.username ?? "This user") hasn't favorited literatures yet."
			case .games:
				detailString = "\(self.viewedUser?.attributes.username ?? "This user") hasn't favorited games yet."
			}
		}

		self.emptyBackgroundView.configureImageView(image: R.image.empty.favorites()!)
		self.emptyBackgroundView.configureLabels(title: "No Favorites", detail: detailString)

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

	/// Fetches the user's favorite list.
	@objc func fetchFavoritesList() async {
		if self.fetchInProgress {
			return
		}
		self.fetchInProgress = true

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.collectionView.backgroundView?.alpha = 0

			self._prefersActivityIndicatorHidden = false

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing favorites list...")
			#endif
		}

		guard let userID = self.viewedUser?.id else { return }
		let userIdentity = UserIdentity(id: userID)

		do {
			let favoriteLibraryResponse = try await KService.getFavorites(forUser: userIdentity, libraryKind: self.libraryKind, next: self.nextPageURL).value

			// Reset data if necessary
			if self.nextPageURL == nil {
				self.shows = []
				self.literatures = []
				self.games = []
			}

			// Save next page url and append new data
			self.nextPageURL = favoriteLibraryResponse.next
			if let shows = favoriteLibraryResponse.data.shows {
				self.shows.append(contentsOf: shows)
			}
			if let literatures = favoriteLibraryResponse.data.literatures {
				self.literatures.append(contentsOf: literatures)
			}
			if let games = favoriteLibraryResponse.data.games {
				self.games.append(contentsOf: games)
			}
		} catch {
			print("-----", error.localizedDescription)
		}

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.configureEmptyDataView()
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}

		// Reset refresh controller title
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh favorites list!")
		#endif

		self.fetchInProgress = false
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.favoritesCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.favoritesCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.favoritesCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		default: break
		}
	}
}

// MARK: - UIToolbarDelegate
extension FavoritesCollectionViewController: UIToolbarDelegate {
	func position(for bar: UIBarPositioning) -> UIBarPosition {
		return .topAttached
	}
}

// MARK: - SectionLayoutKind
extension FavoritesCollectionViewController {
	/// List of  favorites section layout kind.
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
