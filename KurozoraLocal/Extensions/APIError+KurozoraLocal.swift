//
//  APIError+KurozoraLocal.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit

nonisolated extension APIError {
	/// The wait requested by the `Retry-After` header, in seconds.
	var retryAfterInterval: TimeInterval? {
		guard let value = self.response?.value(forHTTPHeaderField: "Retry-After") else { return nil }
		return TimeInterval(value.trimmingCharacters(in: .whitespaces))
	}
}

nonisolated extension Error {
	/// A description of the failure for sync logs.
	var librarySyncDescription: String {
		if let apiError = self as? APIError, let statusCode = apiError.statusCode {
			return "HTTP \(statusCode) \(apiError.message)"
		}
		return self.localizedDescription
	}
}
