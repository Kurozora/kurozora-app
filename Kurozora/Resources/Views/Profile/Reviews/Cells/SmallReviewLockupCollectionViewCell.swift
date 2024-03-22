//
//  SmallReviewLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SmallReviewLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var tertiaryLabel: KLabel!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterImageOverlayView: UIImageView?

	// MARK: - Properties
	lazy var literatureMask: CALayer = {
		let literatureMask = CALayer()
		literatureMask.contents =  UIImage(named: "book_mask")?.cgImage
		literatureMask.frame = self.posterImageView.bounds
		return literatureMask
	}()

	// MARK: - Functions
	func configure(using review: Review?) {
		guard let review = review else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()
		let title: String? = if review.relationships?.literatures != nil {
			review.relationships?.literatures?.data.first?.attributes.title
		} else if review.relationships?.characters != nil {
			review.relationships?.characters?.data.first?.attributes.name
		} else if review.relationships?.people != nil {
			review.relationships?.people?.data.first?.attributes.fullName
		} else if review.relationships?.episodes != nil {
			review.relationships?.episodes?.data.first?.attributes.title
		} else if review.relationships?.games != nil {
			review.relationships?.games?.data.first?.attributes.title
		} else if review.relationships?.shows != nil {
			review.relationships?.shows?.data.first?.attributes.title
		} else if review.relationships?.songs != nil {
			review.relationships?.songs?.data.first?.attributes.title
		} else if review.relationships?.studios != nil {
			review.relationships?.studios?.data.first?.attributes.name
		} else {
			nil
		}

		self.primaryLabel.text = title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		if review.relationships?.literatures != nil {
			review.relationships?.literatures?.data.first?.attributes.posterImage(imageView: self.posterImageView)
		} else if review.relationships?.characters != nil {
			review.relationships?.characters?.data.first?.attributes.personalImage(imageView: self.posterImageView)
		} else if review.relationships?.people != nil {
			review.relationships?.people?.data.first?.attributes.personalImage(imageView: self.posterImageView)
		} else if review.relationships?.episodes != nil {
			review.relationships?.episodes?.data.first?.attributes.bannerImage(imageView: self.posterImageView)
		} else if review.relationships?.games != nil {
			review.relationships?.games?.data.first?.attributes.posterImage(imageView: self.posterImageView)
		} else if review.relationships?.shows != nil {
			review.relationships?.shows?.data.first?.attributes.posterImage(imageView: self.posterImageView)
		} else if review.relationships?.songs != nil {
			review.relationships?.songs?.data.first?.attributes.artworkImage(imageView: self.posterImageView)
		} else if review.relationships?.studios != nil {
			review.relationships?.studios?.data.first?.attributes.profileImage(imageView: self.posterImageView)
		}

		if review.relationships?.literatures != nil {
			self.posterImageView.applyCornerRadius(0.0)
			self.posterImageView.layer.mask = self.literatureMask
			self.posterImageOverlayView?.isHidden = false
		} else if review.relationships?.games != nil {
			self.posterImageView.applyCornerRadius(18.0)
			self.posterImageView.layer.mask = nil
			self.posterImageOverlayView?.isHidden = true
		} else if review.relationships?.people != nil ||
				  review.relationships?.characters != nil ||
				  review.relationships?.studios != nil {
		} else {
			self.posterImageView.applyCornerRadius(10.0)
			self.posterImageView.layer.mask = nil
			self.posterImageOverlayView?.isHidden = true
		}
	}
}
