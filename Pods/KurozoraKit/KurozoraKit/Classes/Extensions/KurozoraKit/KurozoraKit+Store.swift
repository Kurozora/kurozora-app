//
//  KurozoraKit+Store.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 13/09/2020.
//

import TRON

extension KurozoraKit {
	/// Verify the user's transaction receipt.
	///
	/// - Parameters:
	///    - receipt: The Base64 encoded receipt data.
	///
	/// - Returns: An instance of `RequestSender` with the results of the auth token response.
	public func verifyReceipt(_ receipt: String) async -> RequestSender<ReceiptResponse, KKAPIError> {
		let receiptResponseRequest = self.sendVerifyReceiptRequest(receipt)

		do {
			let receiptResponse = try await receiptResponseRequest.value
			if let receipt = receiptResponse.data.first {
				User.current?.attributes.updateSubscription(from: receipt)
			}
		} catch {
			print("Received validate receipt error: \(error.localizedDescription)")
		}

		return receiptResponseRequest
	}

	/// Verify the user's transaction receipt.
	///
	/// - Parameters:
	///    - receipt: The Base64 encoded receipt data.
	///
	/// - Returns: An instance of `RequestSender` with the results of the auth token response.
	private func sendVerifyReceiptRequest(_ receipt: String) -> RequestSender<ReceiptResponse, KKAPIError> {
		// Prepare headers
		var headers = self.headers
		headers.add(.authorization(bearerToken: self.authenticationKey))

		// Prepare request
		let storeVerify = KKEndpoint.Store.verify.endpointValue
		let request: APIRequest<ReceiptResponse, KKAPIError> = tron.codable.request(storeVerify)
			.method(.post)
			.parameters([
				"receipt": receipt
			])
			.headers(headers)

		// Send request
		return request.sender()
	}
}
