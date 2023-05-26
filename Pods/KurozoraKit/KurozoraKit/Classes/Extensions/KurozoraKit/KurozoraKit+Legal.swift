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
	/// - Returns: An instance of `RequestSender` with the results of the privacy policy response.
	public func getPrivacyPolicy() -> RequestSender<LegalResponse, KKAPIError> {
		// Prepare request
		let legalPrivacyPolicy = KKEndpoint.Legal.privacyPolicy.endpointValue
		let request: APIRequest<LegalResponse, KKAPIError> = tron.codable.request(legalPrivacyPolicy)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}

	///  Fetch the latest Terms of Use.
	///
	/// - Returns: An instance of `RequestSender` with the results of the terms of use response.
	public func getTermsOfUse() -> RequestSender<LegalResponse, KKAPIError> {
		// Prepare request
		let legalTermsOfUse = KKEndpoint.Legal.termsOfUse.endpointValue
		let request: APIRequest<LegalResponse, KKAPIError> = tron.codable.request(legalTermsOfUse)
			.method(.get)
			.headers(self.headers)

		// Send request
		return request.sender()
	}
}
