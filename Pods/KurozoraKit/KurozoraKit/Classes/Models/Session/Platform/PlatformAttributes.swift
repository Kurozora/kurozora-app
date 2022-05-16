//
//  PlatformAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 04/08/2020.
//

extension Platform {
	/// A root object that stores information about a single platform, such as the platform's system name, version, and device vendor.
	public struct Attributes: Codable {
		// MARK: - Properties
		/// The description of the platform.
		public let description: String?

		/// The name of the platform.
		public let systemName: String?

		/// The version of the platform.
		public let systemVersion: String?

		/// The device vendor name of the platofrm.
		public let deviceVendor: String?

		/// The device model of the platform.
		public let deviceModel: String?
	}
}
