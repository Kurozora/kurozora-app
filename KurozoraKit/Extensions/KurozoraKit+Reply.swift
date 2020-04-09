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
		Update a reply's vote status with the given `VoteStatus` value.

		- Parameter replyID: The id of the reply whose vote status should be updated.
		- Parameter voteStatus: A `VoteStatus` value by which the reply's current vote status should be updated.
		- Parameter successHandler: A closure returning a vote status value indicating the reply's new vote status.
		- Parameter voteStatus: The vote status value indicating the reply's new vote status.
	*/
	public func voteOnReply(_ replyID: Int, withVoteStatus voteStatus: VoteStatus, withSuccess successHandler: @escaping (_ voteStatus: VoteStatus) -> Void) {
		let forumsRepliesVote = self.kurozoraKitEndpoints.forumsRepliesVote.replacingOccurrences(of: "?", with: "\(replyID)")
		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request(forumsRepliesVote)

		request.headers = headers
		if self._userAuthToken != "" {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"vote": voteStatus.rawValue
		]
		request.perform(withSuccess: { voteThread in
			if let success = voteThread.success {
				if success, let action = voteThread.action {
					successHandler(action == 0 ? .noVote : action == 1 ? .upVote : .downVote)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't vote on this reply 😔", subTitle: error.message)
			print("Received vote reply error: \(error.message ?? "No message available")")
		})
	}
}
