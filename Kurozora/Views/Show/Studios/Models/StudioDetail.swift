//
//  StudioDetail.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum StudioDetail {
	/// List of available studio section types.
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		case header = 0
		case about
		case information
		case shows

		// MARK: - Properties
		/// The string value of a studio section type.
		var stringValue: String {
			switch self {
			case .header:
				return "Header"
			case .about:
				return "About"
			case .information:
				return "Information"
			case .shows:
				return "Shows"
			}
		}

		/// The row count of a studio section type.
		var rowCount: Int {
			switch self {
			case .header:
				return 1
			case .about:
				return 1
			case .information:
				return StudioDetail.Information.allCases.count
			case .shows:
				return 0
			}
		}

		/// The string value of a studio section type segue identifier.
		var segueIdentifier: String {
			switch self {
			case .header:
				return ""
			case .about:
				return ""
			case .information:
				return ""
			case .shows:
				return R.segue.studioDetailsCollectionViewController.showsListSegue.identifier
			}
		}

		// MARK: - Functions
		/// The cell identifier string of a studio section.
		///
		/// - Parameter row: The row integer used to determine the cell reuse identifier.
		///
		/// - Returns: The cell identifier string of a studio section.
		func identifierString(for row: Int = 0) -> String {
			switch self {
			case .header:
				return R.reuseIdentifier.studioHeaderCollectionViewCell.identifier
			case .about:
				return R.reuseIdentifier.textViewCollectionViewCell.identifier
			case .information:
				return StudioDetail.Information(rawValue: row)?.identifierString ?? StudioDetail.Information.website.identifierString
			case .shows:
				return R.reuseIdentifier.smallLockupCollectionViewCell.identifier
			}
		}
	}
}

// MARK: - Information
extension StudioDetail {
	/// List of available studio information types.
	enum Information: Int, CaseIterable {
		// MARK: - Cases
		/// The year in which the studio was founded.
		case founded = 0

		/// The headquarters of the studio.
		case headquarters

		/// The website of the studio.
		case website

		// MARK: - Properties
		/// The string value of a studio information type.
		var stringValue: String {
			switch self {
			case .founded:
				return "Founded"
			case .headquarters:
				return "Headquarters"
			case .website:
				return "Website"
			}
		}

		/// The image value of a studio infomration type.
		var imageValue: UIImage? {
			switch self {
			case .founded:
				return UIImage(systemName: "calendar")
			case .headquarters:
				return UIImage(systemName: "building.2")
			case .website:
				return UIImage(systemName: "safari")
			}
		}

		/// The cell identifier string of a studio information type.
		var identifierString: String {
			switch self {
			case .founded:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .headquarters:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			case .website:
				return R.reuseIdentifier.informationCollectionViewCell.identifier
			}
		}

		// MARK: - Functions
		/// Returns the required information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required information from the given object.
		func information(from studio: Studio) -> String {
			switch self {
			case .founded:
				return studio.attributes.founded?.formatted(date: .abbreviated, time: .omitted) ?? "-"
			case .headquarters:
				return studio.attributes.address ?? "-"
			case .website:
				return studio.attributes.websiteUrl ?? "-"
			}
		}

		/// Returns the required primary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary information from the given object.
		func primaryInformation(from studio: Studio) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required secondary information from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required secondary information from the given object.
		func secondaryInformation(from studio: Studio) -> String? {
			switch self {
			default: return nil
			}
		}

		/// Returns the required primary image from the given object.
		///
		/// - Parameter studio: The object used to extract the infromation from.
		///
		/// - Returns: the required primary image from the given object.
		func primaryImage(from studio: Studio) -> UIImage? {
			switch self {
			default: return nil
			}
		}

		/// Returns the footnote from the given object.
		///
		/// - Parameter studio: The object used to extract the footnote from.
		///
		/// - Returns: the footnote from the given object.
		func footnote(from studio: Studio) -> String? {
			switch self {
			default:
				return nil
			}
		}
	}
}
