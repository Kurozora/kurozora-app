//
//  ReCapModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit

/// The models a Re:CAP period refers to keyed by identity.
struct ReCapModels {
	// MARK: - Properties
	/// The number of models fetched per request.
	private static let chunkSize = 25

	var shows: [KurozoraItemID: Show] = [:]
	var literatures: [KurozoraItemID: Literature] = [:]
	var games: [KurozoraItemID: Game] = [:]
	var genres: [KurozoraItemID: Genre] = [:]
	var themes: [KurozoraItemID: Theme] = [:]
	var studios: [KurozoraItemID: Studio] = [:]
	var characters: [KurozoraItemID: Character] = [:]
	var people: [KurozoraItemID: Person] = [:]

	// MARK: - Functions
	/// Returns the model the given recap entry refers to.
	///
	/// - Parameter recapEntry: The entry whose model to return.
	///
	/// - Returns: The model of the entry.
	func model(for recapEntry: RecapEntry) -> KurozoraItem? {
		guard let relationships = recapEntry.relationships else { return nil }

		if let id = relationships.shows?.data.first?.id { return self.shows[id] }
		if let id = relationships.literatures?.data.first?.id { return self.literatures[id] }
		if let id = relationships.games?.data.first?.id { return self.games[id] }
		if let id = relationships.genres?.data.first?.id { return self.genres[id] }
		if let id = relationships.themes?.data.first?.id { return self.themes[id] }
		if let id = relationships.studios?.data.first?.id { return self.studios[id] }
		if let id = relationships.characters?.data.first?.id { return self.characters[id] }
		if let id = relationships.people?.data.first?.id { return self.people[id] }

		return nil
	}

	/// Fetches the models the given recaps and stats refer to.
	///
	/// - Parameters:
	///    - recapItems: The recaps of the period.
	///    - previousRecapItems: The recaps of the year before the period.
	///    - recapStats: The stats of the period.
	///    - additionalEntries: The other entries shown on the page.
	///
	/// - Returns: The fetched models.
	static func fetch(for recapItems: [RecapItem], previousRecapItems: [RecapItem], recapStats: [RecapStat], additionalEntries: [RecapEntry] = []) async -> ReCapModels {
		let recapEntries = (recapItems + previousRecapItems).flatMap { $0.relationships?.items?.data ?? [] } + additionalEntries
		let statShows = recapStats.compactMap { $0.relationships?.shows?.data.first }

		async let shows: [KurozoraItemID: Show] = Self.fetch(recapEntries.compactMap { $0.relationships?.shows?.data.first } + statShows)
		async let literatures: [KurozoraItemID: Literature] = Self.fetch(recapEntries.compactMap { $0.relationships?.literatures?.data.first })
		async let games: [KurozoraItemID: Game] = Self.fetch(recapEntries.compactMap { $0.relationships?.games?.data.first })
		async let genres: [KurozoraItemID: Genre] = Self.fetch(recapEntries.compactMap { $0.relationships?.genres?.data.first })
		async let themes: [KurozoraItemID: Theme] = Self.fetch(recapEntries.compactMap { $0.relationships?.themes?.data.first })
		async let studios: [KurozoraItemID: Studio] = Self.fetch(recapEntries.compactMap { $0.relationships?.studios?.data.first })
		async let characters: [KurozoraItemID: Character] = Self.fetch(recapEntries.compactMap { $0.relationships?.characters?.data.first })
		async let people: [KurozoraItemID: Person] = Self.fetch(recapEntries.compactMap { $0.relationships?.people?.data.first })

		return await ReCapModels(
			shows: shows,
			literatures: literatures,
			games: games,
			genres: genres,
			themes: themes,
			studios: studios,
			characters: characters,
			people: people
		)
	}

	/// Fetches the models of the given identities.
	///
	/// - Parameter identities: The identities to fetch.
	///
	/// - Returns: The fetched models keyed by identity.
	private static func fetch<Identity: Fetchable, Model: KurozoraItem>(_ identities: [Identity]) async -> [KurozoraItemID: Model] where Identity.Response == ResourceCollection<Model> {
		var seenIDs = Set<KurozoraItemID>()
		let uniqueIdentities = identities.filter { seenIDs.insert($0.id).inserted }
		var models: [KurozoraItemID: Model] = [:]

		for chunkStart in stride(from: 0, to: uniqueIdentities.count, by: Self.chunkSize) {
			let chunk = Array(uniqueIdentities[chunkStart ..< min(chunkStart + Self.chunkSize, uniqueIdentities.count)])

			do {
				let response = try await KService.details(chunk).response()
				for model in response.data {
					models[model.id] = model
				}
			} catch {
				print("----- Failed fetching \(Model.self) details: \(error.localizedDescription)")
			}
		}

		return models
	}
}
