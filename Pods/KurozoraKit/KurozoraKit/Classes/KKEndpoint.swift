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

		/// The endpoint to the seasons belonging to a show.
		case seasons(_ showIdentity: ShowIdentity)

		/// The endpoint to the songs belonging to a show.
		case songs(_ showIdentity: ShowIdentity)

		/// The endpoint to the studios belonging to a show.
		case studios(_ showIdentity: ShowIdentity)

		/// The endpoint to the studio shows related to a show.
		case moreByStudio(_ showIdentity: ShowIdentity)

		/// The endpoint to upcoming for shows.
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

// MARK: - Theme Store
extension KKEndpoint {
	/// The set of available Theme Store API endpoint types.
	internal enum ThemeStore {
		// MARK: - Cases
		/// The endpoint to the index of theme store.
		case index

		/// The endpoint to the details of a theme store item.
		case details(_ appThemeIdentifier: Int)

		// MARK: - Properties
		/// The endpoint value of the Theme Store API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "theme-store"
			case .details(let appThemeIdentifier):
				return "theme-store/\(appThemeIdentifier)"
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

		/// The endpoint to a user's profile.
		case profile(_ userIdentity: UserIdentity)

		/// The endpoint to view a user's favorite shows.
		case favoriteShow(_ userIdentity: UserIdentity)

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
			case .favoriteShow(let userIdentity):
				return "users/\(userIdentity.id)/favorite-anime"
			case .profile(let userIdentity):
				return "users/\(userIdentity.id)/profile"
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
