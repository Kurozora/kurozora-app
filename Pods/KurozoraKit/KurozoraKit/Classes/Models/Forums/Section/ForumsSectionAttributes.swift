//
//  ForumsSectionAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension ForumsSection {
	/**
		A root object that stores information about a single forums section, such as the forums section's name, and lock status.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The name of the forums section.
		public let name: String

		/// Whether the forums section is locked.
		fileprivate let isLocked: Bool

		/// The lock status of the forums section.
		fileprivate var _lockStatus: LockStatus?
	}
}

// MARK: - Helpers
extension ForumsSection.Attributes {
	// MARK: - Properties
	/// The lock status of the forums section.
	public var lockStatus: LockStatus {
		get {
			return _lockStatus ?? LockStatus(from: isLocked)
		}
		set {
			_lockStatus = newValue
		}
	}
}
