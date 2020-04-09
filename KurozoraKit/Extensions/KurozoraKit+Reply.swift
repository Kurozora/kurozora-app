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
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func voteOnReply(_ replyID: Int, withVoteStatus voteStatus: VoteStatus, completion completionHandler: @escaping (_ result: Result<VoteStatus, JSONError>) -> Void) {
		let forumsRepliesVote = self.kurozoraKitEndpoints.forumsRepliesVote.replacingOccurrences(of: "?", with: "\(replyID)")
		let request: APIRequest<VoteThread, JSONError> = tron.swiftyJSON.request(forumsRepliesVote)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self._userAuthToken
		}

		request.method = .post
		request.parameters = [
			"vote": voteStatus.rawValue
		]
		request.perform(withSuccess: { voteThread in
			completionHandler(.success(voteThread.voteStatus ?? .noVote))
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't vote on this reply 😔", subTitle: error.message)
			}
			print("Received vote reply error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
