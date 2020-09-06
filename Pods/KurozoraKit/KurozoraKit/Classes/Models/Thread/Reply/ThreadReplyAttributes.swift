//
//  ThreadReplyAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension ThreadReply {
	/**
		A root object that stores information about a single thread reply, such as the reply's content, and metrics.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The content of the reply.
		public let content: String

		/// The date the reply was created at.
		public let createdAt: String

		/// The metrics of the forums thread.
		public let metrics: ThreadReply.Attributes.Metrics

		/// The vote action of a forums vote.
		public let voteAction: VoteStatus
	}
}
