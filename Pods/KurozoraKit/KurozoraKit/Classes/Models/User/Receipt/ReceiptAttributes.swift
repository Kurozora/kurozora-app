//
//  ReceiptAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/10/2020.
//

extension Receipt {
	/**
		A root object that stores information about a single receipt, such as the receipt's validity.
	*/
	public struct Attributes: Codable {
		/// Whether the receipt is valid.
		public let isValid: Bool
	}
}
