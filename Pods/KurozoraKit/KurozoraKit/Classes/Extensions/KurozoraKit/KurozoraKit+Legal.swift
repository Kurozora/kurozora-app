//
//  KurozoraKit+Legal.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//

import TRON

extension KurozoraKit {
	/// Fetch the latest Privacy Policy.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getPrivacyPolicy(completion completionHandler: @escaping (_ result: Result<Legal, KKAPIError>) -> Void) {
		let legalPrivacyPolicy = KKEndpoint.Legal.privacyPolicy.endpointValue
		let request: APIRequest<LegalResponse, KKAPIError> = tron.codable.request(legalPrivacyPolicy)
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

	///  Fetch the latest Terms of Use.
	///
	/// - Parameters:
	///    - completionHandler: A closure returning a value that represents either a success or a failure, including an associated value in each case.
	///    - result: A value that represents either a success or a failure, including an associated value in each case.
	public func getTermsOfUse(completion completionHandler: @escaping (_ result: Result<Legal, KKAPIError>) -> Void) {
		let legalTermsOfUse = KKEndpoint.Legal.termsOfUse.endpointValue
		let request: APIRequest<LegalResponse, KKAPIError> = tron.codable.request(legalTermsOfUse)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicyResponse in
			completionHandler(.success(privacyPolicyResponse.data))
		}, failure: { [weak self] error in
			guard let self = self else { return }
			if self.services.showAlerts {
				UIApplication.topViewController?.presentAlertController(title: "Can't Get Terms of Use 😔", message: error.message)
			}
			print("❌ Received get terms of use error:", error.errorDescription ?? "Unknown error")
			print("┌ Server message:", error.message ?? "No message")
			print("├ Recovery suggestion:", error.recoverySuggestion ?? "No suggestion available")
			print("└ Failure reason:", error.failureReason ?? "No reason available")
			completionHandler(.failure(error))
		})
	}
}
