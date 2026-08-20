//
//  ReviewRevisionCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import Cosmos
import KurozoraKit
import UIKit

/// A row that shows one superseded version of a review.
class ReviewRevisionCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	private let cosmosView: KCosmosView = {
		var settings = CosmosSettings()
		settings.updateOnTouch = false

		let cosmosView = KCosmosView(frame: .zero, settings: settings)
		cosmosView.translatesAutoresizingMaskIntoConstraints = false
		return cosmosView
	}()

	private let metadataLabel: KTintedLabel = {
		let label = KTintedLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .caption1).bold
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	private let bodyLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .footnote)
		label.adjustsFontForContentSizeCategory = true
		label.numberOfLines = 0
		return label
	}()

	private let spoilerOverlayView = SpoilerOverlayView()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}

	/// Whether the reader revealed this version's spoiler.
	private var isSpoilerRevealed = false

	private static var spoilerWarningText: String {
		#if targetEnvironment(macCatalyst)
		return L10n.reviewSpoilerClick
		#else
		return L10n.reviewSpoilerTap
		#endif
	}

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.configureSubviews()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.configureSubviews()
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()
		self.isSpoilerRevealed = false
	}

	// MARK: - Functions
	/// Configures the cell with one superseded version of a review.
	///
	/// - Parameter revision: The version to show.
	func configure(using revision: ReviewRevision) {
		self.cosmosView.settings.starSize = UIFont.preferredFont(forTextStyle: .caption1).pointSize
		self.cosmosView.rating = revision.attributes.score

		self.metadataLabel.text = self.metadataText(for: revision)
		self.bodyLabel.attributedText = revision.attributes.description.markdownAttributedString()

		self.spoilerOverlayView.configure(warning: Self.spoilerWarningText, cornerRadius: self.layerCornerRadius)
		self.spoilerOverlayView.isHidden = self.isSpoilerRevealed || !revision.attributes.isSpoiler
	}

	/// Builds the recommendation, progress and date line shown above a version's body.
	///
	/// - Parameter revision: The version to build the line from.
	///
	/// - Returns: The joined line.
	private func metadataText(for revision: ReviewRevision) -> String {
		var parts: [String] = []

		if let recommendation = revision.attributes.recommendation {
			parts.append(recommendation.localizedName)
		}

		if let progress = revision.attributes.progress {
			if let progressTotal = revision.attributes.progressTotal {
				parts.append(L10n.reviewProgressEpisode("\(progress)", "\(progressTotal)"))
			} else {
				parts.append(L10n.reviewProgressEpisodeOnly("\(progress)"))
			}
		}

		parts.append(revision.attributes.writtenAt.formatted(date: .abbreviated, time: .omitted))

		return parts.joined(separator: " · ")
	}

	private func configureSubviews() {
		let headerStackView = UIStackView(arrangedSubviews: [self.cosmosView, self.metadataLabel, UIView()])
		headerStackView.axis = .horizontal
		headerStackView.spacing = UIStackView.spacingUseSystem
		headerStackView.alignment = .center

		let contentStackView = UIStackView(arrangedSubviews: [headerStackView, self.bodyLabel])
		contentStackView.axis = .vertical
		contentStackView.spacing = UIStackView.spacingUseSystem
		contentStackView.translatesAutoresizingMaskIntoConstraints = false

		self.contentView.addSubview(contentStackView)
		self.contentView.addSubview(self.spoilerOverlayView)

		NSLayoutConstraint.activate([
			contentStackView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			contentStackView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			contentStackView.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
			contentStackView.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor),

			self.spoilerOverlayView.topAnchor.constraint(equalTo: self.bodyLabel.topAnchor),
			self.spoilerOverlayView.bottomAnchor.constraint(equalTo: self.bodyLabel.bottomAnchor),
			self.spoilerOverlayView.leadingAnchor.constraint(equalTo: self.bodyLabel.leadingAnchor),
			self.spoilerOverlayView.trailingAnchor.constraint(equalTo: self.bodyLabel.trailingAnchor)
		])

		self.spoilerOverlayView.revealHandler = { [weak self] in
			self?.isSpoilerRevealed = true
		}
	}
}
