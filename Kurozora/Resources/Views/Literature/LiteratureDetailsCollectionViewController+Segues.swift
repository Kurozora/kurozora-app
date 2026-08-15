//
//  LiteratureDetailsCollectionViewController+Segues.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension LiteratureDetailsCollectionViewController {
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case castListSegue
		case literaturesListSegue
		case topChartsSegue
		case showsListSegue
		case gamesListSegue
		case studiosListSegue
		case literatureDetailsSegue
		case showDetailsSegue
		case gameDetailsSegue
		case studioDetailsSegue
		case characterDetailsSegue
		case personDetailsSegue
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
		case .topChartsSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
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
			reviewsCollectionViewController.listType = .literature(self.literature)
			reviewsCollectionViewController.givenRating = self.libraryAttributes?.rating
			reviewsCollectionViewController.givenReview = self.libraryAttributes?.review
			reviewsCollectionViewController.givenNote = self.libraryAttributes?.note
		case .castListSegue:
			// Segue to cast list
			guard let castListCollectionViewController = destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .literature
			castListCollectionViewController.literatureIdentity = self.literatureIdentity
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				literaturesListCollectionViewController.title = "\(L10n.moreBy) \(self.literature.attributes.studio ?? L10n.studio)"
				literaturesListCollectionViewController.literatureIdentity = self.literatureIdentity
				literaturesListCollectionViewController.literaturesListFetchType = .moreByStudio
			} else {
				literaturesListCollectionViewController.title = L10n.relatedLiteratures
				literaturesListCollectionViewController.literatureIdentity = self.literatureIdentity
				literaturesListCollectionViewController.literaturesListFetchType = .relatedLiterature
			}
		case .topChartsSegue:
			// Segue to the literatures top chart
			guard let literaturesListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literaturesListCollectionViewController.literaturesListFetchType = .charts
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			showsListCollectionViewController.title = L10n.relatedShows
			showsListCollectionViewController.literatureIdentity = self.literatureIdentity
			showsListCollectionViewController.showsListFetchType = .literature
		case .gamesListSegue:
			// Segue to games list
			guard let gamesListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gamesListCollectionViewController.title = L10n.relatedGames
			gamesListCollectionViewController.literatureIdentity = self.literatureIdentity
			gamesListCollectionViewController.gamesListFetchType = .literature
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.literatureIdentity = self.literatureIdentity
			studiosListCollectionViewController.studiosListFetchType = .literature
		case .literatureDetailsSegue:
			// Segue to literature details
			guard let literatureDetailsCollectionViewController = destination as? LiteratureDetailsCollectionViewController else { return }
			guard let literature = sender as? Literature else { return }
			literatureDetailsCollectionViewController.literature = literature
		case .showDetailsSegue:
			// Segue to show details
			guard let showDetailsCollectionViewController = destination as? ShowDetailsCollectionViewController else { return }
			guard let show = sender as? Show else { return }
			showDetailsCollectionViewController.show = show
		case .gameDetailsSegue:
			// Segue to game details
			guard let gameDetailsCollectionViewController = destination as? GameDetailsCollectionViewController else { return }
			guard let game = sender as? Game else { return }
			gameDetailsCollectionViewController.game = game
		case .studioDetailsSegue:
			// Segue to studio details
			guard let studioDetailsCollectionViewController = destination as? StudioDetailsCollectionViewController else { return }
			guard let studio = sender as? Studio else { return }
			studioDetailsCollectionViewController.studio = studio
		case .characterDetailsSegue:
			// Segue to character details
			guard let characterDetailsCollectionViewController = destination as? CharacterDetailsCollectionViewController else { return }
			guard let character = sender as? Character else { return }
			characterDetailsCollectionViewController.character = character
		case .personDetailsSegue:
			// Segue to person details
			guard let personDetailsCollectionViewController = destination as? PersonDetailsCollectionViewController else { return }
			guard let person = sender as? Person else { return }
			personDetailsCollectionViewController.person = person
		case .reviewDetailsSegue:
			// Segue to review details
			guard
				let navigationController = destination as? KNavigationController,
				let reviewDetailsCollectionViewController = navigationController.viewControllers.first as? ReviewDetailsCollectionViewController,
				let review = sender as? Review
			else { return }
			navigationController.modalPresentationStyle = .formSheet
			reviewDetailsCollectionViewController.review = review
		case .parentalGuideSegue:
			guard let parentalGuideViewController = destination as? ParentalGuideCollectionViewController else { return }
			guard let literatureIdentity = sender as? LiteratureIdentity else { return }
			parentalGuideViewController.mediaType = .literature(literatureIdentity, title: self.literature?.attributes.title, ratingName: self.literature?.attributes.tvRating.name, ratingDescription: self.literature?.attributes.tvRating.description, slug: self.literature?.attributes.slug)
		case .seasonalBrowseSegue:
			guard let seasonalCollectionViewController = destination as? SeasonalCollectionViewController else { return }
			guard let startedAt = self.literature?.attributes.startedAt else { return }
			let (year, derivedSeason) = SeasonOfYear.yearAndSeason(from: startedAt)
			seasonalCollectionViewController.kind = .literatures
			seasonalCollectionViewController.year = year
			seasonalCollectionViewController.season = self.literature?.attributes.publicationSeason.flatMap { SeasonOfYear(pathComponent: $0) } ?? derivedSeason
		}
	}
}
