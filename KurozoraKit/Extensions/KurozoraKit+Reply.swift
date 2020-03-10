//
//  KurozoraKit+Reply.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Upvote or downvote a reply with the given reply id.

		- Parameter replyID: The id of the thread reply to be upvoted/downvoted.
		- Parameter vote: An integer indicating whether the reply is upvoted or downvoted. (0 = downvote, 1 = upvote)
		- Parameter successHandler: A closure returning an integer indicating whether the reply is upvoted or downvoted.
		- Parameter action: The integer indicating whether the reply is upvoted or downvoted.
	*/
	func vote(forReply replyID: Int, vote: Int, withSuccess successHandler: @escaping (_ action: Int) -> Void) {
		let forumsRepliesVote = self.kurozoraKitEndpoints.forumsRepliesVote.replacingOccurrences(of: "?", with: "\(replyID)")
		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request(forumsRepliesVote)

		request.headers = headers
		request.headers["kuro-auth"] = self.userAuthToken

		request.method = .post
		request.parameters = [
			"vote": vote
		]
		request.perform(withSuccess: { vote in
			if let success = vote.success {
				if success, let action = vote.action {
					successHandler(action)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this reply 😔", subTitle: error.message)
			print("Received vote reply error: \(error.message ?? "No message available")")
		})
	}
}
