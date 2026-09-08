//
//  SegueIdentifier.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/12/2025.
//  Copyright © 2025 Kurozora. All rights reserved.
//

import Foundation

/// A type that can be used as a key for encoding and decoding.
protocol SegueIdentifier: RawRepresentable, Sendable where RawValue == String {}

extension SegueIdentifier {
	var description: String {
		self.rawValue
	}

	var debugDescription: String {
		return "\(type(of: self))(stringValue: \"\(self.rawValue)\")"
	}
}
