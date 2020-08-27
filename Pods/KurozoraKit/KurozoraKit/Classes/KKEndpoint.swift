//
//  KKEndpoint.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 10/03/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// The object that stores information about the Kurozora API endpoints.
internal struct KKEndpoint {
	// MARK: - Explore
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

	// MARK: - Shows
	/// The set of available Shows API endpoints types.
	internal enum Shows {
		// MARK: - Cases
		/// The endpoint to the details of a show.
		case details(_ showID: Int)

		/// The endpoint to the actors belonging to a show.
		case actors(_ showID: Int)

		/// The endpoint to the cast belonging to a show.
		case cast(_ showID: Int)

		/// The endpoint to the characters belonging to a show.
		case characters(_ showID: Int)

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
			case .actors(let showID):
				return "anime/\(showID)/actors"
			case .cast(let showID):
				return "anime/\(showID)/cast"
			case .characters(let showID):
				return "anime/\(showID)/characters"
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

	// MARK: - Feed
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

	// MARK: - Forums
	/// The set of available Forums API endpoints types.
	internal enum Forums {
		// MARK: - Cases
		/// The endpoint to the forums sections.
		case sections

		/// The endpoint to the threads in a forums section.
		case threads(_ sectionID: Int)

		// MARK: - Properties
		/// The endpoint value of the Forums API type.
		var endpointValue: String {
			switch self {
			case .sections:
				return "forum-sections"
			case .threads(let sectionID):
				return "forum-sections/\(sectionID)/threads"
			}
		}
	}

	// MARK: - Themes
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

	// MARK: - Users
	/// The set of available Users API endpoint types.
	internal enum Users {
		// MARK: - Cases
		/// The endpoint to sign up a user.
		case signUp

		/// The endpoint to sign in a user.
		case signIn

		/// The endpoint to sign in a user using Sign in with Apple.
		case signInSIWA

		/// The endpoint to sign up a user using Sign in with Apple.
		case signUpSIWA

		/// The edpoint to reset a user's password.
		case resetPassword

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
			case .signInSIWA:
				return "users/signin/siwa"
			case .signUpSIWA:
				return "users/signup/siwa"
			case .resetPassword:
				return "users/reset-password"
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

	// MARK: - Me
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

	// MARK: - Legal
	/// The set of available Legal API endpoint types.
	internal enum Legal {
		// MARK: - Cases
		/// The endpoint to the privacy policy.
		case privacyPolicy

		// MARK: - Properties
		/// The endpoint value of the Legal API type.
		var endpointValue: String {
			switch self {
			case .privacyPolicy:
				return "legal/privacy-policy"
			}
		}
	}
}

