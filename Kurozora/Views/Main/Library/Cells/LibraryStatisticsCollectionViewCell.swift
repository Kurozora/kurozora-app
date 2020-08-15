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
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	var shows: [Show] = [] {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		let tvCount = self.getOccurancesOf(strings: ["Tv"])
		let movieCount = self.getOccurancesOf(strings: ["Movie"])
		let ovaCount = self.getOccurancesOf(strings: ["OVA"])
		let undefinedCount = self.getOccurancesOfNot(strings: ["Tv", "Movie"])
		secondaryLabel.text = "\(tvCount) TV · \(movieCount) Movie · \(ovaCount) OVA · \(undefinedCount) Music/ONA/Specials"
	}

	/// Gets number of occurances of the given string in the shows array.
	func getOccurancesOf(strings: [String]) -> Int {
		return shows.filter({ show -> Bool in
			strings.contains(show.type)
		}).count
	}

	/// Gets number of occurances that doesn't match of the given string in the shows array.
	func getOccurancesOfNot(strings: [String]) -> Int {
		return shows.filter({ show -> Bool in
			!strings.contains(show.type)
		}).count
	}
}
