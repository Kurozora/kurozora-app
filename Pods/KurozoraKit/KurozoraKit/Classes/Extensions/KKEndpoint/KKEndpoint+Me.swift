//
//  KKEndpoint+Me.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 18/08/2020.
//

import Foundation

// MARK: - Access Tokens
extension KKEndpoint.Me {
	/// The set of available Access Token API endpoint types.
	internal enum AccessTokens {
		// MARK: - Cases
		/// The endpoint to the authenticated user's access tokens.
		case index

		/// The endpoint to the details of an access token.
		case details(_ accessToken: String)

		/// The endpoint to update an access token.
		case update(_ accessToken: String)

		/// The endpoint to delete an access token.
		case delete(_ accessToken: String)

		// MARK: - Properties
		/// The endpoint value of the Access Tokens API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/access-tokens"
			case .details(let sessionID):
				return "me/access-tokens/\(sessionID)"
			case .update(let sessionID):
				return "me/access-tokens/\(sessionID)/update"
			case .delete(let sessionID):
				return "me/access-tokens/\(sessionID)/delete"
			}
		}
	}
}

// MARK: - Favorites
extension KKEndpoint.Me {
	/// The set of available Favorites API endpoint types.
	internal enum Favorites {
		// MARK: - Cases
		/// The endpoint to the authenticated user's favorites list.
		case index

		/// The endpoint to get, add or remove shows from the authenticated user's favorites list.
		case update

		// MARK: - Properties
		/// The endpoint value of the Favorites API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/favorites"
			case .update:
				return "me/favorites"
			}
		}
	}
}

// MARK: - Feed
extension KKEndpoint.Me {
	/// The set of available Feed Messages API endpoint types.
	internal enum Feed {
		// MARK: - Cases
		/// The endpoint to the authenticated user's feed messages list.
		case messages

		// MARK: - Properties
		/// The endpoint value of the Feed Messages API type.
		var endpointValue: String {
			switch self {
			case .messages:
				return "me/feed-messages"
			}
		}
	}
}

// MARK: - Library
extension KKEndpoint.Me {
	/// The set of available Library API endpoint types.
	internal enum Library {
		// MARK: - Cases
		/// The endpoint to get models/add models to the authenticated user's library.
		case index

		/// The endpoint to update a model in the authenticated user's library.
		case update

		/// The endpoint to delete a model from the authenticated user's library.
		case delete

		/// The endpoint to import an exported MyAnimeList file into the  authenticated user's library.
		case malImport

		/// The endpoint to import an exported library file into the  authenticated user's library.
		case `import`

		// MARK: - Properties
		/// The endpoint value of the Library API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/library"
			case .update:
				return "me/library/update"
			case .delete:
				return "me/library/delete"
			case .malImport:
				return "me/library/mal-import"
			case .`import`:
				return "me/library/import"
			}
		}
	}
}

// MARK: - Notifications
extension KKEndpoint.Me {
	/// The set of available Notifications API endpoint types.
	internal enum Notifications {
		// MARK: - Cases
		/// The endpoint to the authenticated user's notification list.
		case index

		/// The endpoint to the detials of a notification.
		case details(_ notificationID: String)

		/// The endpoint to delete a notification.
		case delete(_ notificationID: String)

		/// The endpoint to update a notification.
		case update

		// MARK: - Properties
		/// The endpoint value of the Notifications API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/notifications"
			case .details(let notificationID):
				return "me/notifications/\(notificationID)"
			case .delete(let notificationID):
				return "me/notifications/\(notificationID)/delete"
			case .update:
				return "me/notifications/update"
			}
		}
	}
}

// MARK: - Recap
extension KKEndpoint.Me {
	/// The set of available Recap API endpoints types.
	internal enum Recap {
		// MARK: - Cases
		/// The endpoint to the recap page.
		case index

		/// The endpoint to the details of a recap page.
		case details(_ year: String)

		// MARK: - Properties
		/// The endpoint value of the Recap API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/recap"
			case .details(let year):
				return "me/recap/\(year)"
			}
		}
	}
}

// MARK: - Reminders
extension KKEndpoint.Me {
	/// The set of available Reminders API endpoint types.
	internal enum Reminders {
		// MARK: - Cases
		/// The endpoint to the authenticated user's reminders list.
		case index

		/// The endpoint to add or remove shows from the authenticated user's reminders list.
		case update

		/// The endpoint to download the authenticated user's reminders list calendar.
		case download

		// MARK: - Properties
		/// The endpoint value of the Reminder Show API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/reminders"
			case .update:
				return "me/reminders"
			case .download:
				return "me/reminders/download"
			}
		}
	}
}

// MARK: - Sessions
extension KKEndpoint.Me {
	/// The set of available Sessions API endpoint types.
	internal enum Sessions {
		// MARK: - Cases
		/// The endpoint to the authenticated user's sessions.
		case index

		/// The endpoint to the details of a session.
		case details(_ sessionIdentity: SessionIdentity)

		/// The endpoint to delete a session.
		case delete(_ sessionIdentity: SessionIdentity)

		// MARK: - Properties
		/// The endpoint value of the Sessions API type.
		var endpointValue: String {
			switch self {
			case .index:
				return "me/sessions"
			case .details(let sessionIdentity):
				return "me/sessions/\(sessionIdentity.id)"
			case .delete(let sessionIdentity):
				return "me/sessions/\(sessionIdentity.id)/delete"
			}
		}
	}
}
