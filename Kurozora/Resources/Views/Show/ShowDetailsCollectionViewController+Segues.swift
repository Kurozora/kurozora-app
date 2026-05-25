//
//  ShowDetailsCollectionViewController+Segues.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ShowDetailsCollectionViewController {
	enum SegueIdentifiers: String, SegueIdentifier {
		case reviewsListSegue
		case seasonsListSegue
		case castListSegue
		case songsListSegue
		case showsListSegue
		case literaturesListSegue
		case gamesListSegue
		case studiosListSegue
		case showDetailsSegue
		case literatureDetailsSegue
		case gameDetailsSegue
		case studioDetailsSegue
		case characterDetailsSegue
		case personDetailsSegue
		case episodesListSegue
		case songDetailsSegue
		case reviewDetailsSegue
		case parentalGuideSegue
		case seasonalBrowseSegue
	}

	func makeDestinationVC(for identifier: SegueIdentifiers) -> UIViewController? {
		switch identifier {
		case .reviewsListSegue: return ReviewsListCollectionViewController()
		case .seasonsListSegue: return SeasonsListCollectionViewController()
		case .castListSegue: return CastListCollectionViewController()
		case .songsListSegue: return ShowSongsListCollectionViewController()
		case .showsListSegue: return ShowsListCollectionViewController()
		case .literaturesListSegue: return LiteraturesListCollectionViewController()
		case .gamesListSegue: return GamesListCollectionViewController()
		case .studiosListSegue: return StudiosListCollectionViewController()
		case .showDetailsSegue: return ShowDetailsCollectionViewController()
		case .literatureDetailsSegue: return LiteratureDetailsCollectionViewController()
		case .gameDetailsSegue: return GameDetailsCollectionViewController()
		case .studioDetailsSegue: return StudioDetailsCollectionViewController()
		case .characterDetailsSegue: return CharacterDetailsCollectionViewController()
		case .personDetailsSegue: return PersonDetailsCollectionViewController()
		case .episodesListSegue: return EpisodesListCollectionViewController()
		case .songDetailsSegue: return SongDetailsCollectionViewController()
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
			reviewsCollectionViewController.listType = .show(self.show)
		case .seasonsListSegue:
			// Segue to seasons list
			guard let seasonsCollectionViewController = destination as? SeasonsListCollectionViewController else { return }
			seasonsCollectionViewController.showIdentity = self.showIdentity
		case .castListSegue:
			// Segue to cast list
			guard let castListCollectionViewController = destination as? CastListCollectionViewController else { return }
			castListCollectionViewController.castKind = .show
			castListCollectionViewController.showIdentity = self.showIdentity
		case .songsListSegue:
			// Segue to songs list
			guard let showSongsListCollectionViewController = destination as? ShowSongsListCollectionViewController else { return }
			showSongsListCollectionViewController.showIdentity = self.showIdentity
		case .showsListSegue:
			// Segue to shows list
			guard let showsListCollectionViewController = destination as? ShowsListCollectionViewController else { return }
			guard let indexPath = sender as? IndexPath else { return }

			if self.snapshot.sectionIdentifiers[indexPath.section] == .moreByStudio {
				showsListCollectionViewController.title = "\(L10n.moreBy) \(self.show.attributes.studio ?? L10n.studio)"
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .moreByStudio
			} else {
				showsListCollectionViewController.title = L10n.relatedShows
				showsListCollectionViewController.showIdentity = self.showIdentity
				showsListCollectionViewController.showsListFetchType = .relatedShow
			}
		case .literaturesListSegue:
			// Segue to literatures list
			guard let literatureListCollectionViewController = destination as? LiteraturesListCollectionViewController else { return }
			literatureListCollectionViewController.title = L10n.relatedLiteratures
			literatureListCollectionViewController.showIdentity = self.showIdentity
			literatureListCollectionViewController.literaturesListFetchType = .show
		case .gamesListSegue:
			// Segue to games list
			guard let gameListCollectionViewController = destination as? GamesListCollectionViewController else { return }
			gameListCollectionViewController.title = L10n.relatedGames
			gameListCollectionViewController.showIdentity = self.showIdentity
			gameListCollectionViewController.gamesListFetchType = .show
		case .studiosListSegue:
			// Segue to studios list
			guard let studiosListCollectionViewController = destination as? StudiosListCollectionViewController else { return }
			studiosListCollectionViewController.showIdentity = self.showIdentity
			studiosListCollectionViewController.studiosListFetchType = .show
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
		case .episodesListSegue:
			// Segue to episodes list
			guard let episodesListCollectionViewController = destination as? EpisodesListCollectionViewController else { return }
			guard let season = sender as? Season else { return }
			episodesListCollectionViewController.seasonIdentity = SeasonIdentity(id: season.id)
			episodesListCollectionViewController.season = season
			episodesListCollectionViewController.episodesListFetchType = .season
		case .songDetailsSegue:
			// Segue to song details
			guard let songDetailsCollectionViewController = destination as? SongDetailsCollectionViewController else { return }
			guard let song = sender as? Song else { return }
			songDetailsCollectionViewController.song = song
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
			guard let showIdentity = sender as? ShowIdentity else { return }
			parentalGuideViewController.mediaType = .show(showIdentity, title: self.show?.attributes.title, ratingName: self.show?.attributes.tvRating.name, ratingDescription: self.show?.attributes.tvRating.description, slug: self.show?.attributes.slug)
		case .seasonalBrowseSegue:
			guard let seasonalCollectionViewController = destination as? SeasonalCollectionViewController else { return }
			guard let startedAt = self.show?.attributes.startedAt else { return }
			let (year, derivedSeason) = SeasonOfYear.yearAndSeason(from: startedAt)
			seasonalCollectionViewController.kind = .shows
			seasonalCollectionViewController.year = year
			seasonalCollectionViewController.season = self.show?.attributes.airSeason.flatMap { SeasonOfYear(pathComponent: $0) } ?? derivedSeason
		}
	}
}
