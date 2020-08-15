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
	@IBOutlet weak var titleLabel: KSecondaryLabel!
	@IBOutlet weak var detailLabel: KCopyableLabel!
	@IBOutlet weak var separatorView: SecondarySeparatorView!

	// MARK: - Properties
	var showDetailInformation: ShowDetail.Information = .id
	var episodeDetailInformation: EpisodeDetail.Information = .id
	var studioInformationSection: StudioInformationSection = .founded

	var episode: Episode! {
		didSet {
			configureCellWithEpisodeElement()
		}
	}
	var show: Show! {
		didSet {
			configureCell()
		}
	}
	var studio: Studio! {
		didSet {
			configureCellWithStudioElement()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		titleLabel.text = showDetailInformation.stringValue
		detailLabel.text = showDetailInformation.information(from: show)
		separatorView.isHidden = showDetailInformation == .duration
	}

	fileprivate func configureCellWithEpisodeElement() {
		titleLabel.text = episodeDetailInformation.stringValue
		detailLabel.text = episodeDetailInformation.information(from: episode)
		separatorView.isHidden = episodeDetailInformation == .airDate
	}

	fileprivate func configureCellWithStudioElement() {
		titleLabel.text = studioInformationSection.stringValue
		detailLabel.text = studioInformationSection.information(from: studio)
		separatorView.isHidden = studioInformationSection == .website
	}
}
