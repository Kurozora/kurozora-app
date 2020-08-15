//
//  KurozoraKit+Reply.swift
//  KurozoraKit
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
	public func voteOnReply(_ replyID: Int, withVoteStatus voteStatus: VoteStatus, completion completionHandler: @escaping (_ result: Result<VoteStatus, KKAPIError>) -> Void) {
		let forumsRepliesVote = self.kurozoraKitEndpoints.forumsRepliesVote.replacingOccurrences(of: "?", with: "\(replyID)")
		let request: APIRequest<ForumsVoteResponse, KKAPIError> = tron.codable.request(forumsRepliesVote)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.method = .post
		request.parameters = [
			"vote": voteStatus.voteValue
		]
		request.perform(withSuccess: { forumsVoteResponse in
			completionHandler(.success(forumsVoteResponse.data.voteAction))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				SCLAlertView().showError("Can't vote on this reply 😔", subTitle: error.message)
			}
			print("Received vote reply error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
