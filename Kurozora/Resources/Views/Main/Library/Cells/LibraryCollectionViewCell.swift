//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryBaseCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var posterShadowView: UIView?
	@IBOutlet weak var posterContainerView: UIView?
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterBorderView: BorderView?
	@IBOutlet weak var posterImageOverlayView: UIImageView!
	@IBOutlet weak var selectionImageOverlayView: UIImageView!
	@IBOutlet weak var posterAspectRatioConstraint: NSLayoutConstraint?

	// MARK: - Properties
	lazy var literatureMask: UIImageView = {
		let maskView = UIImageView(image: .bookMask)
		return maskView
	}()

	private var posterBoundsObservation: NSKeyValueObservation?

	/// Determines whether to show selection icon.
	var showSelectionIcon: Bool = false

	override var isSelected: Bool {
		didSet {
			self.setNeedsLayout()
		}
	}

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.posterContainerView?.layer.cornerRadius = 22
		self.posterBorderView?.cornerRadius = 22

		self.posterBoundsObservation = self.posterImageView?.observe(\.bounds, options: [.new]) { [weak self] _, _ in
			self?.syncLiteratureMaskFrame()
		}
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.showSelectionIcon = false
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		self.selectionImageOverlayView.isHidden = !self.showSelectionIcon
		self.selectionImageOverlayView.image = self.isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")

		self.syncLiteratureMaskFrame()
	}

	// MARK: - Functions
	/// Configure the cell with the given show's details.
	///
	/// - Parameters:
	///    - show: The show to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using show: Show, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.primaryLabel.text = show.attributes.title

		// Configure poster
		show.attributes.posterImage(imageView: self.posterImageView)

		self.applyPosterAspectRatio(widthToHeight: 2.0 / 3.0)
		self.posterContainerView?.layer.cornerRadius = 22
		self.posterImageView?.applyCornerRadius(22.0)
		self.posterImageView?.layer.borderWidth = 0
		self.posterImageView?.mask = nil
		self.posterImageOverlayView.isHidden = true
		self.posterBorderView?.isHidden = false
	}

	/// Configure the cell with the given literature's details.
	///
	/// - Parameters:
	///    - literature: The literature to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using literature: Literature, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.primaryLabel.text = literature.attributes.title

		// Configure poster
		literature.attributes.posterImage(imageView: self.posterImageView)

		self.applyPosterAspectRatio(widthToHeight: 2.0 / 3.0)
		self.posterContainerView?.layer.cornerRadius = 0
		self.posterImageView?.applyCornerRadius(0.0)
		self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
		self.posterImageView?.mask = self.literatureMask
		self.posterImageOverlayView.isHidden = false
		self.posterBorderView?.isHidden = true
	}

	/// Configure the cell with the given game's details.
	///
	/// - Parameters:
	///    - game: The game to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using game: Game, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.primaryLabel.text = game.attributes.title

		// Configure poster
		game.attributes.posterImage(imageView: self.posterImageView)

		self.applyPosterAspectRatio(widthToHeight: 1.0)
		self.posterContainerView?.layer.cornerRadius = 22
		self.posterImageView?.applyCornerRadius(22.0)
		self.posterImageView?.layer.borderWidth = 0
		self.posterImageView?.mask = nil
		self.posterImageOverlayView.isHidden = true
		self.posterBorderView?.isHidden = false
	}

	fileprivate func syncLiteratureMaskFrame() {
		guard self.posterImageView?.mask === self.literatureMask else { return }
		self.literatureMask.frame = self.posterImageView?.bounds ?? .zero
	}

	/// Replaces the poster container's aspect-ratio constraint with one using the supplied width-to-height multiplier.
	///
	/// - Parameter widthToHeight: The aspect-ratio to apply to the poster.
	private func applyPosterAspectRatio(widthToHeight: CGFloat) {
		guard
			let current = self.posterAspectRatioConstraint,
			let firstItem = current.firstItem,
			abs(current.multiplier - widthToHeight) > .ulpOfOne
		else { return }

		let replacement = NSLayoutConstraint(
			item: firstItem,
			attribute: current.firstAttribute,
			relatedBy: current.relation,
			toItem: current.secondItem,
			attribute: current.secondAttribute,
			multiplier: widthToHeight,
			constant: current.constant
		)
		replacement.priority = current.priority
		replacement.identifier = current.identifier

		current.isActive = false
		replacement.isActive = true
		self.posterAspectRatioConstraint = replacement
	}
}
