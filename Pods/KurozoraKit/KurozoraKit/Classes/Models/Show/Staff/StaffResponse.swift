//
//  StaffResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 15/06/2021.
//

/**
	A root object that stores information about a collection of staff.
*/
public struct StaffResponse: Codable {
	// MARK: - Properties
	/// The data included in the repsonse for a staff object request.
	public let data: [Staff]

	/// The realtive URL to the next page in the paginated response.
	public let next: String?
}
