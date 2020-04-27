//
//  LocationElement.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 27/04/2020.
//

import SwiftyJSON
import TRON

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
