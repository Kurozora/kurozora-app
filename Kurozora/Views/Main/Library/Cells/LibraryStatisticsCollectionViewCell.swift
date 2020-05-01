//
//  LibraryStatisticsCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryStatisticsCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: UILabel! {
		didSet {
			self.secondaryLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	var showDetailsElements: [ShowDetailsElement]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		let tvCount = getOccurancesOf(string: "Tv")
		let movieCount = getOccurancesOf(string: "Movie")
		let undefinedCount = getOccurancesOf(string: "undefined")
		secondaryLabel.text = "\(tvCount) TV · \(movieCount) Movie · \(undefinedCount) OVA/ONA/Specials"
	}

	/// Gets number of occurances of the given string in the showDetailesElements array.
	func getOccurancesOf(string: String) -> Int {
		return showDetailsElements?.filter({ (showDetailElement) -> Bool in
			showDetailElement.type == string
		}).count ?? 0
	}
}
