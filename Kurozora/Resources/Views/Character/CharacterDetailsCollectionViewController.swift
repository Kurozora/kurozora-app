//
//  CharacterDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire

class CharacterDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var characterIdentity: CharacterIdentity? = nil
	var character: Character! {
		didSet {
			self.title = self.character.attributes.name
			self.characterIdentity = CharacterIdentity(id: self.character.id)

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
	var people: [IndexPath: Person] = [:]
	var personIdentities: [PersonIdentity] = []

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
	/// Initialize a new instance of CharacterDetailsCollectionViewController with the given character id.
	///
	/// - Parameter characterID: The character id to use when initializing the view.
	///
	/// - Returns: an initialized instance of CharacterDetailsCollectionViewController.
	static func `init`(with characterID: String) -> CharacterDetailsCollectionViewController {
		if let characterDetailsCollectionViewController = R.storyboard.characters.characterDetailsCollectionViewController() {
			characterDetailsCollectionViewController.characterIdentity = CharacterIdentity(id: characterID)
			return characterDetailsCollectionViewController
		}

		fatalError("Failed to instantiate CharacterDetailsCollectionViewController with the given character id.")
	}

	/// Initialize a new instance of CharacterDetailsCollectionViewController with the given character object.
	///
	/// - Parameter show: The `Show` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of CharacterDetailsCollectionViewController.
	static func `init`(with character: Character) -> CharacterDetailsCollectionViewController {
		if let characterDetailsCollectionViewController = R.storyboard.characters.characterDetailsCollectionViewController() {
			characterDetailsCollectionViewController.character = character
			return characterDetailsCollectionViewController
		}

		fatalError("Failed to instantiate CharacterDetailsCollectionViewController with the given Character object.")
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
		guard let characterIdentity = self.characterIdentity else { return }

		if self.character == nil {
			do {
				let characterResponse = try await KService.getDetails(forCharacter: characterIdentity).value
				self.character = characterResponse.data.first
			} catch {
				print("-----", error.localizedDescription)
			}
		} else {
			self.updateDataSource()
		}

		do {
			let personIdentityResponse = try await KService.getPeople(forCharacter: characterIdentity, limit: 10).value
			self.personIdentities = personIdentityResponse.data
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.getShows(forCharacter: characterIdentity, limit: 10).value
			self.showIdentities = showIdentityResponse.data
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.getLiteratures(forCharacter: characterIdentity, limit: 10).value
			self.literatureIdentities = literatureIdentityResponse.data
		} catch {
			print("-----", error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getGames(forCharacter: characterIdentity, limit: 10).value
			self.gameIdentities = gameIdentityResponse.data
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.characterDetailsCollectionViewController.showsListSegue.identifier:
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.characterIdentity = self.characterIdentity
			showsListCollectionViewController.showsListFetchType = .charcter
		case R.segue.characterDetailsCollectionViewController.showDetailsSegue.identifier:
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.characterDetailsCollectionViewController.literaturesListSegue.identifier:
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.characterIdentity = self.characterIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .charcter
		case R.segue.characterDetailsCollectionViewController.literatureDetailsSegue.identifier:
			guard let literatureDetailCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case R.segue.characterDetailsCollectionViewController.gamesListSegue.identifier:
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.characterIdentity = self.characterIdentity
			gamesListCollectionViewController.gamesListFetchType = .charcter
		case R.segue.characterDetailsCollectionViewController.gameDetailsSegue.identifier:
			guard let gameDetailCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case R.segue.characterDetailsCollectionViewController.peopleListSegue.identifier:
			guard let peopleListCollectionViewController = segue.destination as? PeopleListCollectionViewController else { return }
			peopleListCollectionViewController.characterIdentity = self.characterIdentity
			peopleListCollectionViewController.peopleListFetchType = .character
		case R.segue.characterDetailsCollectionViewController.personDetailsSegue.identifier:
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - UICollectionViewDataSource
extension CharacterDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let characterDetailSection = self.snapshot.sectionIdentifiers[indexPath.section]
		let titleHeaderCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TitleHeaderCollectionReusableView.self, for: indexPath)
		titleHeaderCollectionReusableView.delegate = self
		titleHeaderCollectionReusableView.configure(withTitle: characterDetailSection.stringValue, indexPath: indexPath, segueID: characterDetailSection.segueIdentifier)
		return titleHeaderCollectionReusableView
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension CharacterDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.character.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension CharacterDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension CharacterDetailsCollectionViewController: BaseLockupCollectionViewCellDelegate {
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
				guard let literature = self.literatures[indexPath] else { return }
				modelID = literature.id
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
							self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .literatures:
							self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						case .games:
							self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = value
						button.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
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
								self.shows[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .literatures:
								self.literatures[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
							case .games:
								self.games[indexPath]?.attributes.update(using: libraryUpdateResponse.data)
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

// MARK: - Enums
extension CharacterDetailsCollectionViewController {
	/// List of character section layout kind.
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0

		/// Indicates an about section layout type.
		case about

		/// Indicates an information section layout type.
		case information

		/// Indicates people section layout type.
		case people

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
			case .people:
				return Trans.people
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
			case .people:
				return R.segue.characterDetailsCollectionViewController.peopleListSegue.identifier
			case .shows:
				return R.segue.characterDetailsCollectionViewController.showsListSegue.identifier
			case .literatures:
				return R.segue.characterDetailsCollectionViewController.literaturesListSegue.identifier
			case .games:
				return R.segue.characterDetailsCollectionViewController.gamesListSegue.identifier
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Character` object.
		case character(_: Character, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `ShowIdentity` object.
		case showIdentity(_: ShowIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `LiteratureIdentity` object.
		case literatureIdentity(_: LiteratureIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .character(let character, let id):
				hasher.combine(character)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
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
			case (.character(let character1, let id1), .character(let character2, let id2)):
				return character1 == character2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
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
