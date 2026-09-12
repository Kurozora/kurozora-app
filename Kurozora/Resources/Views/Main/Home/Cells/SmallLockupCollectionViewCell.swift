//
//  SmallLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class SmallLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var timeLabel: KSecondaryLabel!
	@IBOutlet weak var broadcastLabel: BroadcastLabel!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var posterImageOverlay: UIImageView!
	@IBOutlet weak var posterContainerView: UIView!
	@IBOutlet weak var posterBorderView: BorderView!

	// MARK: - Properties
	lazy var literatureMask: UIImageView = {
		let maskView = UIImageView(image: .bookMask)
		return maskView
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	// MARK: - View
	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.posterContainerView.layer.cornerRadius = 22
			self.posterImageView?.applyCornerRadius(22)
			self.posterImageView?.layer.borderWidth = 0
			self.posterBorderView.cornerRadius = 22

			self.posterBoundsObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
				MainActor.assumeIsolated {
					self?.syncLiteratureMaskFrame()
				}
			}
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.timeLabel.text = ""
		self.broadcastLabel.stopCountdown()
		self.broadcastLabel.text = ""
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.syncLiteratureMaskFrame()
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)

		// Configure tagline
		self.ternaryLabel?.text = nil

		let ratingAverage = show?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		self.posterImageView?.applyCornerRadius(22.0)
		self.posterImageView?.layer.borderWidth = 0
		self.posterImageView?.mask = nil
		self.posterImageOverlay.isHidden = true
		self.posterBorderView.isHidden = false

		// Configure time label
		self.timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote).bold

		// Configure broadcast
		self.timeLabel.text = ""
		self.broadcastLabel.text = ""
		if scheduleIsShown, let nextBroadcastAt = show?.attributes.nextBroadcastAt {
			self.timeLabel.text = DateFormatter.broadcastTime.string(from: nextBroadcastAt)

			self.broadcastLabel.startCountdown(to: nextBroadcastAt, duration: show?.attributes.durationCount ?? 0)
		}
	}

	override func configure(using literature: Literature?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: literature, rank: rank, scheduleIsShown: scheduleIsShown)

		// Configure tagline
		self.ternaryLabel?.text = nil

		// Configure score
		let ratingAverage = literature?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		// Configure poster image
		self.posterImageView?.applyCornerRadius(0.0)
		self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
		self.posterImageView?.mask = self.literatureMask
		self.posterImageOverlay.isHidden = false
		self.posterBorderView.isHidden = true

		// Configure time label
		self.timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote).bold

		// Configure broadcast
		self.timeLabel.text = ""
		self.broadcastLabel.text = ""
		if scheduleIsShown, let publicationDate = literature?.attributes.publicationDate {
			self.timeLabel.text = DateFormatter.broadcastTime.string(from: publicationDate)

			self.broadcastLabel.startCountdown(to: publicationDate, duration: literature?.attributes.durationCount ?? 0)
		}
	}

	override func configure(using entry: LocalLibraryEntry?) {
		super.configure(using: entry)

		self.ternaryLabel?.text = nil

		let ratingAverage = entry?.publicRating?.doubleValue ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		if entry?.kind == .literatures {
			self.posterImageView?.applyCornerRadius(0.0)
			self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
			self.posterImageView?.mask = self.literatureMask
			self.posterImageOverlay.isHidden = false
			self.posterBorderView.isHidden = true
		} else {
			self.posterImageView?.applyCornerRadius(22.0)
			self.posterImageView?.layer.borderWidth = 0
			self.posterImageView?.mask = nil
			self.posterImageOverlay.isHidden = true
			self.posterBorderView.isHidden = false
		}

		self.timeLabel.font = UIFont.preferredFont(forTextStyle: .footnote).bold
		self.timeLabel.text = ""
		self.broadcastLabel.text = ""
	}

	/// Configures the cell using a `RelatedShow` object.
	///
	/// - Parameter relatedShow: The `RelatedShow` object used to configure the cell.
	func configure(using relatedShow: RelatedShow) {
		self.configure(using: relatedShow.show)

		// Configure relation
		self.ternaryLabel?.text = relatedShow.attributes.relation.name

		// Configure poster image
		self.posterImageView?.applyCornerRadius(22.0)
		self.posterImageView?.layer.borderWidth = 0
		self.posterImageView?.mask = nil
		self.posterImageOverlay.isHidden = true
		self.posterBorderView.isHidden = false

		// Configure broadcast label
		self.broadcastLabel.text = nil
	}

	/// Configures the cell using a `RelatedLiterature` object.
	///
	/// - Parameter relatedLiterature: The `RelatedLiterature` object used to configure the cell.
	func configure(using relatedLiterature: RelatedLiterature) {
		self.configure(using: relatedLiterature.literature)

		// Configure relation
		self.ternaryLabel?.text = relatedLiterature.attributes.relation.name

		// Configure poster image
		self.posterImageView?.applyCornerRadius(0.0)
		self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
		self.posterImageView?.mask = self.literatureMask
		self.posterImageOverlay.isHidden = false
		self.posterBorderView.isHidden = true

		// Configure broadcast label
		self.broadcastLabel.text = nil
	}

	fileprivate func syncLiteratureMaskFrame() {
		guard
			let posterImageView = self.posterImageView,
			posterImageView.mask === self.literatureMask
		else { return }
		self.literatureMask.frame = posterImageView.bounds
	}
}

// MARK: - Measurement
extension SmallLockupCollectionViewCell {
	/// Returns the item that measures the given show.
	///
	/// - Parameters:
	///    - show: The show the item measures.
	///    - rank: The rank of the show in a ranked list.
	///
	/// - Returns: The item that measures the show.
	static func measurableItem(for show: Show, rank: Int? = nil) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self) { cell in
			cell.configure(using: show, rank: rank)
		}
	}

	/// Returns the item that measures the given literature.
	///
	/// - Parameters:
	///    - literature: The literature the item measures.
	///    - rank: The rank of the literature in a ranked list.
	///
	/// - Returns: The item that measures the literature.
	static func measurableItem(for literature: Literature, rank: Int? = nil) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self) { cell in
			cell.configure(using: literature, rank: rank)
		}
	}

	/// Returns the item that measures the given related show.
	///
	/// - Parameter relatedShow: The related show the item measures.
	///
	/// - Returns: The item that measures the related show.
	static func measurableItem(for relatedShow: RelatedShow) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self) { cell in
			cell.configure(using: relatedShow)
		}
	}

	/// Returns the item that measures the given related literature.
	///
	/// - Parameter relatedLiterature: The related literature the item measures.
	///
	/// - Returns: The item that measures the related literature.
	static func measurableItem(for relatedLiterature: RelatedLiterature) -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: SmallLockupCollectionViewCell.self) { cell in
			cell.configure(using: relatedLiterature)
		}
	}
}
