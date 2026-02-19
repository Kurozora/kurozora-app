//
//  BaseDetailHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/01/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

protocol BaseDetailHeaderCollectionViewCellDelegate: AnyObject {
	func baseDetailHeaderCollectionViewCell(_ cell: BaseDetailHeaderCollectionViewCell, didPressStatus button: UIButton) async
}

class BaseDetailHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlet
	@IBOutlet var bannerImageView: UIImageView!
	@IBOutlet var visualEffectView: KVisualEffectView!

	// Quick details view
	@IBOutlet weak var quickDetailsView: UIView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var rankButton: UIButton!
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var posterImageView: PosterImageView!

	// MARK: - Properties
	weak var delegate: BaseDetailHeaderCollectionViewCellDelegate?
	weak var mediaViewerDelegate: MediaViewerViewDelegate?

	// MARK: - Functions
	override func awakeFromNib() {
		super.awakeFromNib()

		// Configure visual effect
		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			self.visualEffectView.effect = UIGlassEffect(style: .clear)
		}
		self.visualEffectView.layerCornerRadius = 10.0

		// Configure poster
		self.posterImageView.tag = 0
		self.posterImageView.isUserInteractionEnabled = true
		let posterTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.posterImageView.addGestureRecognizer(posterTap)

		// Configure banner
		self.bannerImageView.tag = 1
		self.bannerImageView.isUserInteractionEnabled = true
		let bannerTap = UITapGestureRecognizer(target: self, action: #selector(self.didTapImage))
		self.bannerImageView.addGestureRecognizer(bannerTap)
	}

	@objc private func didTapImage(_ sender: UITapGestureRecognizer) {
		guard let view = sender.view as? UIImageView else { return }
		self.mediaViewerDelegate?.mediaViewerViewDelegate(self, didTapImage: view, at: view.tag)
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.baseDetailHeaderCollectionViewCell(self, didPressStatus: sender)
		}
	}
}
