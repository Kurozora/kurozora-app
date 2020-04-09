//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

public class UserSessions: JSONDecodable {
	// MARK: - Properties
    internal let success: Bool?
	public let message: String?
//	public let authToken: String?
	public let user: UserProfile?
	public let currentSessions: UserSessionsElement?
    public var otherSessions: [UserSessionsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
		self.success = json["success"].boolValue
		self.message = json["message"].stringValue
//		self.authToken = json["kuro_auth_token"].stringValue
		self.user = try? UserProfile(json: json["user"])
		if !json["current_session"].isEmpty {
			self.currentSessions = try? UserSessionsElement(json: json["current_session"])
		} else {
			self.currentSessions = try? UserSessionsElement(json: json["session"])
		}
		var otherSessions = [UserSessionsElement]()

        let otherSessionsArray = json["other_sessions"].arrayValue
		for otherSessionsItem in otherSessionsArray {
			if let userSessionsElement = try? UserSessionsElement(json: otherSessionsItem) {
				otherSessions.append(userSessionsElement)
			}
		}

		self.otherSessions = otherSessions
    }
}

public class UserSessionsElement: JSONDecodable {
	// MARK: - Properties
	public var id: Int?
	public let ip: String?
	public let lastValidated: String?
	public let platform: PlatformElement?
	public let location: LocationElement?

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.id = json["id"].intValue
		self.ip = json["ip"].stringValue
		self.lastValidated = json["last_validated_at"].stringValue
		self.platform = try? PlatformElement(json: json["platform"])
		self.location = try? LocationElement(json: json["location"])
	}
}

public class LocationElement: JSONDecodable {
	// MARK: - Properties
	public let city: String?
	public let region: String?
	public let country: String?
	public let latitude: Double?
	public let longitude: Double?

//	/// The object used to start and stop the delivery of location-related events to the app.
//	fileprivate let locationManager = CLLocationManager()
//
//	/// The coordinates of the current location of the user.
//	fileprivate var currentUserLocation: CLLocationCoordinate2D {
//		locationManager.requestWhenInUseAuthorization()
//
//		if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//			CLLocationManager.authorizationStatus() ==  .authorizedAlways {
//			if let currentLocation: CLLocation = locationManager.location {
//				try? KKServices.shared.KeychainDefaults.set("\(currentLocation.coordinate.latitude)", key: "latitude")
//				try? KKServices.shared.KeychainDefaults.set("\(currentLocation.coordinate.longitude)", key: "longitude")
//				return currentLocation.coordinate
//			}
//		}
//
//		return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
//	}
//
//	public var latitude: Double {
//		guard let latitudeString = KKServices.shared.KeychainDefaults["latitude"], !latitudeString.isEmpty,
//			let latitude = Double(latitudeString) else { return currentUserLocation.latitude }
//		return latitude
//	}
//
//	public var longitude: Double {
//		guard let longitudeString = KKServices.shared.KeychainDefaults["longitude"], !longitudeString.isEmpty,
//			let longitude = Double(longitudeString) else { return currentUserLocation.longitude }
//		return longitude
//	}

	// MARK: - Initializers
	required public init(json: JSON) throws {
		self.city = json["city"].stringValue
		self.region = json["region"].stringValue
		self.country = json["country"].stringValue
		self.latitude = json["latitude"].doubleValue
		self.longitude = json["longitude"].doubleValue
	}
}

public class PlatformElement: JSONDecodable {
	// MARK: - Properties
	public let localized: String?
	public let system: String?
	public let version: String?
	public let deviceVendor: String?
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
