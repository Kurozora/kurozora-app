//
//  PersonDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class PersonDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case showsListSegue
		case showDetailsSegue
		case literaturesListSegue
		case literatureDetailsSegue
		case gamesListSegue
		case gameDetailsSegue
		case charactersListSegue
		case characterDetailsSegue
		case reviewDetailsSegue
	}

	// MARK: - Properties
	var personIdentity: PersonIdentity?
	var person: Person! {
		didSet {
			self.title = self.person.attributes.fullName
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
			self.navigationTitleLabel.text = self.person.attributes.fullName
			self.personIdentity = PersonIdentity(id: self.person.id)
			self.configureNavBarButtons()

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

	var characterIdentities: [CharacterIdentity] = []
	var showIdentities: [ShowIdentity] = []
	var literatureIdentities: [LiteratureIdentity] = []
	var gameIdentities: [GameIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var emptyStateImage: UIImage { .Empty.cast }

	override var emptyStateDetail: String { "This person doesn't have details yet. Please check back again later." }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let person = self.person,
		      let profileURL = URL(string: person.attributes.profile?.url ?? "") else { return [] }
		return [MediaItem(
			url: profileURL,
			type: .image,
			title: person.attributes.fullName,
			description: nil,
			author: nil,
			provider: nil,
			embedHTML: nil,
			extraInfo: nil
		)]
	}

	// MARK: - Initializers
	func callAsFunction(with personID: KurozoraItemID) -> PersonDetailsCollectionViewController {
		let personDetailsCollectionViewController = PersonDetailsCollectionViewController()
		personDetailsCollectionViewController.personIdentity = PersonIdentity(id: personID)
		return personDetailsCollectionViewController
	}

	func callAsFunction(with person: Person) -> PersonDetailsCollectionViewController {
		let personDetailsCollectionViewController = PersonDetailsCollectionViewController()
		personDetailsCollectionViewController.person = person
		return personDetailsCollectionViewController
	}

	// MARK: - View Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureDataSource()
		self.configureNavigationItems()

		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchDetails()
		}
	}

	// MARK: - Functions
	override func fetchDetails() async {
		guard let personIdentity = self.personIdentity else { return }

		if self.person == nil {
			do {
				let personResponse = try await KService.detail(personIdentity).response()
				self.person = personResponse.data.first
			} catch {
				print(error.localizedDescription)
			}
		}

		do {
			let reviewIdentityResponse = try await KService.reviews(for: personIdentity).cursor(nil).limit(10).response()
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let characterIdentityResponse = try await KService.characters(for: personIdentity).limit(10).response()
			self.characterIdentities = characterIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let showIdentityResponse = try await KService.shows(for: personIdentity).limit(10).response()
			self.showIdentities = showIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let literatureIdentityResponse = try await KService.literatures(for: personIdentity).limit(10).response()
			self.literatureIdentities = literatureIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.games(for: personIdentity).limit(10).response()
			self.gameIdentities = gameIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.person?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard let person = self.person else { return nil }
		return try await person.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? {
		guard let person = self.person else { return nil }
		return (.person(person), person.attributes.givenRating, nil)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: LibraryKind) -> (any Libraryable)? {
		return self.cache[indexPath] as? any Libraryable
	}

	override func reminderTarget(at indexPath: IndexPath) -> Show? {
		return self.cache[indexPath] as? Show
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.person?.attributes.givenRating = nil
		self.person?.attributes.givenReview = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }

		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .charactersListSegue: return CharactersListCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		}
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }

		switch identifier {
		case .reviewsListSegue:
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .person(self.person)
		case .showsListSegue:
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.personIdentity = self.personIdentity
			showsListCollectionViewController.showsListFetchType = .person
		case .showDetailsSegue:
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literaturesListSegue:
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.personIdentity = self.personIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .person
		case .literatureDetailsSegue:
			guard let literatureDetailCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailCollectionViewController.literature = literature
		case .gamesListSegue:
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.personIdentity = self.personIdentity
			gamesListCollectionViewController.gamesListFetchType = .person
		case .gameDetailsSegue:
			guard let gameDetailCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailCollectionViewController.game = game
		case .charactersListSegue:
			guard let charactersListCollectionViewController = destination as? CharactersListCollectionViewController else { return }
			charactersListCollectionViewController.personIdentity = self.personIdentity
			charactersListCollectionViewController.charactersListFetchType = .person
		case .characterDetailsSegue:
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .reviewDetailsSegue:
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		}
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension PersonDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.person.attributes.about

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - Cell Configuration
extension PersonDetailsCollectionViewController {
	func getConfiguredSmallCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { [weak self] smallLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .showIdentity:
				let show: Show? = self.fetchModel(at: indexPath)

				if show == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Show>.self, ShowIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: show)
			case .literatureIdentity:
				let literature: Literature? = self.fetchModel(at: indexPath)

				if literature == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Literature>.self, LiteratureIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				smallLockupCollectionViewCell.delegate = self
				smallLockupCollectionViewCell.configure(using: literature)
			default: break
			}
		}
	}

	func getConfiguredGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Game>.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: break
			}
		}
	}

	func getConfiguredCharacterCell() -> UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CharacterLockupCollectionViewCell, ItemKind>(cellNib: CharacterLockupCollectionViewCell.nib) { [weak self] characterLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .characterIdentity:
				let character: Character? = self.fetchModel(at: indexPath)

				if character == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(ResourceCollection<Character>.self, CharacterIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				characterLockupCollectionViewCell.configure(using: character)
			default: break
			}
		}
	}
}
