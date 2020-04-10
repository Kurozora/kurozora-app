//
//  KurozoraKit+Kurozora.swift
//  Kurozora
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
	public func getPrivacyPolicy(completion completionHandler: @escaping (_ result: Result<PrivacyPolicyElement, KKError>) -> Void) {
		let privacyPolicy = self.kurozoraKitEndpoints.privacyPolicy
		let request: APIRequest<PrivacyPolicy, KKError> = tron.swiftyJSON.request(privacyPolicy)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicy in
			if let privacyPolicy = privacyPolicy.privacyPolicy {
				completionHandler(.success(privacyPolicy))
			}
		}, failure: { error in
			if self.services.showAlerts {
				SCLAlertView().showError("Can't get privacy policy 😔", subTitle: error.message)
			}
			print("Received privacy policy error: \(error.message ?? "No message available")")
			completionHandler(.failure(error))
		})
	}
}
