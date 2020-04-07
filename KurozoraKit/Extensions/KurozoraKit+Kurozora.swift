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

		- Parameter successHandler: A closure returning a PrivacyPolicyElement object.
		- Parameter privacyPolicy: The returned PrivacyPolicyElement object.
	*/
	public func getPrivacyPolicy(withSuccess successHandler: @escaping (_ privacyPolicy: PrivacyPolicyElement?) -> Void) {
		let privacyPolicy = self.kurozoraKitEndpoints.privacyPolicy
		let request: APIRequest<PrivacyPolicy, JSONError> = tron.swiftyJSON.request(privacyPolicy)
		request.headers = headers
		request.method = .get
		request.perform(withSuccess: { privacyPolicy in
			if let success = privacyPolicy.success {
				if success {
					successHandler(privacyPolicy.privacyPolicy)
				}
			}
		}, failure: { error in
			SCLAlertView().showError("Can't get privacy policy 😔", subTitle: error.message)
			print("Received privacy policy error: \(error.message ?? "No message available")")
		})
	}
}
