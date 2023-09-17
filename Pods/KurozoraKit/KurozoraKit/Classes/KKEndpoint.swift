//
//  KKEndpoint.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//

import Foundation

/// The namespace that contains the Kurozora API endpoints.
internal enum KKEndpoint { }

// MARK: - Explore
extension KKEndpoint {
	/// The set of available Explore API endpoints types.
	internal enum Explore {
		// MARK: - Cases
		/// The endpoint to the explore page.
		case index

		/// The endpoint to the details of an explore page.
		case details(_ exploreCategoryIdentity: ExploreCategoryIdentity)

		// MARK: - Properties
		/// The endpoint value of the Explore API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "explore"
			case .details(let exploreCategoryIdentity):
				return "explore/\(exploreCategoryIdentity.id)"
			}
		}
	}
}

// MARK: - Misc
extension KKEndpoint {
	/// The set of available Misc API endpoints types.
	internal enum Misc {
		// MARK: - Cases
		/// The endpoint to info.
		case info

		/// The endpoint to settings.
		case settings

		// MARK: - Properties
		/// The endpoint value of the Misc API type.
		var endpointValue: String {
			switch self {
			case .info:
				return "info"
			case .settings:
				return "settings"
			}
		}
	}
}

// MARK: - Cast
extension KKEndpoint {
	/// The set of available Cast API endpoints.
	internal enum Cast {
		// MARK: - Cases
		/// The endpoint to the details of a show cast.
		case showCast(_ castIdentity: CastIdentity)

		/// The endpoint to the details of a literature cast.
		case literatureCast(_ castIdentity: CastIdentity)

		/// The endpoint to the details of a game cast.
		case gameCast(_ castIdentity: CastIdentity)

		// MARK: - Properties
		/// The endpoint value of the Cast API type.
		var endpointValue: String {
			switch self {
			case .showCast(let castIdentity):
				return "show-cast/\(castIdentity.id)"
			case .literatureCast(let castIdentity):
				return "literature-cast/\(castIdentity.id)"
			case .gameCast(let castIdentity):
				return "game-cast/\(castIdentity.id)"
			}
		}
	}
}

// MARK: - Characters
extension KKEndpoint {
	/// The set of available Charactes API endpoints.
	internal enum Characters {
		// MARK: - Cases
		/// The endpoint to the details of a character.
		case details(_ characterIdentity: CharacterIdentity)

		/// The endpoint to the people belonging to a character.
		case people(_ characterIdentity: CharacterIdentity)

		/// The endpoint to the games belonging to a character.
		case games(_ characterIdentity: CharacterIdentity)

		/// The endpoint to the literatures belonging to a character.
		case literatures(_ characterIdentity: CharacterIdentity)

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
			case .games(let characterIdentity):
				return "characters/\(characterIdentity.id)/games"
			case .literatures(let characterIdentity):
				return "characters/\(characterIdentity.id)/literatures"
			case .shows(let characterIdentity):
				return "characters/\(characterIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Episodes
extension KKEndpoint {
	/// The set of available Episodes API endpoints.
	internal enum Episodes {
		// MARK: - Cases
		/// The enpoint to the details of an episode.
		case details(_ episodeIdentity: EpisodeIdentity)

		/// The endpoint to update the watch status of an episode.
		case watched(_ episodeIdentity: EpisodeIdentity)

		/// The endpoint to leave a rating on an episode.
		case rate(_ episodeIdentity: EpisodeIdentity)

		/// The endpoint to the reviews belonging to a show.
		case reviews(_ episodeIdentity: EpisodeIdentity)

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
			case .reviews(let episodeIdentity):
				return "episodes/\(episodeIdentity.id)/reviews"
			}
		}
	}
}

// MARK: - Genres
extension KKEndpoint {
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

// MARK: - People
extension KKEndpoint {
	/// The set of available People API endpoints.
	internal enum People {
		// MARK: - Cases
		/// The endpoint to the details of a person.
		case details(_ personIdentity: PersonIdentity)

		/// The endpoint to the characters belonging to a person.
		case characters(_ personIdentity: PersonIdentity)

		/// The endpoint to the games belonging to a person.
		case games(_ personIdentity: PersonIdentity)

		/// The endpoint to the literatures belonging to a person.
		case literatures(_ personIdentity: PersonIdentity)

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
			case .games(let personIdentity):
				return "people/\(personIdentity.id)/games"
			case .literatures(let personIdentity):
				return "people/\(personIdentity.id)/literatures"
			case .shows(let personIdentity):
				return "people/\(personIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Shows
extension KKEndpoint {
	/// The set of available Shows API endpoints types.
	internal enum Shows {
		// MARK: - Cases
		/// The endpoint to the details of a show.
		case details(_ showIdentity: ShowIdentity)

		/// The endpoint to the cast belonging to a show.
		case cast(_ showIdentity: ShowIdentity)

		/// The endpoint to the characters belonging to a show.
		case characters(_ showIdentity: ShowIdentity)

		/// The endpoint to the people belonging to a show.
		case people(_ showIdentity: ShowIdentity)

		/// The endpoint to leave a rating on a show.
		case rate(_ showIdentity: ShowIdentity)

		/// The endpoint to the related shows belonging to a show.
		case relatedShows(_ showIdentity: ShowIdentity)

		/// The endpoint to the related literatures belonging to a show.
		case relatedLiteratures(_ showIdentity: ShowIdentity)

		/// The endpoint to the related games belonging to a show.
		case relatedGames(_ showIdentity: ShowIdentity)

		/// The endpoint to the reviews belonging to a show.
		case reviews(_ showIdentity: ShowIdentity)

		/// The endpoint to the seasons belonging to a show.
		case seasons(_ showIdentity: ShowIdentity)

		/// The endpoint to the songs belonging to a show.
		case songs(_ showIdentity: ShowIdentity)

		/// The endpoint to the studios belonging to a show.
		case studios(_ showIdentity: ShowIdentity)

		/// The endpoint to the studio shows related to a show.
		case moreByStudio(_ showIdentity: ShowIdentity)

		/// The endpoint to upcoming shows.
		case upcoming

		// MARK: - Properties
		/// The endpoint value of the Shows API type.
		var endpointValue: String {
			switch self {
			case .details(let showIdentity):
				return "anime/\(showIdentity.id)"
			case .cast(let showIdentity):
				return "anime/\(showIdentity.id)/cast"
			case .characters(let showIdentity):
				return "anime/\(showIdentity.id)/characters"
			case .people(let showIdentity):
				return "anime/\(showIdentity.id)/people"
			case .rate(let showIdentity):
				return "anime/\(showIdentity.id)/rate"
			case .relatedShows(let showIdentity):
				return "anime/\(showIdentity.id)/related-shows"
			case .relatedLiteratures(let showIdentity):
				return "anime/\(showIdentity.id)/related-literatures"
			case .relatedGames(let showIdentity):
				return "anime/\(showIdentity.id)/related-games"
			case .reviews(let showIdentity):
				return "anime/\(showIdentity.id)/reviews"
			case .seasons(let showIdentity):
				return "anime/\(showIdentity.id)/seasons"
			case .songs(let showIdentity):
				return "anime/\(showIdentity.id)/songs"
			case .studios(let showIdentity):
				return "anime/\(showIdentity.id)/studios"
			case .moreByStudio(let showIdentity):
				return "anime/\(showIdentity.id)/more-by-studio"
			case .upcoming:
				return "anime/upcoming"
			}
		}
	}
}

// MARK: - Themes
extension KKEndpoint {
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

// MARK: - Literatures
extension KKEndpoint {
	/// The set of available Literature API endpoints types.
	internal enum Literatures {
		// MARK: - Cases
		/// The endpoint to the details of a literature.
		case details(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the cast belonging to a literature.
		case cast(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the characters belonging to a literature.
		case characters(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the people belonging to a literature.
		case people(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to leave a rating on a literature.
		case rate(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the related shows belonging to a literature.
		case relatedShows(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the related literature belonging to a literature.
		case relatedLiteratures(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the related games belonging to a literature.
		case relatedGames(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the reviews belonging to a literature.
		case reviews(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the studios belonging to a literature.
		case studios(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to the studio shows related to a literature.
		case moreByStudio(_ literatureIdentity: LiteratureIdentity)

		/// The endpoint to upcoming literatures.
		case upcoming

		// MARK: - Properties
		/// The endpoint value of the Literatures API type.
		var endpointValue: String {
			switch self {
			case .details(let literatureIdentity):
				return "manga/\(literatureIdentity.id)"
			case .cast(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/cast"
			case .characters(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/characters"
			case .people(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/people"
			case .rate(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/rate"
			case .relatedShows(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/related-shows"
			case .relatedLiteratures(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/related-literatures"
			case .relatedGames(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/related-games"
			case .reviews(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/reviews"
			case .studios(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/studios"
			case .moreByStudio(let literatureIdentity):
				return "manga/\(literatureIdentity.id)/more-by-studio"
			case .upcoming:
				return "manga/upcoming"
			}
		}
	}
}

// MARK: - Games
extension KKEndpoint {
	/// The set of available Games API endpoints types.
	internal enum Games {
		// MARK: - Cases
		/// The endpoint to the details of a game.
		case details(_ gameIdentity: GameIdentity)

		/// The endpoint to the cast belonging to a game.
		case cast(_ gameIdentity: GameIdentity)

		/// The endpoint to the characters belonging to a game.
		case characters(_ gameIdentity: GameIdentity)

		/// The endpoint to the people belonging to a game.
		case people(_ gameIdentity: GameIdentity)

		/// The endpoint to leave a rating on a literature.
		case rate(_ gameIdentity: GameIdentity)

		/// The endpoint to the related shows belonging to a game.
		case relatedShows(_ gameIdentity: GameIdentity)

		/// The endpoint to the related literature belonging to a game.
		case relatedLiteratures(_ gameIdentity: GameIdentity)

		/// The endpoint to the related games belonging to a game.
		case relatedGames(_ gameIdentity: GameIdentity)

		/// The endpoint to the reviews belonging to a game.
		case reviews(_ gameIdentity: GameIdentity)

		/// The endpoint to the studios belonging to a game.
		case studios(_ gameIdentity: GameIdentity)

		/// The endpoint to the studio shows related to a game.
		case moreByStudio(_ gameIdentity: GameIdentity)

		/// The endpoint to upcoming games.
		case upcoming

		// MARK: - Properties
		/// The endpoint value of the Games API type.
		var endpointValue: String {
			switch self {
			case .details(let gameIdentity):
				return "games/\(gameIdentity.id)"
			case .cast(let gameIdentity):
				return "games/\(gameIdentity.id)/cast"
			case .characters(let gameIdentity):
				return "games/\(gameIdentity.id)/characters"
			case .people(let gameIdentity):
				return "games/\(gameIdentity.id)/people"
			case .rate(let gameIdentity):
				return "games/\(gameIdentity.id)/rate"
			case .relatedShows(let gameIdentity):
				return "games/\(gameIdentity.id)/related-shows"
			case .relatedLiteratures(let gameIdentity):
				return "games/\(gameIdentity.id)/related-literatures"
			case .relatedGames(let gameIdentity):
				return "games/\(gameIdentity.id)/related-games"
			case .reviews(let gameIdentity):
				return "games/\(gameIdentity.id)/reviews"
			case .studios(let gameIdentity):
				return "games/\(gameIdentity.id)/studios"
			case .moreByStudio(let gameIdentity):
				return "games/\(gameIdentity.id)/more-by-studio"
			case .upcoming:
				return "games/upcoming"
			}
		}
	}
}

// MARK: - Songs
extension KKEndpoint {
	/// The set of available Songs API endpoints.
	internal enum Songs {
		// MARK: - Cases
		/// The endpoint to the details of a song.
		case details(_ songIdentity: SongIdentity)

		/// The endpoint to the shows of a song.
		case shows(_ songIdentity: SongIdentity)

		// MARK: - Properties
		/// The endpoint value of the Songs API type.
		var endpointValue: String {
			switch self {
			case .details(let songIdentity):
				return "songs/\(songIdentity.id)"
			case .shows(let songIdentity):
				return "songs/\(songIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Feed
extension KKEndpoint {
	/// The set of available Feed API endpoints types.
	internal enum Feed {
		// MARK: - Cases
		/// The endpoint to the explore feed.
		case explore

		/// The endpoint to the user's home feed.
		case home

		/// The endpoint to the posts in the feed.
		case post

		// MARK: - Properties
		/// The endpoint value of the Feed API type.
		var endpointValue: String {
			switch self {
			case .explore:
				return "feed/explore"
			case .home:
				return "feed/home"
			case .post:
				return "feed"
			}
		}
	}
}

// MARK: - Search
extension KKEndpoint {
	/// The set of available Search API endpoint types.
	internal enum Search {
		// MARK: - Cases
		/// The endpoint for searching a resource.
		case index

		/// The endpoint for search suggestions.
		case suggestions

		// MARK: - Properties
		/// The endpoint value of the Search API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "search/"
			case .suggestions:
				return "search/suggestions"
			}
		}
	}
}

// MARK: - Store
extension KKEndpoint {
	/// The set of available Store API endpoint types.
	internal enum Store {
		// MARK: - Cases
		/// The endpoint to verify a receipt.
		case verify

		// MARK: - Properties
		/// The endpoint value of the Store API type.
		var endpointValue: String {
			switch self {
			case .verify:
				return "store/verify"
			}
		}
	}
}

// MARK: - Studios
extension KKEndpoint {
	/// The set of available Studios API endpoints.
	internal enum Studios {
		// MARK: - Cases
		/// The endpoint to the details of a studio.
		case details(_ studioIdentity: StudioIdentity)

		/// The enpoint to the shows belonging to a studio.
		case games(_ studioIdentity: StudioIdentity)

		/// The enpoint to the shows belonging to a studio.
		case literatures(_ studioIdentity: StudioIdentity)

		/// The enpoint to the shows belonging to a studio.
		case shows(_ studioIdentity: StudioIdentity)

		// MARK: - Properties
		/// The endpoint value of the Studios API type.
		var endpointValue: String {
			switch self {
			case .details(let studioIdentity):
				return "studios/\(studioIdentity.id)"
			case .games(let studioIdentity):
				return "studios/\(studioIdentity.id)/games"
			case .literatures(let studioIdentity):
				return "studios/\(studioIdentity.id)/literatures"
			case .shows(let studioIdentity):
				return "studios/\(studioIdentity.id)/anime"
			}
		}
	}
}

// MARK: - Theme Store
extension KKEndpoint {
	/// The set of available Theme Store API endpoint types.
	internal enum ThemeStore {
		// MARK: - Cases
		/// The endpoint to the index of theme store.
		case index

		/// The endpoint to the details of a theme store item.
		case details(_ appThemeID: String)

		// MARK: - Properties
		/// The endpoint value of the Theme Store API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "theme-store"
			case .details(let appThemeID):
				return "theme-store/\(appThemeID)"
			}
		}
	}
}

// MARK: - Users
extension KKEndpoint {
	/// The set of available Users API endpoint types.
	internal enum Users {
		// MARK: - Cases
		/// The endpoint to sign up a user.
		case signUp

		/// The endpoint to sign in a user.
		case signIn

		/// The endpoint to sign in a user using Sign in with Apple.
		case siwaSignIn

		/// The edpoint to reset a user's password.
		case resetPassword

		/// The endpoint to the feed messages.
		case feedMessages(_ userIdentity: UserIdentity)

		/// The endpoint to follow or unfollow a user.
		case follow(_ userIdentity: UserIdentity)

		/// The endpoint to a user's followers list.
		case followers(_ userIdentity: UserIdentity)

		/// The endpoint to a user's following list.
		case following(_ userIdentity: UserIdentity)

		/// The endpoint to view a user's favorites.
		case favorites(_ userIdentity: UserIdentity)

		/// The endpoint to a user's profile.
		case profile(_ userIdentity: UserIdentity)

		/// The endpoint to search for a user.
		case search(_ username: String)

		/// The endpoint to delete a user's account.
		case delete

		// MARK: - Properties
		/// The endpoint value of the Users API type.
		var endpointValue: String {
			switch self {
			case .signUp:
				return "users"
			case .signIn:
				return "users/signin"
			case .siwaSignIn:
				return "users/siwa/signin"
			case .resetPassword:
				return "users/reset-password"
			case .feedMessages(let userIdentity):
				return "users/\(userIdentity.id)/feed-messages"
			case .follow(let userIdentity):
				return "users/\(userIdentity.id)/follow"
			case .followers(let userIdentity):
				return "users/\(userIdentity.id)/followers"
			case .following(let userIdentity):
				return "users/\(userIdentity.id)/following"
			case .favorites(let userIdentity):
				return "users/\(userIdentity.id)/favorites"
			case .profile(let userIdentity):
				return "users/\(userIdentity.id)/profile"
			case .search(let username):
				return "users/search/\(username)"
			case .delete:
				return "users/delete"
			}
		}
	}
}

// MARK: - Me
extension KKEndpoint {
	/// The set of available Me API endpoint types.
	internal enum Me {
		// MARK: - Cases
		/// The endpoint to the authenticated user's details.
		case profile

		/// The endpoint to update the authenticated user's information.
		case update

		/// The endpoint to the authenticated user's followers list.
		case followers

		/// The endpoint tothe authenticated user's following list.
		case following

		// MARK: - Properties
		/// The endpoint value of the Me API type.
		var endpointValue: String {
			switch self {
			case .profile:
				return "me"
			case .update:
				return "me"
			case .followers:
				return "me/followers"
			case .following:
				return "me/following"
			}
		}
	}
}

// MARK: - Legal
extension KKEndpoint {
	/// The set of available Legal API endpoint types.
	internal enum Legal {
		// MARK: - Cases
		/// The endpoint to the Privacy Policy.
		case privacyPolicy

		/// The endpoint to the Terms of Use.
		case termsOfUse

		// MARK: - Properties
		/// The endpoint value of the Legal API type.
		var endpointValue: String {
			switch self {
			case .privacyPolicy:
				return "legal/privacy-policy"
			case .termsOfUse:
				return "legal/terms-of-use"
			}
		}
	}
}
