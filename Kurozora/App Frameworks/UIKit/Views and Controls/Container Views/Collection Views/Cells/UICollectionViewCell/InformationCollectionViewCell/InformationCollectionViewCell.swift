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
	@IBOutlet weak var typeImageView: UIImageView?
	@IBOutlet weak var typeLabel: KSecondaryLabel!
	@IBOutlet weak var headlineLabel: KLabel!
	@IBOutlet weak var primaryLabel: KLabel? // Make explicit
	@IBOutlet weak var primaryImageView: UIImageView? // Make explicit
	@IBOutlet weak var secondaryLabel: KLabel? // Make explicit
	@IBOutlet weak var footerLabel: KSecondaryLabel? // Make explicit
	@IBOutlet weak var separatorView: SecondarySeparatorView? // Remove

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

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		self.typeImageView?.theme_tintColor = KThemePicker.subTextColor.rawValue
		self.primaryImageView?.theme_tintColor = KThemePicker.textColor.rawValue
	}

	// MARK: - Functions
	/// The shared settings used to initialize the cell.
	fileprivate func sharedInit() {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.cornerRadius = 8
	}

	/// Configure the cell with the given person details.
	fileprivate func configureCellWithPerson() {
		typeLabel.text = self.personDetailsInformationSection.stringValue
		headlineLabel.text = self.personDetailsInformationSection.information(from: self.person)
		separatorView?.isHidden = self.personDetailsInformationSection == .givenName
	}

	/// Configure the cell with the given character details.
	fileprivate func configureCellWithCharacter() {
		typeLabel.text = self.characterInformationSection.stringValue
		headlineLabel.text = self.characterInformationSection.information(from: self.character)
		separatorView?.isHidden = self.characterInformationSection == .astrologicalSign
	}

	/// Configure the cell with the given episode details.
	fileprivate func configureCellWithEpisode() {
		typeLabel.text = self.episodeDetailInformation.stringValue
		headlineLabel.text = self.episodeDetailInformation.information(from: self.episode)
		separatorView?.isHidden = self.episodeDetailInformation == .airDate
	}

	/// Configure the cell with the given show details.
	fileprivate func configureCellWithShow() {
		typeImageView?.image = self.showDetailInformation.imageValue
		typeLabel.text = self.showDetailInformation.stringValue
		headlineLabel.text = self.showDetailInformation.information(from: self.show)
		primaryLabel?.text = self.showDetailInformation.primaryInformation(from: self.show)
		primaryImageView?.image = self.showDetailInformation.primaryImage(from: self.show)
		secondaryLabel?.text = self.showDetailInformation.secondaryInformation(from: self.show)
		footerLabel?.text = self.showDetailInformation.footnote(from: self.show)

		switch self.showDetailInformation {
		case .aireDates:
			secondaryLabel?.textAlignment = .right
			secondaryLabel?.font = .preferredFont(forTextStyle: .headline)
		default:
			secondaryLabel?.textAlignment = .natural
			secondaryLabel?.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given studio details.
	fileprivate func configureCellWithStudio() {
		typeLabel.text = self.studioDetailsInformationSection.stringValue
		headlineLabel.text = self.studioDetailsInformationSection.information(from: self.studio)
		separatorView?.isHidden = self.studioDetailsInformationSection == .website
	}
}
