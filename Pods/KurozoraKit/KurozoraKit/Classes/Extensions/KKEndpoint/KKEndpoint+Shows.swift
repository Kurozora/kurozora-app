//
//  KKEndpoint+Shows.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/08/2020.
//

import Foundation

// MARK: - People
extension KKEndpoint.Shows {
	/// The set of available People API endpoints.
	internal enum People {
		// MARK: - Cases
		/// The endpoint to the details of a person.
		case details(_ personID: Int)

		/// The endpoint to the characters belonging to a person.
		case characters(_ personID: Int)

		/// The endpoint to the shows belonging to a person.
		case shows(_ personID: Int)

		// MARK: - Properties
		/// The endpoint value of the People API type.
		var endpointValue: String {
			switch self {
			case .details(let personID):
				return "people/\(personID)"
			case .characters(let personID):
				return "people/\(personID)/characters"
			case .shows(let personID):
				return "people/\(personID)/anime"
			}
		}
	}
}

// MARK: - Characters
extension KKEndpoint.Shows {
	/// The set of available Charactes API endpoints.
	internal enum Characters {
		// MARK: - Cases
		/// The endpoint to the details of a character.
		case details(_ characterID: Int)

		/// The endpoint to the people belonging to a character.
		case people(_ characterID: Int)

		/// The endpoint to the shows belonging to a character.
		case shows(_ characterID: Int)

		// MARK: - Properties
		/// The endpoint value of the Charactes API type.
		var endpointValue: String {
			switch self {
			case .details(let characterID):
				return "characters/\(characterID)"
			case .people(let characterID):
				return "characters/\(characterID)/people"
			case .shows(let characterID):
				return "characters/\(characterID)/anime"
			}
		}
	}
}

// MARK: - Episodes
extension KKEndpoint.Shows {
	/// The set of available Episodes API endpoints.
	internal enum Episodes {
		// MARK: - Cases
		/// The enpoint to the details of an episode.
		case details(_ episodeID: Int)

		/// The endpoint to update the watch status of an episode.
		case watched(_ episodeID: Int)

		// MARK: - Properties
		/// The endpoint value of the Episodes API type.
		var endpointValue: String {
			switch self {
			case .details(let episodeID):
				return "anime-episodes/\(episodeID)"
			case .watched(let episodeID):
				return "anime-episodes/\(episodeID)/watched"
			}
		}
	}
}

// MARK: - Genres
extension KKEndpoint.Shows {
	/// The set of available Genres API endpoints types.
	internal enum Genres {
		// MARK: - Cases
		/// The endpoint to the index of genres.
		case index

		/// The endpoint to the details of a genre.
		case details(_ genreID: Int)

		// MARK: - Properties
		/// The endpoint value of the Genres API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "genres"
			case .details(let genreID):
				return "genres/\(genreID)"
			}
		}
	}
}

// MARK: - Seasons
extension KKEndpoint.Shows {
	/// The set of available Seasons API endpoints.
	internal enum Seasons {
		// MARK: - Cases
		/// The endpoint to the details of a season.
		case details(_ seasonID: Int)

		/// The endpoint to the episodes related to a season.
		case episodes(_ seasonID: Int)

		// MARK: - Properties
		/// The endpoint value of the Seasons API type.
		var endpointValue: String {
			switch self {
			case .details(let seasonID):
				return "anime-seasons/\(seasonID)"
			case .episodes(let seasonID):
				return "anime-seasons/\(seasonID)/episodes"
			}
		}
	}
}

// MARK: - Studios
extension KKEndpoint.Shows {
	/// The set of available Studios API endpoints.
	internal enum Studios {
		// MARK: - Cases
		/// The endpoint to the details of a studio.
		case details(_ studioID: Int)

		/// The enpoint to the shows belonging to a studio.
		case shows(_ studioID: Int)

		// MARK: - Properties
		/// The endpoint value of the Studios API type.
		var endpointValue: String {
			switch self {
			case .details(let studioID):
				return "studios/\(studioID)"
			case .shows(let studioID):
				return "studios/\(studioID)/anime"
			}
		}
	}
}
