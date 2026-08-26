//
//  TrailerLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// Reports interactions with a trailer lockup cell.
protocol TrailerLockupCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the reader tapped the cell's trailer banner.
	///
	/// - Parameter cell: The cell whose banner was tapped.
	func trailerLockupCollectionViewCellDidSelectTrailer(_ cell: TrailerLockupCollectionViewCell)
}

/// A cell that leads with the trailer's banner and plays it in the featured player when tapped.
class TrailerLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - Views
	/// The title's banner.
	private let bannerView: BannerImageView = {
		let imageView = BannerImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		return imageView
	}()

	/// The control that features the trailer when the banner is tapped.
	private let bannerControl: UIControl = {
		let control = UIControl()
		control.translatesAutoresizingMaskIntoConstraints = false
		control.layerCornerRadius = 12.0
		control.layer.masksToBounds = true
		return control
	}()

	/// The glyph indicating the banner plays the trailer.
	private let playGlyphButton: KButton = {
		let button = KButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isUserInteractionEnabled = false
		button.highlightBackgroundColorEnabled = false
		button.springEnabled = true
		button.addBlurEffect()
		button.theme_tintColor = KThemePicker.textColor.rawValue
		button.layerCornerRadius = 24.0
		button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 20.0, weight: .semibold), forImageIn: .normal)
		button.setImage(UIImage(systemName: "play.fill"), for: .normal)
		return button
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

	/// The button that puts the title in the library.
	private let statusButton: KTintedButton = {
		let button = KTintedButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .medium)
		button.layerCornerRadius = 15.0
		return button
	}()

	// MARK: - Properties
	/// The object responsible for delegating trailer interactions.
	weak var trailerDelegate: TrailerLockupCollectionViewCellDelegate?

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
	/// Configures the cell's view hierarchy and layout.
	private func sharedInit() {
		self.bannerImageView = self.bannerView
		self.bannerView.layerCornerRadius = 12.0
		self.primaryLabel = self.titleLabel
		self.secondaryLabel = self.metaLabel
		self.libraryStatusButton = self.statusButton
		self.statusButton.addTarget(self, action: #selector(self.chooseStatusButtonPressed(_:)), for: .touchUpInside)
		self.bannerControl.addTarget(self, action: #selector(self.bannerTapped), for: .touchUpInside)

		let textStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.metaLabel])
		textStackView.translatesAutoresizingMaskIntoConstraints = false
		textStackView.axis = .vertical
		textStackView.spacing = 4.0

		self.contentView.addSubview(self.bannerView)
		self.contentView.addSubview(self.bannerControl)
		self.bannerControl.addSubview(self.playGlyphButton)
		self.contentView.addSubview(textStackView)
		self.contentView.addSubview(self.statusButton)

		self.statusButton.setContentCompressionResistancePriority(.required, for: .horizontal)
		self.statusButton.setContentHuggingPriority(.required, for: .horizontal)

		NSLayoutConstraint.activate([
			self.bannerControl.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.bannerControl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.bannerControl.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.bannerControl.heightAnchor.constraint(equalTo: self.bannerControl.widthAnchor, multiplier: 9.0 / 16.0),

			self.bannerView.topAnchor.constraint(equalTo: self.bannerControl.topAnchor),
			self.bannerView.leadingAnchor.constraint(equalTo: self.bannerControl.leadingAnchor),
			self.bannerView.trailingAnchor.constraint(equalTo: self.bannerControl.trailingAnchor),
			self.bannerView.bottomAnchor.constraint(equalTo: self.bannerControl.bottomAnchor),

			self.playGlyphButton.centerXAnchor.constraint(equalTo: self.bannerControl.centerXAnchor),
			self.playGlyphButton.centerYAnchor.constraint(equalTo: self.bannerControl.centerYAnchor),
			self.playGlyphButton.widthAnchor.constraint(equalToConstant: 48.0),
			self.playGlyphButton.heightAnchor.constraint(equalToConstant: 48.0),

			textStackView.topAnchor.constraint(equalTo: self.bannerControl.bottomAnchor, constant: 12.0),
			textStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			textStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.statusButton.leadingAnchor.constraint(equalTo: textStackView.trailingAnchor, constant: 8.0),
			self.statusButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.statusButton.topAnchor.constraint(equalTo: textStackView.topAnchor),
			self.statusButton.heightAnchor.constraint(equalToConstant: 30.0),
			self.statusButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 84.0)
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

	/// Updates the banner glyph to reflect whether the trailer is playing.
	///
	/// - Parameter isPlaying: Whether the trailer is playing in the featured player.
	func setPlaying(_ isPlaying: Bool) {
		self.playGlyphButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
	}

	/// Notifies the delegate that the banner was tapped.
	@objc private func bannerTapped() {
		self.trailerDelegate?.trailerLockupCollectionViewCellDidSelectTrailer(self)
	}
}
