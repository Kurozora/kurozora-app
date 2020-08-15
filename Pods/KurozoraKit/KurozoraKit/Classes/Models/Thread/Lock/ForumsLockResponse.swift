//
//  ForumsLockResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 09/12/2018.
//

/**
	A root object that stores information about a forums lock.
*/
public struct ForumsLockResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a forums lock reply object request.
	public let data: ForumsLock
}
