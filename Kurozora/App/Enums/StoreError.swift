//
//  StoreError.swift
//  Kurozora
//
//  Created by Khoren Katklian on 28/04/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import Foundation

/// The set of available store errors.
public enum StoreError: Error {
	// MARK: - Cases
	/// Indicating the verification has failed.
	case failedVerification
}
