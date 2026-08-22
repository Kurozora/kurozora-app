//
//  TrailerHeroCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A cell that gives one trailer the prominent placement above the grid.
class TrailerHeroCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - Views
	/// The title's banner.
	private let bannerView: BannerImageView = {
		let imageView = BannerImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	/// The view that plays the trailer.
	let trailerPlayerView: KTrailerPlayerView = {
		let trailerPlayerView = KTrailerPlayerView()
		trailerPlayerView.showsMuteToggle = true
		trailerPlayerView.translatesAutoresizingMaskIntoConstraints = false
		trailerPlayerView.layerCornerRadius = 22.0
		trailerPlayerView.layer.masksToBounds = true
		return trailerPlayerView
	}()

	/// The title the trailer belongs to.
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .title2).bold
		label.numberOfLines = 2
		return label
	}()

	/// The title's genres and when it lands.
	private let metaLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.numberOfLines = 1
		return label
	}()

	/// The button that puts the title in the library.
	private let statusButton: KTintedButton = {
		let button = KTintedButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .medium)
		button.layerCornerRadius = 15.0
		return button
	}()

	// MARK: - Properties
	/// The URL of the preferred trailer.
	var preferredTrailerURL: String?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.preferredTrailerURL = nil
		self.trailerPlayerView.stopTrailer()
	}

	/// The shared settings used to initialize the cell.
	private func sharedInit() {
		self.bannerImageView = self.bannerView
		self.bannerView.layerCornerRadius = 22.0
		self.primaryLabel = self.titleLabel
		self.secondaryLabel = self.metaLabel
		self.libraryStatusButton = self.statusButton
		self.statusButton.addTarget(self, action: #selector(self.chooseStatusButtonPressed(_:)), for: .touchUpInside)

		let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.metaLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 4.0

		self.contentView.addSubview(self.bannerView)
		self.contentView.addSubview(self.trailerPlayerView)
		self.contentView.addSubview(stackView)
		self.contentView.addSubview(self.statusButton)

		self.statusButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.statusButton.setContentHuggingPriority(.required, for: .horizontal)

		NSLayoutConstraint.activate([
			self.trailerPlayerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.trailerPlayerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.trailerPlayerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.trailerPlayerView.heightAnchor.constraint(equalTo: self.trailerPlayerView.widthAnchor, multiplier: 9.0 / 16.0),

			self.bannerView.topAnchor.constraint(equalTo: self.trailerPlayerView.topAnchor),
			self.bannerView.leadingAnchor.constraint(equalTo: self.trailerPlayerView.leadingAnchor),
			self.bannerView.trailingAnchor.constraint(equalTo: self.trailerPlayerView.trailingAnchor),
			self.bannerView.bottomAnchor.constraint(equalTo: self.trailerPlayerView.bottomAnchor),

			stackView.topAnchor.constraint(equalTo: self.trailerPlayerView.bottomAnchor, constant: 12.0),
			stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor),

			self.statusButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 8.0),
			self.statusButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.statusButton.topAnchor.constraint(equalTo: stackView.topAnchor),
			self.statusButton.heightAnchor.constraint(equalToConstant: 30.0),
			self.statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84.0)
		])
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let show = show else { return }

		self.metaLabel.text = show.attributes.trailerMetaLine
		self.trailerPlayerView.loadTrailer(fromURL: self.preferredTrailerURL ?? show.attributes.videoUrl)
	}

	override func configure(using game: Game?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: game, rank: rank, scheduleIsShown: scheduleIsShown)
		guard let game = game else { return }

		self.metaLabel.text = game.attributes.trailerMetaLine
		self.trailerPlayerView.loadTrailer(fromURL: self.preferredTrailerURL ?? game.attributes.videoUrl)
	}
}
