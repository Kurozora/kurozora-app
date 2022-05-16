//
//  StudioInformation.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// List of available studio information types.
enum StudioInformation: Int, CaseIterable {
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
			return Trans.founded
		case .headquarters:
			return Trans.headquarters
		case .website:
			return Trans.websites
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
