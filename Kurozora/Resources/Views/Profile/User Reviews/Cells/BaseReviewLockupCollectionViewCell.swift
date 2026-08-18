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
	@IBOutlet weak var posterImageView: UIImageView!
	@IBOutlet weak var posterImageOverlayView: UIImageView?
	@IBOutlet weak var posterBorderView: BorderView?

	// MARK: - Properties
	lazy var literatureMask: UIImageView = {
		let maskView = UIImageView(image: .bookMask)
		return maskView
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	private let spoilerOverlayView = SpoilerOverlayView()

	/// Whether the reader revealed this review's spoiler.
	private var isSpoilerRevealed = false

	private static var spoilerWarningText: String {
		#if targetEnvironment(macCatalyst)
		return L10n.reviewSpoilerClick
		#else
		return L10n.reviewSpoilerTap
		#endif
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()
		self.posterBoundsObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
			self?.syncLiteratureMaskFrame()
		}

		self.spoilerOverlayView.configure(warning: Self.spoilerWarningText, cornerRadius: 10)
		self.spoilerOverlayView.revealHandler = { [weak self] in
			self?.isSpoilerRevealed = true
		}

		self.contentView.addSubview(self.spoilerOverlayView)
		NSLayoutConstraint.activate([
			self.spoilerOverlayView.topAnchor.constraint(equalTo: self.tertiaryLabel.topAnchor),
			self.spoilerOverlayView.bottomAnchor.constraint(equalTo: self.tertiaryLabel.bottomAnchor),
			self.spoilerOverlayView.leadingAnchor.constraint(equalTo: self.tertiaryLabel.leadingAnchor),
			self.spoilerOverlayView.trailingAnchor.constraint(equalTo: self.tertiaryLabel.trailingAnchor)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.syncLiteratureMaskFrame()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.isSpoilerRevealed = false
	}

	// MARK: - Functions
	/// Renders the parts of `review` shared by every reviewable kind.
	///
	/// - Parameter review: The review to display.
	private func configureReviewDetails(using review: Review) {
		self.secondaryLabel.text = review.attributes.createdAt.formatted(date: .abbreviated, time: .omitted)
		self.tertiaryLabel.text = review.attributes.description
		self.scoreLabel.text = "\(review.attributes.score)"
		self.scoreView.rating = review.attributes.score
		self.spoilerOverlayView.isHidden = self.isSpoilerRevealed || !(review.attributes.isSpoiler && !(review.attributes.description ?? "").isEmpty)
	}

	func configure(using review: Review?, for character: Character?) {
		guard let review = review, let character = character else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = character.attributes.name
		self.configureReviewDetails(using: review)

		// Configure poster
		character.attributes.profileImage(imageView: self.posterImageView)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for episode: Episode?) {
		guard let review = review, let episode = episode else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = episode.attributes.title
		self.configureReviewDetails(using: review)

		// Configure banner
		episode.attributes.bannerImage(imageView: self.posterImageView)
		(self.posterImageView as? RoundedRectangleImageView)?.applyCornerRadius(10.0)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.cornerRadius = 10.0
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for game: Game?) {
		guard let review = review, let game = game else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = game.attributes.title
		self.configureReviewDetails(using: review)

		// Configure poster
		game.attributes.posterImage(imageView: self.posterImageView)
		(self.posterImageView as? RoundedRectangleImageView)?.applyCornerRadius(22.0)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.cornerRadius = 22.0
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for literature: Literature?) {
		guard let review = review, let literature = literature else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = literature.attributes.title
		self.configureReviewDetails(using: review)

		// Configure poster
		literature.attributes.posterImage(imageView: self.posterImageView)
		(self.posterImageView as? RoundedRectangleImageView)?.applyCornerRadius(0.0)
		self.literatureMask.frame = self.posterImageView.bounds
		self.posterImageView.mask = self.literatureMask
		self.posterImageOverlayView?.isHidden = false
		self.posterBorderView?.isHidden = true
	}

	func configure(using review: Review?, for person: Person?) {
		guard let review = review, let person = person else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = person.attributes.fullName
		self.configureReviewDetails(using: review)

		// Configure poster
		person.attributes.profileImage(imageView: self.posterImageView)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for show: Show?) {
		guard let review = review, let show = show else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = show.attributes.title
		self.configureReviewDetails(using: review)

		// Configure poster
		show.attributes.posterImage(imageView: self.posterImageView)
		(self.posterImageView as? RoundedRectangleImageView)?.applyCornerRadius(22.0)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.cornerRadius = 22.0
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for song: Song?) {
		guard let review = review, let song = song else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = song.attributes.title
		self.configureReviewDetails(using: review)

		// Configure artwork
		song.attributes.artworkImage(imageView: self.posterImageView)
		(self.posterImageView as? RoundedRectangleImageView)?.applyCornerRadius(22.0)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.cornerRadius = 22.0
		self.posterBorderView?.isHidden = false
	}

	func configure(using review: Review?, for studio: Studio?) {
		guard let review = review, let studio = studio else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.primaryLabel.text = studio.attributes.name
		self.configureReviewDetails(using: review)

		// Configure poster
		studio.attributes.profileImage(imageView: self.posterImageView)
		self.posterImageView.mask = nil
		self.posterImageView.layer.borderWidth = 0
		self.posterImageOverlayView?.isHidden = true
		self.posterBorderView?.isHidden = false
	}

	fileprivate func syncLiteratureMaskFrame() {
		guard self.posterImageView?.mask === self.literatureMask else { return }
		self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
	}
}
