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
	var actorDetailsInformationSection: ActorDetailsInformationSection = .occupation
	var characterInformationSection: CharacterInformationSection = .debut
	var episodeDetailInformation: EpisodeDetail.Information = .id
	var showDetailInformation: ShowDetail.Information = .id
	var studioInformationSection: StudioInformationSection = .founded

	var actor: Actor! {
		didSet {
			configureCellWithActor()
		}
	}
	var character: Character! {
		didSet {
			configureCellWithCharacter()
		}
	}
	var episode: Episode! {
		didSet {
			configureCellWithEpisode()
		}
	}
	var show: Show! {
		didSet {
			configureCellWithShow()
		}
	}
	var studio: Studio! {
		didSet {
			configureCellWithStudio()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given actor details.
	fileprivate func configureCellWithActor() {
		titleLabel.text = self.actorDetailsInformationSection.stringValue
		detailLabel.text = self.actorDetailsInformationSection.information(from: self.actor)
		separatorView.isHidden = self.actorDetailsInformationSection == .occupation
	}

	/// Configure the cell with the given character details.
	fileprivate func configureCellWithCharacter() {
		titleLabel.text = self.characterInformationSection.stringValue
		detailLabel.text = self.characterInformationSection.information(from: self.character)
		separatorView.isHidden = self.characterInformationSection == .astrologicalSign
	}

	/// Configure the cell with the given episode details.
	fileprivate func configureCellWithEpisode() {
		titleLabel.text = self.episodeDetailInformation.stringValue
		detailLabel.text = self.episodeDetailInformation.information(from: self.episode)
		separatorView.isHidden = self.episodeDetailInformation == .airDate
	}

	/// Configure the cell with the given show details.
	fileprivate func configureCellWithShow() {
		titleLabel.text = self.showDetailInformation.stringValue
		detailLabel.text = self.showDetailInformation.information(from: self.show)
		separatorView.isHidden = self.showDetailInformation == .duration
	}

	/// Configure the cell with the given studio details.
	fileprivate func configureCellWithStudio() {
		titleLabel.text = self.studioInformationSection.stringValue
		detailLabel.text = self.studioInformationSection.information(from: self.studio)
		separatorView.isHidden = self.studioInformationSection == .website
	}
}
