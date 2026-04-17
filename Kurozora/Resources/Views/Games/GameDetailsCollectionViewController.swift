//
//  GameDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/03/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import AVFoundation
import Intents
import IntentsUI
import KurozoraKit
import UIKit

class GameDetailsCollectionViewController: DetailsCollectionViewController, SectionFetchable {
	// MARK: - Properties
	var gameIdentity: GameIdentity?
	var game: Game! {
		didSet {
			self.title = self.game.attributes.title
			if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
				self.navigationItem.largeTitle = ""
			}
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

	var relatedGames: [RelatedGame] = []
	var relatedShows: [RelatedShow] = []
	var relatedLiteratures: [RelatedLiterature] = []
	var castIdentities: [CastIdentity] = []
	var studioIdentities: [StudioIdentity] = []
	var studioGameIdentities: [GameIdentity] = []

	var cache: [IndexPath: KurozoraItem] = [:]
	var isFetchingSection: Set<SectionLayoutKind> = []

	var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
	var snapshot: NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>!

	// MARK: - Overridden Properties
	override var favoriteTarget: (any Libraryable)? { self.game }

	// TODO: Enable once reminders are supported for Game.
//	override var reminderTarget: (any Libraryable)? { self.game }

	override var emptyStateImage: UIImage { .Empty.gameLibrary }

	override var emptyStateDetail: String { "This game doesn't have details yet. Please check back again later." }

	override var reviewDetailsSegueIdentifier: (any SegueIdentifier)? { SegueIdentifiers.reviewDetailsSegue }

	override var mediaItems: [MediaItem] {
		guard let game = self.game else { return [] }
		var items: [MediaItem] = []
		if let posterURL = URL(string: game.attributes.poster?.url ?? "") {
			items.append(MediaItem(url: posterURL, type: .image, title: game.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		if let bannerURL = URL(string: game.attributes.banner?.url ?? "") {
			items.append(MediaItem(url: bannerURL, type: .image, title: game.attributes.title, description: nil, author: nil, provider: nil, embedHTML: nil, extraInfo: nil))
		}
		return items
	}

	// MARK: - Initializers
	func callAsFunction(with gameID: KurozoraItemID) -> GameDetailsCollectionViewController {
		let gameDetailsCollectionViewController = GameDetailsCollectionViewController()
		gameDetailsCollectionViewController.gameIdentity = GameIdentity(id: gameID)
		return gameDetailsCollectionViewController
	}

	func callAsFunction(with game: Game) -> GameDetailsCollectionViewController {
		let gameDetailsCollectionViewController = GameDetailsCollectionViewController()
		gameDetailsCollectionViewController.game = game
		return gameDetailsCollectionViewController
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
		guard let gameIdentity = self.gameIdentity else { return }

		if self.game == nil {
			do {
				let gameResponse = try await KService.getDetails(forGame: gameIdentity)
				self.game = gameResponse.data.first

				// Donate suggestion to Siri.
				self.userActivity = self.game.openDetailUserActivity
			} catch {
				print(error.localizedDescription)
			}

			self.configureNavBarButtons()
		} else {
			// Donate suggestion to Siri.
			self.userActivity = self.game.openDetailUserActivity

			self.updateDataSource()
			self.configureNavBarButtons()
		}

		do {
			let reviewIdentityResponse = try await KService.getReviews(forGame: gameIdentity, next: nil, limit: 10)
			self.reviews = reviewIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let castIdentityResponse = try await KService.getCast(forGame: gameIdentity, limit: 10)
			self.castIdentities = castIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let studioIdentityResponse = try await KService.getStudios(forGame: gameIdentity, limit: 10)
			self.studioIdentities = studioIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let gameIdentityResponse = try await KService.getMoreByStudio(forGame: gameIdentity, limit: 10)
			self.studioGameIdentities = gameIdentityResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedGameResponse = try await KService.getRelatedGames(forGame: gameIdentity, limit: 10)
			self.relatedGames = relatedGameResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedShowResponse = try await KService.getRelatedShows(forGame: gameIdentity, limit: 10)
			self.relatedShows = relatedShowResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}

		do {
			let relatedLiteratureResponse = try await KService.getRelatedLiteratures(forGame: gameIdentity, limit: 10)
			self.relatedLiteratures = relatedLiteratureResponse.data
			self.updateDataSource()
		} catch {
			print(error.localizedDescription)
		}
	}

	override func makeMoreMenu() -> UIMenu? {
		return self.game?.makeContextMenu(in: self, userInfo: [:], sourceView: nil, barButtonItem: self.moreBarButtonItem)
	}

	override func rateItem(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard let game = self.game else { return nil }
		return try await game.rate(using: rating, description: description)
	}

	override func writeAReviewContext() -> (kind: ReviewTextEditor.Kind, rating: Double?, review: String?)? {
		guard let game = self.game else { return nil }
		return (.game(game), game.attributes.library?.rating, nil)
	}

	override func libraryStatusTarget(at indexPath: IndexPath, kind: KKLibrary.Kind) -> (any Libraryable)? {
		switch kind {
		case .shows:
			return self.relatedShows[safe: indexPath.item]?.show
		case .literatures:
			return self.relatedLiteratures[safe: indexPath.item]?.literature
		case .games:
			switch self.dataSource.sectionIdentifier(for: indexPath.section) {
			case .moreByStudio: return self.cache[indexPath] as? Game
			case .relatedGames: return self.relatedGames[safe: indexPath.item]?.game
			default: return nil
			}
		}
	}

	override func didDeleteReview(at indexPath: IndexPath?) {
		self.game?.attributes.library?.rating = nil
		self.game?.attributes.library?.review = nil
	}

	// MARK: - Segue
	override func makeDestination(for identifier: any SegueIdentifier) -> UIViewController? {
		guard let identifier = identifier as? SegueIdentifiers else { return nil }
		return self.makeDestinationVC(for: identifier)
	}

	override func prepare(for identifier: any SegueIdentifier, destination: UIViewController, sender: Any?) {
		guard let identifier = identifier as? SegueIdentifiers else { return }
		self.prepareDestination(for: identifier, destination: destination, sender: sender)
	}
}

// MARK: - CastCollectionViewCellDelegate
extension GameDetailsCollectionViewController: CastCollectionViewCellDelegate {
	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressPersonButton button: UIButton) {
		self.show(SegueIdentifiers.personDetailsSegue, sender: cell)
	}

	func castCollectionViewCell(_ cell: CastCollectionViewCell, didPressCharacterButton button: UIButton) {
		self.show(SegueIdentifiers.characterDetailsSegue, sender: cell)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension GameDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		let synopsisViewController = SynopsisViewController()
		synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
		synopsisViewController.synopsis = self.game.attributes.synopsis

		let kNavigationController = KNavigationController(rootViewController: synopsisViewController)
		kNavigationController.modalPresentationStyle = .formSheet

		self.present(kNavigationController, animated: true)
	}
}

// MARK: - Cell Configuration
extension GameDetailsCollectionViewController {
	func getConfiguredCastCell() -> UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<CastCollectionViewCell, ItemKind>(cellNib: CastCollectionViewCell.nib) { [weak self] castCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .castIdentity:
				let cast: Cast? = self.fetchModel(at: indexPath)

				if cast == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(CastResponse.self, CastIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				castCollectionViewCell.delegate = self
				castCollectionViewCell.configure(using: cast)
			default: return
			}
		}
	}

	func getConfiguredStudioGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { [weak self] gameLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .gameIdentity:
				let game: Game? = self.fetchModel(at: indexPath)

				if game == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(GameResponse.self, GameIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				gameLockupCollectionViewCell.delegate = self
				gameLockupCollectionViewCell.configure(using: game)
			default: return
			}
		}
	}

	func getConfiguredStudioCell() -> UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<StudioLockupCollectionViewCell, ItemKind>(cellNib: StudioLockupCollectionViewCell.nib) { [weak self] studioLockupCollectionViewCell, indexPath, itemKind in
			guard let self = self else { return }

			switch itemKind {
			case .studioIdentity:
				let studio: Studio? = self.fetchModel(at: indexPath)

				if studio == nil, let section = self.snapshot.sectionIdentifier(containingItem: itemKind), !self.isFetchingSection.contains(section) {
					Task {
						await self.fetchSectionIfNeeded(StudioResponse.self, StudioIdentity.self, at: indexPath, itemKind: itemKind)
					}
				}

				studioLockupCollectionViewCell.configure(using: studio)
			default: break
			}
		}
	}

	func getConfiguredRelatedShowCell() -> UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<SmallLockupCollectionViewCell, ItemKind>(cellNib: SmallLockupCollectionViewCell.nib) { smallLockupCollectionViewCell, _, itemKind in
			smallLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedShow(let relatedShow, _):
				smallLockupCollectionViewCell.configure(using: relatedShow)
			case .relatedLiterature(let relatedLiterature, _):
				smallLockupCollectionViewCell.configure(using: relatedLiterature)
			default: return
			}
		}
	}

	func getConfiguredRelatedGameCell() -> UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind> {
		return UICollectionView.CellRegistration<GameLockupCollectionViewCell, ItemKind>(cellNib: GameLockupCollectionViewCell.nib) { gameLockupCollectionViewCell, _, itemKind in
			gameLockupCollectionViewCell.delegate = self

			switch itemKind {
			case .relatedGame(let relatedGame, _):
				gameLockupCollectionViewCell.configure(using: relatedGame)
			default: return
			}
		}
	}
}
