//
//  SearchIntent.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/02/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import Foundation
import AppIntents
import KurozoraKit

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SearchIntent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "SearchIntentIntent"

    static var title: LocalizedStringResource = "Find on Kurozora"
    static var description = IntentDescription("Search for anime, manga, games, and more in Kurozora")

    @Parameter(title: "Search in", default: .kurozora)
    var scope: KKSearchScopeAppEnum

    @Parameter(title: "For", default: .shows)
    var type: KKSearchTypeAppEnum

    @Parameter(title: "Title")
    var title: String

	/// Launch your app when the system triggers this intent.
	static let openAppWhenRun: Bool = true

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\.$title) on Kurozora") {
            \.$scope
            \.$type
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$title, \.$scope, \.$type)) { title, scope, _ in
            DisplayRepresentation(
                title: "Find \(title) in \(scope)",
                subtitle: "Search for \(title) in \(scope)"
            )
        }
        IntentPrediction(parameters: (\.$title)) { title in
            DisplayRepresentation(
                title: "Find \(title)",
                subtitle: "Search for \(title) in Kurozora"
            )
        }
    }

	func perform() async throws -> some IntentResult {
		guard let url = URL(string: "kz://search") else {
			return .result()
		}
		await KurozoraDelegate.shared.schemeHandler((UIApplication.sharedKeyWindow?.windowScene?.session.scene)!, open: url)
//		let scope = self.scope.kkSearchScopeValue
//		let type = self.type.kkSearchTypeValue
//		let searchResults = try await KService.search(scope, of: [type], for: self.title, filter: nil).value
//		let count = {
//			switch type {
//			case .characters:
//				return searchResults.data.characters?.data.count ?? 0
//			case .episodes:
//				return searchResults.data.episodes?.data.count ?? 0
//			case .games:
//				return searchResults.data.games?.data.count ?? 0
//			case .literatures:
//				return searchResults.data.literatures?.data.count ?? 0
//			case .people:
//				return searchResults.data.people?.data.count ?? 0
//			case .shows:
//				return searchResults.data.shows?.data.count ?? 0
//			case .songs:
//				return searchResults.data.songs?.data.count ?? 0
//			case .studios:
//				return searchResults.data.studios?.data.count ?? 0
//			case .users:
//				return searchResults.data.users?.data.count ?? 0
//			}
//		}()
//
//		if count == 0 {
//			return IntentItem("There are \(count) titles matching ‘\(self.title)’.", title: "")
//		}
//
//		switch type {
//		case .characters:
//			guard let identity = searchResults.data.characters?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let characterResponse = try await KService.getDetails(forCharacter: identity).value
//			let character = characterResponse.data.first
//			return IntentItem("\(character?.attributes.name ?? "") (https://kurozora.app/characters/\(character?.attributes.slug ?? ""))"), title: "")
//		case .episodes:
//			guard let identity = searchResults.data.episodes?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let episodeResponse = try await KService.getDetails(forEpisode: identity).value
//			let episode = episodeResponse.data.first
//			return IntentItem("\(episode?.attributes.title ?? "") (https://kurozora.app/episodes/\(episode?.id ?? ""))"), title: "")
//		case .games:
//			guard let identity = searchResults.data.games?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let gameResponse = try await KService.getDetails(forGame: identity).value
//			let game = gameResponse.data.first
//			return IntentItem("\(game?.attributes.title ?? "") (https://kurozora.app/games/\(game?.attributes.slug ?? ""))"), title: "")
//		case .literatures:
//			guard let identity = searchResults.data.literatures?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let literatureResponse = try await KService.getDetails(forLiterature: identity).value
//			let literature = literatureResponse.data.first
//			return IntentItem("\(literature?.attributes.title ?? "") (https://kurozora.app/manga/\(literature?.attributes.slug ?? ""))"), title: "")
//		case .people:
//			guard let identity = searchResults.data.people?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let peopleResponse = try await KService.getDetails(forPerson: identity).value
//			let people = peopleResponse.data.first
//			return IntentItem("\(people?.attributes.fullName ?? "") (https://kurozora.app/people/\(people?.attributes.slug ?? ""))"), title: "")
//		case .shows:
//			guard let identity = searchResults.data.shows?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let showResponse = try await KService.getDetails(forShow: identity).value
//			let show = showResponse.data.first
//			return IntentItem("\(show?.attributes.title ?? "") (https://kurozora.app/anime/\(show?.attributes.slug ?? ""))"), title: "")
//		case .songs:
//			guard let identity = searchResults.data.songs?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let songResponse = try await KService.getDetails(forSong: identity).value
//			let song = songResponse.data.first
//			return IntentItem("\(song?.attributes.title ?? "") (https://kurozora.app/songs/\(song?.id ?? ""))"), title: "")
//		case .studios:
//			guard let identity = searchResults.data.studios?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let studioResponse = try await KService.getDetails(forStudio: identity).value
//			let studio = studioResponse.data.first
//			return IntentItem("\(studio?.attributes.name ?? "") (https://kurozora.app/studios/\(studio?.attributes.slug ?? ""))"), title: "")
//		case .users:
//			guard let identity = searchResults.data.users?.data.first else {
//				return IntentItem("There are \(count) titles matching ‘\(self.title)’."), title: "")
//			}
//			let userResponse = try await KService.getDetails(forUser: identity).value
//			let user = userResponse.data.first
//
//
//			return IntentItem(user?.attributes.username ?? "", title: "https://kurozora.app/profile/\(user?.attributes.slug ?? "")", subtitle: user?.attributes.biography, image: "")
//		}
		return .result()
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func titleParameterPrompt(title: String) -> Self {
        "Searching for \(title) in Kurozora..."
    }
    static func titleParameterDisambiguationIntro(count: Int, title: String) -> Self {
        "There are \(count) titles matching ‘\(title)’."
    }
    static func titleParameterConfirmation(title: String) -> Self {
        "Just to confirm, you wanted ‘\(title)’?"
    }
}
