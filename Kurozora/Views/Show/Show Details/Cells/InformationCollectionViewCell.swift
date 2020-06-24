//
//  InformationCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/08/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class InformationCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KSecondarText!
	@IBOutlet weak var detailLabel: KCopyableLabel!
	@IBOutlet weak var separatorView: SecondarySeparatorView!

	// MARK: - Properties
	var episodeElement: EpisodeElement? {
		didSet {
			configureCell()
		}
	}
	var showDetailsElement: ShowDetailsElement? {
		didSet {
			configureCell()
		}
	}
	var studioElement: StudioElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let showDetailsElement = showDetailsElement else {
			configureCellWithEpisodeElement()
			return
		}
		guard let showDetailInformation = ShowDetail.Information(rawValue: indexPath?.row ?? 0) else { return }

		titleLabel.text = showDetailInformation.stringValue
		detailLabel.text = showDetailInformation.information(from: showDetailsElement)
		separatorView.isHidden = showDetailInformation == .languages
	}

	fileprivate func configureCellWithEpisodeElement() {
		guard let episodeElement = episodeElement else {
			configureCellWithStudioElement()
			return
		}
		guard let episodeDetailInformation = EpisodeDetail.Information(rawValue: indexPath?.row ?? 0) else { return }

		titleLabel.text = episodeDetailInformation.stringValue
		detailLabel.text = episodeDetailInformation.information(from: episodeElement)
		separatorView.isHidden = episodeDetailInformation == .airDate
	}

	fileprivate func configureCellWithStudioElement() {
		guard let studioElement = studioElement else { return }
		guard let studioInformationSection = StudioInformationSection(rawValue: indexPath?.row ?? 0) else { return }

		titleLabel.text = studioInformationSection.stringValue
		detailLabel.text = studioInformationSection.information(from: studioElement)
		separatorView.isHidden = studioInformationSection == .website
	}
}
