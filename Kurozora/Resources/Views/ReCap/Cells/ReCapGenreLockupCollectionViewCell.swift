//
//  ReCapGenreLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

/// A gradient card listing the top genres or themes of a Re:CAP.
final class ReCapGenreLockupCollectionViewCell: KCollectionViewCell {
	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	/// The number of names the card lists.
	static let maximumNameCount = 5

	/// The corner radius of the card.
	private static let cornerRadius: CGFloat = ReCapCardCollectionViewCell.cornerRadius

	/// The height the gradient is laid out for relative to the card's width.
	private static let gradientHeightRatio: CGFloat = 0.67

	/// The page width whose gradient metrics the card uses.
	private static let gradientPageWidth: CGFloat = 1280.0

	/// Called with the index of the selected name.
	var nameSelectedHandler: ((Int) -> Void)?

	/// The context menus of the listed names.
	let contextMenuHandler = ReCapContextMenuHandler()

	/// The page width the blobs were configured for.
	private var configuredPageWidth: CGFloat = 0.0

	// MARK: - Views
	private let cardView = UIView()

	private let backgroundGradientView = GradientView()

	private let blobsView = ReCapGradientView()

	private let namesStackView = UIStackView()

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
		self.contentView.layoutIfNeeded()

		let pageWidth = Self.gradientPageWidth
		let cardBounds = self.cardView.bounds

		if cardBounds.width > 0.0, cardBounds.height > 0.0 {
			let points = ReCapGradientView.gradientPoints(in: cardBounds, angle: 135.0)
			self.backgroundGradientView.gradientLayer?.startPoint = CGPoint(x: points.start.x / cardBounds.width, y: points.start.y / cardBounds.height)
			self.backgroundGradientView.gradientLayer?.endPoint = CGPoint(x: points.end.x / cardBounds.width, y: points.end.y / cardBounds.height)
		}

		self.blobsView.frame = cardBounds

		guard pageWidth != self.configuredPageWidth else { return }
		self.configuredPageWidth = pageWidth
		self.blobsView.blurRadius = { _ in ReCapGradientView.genreCardBlurRadius(pageWidth: pageWidth) }
		self.blobsView.blobs = ReCapGradientView.genreCard(pageWidth: pageWidth)
	}

	// MARK: - Functions
	private func sharedInit() {
		self.cardView.clipsToBounds = true
		self.cardView.layer.cornerRadius = Self.cornerRadius
		self.cardView.layer.cornerCurve = .continuous
		self.cardView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.cardView)

		self.backgroundGradientView.translatesAutoresizingMaskIntoConstraints = false
		self.cardView.addSubview(self.backgroundGradientView)
		self.backgroundGradientView.fillToSuperview()

		self.blobsView.brightness = 0.95
		self.blobsView.referenceHeight = { $0.width * Self.gradientHeightRatio }
		self.cardView.addSubview(self.blobsView)

		self.namesStackView.axis = .vertical
		self.namesStackView.spacing = 12.0
		self.namesStackView.alignment = .leading
		self.namesStackView.translatesAutoresizingMaskIntoConstraints = false
		self.cardView.addSubview(self.namesStackView)

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.namesStackView.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 20.0),
			self.namesStackView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 20.0),
			self.namesStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.cardView.trailingAnchor, constant: -20.0),
			self.namesStackView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -48.0),
		])
	}

	/// Configures the card with the given names and recap colors.
	///
	/// - Parameters:
	///    - names: The names of the top genres or themes.
	///    - colors: The recap colors the card is painted with.
	func configure(using names: [String], colors: [UIColor]) {
		self.backgroundGradientView.backgroundColors = colors.map(\.cgColor)
		self.blobsView.colors = colors

		let isLight = colors.allSatisfy(\.isLight)
		let textColor: UIColor = isLight ? UIColor.black.withAlphaComponent(0.55) : UIColor.white.withAlphaComponent(0.94)

		self.namesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

		for (index, name) in names.prefix(Self.maximumNameCount).enumerated() {
			let rankLabel = UILabel()
			rankLabel.text = "\(index + 1)"
			rankLabel.font = UIFont.preferredFont(forTextStyle: .title2).semibold
			rankLabel.textColor = textColor
			rankLabel.isAccessibilityElement = false
			rankLabel.widthAnchor.constraint(equalToConstant: 24.0).isActive = true

			let nameLabel = UILabel()
			nameLabel.text = name
			nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
			nameLabel.textColor = textColor
			nameLabel.lineBreakMode = .byClipping

			let rowStackView = UIStackView(arrangedSubviews: [rankLabel, nameLabel])
			rowStackView.axis = .horizontal
			rowStackView.alignment = .center
			rowStackView.spacing = 16.0
			rowStackView.alpha = 1.0 - CGFloat(index) * 0.12
			rowStackView.tag = index
			rowStackView.isAccessibilityElement = true
			rowStackView.accessibilityLabel = name
			rowStackView.accessibilityTraits = .button
			rowStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nameTapped(_:))))
			self.contextMenuHandler.addInteraction(to: rowStackView, index: index)

			self.namesStackView.addArrangedSubview(rowStackView)
		}
	}

	@objc private func nameTapped(_ sender: UITapGestureRecognizer) {
		guard let index = sender.view?.tag else { return }
		self.nameSelectedHandler?(index)
	}
}
