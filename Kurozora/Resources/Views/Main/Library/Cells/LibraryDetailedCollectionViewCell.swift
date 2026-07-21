//
//  LibraryDetailedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryDetailedCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var episodeBorderView: BorderView!
	@IBOutlet weak var shadowImageView: UIImageView?
	@IBOutlet weak var userProgressLabel: UILabel!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.bannerContainerView.layer.cornerRadius = 22
		self.episodeImageView?.applyCornerRadius(22)
		self.episodeImageView?.layer.borderWidth = 0
		self.episodeBorderView.cornerRadius = 22

		self.shadowImageView?.layer.cornerRadius = 22
		self.shadowImageView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.shadowImageView?.layer.masksToBounds = true
	}

	// MARK: - Functions
	override func configure(using entry: LocalLibraryEntry, showSelectionIcon: Bool) {
		super.configure(using: entry, showSelectionIcon: showSelectionIcon)

		self.primaryLabel.textColor = .white
		self.userProgressLabel.text = entry.informationStringShort
		entry.bannerImage(imageView: self.episodeImageView)

		self.posterShadowView?.applyShadow()

		switch entry.kind {
		case .shows, .games:
			self.posterImageView?.applyCornerRadius(12.0)
			self.posterBorderView?.cornerRadius = 12.0
			self.posterBorderView?.isHidden = false
		case .literatures:
			break
		}
	}
}
