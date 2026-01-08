//
//  BaseDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol BaseDetailHeaderCollectionViewCellDelegate: AnyObject {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didTapImage imageView: UIImageView, at index: Int)
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async
}

class BaseDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlet
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var visualEffectView: KVisualEffectView!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var rankButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!

	weak var delegate: BaseDetailHeaderCollectionViewCellDelegate?

	// MARK: - Functions
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure visual effect
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.visualEffectView.effect = UIGlassEffect(style: .clear)
		}
		self.visualEffectView.layerCornerRadius = 10.0

		// Configure poster
		self.posterImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapPoster))
		self.posterImageView.addGestureRecognizer(posterTap)

		// Configure banner
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapBanner))
		self.bannerImageView.addGestureRecognizer(bannerTap)
	}

	@objc private func didTapBanner(_ sender: UIImageView) {
		#if DEBUG
		self.delegate?.baseDetailHeaderCollectionViewCell(self, didTapImage: sender, at: 1)
		#endif
	}

	@objc private func didTapPoster(_ sender: UIImageView) {
		#if DEBUG
		self.delegate?.baseDetailHeaderCollectionViewCell(self, didTapImage: sender, at: 0)
		#endif
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressStatus: sender)
		}
	}
}
