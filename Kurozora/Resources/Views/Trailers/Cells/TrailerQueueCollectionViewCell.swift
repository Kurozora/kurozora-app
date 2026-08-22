//
//  TrailerQueueCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A cell that lists a trailer waiting behind the one being played.
class TrailerQueueCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - Views
	/// The title's banner.
	private let bannerView: BannerImageView = {
		let imageView = BannerImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layerCornerRadius = 8.0
		return imageView
	}()

	/// The title the trailer belongs to.
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .subheadline).semibold
		label.numberOfLines = 2
		return label
	}()

	/// The title's genres and when it lands.
	private let metaLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption1)
		label.numberOfLines = 1
		return label
	}()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.primaryLabel = self.titleLabel
		self.secondaryLabel = self.metaLabel
		self.bannerImageView = self.bannerView

		let textStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.metaLabel])
		textStackView.translatesAutoresizingMaskIntoConstraints = false
		textStackView.axis = .vertical
		textStackView.spacing = 4.0

		self.contentView.addSubview(self.bannerView)
		self.contentView.addSubview(textStackView)

		self.bannerView.setContentCompressionResistancePriority(.required, for: .horizontal)

		NSLayoutConstraint.activate([
			self.bannerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.bannerView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.bannerView.widthAnchor.constraint(equalToConstant: 112.0),
			self.bannerView.heightAnchor.constraint(equalTo: self.bannerView.widthAnchor, multiplier: 9.0 / 16.0),
			self.bannerView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor),

			textStackView.leadingAnchor.constraint(equalTo: self.bannerView.trailingAnchor, constant: 12.0),
			textStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			textStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			textStackView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor)
		])
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let show = show else { return }

		self.metaLabel.text = show.attributes.trailerMetaLine
	}

	override func configure(using game: Game?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: game, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let game = game else { return }

		self.metaLabel.text = game.attributes.trailerMetaLine
	}
}
