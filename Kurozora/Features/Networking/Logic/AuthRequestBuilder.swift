//
//  AuthRequestBuilder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import PusherSwift
import TRON

class AuthRequestBuilder: AuthRequestBuilderProtocol {
	func requestFor(socketID: String, channelName: String) -> URLRequest? {
		guard let userID = User.currentID else { return nil }
		let authToken = User.authToken

		var request = URLRequest(url: URL(string: "https://kurozora.app/api/v1/users/\(userID)/authenticate-channel")!)
		request.httpMethod = "POST"
		request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: String.Encoding.utf8)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.addValue(authToken, forHTTPHeaderField: "kuro-auth")
		return request
	}
}
