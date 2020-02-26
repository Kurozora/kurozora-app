//
//  KService.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Alamofire
import TRON

struct KService {
	// MARK: - Properties
	let tron = TRON(baseURL: "https://kurozora.app/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])
	//	let tron = TRON(baseURL: "http://kurozora-web.test/api/v1/", plugins: [NetworkActivityPlugin(application: UIApplication.shared)])

	let headers: HTTPHeaders = [
		"Content-Type": "application/x-www-form-urlencoded",
		"accept": "application/json"
	]

	static let shared = KService()
}
