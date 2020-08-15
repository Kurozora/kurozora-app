//
//  FeedSectionAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 07/08/2020.
//

extension FeedSection {
	/**
		A root object that stores information about a single feed section, such as the feed section's name, and lock status.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The name of the feed section.
		public let name: String

		/// Whether the feed section is locked.
		fileprivate let isLocked: Bool

		/// The lock status of the feed section.
		fileprivate var _lockStatus: LockStatus?
	}
}

// MARK: - Helpers
extension FeedSection.Attributes {
	// MARK: - Properties
	/// The lock status of the feed section.
	public var lockStatus: LockStatus {
		get {
			return _lockStatus ?? LockStatus(from: isLocked)
		}
		set {
			_lockStatus = newValue
		}
	}
}

