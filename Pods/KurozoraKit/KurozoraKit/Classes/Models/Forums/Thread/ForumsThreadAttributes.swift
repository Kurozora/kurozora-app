//
//  ForumsThreadElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

extension ForumsThread {
	/**
		A root object that stores information about a single forums thread, such as the thread's title, content, and lock status.
	*/
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The title of the forums thread.
		public let title: String

		/// The content of the forums thread.
		public let content: String

		/// Whether the forums thread is locked.
		fileprivate let isLocked: Bool

		/// The lock status of the forums thread.
		fileprivate var _lockStatus: LockStatus?

		/// The count of replies on the forums thread.
		public let replyCount: Int

		/// The metrics of the forums thread.
		public let metrics: ForumsThread.Attributes.Metrics

		/// The date the forums thread was created at.
		public let createdAt: String
	}
}

// MARK: - Helpers
extension ForumsThread.Attributes {
	// MARK: - Properties
	/// The lock status of the forums thread.
	public var lockStatus: LockStatus {
		get {
			return _lockStatus ?? LockStatus(from: isLocked)
		}
		set {
			_lockStatus = newValue
		}
	}
}
