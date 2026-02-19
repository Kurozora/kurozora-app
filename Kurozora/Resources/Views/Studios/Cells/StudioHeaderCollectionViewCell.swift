//
//  StudioHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class StudioHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryImageView: StudioLogoImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!

	// MARK: - Properties
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure image view
		self.primaryImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.primaryImageView.addGestureRecognizer(posterTap)
	}

	// MARK: - Functions
	/// Configure the cell with the given studio object.
	///
	/// - Parameter studio: The `Studio` object used to configure the cell.
	func configure(using studio: Studio) {
		self.primaryLabel.text = studio.attributes.name

		if let foundingYear = studio.attributes.foundedAt {
			self.secondaryLabel.text = Trans.foundedOn(date: foundingYear.formatted(date: .abbreviated, time: .omitted))
		} else {
			self.secondaryLabel.text = nil
		}

		if studio.attributes.profile != nil {
			studio.attributes.profileImage(imageView: self.primaryImageView)
		} else {
			studio.attributes.logoImage(imageView: self.primaryImageView)
		}
	}

	@objc private func didTapImage(_ sender: UIImageView) {
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: sender, at: 0)
	}
}
