//
//  KurozoraKit+Legal.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON

extension KurozoraKit {
	/**
		Fetch the latest privacy policy.

		- Parameter completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
		- Parameter result: A value that represents either a success or a failure, including an associated value in each case.
	*/
	public func getPrivacyPolicy(completion completionHandler: @escaping (_ result: Result<PrivacyPolicy, KKAPIError>) -> Void) {
		let legalPrivacyPolicy = KKEndpoint.Legal.privacyPolicy.endpointValue
		let request: APIRequest<PrivacyPolicyResponse, KKAPIError> = tron.codable.request(legalPrivacyPolicy)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicyResponse in
			completionHandler(.success(privacyPolicyResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Privacy Policy 😔", message: error.message)
			}
			print("❌ Received get privacy policy error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
