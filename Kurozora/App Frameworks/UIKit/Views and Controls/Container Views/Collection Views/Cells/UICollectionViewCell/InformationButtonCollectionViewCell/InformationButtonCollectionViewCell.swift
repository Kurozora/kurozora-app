//
//  InformationButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class InformationButtonCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var typeImageView: UIImageView!
	@IBOutlet weak var typeLabel: KSecondaryLabel!
	@IBOutlet weak var primaryLabel: KTappableLabel!
	@IBOutlet weak var primaryImageViewHeightConstraint: NSLayoutConstraint?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		self.typeImageView?.theme_tintColor = KThemePicker.subTextColor.rawValue
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	fileprivate func sharedInit() {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layerCornerRadius = 8
	}

	/// Configure the cell with the given studio information.
	func configure(for studio: Studio, using studioDetailInformation: StudioDetail.Information) {
		self.primaryImageViewHeightConstraint?.isActive = false
		self.typeImageView.image = studioDetailInformation.imageValue
		self.typeLabel.text = studioDetailInformation.stringValue

		let information = studioDetailInformation.information(from: studio)

		if information == "-" {
			self.primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
			self.primaryLabel.text = information
		} else {
			let urls = information.trimmingCharacters(in: .whitespacesAndNewlines)
				.components(separatedBy: "\n")
				.compactMap {
					let url = URL(string: $0)
					let domain = url?.rootDomain ?? $0

					return (domain, $0)
				}

			self.primaryLabel.setLinks(with: urls)
		}
	}
}
