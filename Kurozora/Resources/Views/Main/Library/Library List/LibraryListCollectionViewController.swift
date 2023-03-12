//
//  LibraryListCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryListCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var shows: [Show] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}
	var literatures: [Literature] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}
	var games: [Game] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()

			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
		}
	}
	var nextPageURL: String?
	var libraryStatus: KKLibrary.Status = .planning
	var sectionIndex: Int?
	var librarySortType: KKLibrary.SortType = .none
	var librarySortTypeOption: KKLibrary.SortType.Options = .none {
		didSet {
			self.nextPageURL = nil
			self.delegate?.libraryListViewController(updateSortWith: librarySortType)
		}
	}
	var libraryCellStyle: KKLibrary.CellStyle = .detailed
	weak var delegate: LibraryListViewControllerDelegate?
	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil

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
			self.enableRefreshControl()
		}
		self.handleRefreshControl()
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(addToLibrary(_:)), name: Notification.Name("AddTo\(self.libraryStatus.sectionValue)Section"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(removeFromLibrary(_:)), name: Notification.Name("RemoveFrom\(self.libraryStatus.sectionValue)Section"), object: nil)

		// Add bottom inset to avoid the tabbar obscuring the view
		self.collectionView.contentInset.bottom = 50

		// Hide activity indicator if user is not signed in.
		if !User.isSignedIn {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		// Add Refresh Control to Collection View
		self.enableRefreshControl()
		#if !targetEnvironment(macCatalyst)
		let libraryStatus: String

		switch UserSettings.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
		}

		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(libraryStatus.lowercased()) list.")
		#endif

		self.configureDataSource()

		// Fetch library if user is signed in
		if User.isSignedIn {
			DispatchQueue.global(qos: .userInteractive).async { [weak self] in
				guard let self = self else { return }
				Task {
					await self.fetchLibrary()
				}
			}
		}
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// Save current page index
		UserSettings.set(self.sectionIndex, forKey: .libraryPage)

		// Setup library view controller delegate
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDelegate = self
		(tabmanParent as? LibraryViewController)?.libraryViewControllerDataSource = self

		// Update change layout button to reflect user settings
		self.delegate?.libraryListViewController(updateLayoutWith: self.libraryCellStyle)

		// Update sort type button to reflect user settings
		self.delegate?.libraryListViewController(updateSortWith: self.librarySortType)
	}

	// MARK: - Functions
	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 || !User.isSignedIn {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	override func handleRefreshControl() {
		self.nextPageURL = nil
		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			guard let self = self else { return }
			Task {
				await self.fetchLibrary()
			}
		}
	}

	override func configureEmptyDataView() {
		let titleString: String
		var subtitleString: String
		let image: UIImage
		let buttonTitle: String
		let buttonAction: (() -> Void)?
		let libraryStatus: String

		switch UserSettings.libraryKind {
		case .shows:
			libraryStatus = self.libraryStatus.showStringValue
			titleString = "No Shows"
			subtitleString = "Add a show to your \(libraryStatus.lowercased()) list and it will show up here."
			image = R.image.empty.animeLibrary()!
		case .literatures:
			libraryStatus = self.libraryStatus.literatureStringValue
			titleString = "No Literatures"
			subtitleString = "Add a literature to your \(libraryStatus.lowercased()) list and it will show up here."
			image = R.image.empty.mangaLibrary()!
		case .games:
			libraryStatus = self.libraryStatus.gameStringValue
			titleString = "No Games"
			subtitleString = "Add a game to your \(libraryStatus.lowercased()) list and it will show up here."
			image = R.image.empty.gameLibrary()!
		}

		if User.isSignedIn {
			buttonTitle = ""
			buttonAction = nil
		} else {
			subtitleString = "Library is currently available to registered Kurozora users only."
			buttonTitle = "Sign In"
			buttonAction = {
				if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
					let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
					self.present(kNavigationController, animated: true)
				}
			}
		}

		self.emptyBackgroundView.configureImageView(image: image)
		self.emptyBackgroundView.configureLabels(title: titleString, detail: subtitleString)
		self.emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Enables and disables the refresh control according to the user sign in state.
	private func enableRefreshControl() {
		self._prefersRefreshControlDisabled = !User.isSignedIn
	}

	/// Fetch the library items for the current user.
	func fetchLibrary() async {
		if User.isSignedIn {
			let libraryStatus: String

			switch UserSettings.libraryKind {
			case .shows:
				libraryStatus = self.libraryStatus.showStringValue
			case .literatures:
				libraryStatus = self.libraryStatus.literatureStringValue
			case .games:
				libraryStatus = self.libraryStatus.gameStringValue
			}

			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing your \(libraryStatus.lowercased()) list...")
				#endif
			}

			do {
				let libraryResponse = try await KService.getLibrary(UserSettings.libraryKind, withLibraryStatus: self.libraryStatus, withSortType: self.librarySortType, withSortOption: librarySortTypeOption, next: self.nextPageURL).value

				// Reset data if necessary
				if self.nextPageURL == nil {
					self.shows = []
					self.literatures = []
					self.games = []
				}

				// Save next page url and append new data
				self.nextPageURL = libraryResponse.next
				if let shows = libraryResponse.data.shows {
					self.shows.append(contentsOf: shows)
				}
				if let literatures = libraryResponse.data.literatures {
					self.literatures.append(contentsOf: literatures)
				}
				if let games = libraryResponse.data.games {
					self.games.append(contentsOf: games)
				}
			} catch {
				print(error.localizedDescription)
			}

			// Reset refresh controller title
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your \(libraryStatus.lowercased()) list.")
			#endif
		} else {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.shows.removeAll()
				self.collectionView.reloadData {
					self.toggleEmptyDataView()
				}
			}
		}
	}

	/// Add the given show to the library.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func addToLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			guard let self = self else { return }
			Task {
				await self.fetchLibrary()
			}
		}
	}

	/// Removes the given show from the library.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers that bridges to Notification.
	@objc func removeFromLibrary(_ notification: NSNotification) {
		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			guard let self = self else { return }
			Task {
				await self.fetchLibrary()
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.libraryListCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailCollectionViewController.show = show
		case R.segue.libraryListCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.libraryListCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		default: break
		}
	}
}

// MARK: - UICollectionViewDragDelegate
extension LibraryListCollectionViewController: UICollectionViewDragDelegate {
	func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		guard let libraryBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? LibraryBaseCollectionViewCell else { return [] }
		var userActivity: NSUserActivity
		var localObject: Any?

		switch UserSettings.libraryKind {
		case .shows:
			guard let selectedShow = self.shows[safe: indexPath.row] else { return [] }
			userActivity = selectedShow.openDetailUserActivity
			localObject = selectedShow
		case .literatures:
			guard let selectedLiterature = self.literatures[safe: indexPath.row] else { return [] }
			userActivity = selectedLiterature.openDetailUserActivity
			localObject = selectedLiterature
		case .games:
			guard let selectedGame = self.games[safe: indexPath.row] else { return [] }
			userActivity = selectedGame.openDetailUserActivity
			localObject = selectedGame
		}

		let itemProvider = NSItemProvider(object: (libraryBaseCollectionViewCell as? LibraryDetailedCollectionViewCell)?.episodeImageView?.image ?? libraryBaseCollectionViewCell.posterImageView.image ?? R.image.placeholders.showPoster()!)
		itemProvider.suggestedName = libraryBaseCollectionViewCell.titleLabel.text
		itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = localObject

        return [dragItem]
    }
}

// MARK: - LibraryViewControllerDataSource
extension LibraryListCollectionViewController: LibraryViewControllerDataSource {
	func sortValue() -> KKLibrary.SortType {
		return self.librarySortType
	}

	func sortOptionValue() -> KKLibrary.SortType.Options {
		return self.librarySortTypeOption
	}
}

// MARK: - LibraryViewControllerDelegate
extension LibraryListCollectionViewController: LibraryViewControllerDelegate {
	func libraryViewController(_ view: LibraryViewController, didChange libraryKind: KKLibrary.Kind) {
		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			guard let self = self else { return }
			DispatchQueue.main.async {
				self.configureEmptyDataView()
			}

			Task {
				await self.fetchLibrary()
			}
		}
	}

	func sortLibrary(by sortType: KKLibrary.SortType, option: KKLibrary.SortType.Options) {
		self.librarySortType = sortType
		self.librarySortTypeOption = option

//		switch (self.librarySortType, self.librarySortTypeOption) {
//		case (.alphabetically, .ascending):
//			self.shows.sort { $0.attributes.title < $1.attributes.title }
//			self.updateDataSource()
//		case (.alphabetically, .descending):
//			self.shows.sort { $0.attributes.title > $1.attributes.title }
//			self.updateDataSource()
//		default: break
//		}

		DispatchQueue.global(qos: .userInteractive).async { [weak self] in
			guard let self = self else { return }
			Task {
				await self.fetchLibrary()
			}
		}
	}
}

// MARK: - UIScrollViewDelegate
extension LibraryListCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if let parent = self.parent?.parent as? LibraryViewController {
			parent.scrollView.contentSize = scrollView.contentSize
			parent.scrollView.contentInset = scrollView.contentInset
			parent.scrollView.contentOffset = scrollView.contentOffset
			parent.scrollView.decelerationRate = scrollView.decelerationRate
			parent.scrollView.panGestureRecognizer.state = scrollView.panGestureRecognizer.state
			parent.scrollView.directionalPressGestureRecognizer.state = scrollView.directionalPressGestureRecognizer.state
		}
	}
}

// MARK: - SectionLayoutKind
extension LibraryListCollectionViewController {
	/// List of cast section layout kind.
	///
	/// ```
	/// case main = 0
	/// ```
	enum SectionLayoutKind: Int, CaseIterable {
		case main = 0
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Show` object.
		case show(_: Show, id: UUID = UUID())

		/// Indicates the item kind contains a `Literature` object.
		case literature(_: Literature, id: UUID = UUID())

		/// Indicates the item kind contains a `Game` object.
		case game(_: Game, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .literature(let literature, let id):
				hasher.combine(literature)
				hasher.combine(id)
			case .game(let game, let id):
				hasher.combine(game)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1 == show2 && id1 == id2
			case (.literature(let literature1, let id1), .literature(let literature2, let id2)):
				return literature1 == literature2 && id1 == id2
			case (.game(let game1, let id1), .game(let game2, let id2)):
				return game1 == game2 && id1 == id2
			default:
				return false
			}
		}
	}
}
