//
//  KurozoraKit+Store.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/09/2020.
//

import TRON

extension KurozoraKit {
	/**
		Verify the user's transaction receipt.

		- Parameter receipt: The Base64 encoded receipt data.
		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func verifyReceipt(_ receipt: String, completion completionHandler: @escaping (_ result: Result<[Receipt], KKAPIError>) -> Void) {
		let storeVerify = KKEndpoint.Store.verify.endpointValue
		let request: APIRequest<ReceiptResponse, KKAPIError> = tron.codable.request(storeVerify)

		request.headers = headers
		request.headers.add(.authorization(bearerToken: self.authenticationKey))

		request.parameters = [
			"receipt": receipt
		]
		request.method = .post
		request.perform(withSuccess: { receiptResponse in
			if let receipt = receiptResponse.data.first {
				User.current?.attributes.updateSubscription(from: receipt)
			}
			completionHandler(.success(receiptResponse.data))
		}, failure: { error in
			print("Received validate receipt error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
