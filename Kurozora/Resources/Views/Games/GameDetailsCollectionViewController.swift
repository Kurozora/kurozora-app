//
//  GameDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Alamofire
import AVFoundation
import Intents
import IntentsUI

class GameDetailsCollectionViewController: KCollectionViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var navigationTitleView: UIView!
	@IBOutlet weak var navigationTitleLabel: UILabel! {
		didSet {
			self.navigationTitleLabel.theme_textColor = KThemePicker.barTitleTextColor.rawValue
		}
	}

	// MARK: - Properties
	var gameIdentity: GameIdentity? = nil
	var game: Game! {
		didSet {
			self.navigationTitleLabel.text = self.game.attributes.title
			self.gameIdentity = GameIdentity(id: self.game.id)

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

	/// Related Game properties.
	var relatedGames: [RelatedGame] = []

	/// Related Show properties.
	var relatedShows: [RelatedShow] = []

	/// Related Literature properties.
	var relatedLiteratures: [RelatedLiterature] = []

	/// Cast properties.
	var cast: [IndexPath: Cast] = [:]
	var castIdentities: [CastIdentity] = []

	/// Studio properties.
	var studios: [IndexPath: Studio] = [:]
	var studioIdentities: [StudioIdentity] = []
//	var studio: Studio!
	var studioGames: [IndexPath: Game] = [:]
	var studioGameIdentities: [GameIdentity] = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>! = nil
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>! = nil
	var prefetchingIndexPathOperations: [IndexPath: DataRequest] = [:]

	// Touch Bar
	#if targetEnvironment(macCatalyst)
	var toggleGameIsFavoriteTouchBarItem: NSButtonTouchBarItem?
	var toggleGameIsRemindedTouchBarItem: NSButtonTouchBarItem?
	#endif

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
	/// Initialize a new instance of GameDetailsCollectionViewController with the given game id.
	///
	/// - Parameter gameID: The game id to use when initializing the view.
	///
	/// - Returns: an initialized instance of GameDetailsCollectionViewController.
	static func `init`(with gameID: String) -> GameDetailsCollectionViewController {
		if let gameDetailsCollectionViewController = R.storyboard.games.gameDetailsCollectionViewController() {
			gameDetailsCollectionViewController.gameIdentity = GameIdentity(id: gameID)
			return gameDetailsCollectionViewController
		}

		fatalError("Failed to instantiate GameDetailsCollectionViewController with the given game id.")
	}

	/// Initialize a new instance of GameDetailsCollectionViewController with the given game object.
	///
	/// - Parameter game: The `Game` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of GameDetailsCollectionViewController.
	static func `init`(with game: Game) -> GameDetailsCollectionViewController {
		if let gameDetailsCollectionViewController = R.storyboard.games.gameDetailsCollectionViewController() {
			gameDetailsCollectionViewController.game = game
			return gameDetailsCollectionViewController
		}

		fatalError("Failed to instantiate GameDetailsCollectionViewController with the given Game object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleFavoriteToggle(_:)), name: .KModelFavoriteIsToggled, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleReminderToggle(_:)), name: .KModelReminderIsToggled, object: nil)

		self.navigationTitleLabel.alpha = 0

		// Add refresh control
		#if DEBUG
		self._prefersRefreshControlDisabled = false
		#else
		self._prefersRefreshControlDisabled = true
		#endif

		self.configureDataSource()

		// Fetch game details.
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Make the navigation bar background clear
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		// Restore the navigation bar to default
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	override func configureEmptyDataView() {
		self.emptyBackgroundView.configureImageView(image: R.image.empty.animeLibrary()!)
		self.emptyBackgroundView.configureLabels(title: "No Details", detail: "This game doesn't have details yet. Please check back again later.")

		self.collectionView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of rows.
	func toggleEmptyDataView() {
		if self.collectionView.numberOfSections == 0 {
			self.collectionView.backgroundView?.animateFadeIn()
		} else {
			self.collectionView.backgroundView?.animateFadeOut()
		}
	}

	/// Fetches details for the given game identity. If none given then the currently viewed game's details are fetched.
	func fetchDetails() async {
		guard let gameIdentity = self.gameIdentity else { return }

		if self.game == nil {
			KService.getDetails(forGame: gameIdentity) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let games):
					self.game = games.first

					// Donate suggestion to Siri
					self.userActivity = self.game.openDetailUserActivity
				case .failure: break
				}
			}
		} else {
			// Donate suggestion to Siri
			self.userActivity = self.game.openDetailUserActivity

			self.updateDataSource()
		}

		do {
			let castIdentityResponse = try await KService.getCast(forGame: gameIdentity, limit: 10).value
			self.castIdentities = castIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forGame: gameIdentity, limit: 10).value
			self.studioIdentities = studioIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getMoreByStudio(forGame: gameIdentity, limit: 10).value
			self.studioGameIdentities = gameIdentityResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGameResponse = try await KService.getRelatedGames(forGame: gameIdentity, limit: 10).value
			self.relatedGames = relatedGameResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forGame: gameIdentity, limit: 10).value
			self.relatedShows = relatedShowResponse.data
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteratureResponse = try await KService.getRelatedLiteratures(forGame: gameIdentity, limit: 10).value
			self.relatedLiteratures = relatedLiteratureResponse.data
		} catch {
			print(error.localizedDescription)
		}

		self.updateDataSource()
	}

	@objc func toggleFavorite() {
		self.game?.toggleFavorite()
	}

	@objc func toggleReminder() {
//		self.game?.toggleReminder()
	}

	@objc func shareGame() {
		self.game?.openShareSheet(on: self)
	}

	@objc func handleFavoriteToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.game.attributes.favoriteStatus == .favorited ? "heart.fill" : "heart"
		self.toggleGameIsFavoriteTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	@objc func handleReminderToggle(_ notification: NSNotification) {
		#if targetEnvironment(macCatalyst)
		let name = self.game.attributes.reminderStatus == .reminded ? "bell.fill" : "bell"
		self.toggleGameIsRemindedTouchBarItem?.image = UIImage(systemName: name)
		#endif
	}

	// MARK: - IBActions
	@IBAction func moreButtonPressed(_ sender: UIBarButtonItem) {
		self.game?.openShareSheet(on: self, barButtonItem: sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.gameDetailsCollectionViewController.castListSegue.identifier:
			// Segue to cast list
			guard let castListCollectionViewController = segue.destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .game
			castListCollectionViewController.gameIdentity = self.gameIdentity
		case R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier:
			// Segue to games list
			guard let gamesListCollectionViewController = segue.destination as? GamesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				gamesListCollectionViewController.title = "\(Trans.moreBy) \(self.game.attributes.studio ?? Trans.studio)"
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .moreByStudio
			} else {
				gamesListCollectionViewController.title = Trans.relatedGames
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .relatedGame
			}
		case R.segue.gameDetailsCollectionViewController.showsListSegue.identifier:
			// Segue to shows list
			guard let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = Trans.relatedShows
			showsListCollectionViewController.gameIdentity = self.gameIdentity
			showsListCollectionViewController.showsListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.literaturesListSegue.identifier:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = segue.destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.title = Trans.relatedLiteratures
			literaturesListCollectionViewController.gameIdentity = self.gameIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.studiosListSegue.identifier:
			// Segue to studios list
			guard let studiosListCollectionViewController = segue.destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.gameIdentity = self.gameIdentity
			studiosListCollectionViewController.studiosListFetchType = .game
		case R.segue.gameDetailsCollectionViewController.gameDetailsSegue.identifier:
			// Segue to game details
			guard let gameDetailsCollectionViewController = segue.destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case R.segue.gameDetailsCollectionViewController.showDetailsSegue.identifier:
			// Segue to show details
			guard let showDetailsCollectionViewController = segue.destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case R.segue.gameDetailsCollectionViewController.literatureDetailsSegue.identifier:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = segue.destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case R.segue.gameDetailsCollectionViewController.studioDetailsSegue.identifier:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = segue.destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case R.segue.showDetailsCollectionViewController.characterDetailsSegue.identifier:
			// Segue to character details
			guard let characterDetailsCollectionViewController = segue.destination as? CharacterDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let character = self.cast[indexPath]?.relationships.characters.data.first else { return }
			characterDetailsCollectionViewController.character = character
		case R.segue.showDetailsCollectionViewController.personDetailsSegue.identifier:
			// Segue to person details
			guard let personDetailsCollectionViewController = segue.destination as? PersonDetailsCollectionViewController else { return }
			guard let cell = sender as? CastCollectionViewCell else { return }
			guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
			guard let person = self.cast[indexPath]?.relationships.people?.data.first else { return }
			personDetailsCollectionViewController.person = person
		default: break
		}
	}
}

// MARK: - CastCollectionViewCellDelegate
extension GameDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.personDetailsSegue.identifier, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.performSegue(withIdentifier: R.segue.gameDetailsCollectionViewController.characterDetailsSegue.identifier, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension GameDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.game.attributes.synopsis
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension GameDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}

// MARK: - UIScrollViewDelegate
extension GameDetailsCollectionViewController {
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let navigationBar = self.navigationController?.navigationBar
		let firstCell = self.collectionView.cellForItem(at: [0, 0])

		let globalNavigationBarPositionY = navigationBar?.superview?.convert(navigationBar?.frame.origin ?? CGPoint(x: 0, y: 0), to: nil).y ?? .zero
		let offset = scrollView.contentOffset.y
		let firstCellHeight = firstCell?.frame.size.height ?? .zero

		let percentage = offset / (firstCellHeight - globalNavigationBarPositionY)

		if percentage.isFinite, percentage >= 0 {
			self.navigationTitleLabel.alpha = percentage
		}
	}
}

// MARK: - RatingCollectionViewCellDelegate
extension GameDetailsCollectionViewController: RatingCollectionViewCellDelegate {
	func ratingCollectionViewCell(rateWith rating: Double) {
		self.game.rate(using: rating)
	}
}

extension GameDetailsCollectionViewController {
	enum SectionLayoutKind: Int, CaseIterable {
		// MARK: - Cases
		/// Indicates a header section layout type.
		case header = 0
		case badge
		case synopsis
		case rating
		case information
		case cast
		case studios
		case moreByStudio
		case relatedGames
		case relatedShows
		case relatedLiteratures
		case sosumi

		// MARK: - Properties
		/// The string value of a game section type.
		var stringValue: String {
			switch self {
			case .header:
				return Trans.header
			case .badge:
				return Trans.badges
			case .synopsis:
				return Trans.synopsis
			case .rating:
				return Trans.ratings
			case .information:
				return Trans.information
			case .cast:
				return Trans.cast
			case .studios:
				return Trans.studios
			case .moreByStudio:
				return Trans.moreBy
			case .relatedGames:
				return Trans.relatedGames
			case .relatedShows:
				return Trans.relatedShows
			case .relatedLiteratures:
				return Trans.relatedLiteratures
			case .sosumi:
				return Trans.copyright
			}
		}

		/// The string value of a game section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .badge:
				return ""
			case .synopsis:
				return ""
			case .rating:
				return ""
			case .information:
				return ""
			case .cast:
				return R.segue.gameDetailsCollectionViewController.castListSegue.identifier
			case .studios:
				return R.segue.gameDetailsCollectionViewController.studiosListSegue.identifier
			case .moreByStudio:
				return R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier
			case .relatedGames:
				return R.segue.gameDetailsCollectionViewController.gamesListSegue.identifier
			case .relatedShows:
				return R.segue.gameDetailsCollectionViewController.showsListSegue.identifier
			case .relatedLiteratures:
				return R.segue.gameDetailsCollectionViewController.literaturesListSegue.identifier
			case .sosumi:
				return ""
			}
		}
	}

	/// List of available Item Kind types.
	enum ItemKind: Hashable {
		// MARK: - Cases
		/// Indicates the item kind contains a `Game` object.
		case game(_: Game, id: UUID = UUID())

		/// Indicates the item kind contains a `GameIdentity` object.
		case gameIdentity(_: GameIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedGame` object.
		case relatedGame(_: RelatedGame, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedShow` object.
		case relatedShow(_: RelatedShow, id: UUID = UUID())

		/// Indicates the item kind contains a `RelatedLiterature` object.
		case relatedLiterature(_: RelatedLiterature, id: UUID = UUID())

		/// Indicates the item kind contains a `CharacterIdentity` object.
		case characterIdentity(_: CharacterIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `PersonIdentity` object.
		case personIdentity(_: PersonIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `CastIdentity` object.
		case castIdentity(_: CastIdentity, id: UUID = UUID())

		/// Indicates the item kind contains a `StudioIdentity` object.
		case studioIdentity(_: StudioIdentity, id: UUID = UUID())

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .game(let game, let id):
				hasher.combine(game)
				hasher.combine(id)
			case .gameIdentity(let gameIdentity, let id):
				hasher.combine(gameIdentity)
				hasher.combine(id)
			case .relatedGame(let relatedGame, let id):
				hasher.combine(relatedGame)
				hasher.combine(id)
			case .relatedShow(let relatedShow, let id):
				hasher.combine(relatedShow)
				hasher.combine(id)
			case .relatedLiterature(let relatedLiterature, let id):
				hasher.combine(relatedLiterature)
				hasher.combine(id)
			case .characterIdentity(let characterIdentity, let id):
				hasher.combine(characterIdentity)
				hasher.combine(id)
			case .personIdentity(let personIdentity, let id):
				hasher.combine(personIdentity)
				hasher.combine(id)
			case .castIdentity(let castIdentity, let id):
				hasher.combine(castIdentity)
				hasher.combine(id)
			case .studioIdentity(let studioIdentity, let id):
				hasher.combine(studioIdentity)
				hasher.combine(id)
			}
		}

		static func == (lhs: ItemKind, rhs: ItemKind) -> Bool {
			switch (lhs, rhs) {
			case (.game(let game1, let id1), .game(let game2, let id2)):
				return game1 == game2 && id1 == id2
			case (.gameIdentity(let gameIdentity1, let id1), .gameIdentity(let gameIdentity2, let id2)):
				return gameIdentity1 == gameIdentity2 && id1 == id2
			case (.relatedGame(let relatedGame1, let id1), .relatedGame(let relatedGame2, let id2)):
				return relatedGame1 == relatedGame2 && id1 == id2
			case (.relatedShow(let relatedShow1, let id1), .relatedShow(let relatedShow2, let id2)):
				return relatedShow1 == relatedShow2 && id1 == id2
			case (.relatedLiterature(let relatedLiterature1, let id1), .relatedLiterature(let relatedLiterature2, let id2)):
				return relatedLiterature1 == relatedLiterature2 && id1 == id2
			case (.characterIdentity(let characterIdentity1, let id1), .characterIdentity(let characterIdentity2, let id2)):
				return characterIdentity1 == characterIdentity2 && id1 == id2
			case (.personIdentity(let personIdentity1, let id1), .personIdentity(let personIdentity2, let id2)):
				return personIdentity1 == personIdentity2 && id1 == id2
			case (.castIdentity(let castIdentity1, let id1), .castIdentity(let castIdentity2, let id2)):
				return castIdentity1 == castIdentity2 && id1 == id2
			case (.studioIdentity(let studioIdentity1, let id1), .studioIdentity(let studioIdentity2, let id2)):
				return studioIdentity1 == studioIdentity2 && id1 == id2
			default:
				return false
			}
		}
	}
}
