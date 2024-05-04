//
//  TextViewCollectionViewCellType.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import Foundation

/// List of available text view collection view cell types.
enum TextViewCollectionViewCellType {
	// MARK: - Cases
	/// Indicates the cell is of synopsis type.
	case synopsis
	/// Indicates the cell is of about type.
	case about
	/// Indicates the cell is of lyrics type.
	case lyrics

	// MARK: - Properties
	/// Returns the string value of a text view collection view cell type.
	var stringValue: String {
		switch self {
		case .synopsis:
			return Trans.synopsis
		case .about:
			return Trans.about
		case .lyrics:
			return Trans.lyrics
		}
	}

	/// Returns the integer value for maximum number of lines of a text view collection view cell type.
	var maximumNumberOfLinesValue: Int {
		switch self {
		case .synopsis:
			#if targetEnvironment(macCatalyst)
			return 10
			#else
			return 5
			#endif
		case .about, .lyrics:
			#if targetEnvironment(macCatalyst)
			return 15
			#else
			return 10
			#endif
		}
	}
}
