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
		case details(_ personIdentity: PersonIdentity)

		/// The endpoint to the characters belonging to a person.
		case characters(_ personIdentity: PersonIdentity)

		/// The endpoint to the shows belonging to a person.
		case shows(_ personIdentity: PersonIdentity)

		// MARK: - Properties
		/// The endpoint value of the People API type.
		var endpointValue: String {
			switch self {
			case .details(let personIdentity):
				return "people/\(personIdentity.id)"
			case .characters(let personIdentity):
				return "people/\(personIdentity.id)/characters"
			case .shows(let personIdentity):
				return "people/\(personIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Cast
extension KKEndpoint.Shows {
	/// The set of available Cast API endpoints.
	internal enum Cast {
		// MARK: - Cases
		/// The endpoint to the details of a cast.
		case details(_ castIdentity: CastIdentity)

		// MARK: - Properties
		/// The endpoint value of the Cast API type.
		var endpointValue: String {
			switch self {
			case .details(let castIdentity):
				return "cast/\(castIdentity.id)"
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
		case details(_ characterIdentity: CharacterIdentity)

		/// The endpoint to the people belonging to a character.
		case people(_ characterIdentity: CharacterIdentity)

		/// The endpoint to the shows belonging to a character.
		case shows(_ characterIdentity: CharacterIdentity)

		// MARK: - Properties
		/// The endpoint value of the Charactes API type.
		var endpointValue: String {
			switch self {
			case .details(let characterIdentity):
				return "characters/\(characterIdentity.id)"
			case .people(let characterIdentity):
				return "characters/\(characterIdentity.id)/people"
			case .shows(let characterIdentity):
				return "characters/\(characterIdentity.id)/anime"
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
		case details(_ episodeIdentity: EpisodeIdentity)

		/// The endpoint to update the watch status of an episode.
		case watched(_ episodeIdentity: EpisodeIdentity)

		/// The endpoint to leave a rating on an episode.
		case rate(_ episodeIdentity: EpisodeIdentity)

		// MARK: - Properties
		/// The endpoint value of the Episodes API type.
		var endpointValue: String {
			switch self {
			case .details(let episodeIdentity):
				return "episodes/\(episodeIdentity.id)"
			case .watched(let episodeIdentity):
				return "episodes/\(episodeIdentity.id)/watched"
			case .rate(let episodeIdentity):
				return "episodes/\(episodeIdentity.id)/rate"
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
		case details(_ genreIdentity: GenreIdentity)

		// MARK: - Properties
		/// The endpoint value of the Genres API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "genres"
			case .details(let genreIdentity):
				return "genres/\(genreIdentity.id)"
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
		case details(_ seasonIdentity: SeasonIdentity)

		/// The endpoint to the episodes related to a season.
		case episodes(_ seasonIdentity: SeasonIdentity)

		// MARK: - Properties
		/// The endpoint value of the Seasons API type.
		var endpointValue: String {
			switch self {
			case .details(let seasonIdentity):
				return "seasons/\(seasonIdentity.id)"
			case .episodes(let seasonIdentity):
				return "seasons/\(seasonIdentity.id)/episodes"
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
		case details(_ studioIdentity: StudioIdentity)

		/// The enpoint to the shows belonging to a studio.
		case shows(_ studioIdentity: StudioIdentity)

		// MARK: - Properties
		/// The endpoint value of the Studios API type.
		var endpointValue: String {
			switch self {
			case .details(let studioIdentity):
				return "studios/\(studioIdentity.id)"
			case .shows(let studioIdentity):
				return "studios/\(studioIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Themes
extension KKEndpoint.Shows {
	/// The set of available Themes API endpoint types.
	internal enum Themes {
		// MARK: - Cases
		/// The endpoint to the index of themes.
		case index

		/// The endpoint to the details of a theme.
		case details(_ themeIdentity: ThemeIdentity)

		// MARK: - Properties
		/// The endpoint value of the Themes API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "themes"
			case .details(let themeIdentity):
				return "themes/\(themeIdentity.id)"
			}
		}
	}
}
