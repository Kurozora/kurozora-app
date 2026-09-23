//
//  ReCapMilestoneCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/01/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// A card showing a milestone of a Re:CAP.
final class ReCapMilestoneCollectionViewCell: ReCapCardCollectionViewCell {
	// MARK: - Properties
	override var surface: Surface {
		return .blur
	}

	/// The diameter of the ring.
	private static let ringDiameter: CGFloat = 232.0

	/// The height of the artwork strip.
	private static let artworkStripHeight: CGFloat = 160.0

	/// The space between the artworks of the strip.
	private static let artworkSpacing: CGFloat = 16.0

	// MARK: - Views
	private let titleLabel = UILabel()

	private let subtitleLabel = UILabel()

	private let ringView = ReCapMilestoneRingView()

	private let countLabel = UILabel()

	private let unitLabel = UILabel()

	private let artworkStripView = UIView()

	private var artworkImageViews: [PosterImageView] = []

	private var artworkStripHeightConstraint: NSLayoutConstraint!

	private var artworkStripBottomConstraint: NSLayoutConstraint!

	/// The artwork the strip shows.
	private var artworkStyle: ReCapMilestone.ArtworkStyle = .none

	/// Called with the index of the selected artwork.
	var artworkSelectedHandler: ((Int) -> Void)?

	/// The context menus of the artworks.
	let contextMenuHandler = ReCapContextMenuHandler()

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureView()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureView()
	}

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.layoutIfNeeded()
		self.layoutArtworks()
	}

	// MARK: - Functions
	private func configureView() {
		self.titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.titleLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.titleLabel.text = L10n.recapMilestone
		self.subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.subtitleLabel.theme_textColor = KThemePicker.subTextColor.rawValue
		self.subtitleLabel.numberOfLines = 0

		self.countLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
		self.countLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.countLabel.textAlignment = .center
		self.countLabel.adjustsFontSizeToFitWidth = true
		self.unitLabel.font = UIFont.preferredFont(forTextStyle: .body).semibold
		self.unitLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.unitLabel.textAlignment = .center
		self.unitLabel.numberOfLines = 2

		let headerStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.subtitleLabel])
		headerStackView.axis = .vertical
		headerStackView.translatesAutoresizingMaskIntoConstraints = false

		let ringLabelsStackView = UIStackView(arrangedSubviews: [self.countLabel, self.unitLabel])
		ringLabelsStackView.axis = .vertical
		ringLabelsStackView.alignment = .center
		ringLabelsStackView.translatesAutoresizingMaskIntoConstraints = false

		self.ringView.translatesAutoresizingMaskIntoConstraints = false
		self.ringView.isAccessibilityElement = true
		self.ringView.accessibilityTraits = .staticText
		self.ringView.addSubview(ringLabelsStackView)

		self.artworkStripView.translatesAutoresizingMaskIntoConstraints = false

		self.cardView.addSubview(headerStackView)
		self.cardView.addSubview(self.ringView)
		self.cardView.addSubview(self.artworkStripView)

		self.artworkStripHeightConstraint = self.artworkStripView.heightAnchor.constraint(equalToConstant: Self.artworkStripHeight)
		self.artworkStripBottomConstraint = self.artworkStripView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -16.0)

		NSLayoutConstraint.activate([
			headerStackView.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 16.0),
			headerStackView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 16.0),
			headerStackView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -16.0),

			self.ringView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 24.0),
			self.ringView.centerXAnchor.constraint(equalTo: self.cardView.centerXAnchor),
			self.ringView.widthAnchor.constraint(equalToConstant: Self.ringDiameter),
			self.ringView.heightAnchor.constraint(equalToConstant: Self.ringDiameter),

			ringLabelsStackView.centerYAnchor.constraint(equalTo: self.ringView.centerYAnchor),
			ringLabelsStackView.leadingAnchor.constraint(equalTo: self.ringView.leadingAnchor, constant: 48.0),
			ringLabelsStackView.trailingAnchor.constraint(equalTo: self.ringView.trailingAnchor, constant: -48.0),

			self.artworkStripView.topAnchor.constraint(equalTo: self.ringView.bottomAnchor, constant: 24.0),
			self.artworkStripView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor),
			self.artworkStripView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor),
			self.artworkStripHeightConstraint,
			self.artworkStripBottomConstraint,
		])
	}

	/// Configures the card with the given milestone.
	///
	/// - Parameter milestone: The milestone the card shows.
	func configure(using milestone: ReCapMilestone) {
		self.subtitleLabel.text = milestone.subtitle
		self.countLabel.text = milestone.count
		self.unitLabel.text = milestone.unit
		self.ringView.accessibilityLabel = "\(milestone.count) \(milestone.unit)"

		self.artworkStyle = milestone.artworkStyle
		self.artworkImageViews.forEach { $0.removeFromSuperview() }
		self.contextMenuHandler.previewCornerRadius = milestone.artworkStyle == .squares ? 24.0 : 8.0
		self.artworkImageViews = milestone.artworks.enumerated().map { index, artwork in
			let imageView = PosterImageView(frame: .zero)
			imageView.contentMode = .scaleAspectFill
			imageView.clipsToBounds = true
			imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.artworkTapped(_:))))
			self.contextMenuHandler.addInteraction(to: imageView, index: index)
			imageView.layer.borderWidth = 0.0
			imageView.applyCornerRadius(milestone.artworkStyle == .squares ? 24.0 : 8.0)
			imageView.backgroundColor = artwork.backgroundColor.flatMap { UIColor(hexString: $0) }
			artwork.setImage(imageView)

			let borderView = BorderView()
			borderView.cornerRadius = milestone.artworkStyle == .squares ? 24.0 : 8.0
			borderView.translatesAutoresizingMaskIntoConstraints = false
			imageView.addSubview(borderView)
			borderView.fillToSuperview()

			self.artworkStripView.addSubview(imageView)
			return imageView
		}

		let hasArtwork = !self.artworkImageViews.isEmpty
		self.artworkStripView.isHidden = !hasArtwork
		self.artworkStripHeightConstraint.constant = hasArtwork ? Self.artworkStripHeight : 0.0
		self.artworkStripBottomConstraint.constant = hasArtwork ? -16.0 : -4.0
		self.setNeedsLayout()
	}

	@objc private func artworkTapped(_ sender: UITapGestureRecognizer) {
		guard let index = sender.view?.tag else { return }
		self.artworkSelectedHandler?(index)
	}

	/// Places the artworks along the bottom of the strip.
	private func layoutArtworks() {
		let count = CGFloat(self.artworkImageViews.count)
		guard count > 0 else { return }

		let cardWidth = self.cardView.bounds.width
		let posterWidth = (cardWidth * 1.47 - Self.artworkSpacing * 3.0) / 4.0
		let itemHeight = max(posterWidth * 4.23 / 3.0, 108.0)
		let aspectRatio: CGFloat

		switch self.artworkStyle {
		case .posters:
			aspectRatio = 3.0 / 4.23
		case .banners:
			aspectRatio = 16.0 / 9.0
		case .squares:
			aspectRatio = 1.0
		case .none:
			return
		}

		let itemWidth = itemHeight * aspectRatio
		let rowWidth = itemWidth * count + Self.artworkSpacing * (count - 1.0)
		let originX = (cardWidth - rowWidth) / 2.0
		let stripHeight = self.artworkStripView.bounds.height

		for (index, imageView) in self.artworkImageViews.enumerated() {
			let x = originX + CGFloat(index) * (itemWidth + Self.artworkSpacing)
			imageView.frame = CGRect(x: x, y: max(stripHeight - itemHeight, 0.0), width: itemWidth, height: itemHeight)
		}
	}
}

// MARK: - ReCapMilestoneRingView
/// The ring drawn around the count of a milestone.
private final class ReCapMilestoneRingView: UIView {
	// MARK: - Properties
	/// The thickness of the ring relative to its diameter.
	private static let lineWidthRatio: CGFloat = 60.5 / 864.5

	private let baseLayer = CAShapeLayer()

	private let sweepLayer = CALayer()

	private let sweepGradientLayer = CAGradientLayer()

	private let sweepMaskLayer = CAShapeLayer()

	/// The layer that keeps the cap's shadow inside the ring.
	private let capContainerLayer = CALayer()

	private let capMaskLayer = CAShapeLayer()

	/// The rounded end of the sweep that casts a shadow onto the ring.
	private let capLayer = CAShapeLayer()

	/// The offset of the cap's shadow relative to the ring's thickness.
	private static let capShadowOffsetRatio: CGFloat = 21.0 / 60.5

	/// The blur of the cap's shadow relative to the ring's thickness.
	private static let capShadowRadiusRatio: CGFloat = 14.5 / 60.5

	/// The location along the sweep where its fade begins.
	private var fadeStartLocation: CGFloat = 0.0

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
	override func layoutSubviews() {
		super.layoutSubviews()

		let lineWidth = self.bounds.width * Self.lineWidthRatio
		let radius = (min(self.bounds.width, self.bounds.height) - lineWidth) / 2.0
		let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
		let startAngle = -CGFloat.pi / 3.0
		let ringPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
		let sweepPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: startAngle + .pi * 1.845, clockwise: true)

		self.baseLayer.frame = self.bounds
		self.baseLayer.path = ringPath.cgPath
		self.baseLayer.lineWidth = lineWidth

		self.sweepLayer.frame = self.bounds
		self.sweepGradientLayer.frame = self.bounds
		let capAngle = radius > 0.0 ? (lineWidth / 2.0) / radius : 0.0
		let gradientAngle = startAngle - capAngle * 1.5
		self.sweepGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
		self.sweepGradientLayer.endPoint = CGPoint(x: 0.5 + cos(gradientAngle) * 0.5, y: 0.5 + sin(gradientAngle) * 0.5)
		self.fadeStartLocation = capAngle * 3.0 / (.pi * 2.0)
		self.sweepMaskLayer.frame = self.bounds
		self.sweepMaskLayer.path = sweepPath.cgPath
		self.sweepMaskLayer.lineWidth = lineWidth

		let endAngle = startAngle + .pi * 1.845
		let endPoint = CGPoint(x: center.x + cos(endAngle) * radius, y: center.y + sin(endAngle) * radius)
		let tangent = CGPoint(x: -sin(endAngle), y: cos(endAngle))
		self.capContainerLayer.frame = self.bounds
		self.capMaskLayer.frame = self.bounds
		self.capMaskLayer.path = ringPath.cgPath
		self.capMaskLayer.lineWidth = lineWidth
		self.capLayer.frame = self.bounds
		self.capLayer.path = UIBezierPath(arcCenter: endPoint, radius: lineWidth / 2.0, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true).cgPath
		self.capLayer.shadowOffset = CGSize(width: tangent.x * lineWidth * Self.capShadowOffsetRatio, height: tangent.y * lineWidth * Self.capShadowOffsetRatio)
		self.capLayer.shadowRadius = lineWidth * Self.capShadowRadiusRatio

		self.updateSweepColors()
	}

	/// Paints the sweep with the tint color fading in from its start.
	private func updateSweepColors() {
		let tintColor = KThemePicker.tintColor.colorValue
		self.sweepGradientLayer.colors = [tintColor.withAlphaComponent(0.0).cgColor, tintColor.withAlphaComponent(0.0).cgColor, tintColor.cgColor, tintColor.cgColor]
		self.sweepGradientLayer.locations = [0.0, NSNumber(value: self.fadeStartLocation), NSNumber(value: self.fadeStartLocation + 0.12), 1.0]
	}

	// MARK: - Functions
	private func sharedInit() {
		self.isUserInteractionEnabled = false

		self.baseLayer.fillColor = UIColor.clear.cgColor
		self.baseLayer.theme_strokeColor = KThemePicker.tintColor.cgColorPicker

		self.sweepMaskLayer.fillColor = UIColor.clear.cgColor
		self.sweepMaskLayer.strokeColor = UIColor.black.cgColor
		self.sweepMaskLayer.lineCap = .round

		self.sweepGradientLayer.type = .conic
		self.sweepGradientLayer.mask = self.sweepMaskLayer

		self.sweepLayer.addSublayer(self.sweepGradientLayer)

		self.capMaskLayer.fillColor = UIColor.clear.cgColor
		self.capMaskLayer.strokeColor = UIColor.black.cgColor
		self.capLayer.theme_fillColor = KThemePicker.tintColor.cgColorPicker
		self.capLayer.shadowColor = UIColor(red: 0.573, green: 0.373, blue: 0.373, alpha: 1.0).cgColor
		self.capLayer.shadowOpacity = 1.0
		self.capContainerLayer.mask = self.capMaskLayer
		self.capContainerLayer.addSublayer(self.capLayer)

		self.layer.addSublayer(self.baseLayer)
		self.layer.addSublayer(self.sweepLayer)
		self.layer.addSublayer(self.capContainerLayer)
	}
}
