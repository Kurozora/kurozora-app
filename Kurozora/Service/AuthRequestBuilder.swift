//
//  AuthRequestBuilder.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import PusherSwift

class AuthRequestBuilder: AuthRequestBuilderProtocol {
	func requestFor(socketID: String, channelName: String) -> URLRequest? {
		guard let userId = User.currentId() else {return nil}
		guard let sessionSecret = User.currentSessionSecret() else {return nil}

		var request = URLRequest(url: URL(string: "https://kurozora.app/api/v1/user/authenticate_channel")!)
		request.httpMethod = "POST"
		request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)&user_id=\(userId)&session_secret=\(sessionSecret)".data(using: String.Encoding.utf8)

		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.addValue("app.kurozora.anime", forHTTPHeaderField: "User-Agent")
		return request
	}
}
