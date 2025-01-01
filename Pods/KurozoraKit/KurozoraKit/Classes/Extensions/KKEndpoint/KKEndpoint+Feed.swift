//
//  KKEndpoint+Feed.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/08/2020.
//

// MARK: - Messages
extension KKEndpoint.Feed {
	/// The set of available Messages API endpoints types.
	internal enum Messages {
		// MARK: - Cases
		/// The endpoint to the message details.
		case details(_ messageID: String)

		/// The endpoint to update the message details.
		case update(_ messageID: String)

		/// The endpoint to heart or unheart a feed message.
		case heart(_ messageID: String)

		/// The endpoint to pin or unpin a feed message.
		case pin(_ messageID: String)

		/// The endpoint to the replies of a feed message.
		case replies(_ messageID: String)

		/// The endpoint to delete the message details.
		case delete(_ messageID: String)

		// MARK: - Properties
		/// The endpoint value of the Messages API type.
		var endpointValue: String {
			switch self {
			case .details(let messageID):
				return "feed/messages/\(messageID)"
			case .update(let messageID):
				return "feed/messages/\(messageID)/update"
			case .heart(let messageID):
				return "feed/messages/\(messageID)/heart"
			case .pin(let messageID):
				return "feed/messages/\(messageID)/pin"
			case .replies(let messageID):
				return "feed/messages/\(messageID)/replies"
			case .delete(let messageID):
				return "feed/messages/\(messageID)/delete"
			}
		}
	}
}
