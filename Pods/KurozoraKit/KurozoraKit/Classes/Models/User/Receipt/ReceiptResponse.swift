//
//  ReceiptResponse.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/10/2020.
//

/// A root object that stores information about a collection of receipts.
public struct ReceiptResponse: Codable {
	// MARK: - Properties
	/// The data included in the response for a receipt object request.
	public let data: [Receipt]
}
