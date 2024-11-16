//
//  ReCapMilestoneCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2024.
//  Copyright © 2024 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class ReCapMilestoneCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!
	@IBOutlet weak var tertiaryLabel: KLabel!
	@IBOutlet weak var quaternaryLabel: KLabel!
	@IBOutlet weak var progressView: KCircularProgressView!

	// MARK: - Functions
	/// Configures the cell with the given `RecapItem` object.
	///
	/// - Parameters:
	///    - recapItem: The `RecapItem` object used to configure the cell.
	///    - milestoneKind: The kind of milestone to configure.
	func configure(using recapItem: RecapItem?, milestoneKind: MilestoneKind) {
		guard let recapItem = recapItem else {
			self.showSkeleton()
			return
		}
		self.hideSkeleton()

		self.contentView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.contentView.layerCornerRadius = 10.0

		self.primaryLabel.font = UIFont.preferredFont(forTextStyle: .title1).bold
		self.secondaryLabel.font = UIFont.preferredFont(forTextStyle: .title1).bold
		self.tertiaryLabel.font = UIFont.preferredFont(forTextStyle: .title1).bold
		self.quaternaryLabel.font = UIFont.preferredFont(forTextStyle: .title3).bold

		self.secondaryLabel.text = milestoneKind.stringValue
		self.quaternaryLabel.text = milestoneKind.unitValue

		switch milestoneKind {
		case .minuetsWatched:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsDuration)"
		case .episodesWatched:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsCount)"
		case .minuetsRead:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsDuration)"
		case .chaptersRead:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsCount)"
		case .minutesPlayed:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsDuration)"
		case .gamesPlayed:
			self.tertiaryLabel.text = "\(recapItem.attributes.totalPartsCount)"
		case .topPercentile:
			let topPercentile = String(format: "%.2f", recapItem.attributes.topPercentile)

			self.secondaryLabel.text = "You were in the top \(topPercentile) of \(recapItem.attributes.type) watchers this year."
			self.tertiaryLabel.text = "\(topPercentile)%"
			self.quaternaryLabel.text = "Top \(recapItem.attributes.type) Watcher"
		}

		self.progressView.lineWidth = 16.0
		self.progressView.defaultProgress = 1.0
		self.progressView.updateProgress(100.0)
	}
}
