//
//  SplashscreenModels.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit

enum Splashscreen {
	enum AnimateLogo {
		struct Request {
			let completion: ((Bool) -> Void)?
		}

		struct Response {
			let completion: ((Bool) -> Void)?
		}

		struct ViewModel {
			let completion: ((Bool) -> Void)?
		}
	}
}
