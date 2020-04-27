//
//  PlatformElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

/**
	A mutable object that stores information about a single platform, such as the platform's system name, version, and device vendor.
*/
public class PlatformElement: JSONDecodable {
	// MARK: - Properties
	/// The localized string of the platform.
	public let localized: String?

	/// The system name of the platform.
	public let system: String?

	/// The version of the platform.
	public let version: String?

	/// The device vendor name of the platofrm.
	public let deviceVendor: String?

	/// The device name of the platform.
	public let deviceName: String?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.localized = json["human_readable_format"].stringValue
		self.system = json["platform"].stringValue
		self.version = json["platform_version"].stringValue
		self.deviceVendor = json["device_vendor"].stringValue
		self.deviceName = json["device_model"].stringValue
	}
}
