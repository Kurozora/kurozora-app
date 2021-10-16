//
//  KKEndpoint.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// The namespace that contains the Kurozora API endpoints.
internal enum KKEndpoint {
}

// MARK: - Explore
extension KKEndpoint {
	/// The set of available Explore API endpoints types.
	internal enum Explore {
		// MARK: - Cases
		/// The endpoint to the explore page.
		case index

		// MARK: - Properties
		/// The endpoint value of the Explore API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "explore"
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
		case details(_ showID: Int)

		/// The endpoint to the cast belonging to a show.
		case cast(_ showID: Int)

		/// The endpoint to the characters belonging to a show.
		case characters(_ showID: Int)

		/// The endpoint to the people belonging to a show.
		case people(_ showID: Int)

		/// The endpoint to leave a rating on a show.
		case rate(_ showID: Int)

		/// The endpoint to the related shows belonging to a show.
		case relatedShows(_ showID: Int)

		/// The endpoint to the seasons belonging to a show.
		case seasons(_ showID: Int)

		/// The endpoint to search for shows.
		case search

		// MARK: - Properties
		/// The endpoint value of the Shows API type.
		var endpointValue: String {
			switch self {
			case .details(let showID):
				return "anime/\(showID)"
			case .cast(let showID):
				return "anime/\(showID)/cast"
			case .characters(let showID):
				return "anime/\(showID)/characters"
			case .people(let showID):
				return "anime/\(showID)/people"
			case .rate(let showID):
				return "anime/\(showID)/rate"
			case .relatedShows(let showID):
				return "anime/\(showID)/related-shows"
			case .seasons(let showID):
				return "anime/\(showID)/seasons"
			case .search:
				return "anime/search"
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

// MARK: - Themes
extension KKEndpoint {
	/// The set of available Themes API endpoint types.
	internal enum Themes {
		// MARK: - Cases
		/// The endpoint to the index of themes.
		case index

		/// The endpoint to the details of a theme.
		case details(_ themeID: Int)

		// MARK: - Properties
		/// The endpoint value of the Themes API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "themes"
			case .details(let themeID):
				return "themes/\(themeID)"
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
		case feedMessages(_ userID: Int)

		/// The endpoint to follow or unfollow a user.
		case follow(_ userID: Int)

		/// The endpoint to a user's followers list.
		case followers(_ userID: Int)

		/// The endpoint to a user's following list.
		case following(_ userID: Int)

		/// The endpoint to a user's profile.
		case profile(_ userID: Int)

		/// The endpoint to view a user's favorite shows.
		case favoriteShow(_ userID: Int)

		/// The endpoint to search for users.
		case search

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
			case .feedMessages(let userID):
				return "users/\(userID)/feed-messages"
			case .follow(let userID):
				return "users/\(userID)/follow"
			case .followers(let userID):
				return "users/\(userID)/followers"
			case .following(let userID):
				return "users/\(userID)/following"
			case .favoriteShow(let userID):
				return "users/\(userID)/favorite-anime"
			case .profile(let userID):
				return "users/\(userID)/profile"
			case .search:
				return "users/search"
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
