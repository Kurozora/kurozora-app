//
//  Session.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import TRON
import SwiftyJSON

/**
	A mutable object that stores information about a collection of user sessions, such as the current session, and a collection of other sessions.
*/
public class UserSessions: JSONDecodable {
	// MARK: - Properties
	/// The user profile related to the session.
	public let user: UserProfile?

	/// The user's current session.
	public let currentSessions: UserSessionsElement?

	/// The collection of the user's other sessions.
    public var otherSessions: [UserSessionsElement]?

	// MARK: - Initializers
    required public init(json: JSON) throws {
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

/**
	A mutable object that stores information about a single user session, such as the session's ip address, last validated date, and platform.
*/
public class UserSessionsElement: JSONDecodable {
	// MARK: - Properties
	/// The id of the session.
	public var id: Int?

	/// The ip address form where the session was created.
	public let ip: String?

	/// The last time the session has been validated.
	public let lastValidated: String?

	/// The platform on which the session was created.
	public let platform: PlatformElement?

	/// The location where the session was created.
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

/**
	A mutable object that stores information about a single location, such as the location's region, latitude, and longitude.
*/
public class LocationElement: JSONDecodable {
	// MARK: - Properties
	/// The city's name of the location.
	public let city: String?

	/// The region's name of the location.
	public let region: String?

	/// The country's name of the location.
	public let country: String?

	/// The latitude of the location.
	public let latitude: Double?

	/// The longitude of the location.
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
