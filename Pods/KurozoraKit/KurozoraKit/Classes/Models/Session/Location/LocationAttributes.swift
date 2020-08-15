//
//  LocationAttributes.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 05/08/2020.
//

extension Location {
	/**
		A root object that stores information about a single location, such as the location's region, latitude, and longitude.
	*/
	public struct Attributes: Codable {
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
	}
}
