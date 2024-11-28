//
//  PersonDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class PersonDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var personIdentity: PersonIdentity? = nil
	var person: Person! {
		didSet {
			self.title = self.person.attributes.fullName
			self.personIdentity = PersonIdentity(id: self.person.id)

			self._prefersActivityIndicatorHidden = true
			#if targetEnvironment(macCatalyst)
			self.touchBar = nil
			#endif

			#if DEBUG
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.endRefreshing()
			#endif
			#endif
		}
	}
	var characters: [IndexPath: Character] = [:]
	var characterIdentities: [CharacterIdentity] = []

	var shows: [IndexPath: Show] = [:]
	var showIdentities: [ShowIdentity] = []

	var literatures: [IndexPath: Literature] = [:]
	var literatureIdentities: [LiteratureIdentity] = []

	var games: [IndexPath: Game] = [:]
	var gameIdentities: [GameIdentity] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

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
	/// Initialize a new instance of PersonDetailsCollectionViewController with the given person id.
	///
	/// - Parameter personID: The person id to use when initializing the view.
	///
	/// - Returns: an initialized instance of PersonDetailsCollectionViewController.
	static func `init`(with personID: String) -> PersonDetailsCollectionViewController {
		if let personDetailsCollectionViewController = R.storyboard.people.personDetailsCollectionViewController() {
			personDetailsCollectionViewController.personIdentity = PersonIdentity(id: personID)
			return personDetailsCollectionViewController
		}

		fatalError("Failed to instantiate PersonDetailsCollectionViewController with the given perosn id.")
	}

	/// Initialize a new instance of PersonDetailsCollectionViewController with the given person object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of PersonDetailsCollectionViewController.
	static func `init`(with person: Person) -> PersonDetailsCollectionViewController {
		if let personDetailsCollectionViewController = R.storyboard.people.personDetailsCollectionViewController() {
			personDetailsCollectionViewController.person = person
			return personDetailsCollectionViewController
		}

		fatalError("Failed to instantiate PersonDetailsCollectionViewController with the given Person object.")
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch person details
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

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: R.image.empty.cast()!)
		self.emptyBackgroundView.configureLabels(title: "No Details", detail: "This character doesn't have details yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfItems() == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	func fetchDetails() async {
		guard let personIdentity = self.personIdentity else { return }

		if self.person == nil {
			do {
				let personResponse = try await KService.getDetails(forPerson: personIdentity).value
				self.person = personResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		} else {
			self.updateDataSource()
		}

		do {
			let characterIdentityResponse = try await KService.getCharacters(forPerson: personIdentity, limit: 10).value
			self.characterIdentities = characterIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forPerson: personIdentity, limit: 10).value
			self.showIdentities = showIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.getLiteratures(forPerson: personIdentity, limit: 10).value
			self.literatureIdentities = literatureIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getGames(forPerson: personIdentity, limit: 10).value
			self.gameIdentities = gameIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		self.updateDataSource()
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.personDetailsCollectionViewController.showsListSegue.identifier:
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.personIdentity = self.personIdentity
			showsListCollectionViewController.showsListFetchType = .person
		case R.segue.personDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.personDetailsCollectionViewController.literaturesListSegue.identifier:
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.personIdentity = self.personIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .person
		case R.segue.personDetailsCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.personDetailsCollectionViewController.gamesListSegue.identifier:
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.personIdentity = self.personIdentity
			gamesListCollectionViewController.gamesListFetchType = .person
		case R.segue.personDetailsCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case R.segue.personDetailsCollectionViewController.charactersListSegue.identifier:
			guard let charactersListCollectionViewController = segue.destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.personIdentity = self.personIdentity
			charactersListCollectionViewController.charactersListFetchType = .person
		case R.segue.personDetailsCollectionViewController.characterDetailsSegue.identifier:
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		default: break
		}
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension PersonDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			let modelID: String

			switch cell.libraryKind {
			case .shows:
				guard let show = self.shows[indexPath] else { return }
				modelID = show.id
			case .literatures:
				guard let literatures = self.literatures[indexPath] else { return }
				modelID = literatures.id
			case .games:
				guard let game = self.games[indexPath] else { return }
				modelID = game.id
			}

			let oldLibraryStatus = cell.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
				Task {
					do {
						let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, withLibraryStatus: value, modelID: modelID).value

						switch cell.libraryKind {
						case .shows:
							self.shows[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.literatures[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							self.games[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

						// Request review
						ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
					} catch let error as KKAPIError {
						self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
						print("----- Add to library failed", error.message)
					}
				}
			})

			if cell.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.removeFromLibrary, style: .destructive) { _ in
					Task {
						do {
							let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, modelID: modelID).value

							switch cell.libraryKind {
							case .shows:
								self.shows[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
							case .literatures:
								self.literatures[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
							case .games:
								self.games[indexPath]?.attributes.library?.update(using: libraryUpdateResponse.data)
							}

							// Update edntry in library
							cell.libraryStatus = .none
							button.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						} catch let error as KKAPIError {
							self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
							print("----- Remove from library failed", error.message)
						}
					}
				})
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
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.shows[indexPath] else { return }
		show.toggleReminder(on: self)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension PersonDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.person.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension PersonDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - Enums
extension PersonDetailsCollectionViewController {
	/// List of person section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates an about section layout type.
		case about

		/// Indicates an information section layout type.
		case information

		/// Indicates characters section layout type.
		case characters

		/// Indicates shows section layout type.
		case shows

		/// Indicates literatures section layout type.
		case literatures

		/// Indicates games section layout type.
		case games

		// MARK: - Properties
		/// The string value of a character section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .about:
				return Trans.about
			case .information:
				return Trans.information
			case .characters:
				return Trans.characters
			case .shows:
				return Trans.shows
			case .literatures:
				return Trans.literatures
			case .games:
				return Trans.games
			}
		}

		/// The string value of a character section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .about:
				return ""
			case .information:
				return ""
			case .characters:
				return R.segue.personDetailsCollectionViewController.charactersListSegue.identifier
			case .shows:
				return R.segue.personDetailsCollectionViewController.showsListSegue.identifier
			case .literatures:
				return R.segue.personDetailsCollectionViewController.literaturesListSegue.identifier
			case .games:
				return R.segue.personDetailsCollectionViewController.gamesListSegue.identifier
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Person` object.
		case person(_: Person, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .person(let person, let id):
				hasher.combine(person)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .showIdentity(let showIdentity, let id):
				hasher.combine(showIdentity)
				hasher.combine(id)
			case .literatureIdentity(let literatureIdentity, let id):
				hasher.combine(literatureIdentity)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.person(let person1, let id1), .person(let person2, let id2)):
				return person1 == person2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.showIdentity(let showIdentity1, let id1), .showIdentity(let showIdentity2, let id2)):
				return showIdentity1 == showIdentity2 && id1 == id2
			case (.literatureIdentity(let literatureIdentity1, let id1), .literatureIdentity(let literatureIdentity2, let id2)):
				return literatureIdentity1 == literatureIdentity2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
