//
//  BaseReviewLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/03/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseReviewLockupCollectionViewCell: KCollectionViewCell {
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
	func configure(using review: Review?, for character: Character?) {
		guard let review = review, let character = character else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = character.attributes.name
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		character.attributes.personalImage(imageView: self.posterImageView)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for episode: Episode?) {
		guard let review = review, let episode = episode else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = episode.attributes.title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure banner
		episode.attributes.bannerImage(imageView: self.posterImageView)
		self.posterImageView.applyCornerRadius(10.0)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for game: Game?) {
		guard let review = review, let game = game else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = game.attributes.title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		game.attributes.posterImage(imageView: self.posterImageView)
		self.posterImageView.applyCornerRadius(18.0)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for literature: Literature?) {
		guard let review = review, let literature = literature else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = literature.attributes.title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		literature.attributes.posterImage(imageView: self.posterImageView)
		self.posterImageView.applyCornerRadius(0.0)
		self.posterImageView.layer.mask = self.literatureMask
		self.posterImageOverlayView?.isHidden = false
	}

	func configure(using review: Review?, for person: Person?) {
		guard let review = review, let person = person else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = person.attributes.fullName
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		person.attributes.personalImage(imageView: self.posterImageView)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for show: Show?) {
		guard let review = review, let show = show else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = show.attributes.title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		show.attributes.posterImage(imageView: self.posterImageView)
		self.posterImageView.applyCornerRadius(10.0)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for song: Song?) {
		guard let review = review, let song = song else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = song.attributes.title
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure artwork
		song.attributes.artworkImage(imageView: self.posterImageView)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}

	func configure(using review: Review?, for studio: Studio?) {
		guard let review = review, let studio = studio else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = studio.attributes.name
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score

		// Configure poster
		studio.attributes.profileImage(imageView: self.posterImageView)
		self.posterImageView.layer.mask = nil
		self.posterImageOverlayView?.isHidden = true
	}
}
