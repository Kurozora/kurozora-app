//
//  KurozoraKit+Legal.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 29/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import TRON
import SCLAlertView

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
				SCLAlertView().showError("Can't get privacy policy 😔", subTitle: error.message)
			}
			print("Received privacy policy error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
