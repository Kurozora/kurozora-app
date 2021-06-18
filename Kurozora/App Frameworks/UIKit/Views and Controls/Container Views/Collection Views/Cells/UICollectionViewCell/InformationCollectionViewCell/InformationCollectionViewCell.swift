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
	var personDetailsInformationSection: PersonDetailsInformationSection = .givenName
	var characterInformationSection: CharacterInformationSection = .debut
	var episodeDetailInformation: EpisodeDetail.Information = .number
	var showDetailInformation: ShowDetail.Information = .type
	var studioDetailsInformationSection: StudioDetailsInformationSection = .founded

	var person: Person! {
		didSet {
			configureCellWithPerson()
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
	/// Configure the cell with the given person details.
	fileprivate func configureCellWithPerson() {
		titleLabel.text = self.personDetailsInformationSection.stringValue
		detailLabel.text = self.personDetailsInformationSection.information(from: self.person)
		separatorView.isHidden = self.personDetailsInformationSection == .givenName
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
		titleLabel.text = self.studioDetailsInformationSection.stringValue
		detailLabel.text = self.studioDetailsInformationSection.information(from: self.studio)
		separatorView.isHidden = self.studioDetailsInformationSection == .website
	}
}
