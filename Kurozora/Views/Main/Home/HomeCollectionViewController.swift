//
//  HomeCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import WhatsNew

class HomeCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	lazy var genre: Genre? = nil
	lazy var theme: Theme? = nil
	let actionsArray: [[[String: String]]] = [
		[["title": "About In-App Purchases", "url": "https://kurozora.app/kb/iap"], ["title": "About Personalisation", "url": "https://kurozora.app/kb/personalisation"], ["title": "Welcome to Kurozora", "url": "https://kurozora.app/welcome"]],
		[["title": "Redeem", "segueId": R.segue.homeCollectionViewController.redeemSegue.identifier], ["title": "Become a Pro User", "segueId": R.segue.homeCollectionViewController.subscriptionSegue.identifier]]
	]

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var exploreCategories: [ExploreCategory] = [] {
		didSet {
			self.updateDataSource()
			self._prefersActivityIndicatorHidden = true
			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}

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

	// MARK: - Initializers
	/**
		Initialize a new instance of HomeCollectionViewController with the given genre object.

		- Parameter genre: The genre object to use when initializing the view.

		- Returns: an initialized instance of HomeCollectionViewController.
	*/
	static func `init`(with genre: Genre) -> HomeCollectionViewController {
		if let homeCollectionViewController = R.storyboard.home.homeCollectionViewController() {
			homeCollectionViewController.genre = genre
			return homeCollectionViewController
		}

		fatalError("Failed to instantiate HomeCollectionViewController with the given Genre object.")
	}

	/**
		Initialize a new instance of HomeCollectionViewController with the given theme object.

		- Parameter theme: The theme object to use when initializing the view.

		- Returns: an initialized instance of HomeCollectionViewController.
	*/
	static func `init`(with theme: Theme) -> HomeCollectionViewController {
		if let homeCollectionViewController = R.storyboard.home.homeCollectionViewController() {
			homeCollectionViewController.theme = theme
			return homeCollectionViewController
		}

		fatalError("Failed to instantiate HomeCollectionViewController with the given Theme object.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.title = self.genre?.attributes.name ?? self.theme?.attributes.name ?? "Explore"
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Add Refresh Control to Collection View
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch explore details.
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchExplore()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Show what's new in the app if necessary.
		self.showWhatsNew()
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		DispatchQueue.global(qos: .userInteractive).async {
			self.fetchExplore()
		}
	}

	/// Shows what's new in the app if necessary.
	fileprivate func showWhatsNew() {
		if WhatsNew.shouldPresent() {
			let whatsNew = KWhatsNewViewController(titleText: "What's New", buttonText: "Continue", items: KWhatsNewModel.current)
			self.present(whatsNew, animated: true)
		}
	}

	/// Fetches the explore page from the server.
	fileprivate func fetchExplore() {
		KService.getExplore(genreID: self.genre?.id, themeID: self.theme?.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let exploreCategories):
				// Remove any empty sections
				self.exploreCategories = exploreCategories.filter { exploreCategory in
					switch exploreCategory.attributes.exploreCategoryType {
					case .shows, .upcomingShows, .mostPopularShows:
						return !(exploreCategory.relationships.shows?.data.isEmpty ?? false)
					case .genres:
						return !(exploreCategory.relationships.genres?.data.isEmpty ?? false)
					case .themes:
						return !(exploreCategory.relationships.themes?.data.isEmpty ?? false)
					case .characters:
						return !(exploreCategory.relationships.characters?.data.isEmpty ?? false)
					case .people:
						return !(exploreCategory.relationships.people?.data.isEmpty ?? false)
					}
				}
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.homeCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				guard let show = sender as? Show else { return }
				showDetailCollectionViewController.showID = show.id
			}
		case R.segue.homeCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				guard let indexPath = sender as? IndexPath else { return }
				showsListCollectionViewController.title = exploreCategories[indexPath.section].attributes.title
				showsListCollectionViewController.shows = exploreCategories[indexPath.section].relationships.shows?.data ?? []
			}
		case R.segue.homeCollectionViewController.exploreSegue.identifier:
			// Segue to genre or theme explore
			if let homeCollectionViewController = segue.destination as? HomeCollectionViewController {
				if let genre = sender as? Genre {
					homeCollectionViewController.genre = genre
				} else if let theme = sender as? Theme {
					homeCollectionViewController.theme = theme
				}
			}
		case R.segue.homeCollectionViewController.characterSegue.identifier:
			// Segue to character details
			if let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController {
				guard let character = sender as? Character else { return }
				characterDetailsCollectionViewController.characterID = character.id
			}
		case R.segue.homeCollectionViewController.charactersListSegue.identifier:
			// Segue to characters list
			if let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController {
				guard let indexPath = sender as? IndexPath else { return }
				charactersListCollectionViewController.title = exploreCategories[indexPath.section].attributes.title
				charactersListCollectionViewController.characters = exploreCategories[indexPath.section].relationships.characters?.data ?? []
			}
		case R.segue.homeCollectionViewController.personSegue.identifier:
			// Segue to person details
			if let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController {
				guard let person = sender as? Person else { return }
				personDetailsCollectionViewController.personID = person.id
			}
		case R.segue.homeCollectionViewController.peopleListSegue.identifier:
			// Segue to people list
			if let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController {
				guard let indexPath = sender as? IndexPath else { return }
				peopleListCollectionViewController.title = exploreCategories[indexPath.section].attributes.title
				peopleListCollectionViewController.people = exploreCategories[indexPath.section].relationships.people?.data ?? []
			}
		default: break
		}
	}
}

// MARK: - Helper functions
extension HomeCollectionViewController {
	/**
		Dequeues and returns collection view cells for the vertical collection view cell style.

		- Parameter verticalCollectionCellStyle: The style of the collection view cell to be dequeued.
		- Parameter indexPath: The indexPath for which the collection view cell should be dequeued.

		- Returns: The dequeued collection view cell.
	*/
	func createExploreCell(with verticalCollectionCellStyle: VerticalCollectionCellStyle, for indexPath: IndexPath) -> UICollectionViewCell {
		switch verticalCollectionCellStyle {
		case .legal:
			guard let legalExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? LegalCollectionViewCell else {
				fatalError("Cannot dequeue reusable cell with identifier \(verticalCollectionCellStyle.identifierString)")
			}
			return legalExploreCollectionViewCell
		default:
			guard let actionBaseExploreCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: verticalCollectionCellStyle.identifierString, for: indexPath) as? ActionBaseExploreCollectionViewCell else {
					fatalError("Cannot dequeue reusable cell with identifier \(verticalCollectionCellStyle.identifierString)")
			}
			return actionBaseExploreCollectionViewCell
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension HomeCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension HomeCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func reminderButtonPressed(on cell: BaseLockupCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.exploreCategories[indexPath.section].relationships.shows?.data[indexPath.item] else { return }
		show.toggleReminder()
	}

	func chooseStatusButtonPressed(_ sender: UIButton, on cell: BaseLockupCollectionViewCell) {
		WorkflowController.shared.isSignedIn {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let show = self.exploreCategories[indexPath.section].relationships.shows?.data[indexPath.item] else { return }

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { (title, value)  in
				KService.addToLibrary(withLibraryStatus: value, showID: show.id) { result in
					switch result {
					case .success(let libraryUpdate):
						show.attributes.update(using: libraryUpdate)

						// Update entry in library
						cell.libraryStatus = value
						cell.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { _ in
					KService.removeFromLibrary(showID: show.id) { result in
						switch result {
						case .success(let libraryUpdate):
							show.attributes.update(using: libraryUpdate)

							// Update edntry in library
							cell.libraryStatus = .none
							cell.libraryStatusButton?.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
						}
					}
				}))
			}

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.present(actionSheetAlertController, animated: true, completion: nil)
			}
		}
	}
}

// MARK: - SectionLayoutKind
extension HomeCollectionViewController {
	/**
		List of available Section Layout Kind types.
	*/
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header(id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .header(let id):
				hasher.combine(id)
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.header(let id1), .header(let id2)):
				return id1 == id2
			}
		}
	}
}

// MARK: - ItemKind
extension HomeCollectionViewController {
	/**
		List of available Item Kind types.
	*/
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a Show object.
		case show(_: Show, id: UUID = UUID())

		/// Indicates the item kind contains a Genre object.
		case genre(_: Genre, id: UUID = UUID())

		/// Indicates the item kind contains a Theme object.
		case theme(_: Theme, id: UUID = UUID())

		/// Indicates the item kind contains a Character object.
		case character(_: Character, id: UUID = UUID())

		/// Indicates the item kind contains a Person object.
		case person(_: Person, id: UUID = UUID())

		/// Indicates the item kind contains an other type object.
		case other(_: Int)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .show(let show, let id):
				hasher.combine(show)
				hasher.combine(id)
			case .genre(let genre, let id):
				hasher.combine(genre)
				hasher.combine(id)
			case .theme(let theme, let id):
				hasher.combine(theme)
				hasher.combine(id)
			case .character(let character, let id):
				hasher.combine(character)
				hasher.combine(id)
			case .person(let person, let id):
				hasher.combine(person)
				hasher.combine(id)
			case .other(let int):
				hasher.combine(int)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.show(let show1, let id1), .show(let show2, let id2)):
				return show1.id == show2.id && id1 == id2
			case (.genre(let genre1, let id1), .genre(let genre2, let id2)):
				return genre1.id == genre2.id && id1 == id2
			case (.theme(let theme1, let id1), .theme(let theme2, let id2)):
				return theme1.id == theme2.id && id1 == id2
			case (.character(let character1, let id1), .character(let character2, let id2)):
				return character1.id == character2.id && id1 == id2
			case (.person(let person1, let id1), .person(let person2, let id2)):
				return person1.id == person2.id && id1 == id2
			case (.other(let int1), .other(let int2)):
				return int1 == int2
			default:
				return false
			}
		}
	}
}
