//
//  StudioInformationSection.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	Set of available studio information sections.
*/
enum StudioInformationSection: Int, CaseIterable {
	// MARK: - Cases
	case founded = 0
	case headquarters = 1
	case website = 2

	// MARK: - Properties
	/// The string value of a studio information section.
	var stringValue: String {
		switch self {
		case .founded:
			return "Founded"
		case .headquarters:
			return "Headquarters"
		case .website:
			return "Studio Website"
		}
	}

	/// The image value of a studio infomration section.
	var imageValue: UIImage? {
		switch self {
		case .website:
			return R.image.symbols.safari()
		default:
			return nil
		}
	}

	/// The cell identifier string of a studio information section.
	var identifierString: String {
		switch self {
		case .founded:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .headquarters:
			return R.reuseIdentifier.informationCollectionViewCell.identifier
		case .website:
			return R.reuseIdentifier.informationButtonCollectionViewCell.identifier
		}
	}
}
