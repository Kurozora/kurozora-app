//
//  KKEndpoint+Shows.swift
//  KurozoraKit
//
//  Created by Khoren Katklian on 16/08/2020.
//

import Foundation

// MARK: - Seasons
extension KKEndpoint.Shows {
	/// The set of available Seasons API endpoints.
	internal enum Seasons {
		// MARK: - Cases
		/// The endpoint to the details of a season.
		case details(_ seasonIdentity: SeasonIdentity)

		/// The endpoint to the episodes related to a season.
		case episodes(_ seasonIdentity: SeasonIdentity)

		/// The endpoint to update the watch status of an season.
		case watched(_ seasonIdentity: SeasonIdentity)

		// MARK: - Properties
		/// The endpoint value of the Seasons API type.
		var endpointValue: String {
			switch self {
			case .details(let seasonIdentity):
				return "seasons/\(seasonIdentity.id)"
			case .episodes(let seasonIdentity):
				return "seasons/\(seasonIdentity.id)/episodes"
			case .watched(let seasonIdentity):
				return "seasons/\(seasonIdentity.id)/watched"
			}
		}
	}
}
