//
//  HiddenStatus.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 25/02/2024.
//

import Foundation

/// The set of available hidden status types.
///
/// ```
/// case notHidden = -1
/// case disabled = 0
/// case hidden = 1
/// ```
public enum HiddenStatus: Int, Codable, Sendable {
	// MARK: - Cases
	/// The title is not hidden.
	case notHidden = -1

	/// The title can't be hidden or unhidden.
	case disabled = 0

	/// The title is hidden.
	case hidden = 1

	// MARK: - Initializers
	/// Initializes an instance of `HiddenStatus` with the given bool value.
	///
	/// If `nil` is given, then an instance of `.disabled` is initialized.
	///
	/// - Parameter bool: The boolean value used to initialize an instance of `HiddenStatus`.
	public init(_ bool: Bool?) {
		if let bool = bool {
			self = bool ? .hidden : .notHidden
		} else {
			self = .disabled
		}
	}
}
