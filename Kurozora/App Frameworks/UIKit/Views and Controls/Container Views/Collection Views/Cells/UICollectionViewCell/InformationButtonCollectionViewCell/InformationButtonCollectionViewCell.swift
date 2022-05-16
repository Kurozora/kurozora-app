//
//  InformationButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol InformationButtonCollectionViewCellDelegate: AnyObject {
	func informationButtonCollectionViewCell(_ cell: InformationButtonCollectionViewCell, didPressButton button: UIButton)
}

class InformationButtonCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KTintedLabel!
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var separatorView: SecondarySeparatorView!

	// MARK: - Properties
	weak var delegate: InformationButtonCollectionViewCellDelegate?
	private(set) var studioInformation: StudioInformation = .website

	// MARK: - Functions
	/// Configure the cell with the given studio information.
	func configure(using studioInformation: StudioInformation) {
		self.studioInformation = studioInformation
		self.titleLabel.text = studioInformation.stringValue
		self.iconImageView.image = studioInformation.imageValue
		self.separatorView.isHidden = studioInformation == .website
	}

	// MARK: - IBActions
	@IBAction func actionButtonPressed(_ sender: KButton) {
		self.delegate?.informationButtonCollectionViewCell(self, didPressButton: sender)
	}
}
