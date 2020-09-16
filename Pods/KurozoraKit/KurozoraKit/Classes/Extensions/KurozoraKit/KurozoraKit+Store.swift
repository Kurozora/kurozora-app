//
//  KurozoraKit+Store.swift
//  Alamofire
//
//  Created by Khoren Katklian on 13/09/2020.
//

import TRON
import SCLAlertView

extension KurozoraKit {
	/**
		Verify the user's transaction receipt.

		- Parameter receipt: The Base64 encoded receipt data.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func verifyReceipt(_ receipt: String, completion completionHandler: @escaping (_ result: Result<KKSuccess, KKAPIError>) -> Void) {
		let storeVerify = KKEndpoint.Store.verify.endpointValue
		let request: APIRequest<KKSuccess, KKAPIError> = tron.codable.request(storeVerify)

		request.headers = headers
		if User.isSignedIn {
			request.headers["kuro-auth"] = self.authenticationKey
		}

		request.parameters = [
			"receipt": receipt
		]
		request.method = .post
		request.perform(withSuccess: { kkSuccess in
			completionHandler(.success(kkSuccess))
		}, failure: { error in
			print("Received validate receipt error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
