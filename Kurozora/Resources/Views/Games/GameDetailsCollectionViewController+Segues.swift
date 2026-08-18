//
//  GameDetailsCollectionViewController+Segues.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension GameDetailsCollectionViewController {
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case castListSegue
		case gamesListSegue
		case topChartsSegue
		case showsListSegue
		case literaturesListSegue
		case studiosListSegue
		case gameDetailsSegue
		case showDetailsSegue
		case literatureDetailsSegue
		case studioDetailsSegue
		case personDetailsSegue
		case characterDetailsSegue
		case reviewDetailsSegue
		case parentalGuideSegue
		case seasonalBrowseSegue
	}

	func makeDestinationVC(for identifier: SegueIdentifiers) -> UIViewController? {
		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .castListSegue: return CastListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .topChartsSegue: return GamesListCollectionViewController()
		case .studiosListSegue: return StudiosListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .reviewDetailsSegue: return KNavigationController(rootViewController: ReviewDetailsCollectionViewController())
		case .parentalGuideSegue: return ParentalGuideCollectionViewController()
		case .seasonalBrowseSegue: return SeasonalCollectionViewController()
		}
	}

	func prepareDestination(for identifier: SegueIdentifiers, destination: UIViewController, sender: Any?) {
		switch identifier {
		case .reviewsListSegue:
			// Segue to reviews list
			guard let reviewsCollectionViewController = destination as? ReviewsListCollectionViewController else { return }
			reviewsCollectionViewController.listType = .game(self.game)
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
			reviewsCollectionViewController.givenNote = self.libraryAttributes?.note
			reviewsCollectionViewController.givenIsSpoiler = self.libraryAttributes?.isSpoiler ?? false
		case .castListSegue:
			// Segue to cast list
			guard let castListCollectionViewController = destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .game
			castListCollectionViewController.gameIdentity = self.gameIdentity
		case .gamesListSegue:
			// Segue to games list
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				gamesListCollectionViewController.title = "\(L10n.moreBy) \(self.game.attributes.studio ?? L10n.studio)"
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .moreByStudio
			} else {
				gamesListCollectionViewController.title = L10n.relatedGames
				gamesListCollectionViewController.gameIdentity = self.gameIdentity
				gamesListCollectionViewController.gamesListFetchType = .relatedGame
			}
		case .topChartsSegue:
			// Segue to the games top chart
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.gamesListFetchType = .charts
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = L10n.relatedShows
			showsListCollectionViewController.gameIdentity = self.gameIdentity
			showsListCollectionViewController.showsListFetchType = .game
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.title = L10n.relatedLiteratures
			literaturesListCollectionViewController.gameIdentity = self.gameIdentity
			literaturesListCollectionViewController.literaturesListFetchType = .game
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.gameIdentity = self.gameIdentity
			studiosListCollectionViewController.studiosListFetchType = .game
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case .characterDetailsSegue:
			// Segue to character details
			guard
				let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController,
				let cell = sender as? CastCollectionViewCell,
				let indexPath = self.collectionView.indexPath(for: cell),
				let cast = self.cache[indexPath] as? Cast,
				let character = cast.relationships.characters.data.first
			else { return }
			characterDetailsCollectionViewController.character = character
		case .personDetailsSegue:
			// Segue to person details
			guard
				let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController,
				let cell = sender as? CastCollectionViewCell,
				let indexPath = self.collectionView.indexPath(for: cell),
				let cast = self.cache[indexPath] as? Cast,
				let person = cast.relationships.people?.data.first
			else { return }
			personDetailsCollectionViewController.person = person
		case .reviewDetailsSegue:
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		case .parentalGuideSegue:
			guard let parentalGuideViewController = destination as? ParentalGuideCollectionViewController else { return }
			guard let gameIdentity = sender as? GameIdentity else { return }
			parentalGuideViewController.mediaType = .game(gameIdentity, title: self.game?.attributes.title, ratingName: self.game?.attributes.tvRating.name, ratingDescription: self.game?.attributes.tvRating.description, slug: self.game?.attributes.slug)
		case .seasonalBrowseSegue:
			guard let seasonalCollectionViewController = destination as? SeasonalCollectionViewController else { return }
			guard let startedAt = self.game?.attributes.startedAt else { return }
			let (year, derivedSeason) = SeasonOfYear.yearAndSeason(from: startedAt)
			seasonalCollectionViewController.kind = .games
			seasonalCollectionViewController.year = year
			seasonalCollectionViewController.season = self.game?.attributes.publicationSeason.flatMap { SeasonOfYear(pathComponent: $0) } ?? derivedSeason
		}
	}
}
