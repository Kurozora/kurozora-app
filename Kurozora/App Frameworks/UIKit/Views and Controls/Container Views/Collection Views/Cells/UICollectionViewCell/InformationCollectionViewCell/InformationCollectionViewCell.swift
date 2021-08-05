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
	@IBOutlet weak var typeImageView: UIImageView!
	@IBOutlet weak var typeLabel: KSecondaryLabel!
	@IBOutlet weak var headlineLabel: KLabel!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var primaryImageView: UIImageView!
	@IBOutlet weak var secondaryLabel: KLabel!
	@IBOutlet weak var footerLabel: KSecondaryLabel!
	@IBOutlet weak var primaryImageViewHeightConstraint: NSLayoutConstraint?

	// MARK: - Properties
	var personDetailInformation: PersonDetail.Information = .aliases
	var characterDetailInformation: CharacterDetail.Information = .debut
	var episodeDetailInformation: EpisodeDetail.Information = .number
	var showDetailInformation: ShowDetail.Information = .type
	var studioDetailInformation: StudioDetail.Information = .founded

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
		typeImageView.image = self.personDetailInformation.imageValue
		typeLabel.text = self.personDetailInformation.stringValue
		headlineLabel.text = self.personDetailInformation.information(from: self.person)
		primaryLabel.text = self.personDetailInformation.primaryInformation(from: self.person)
		primaryImageView.image = self.personDetailInformation.primaryImage(from: self.person)
		secondaryLabel.text = self.personDetailInformation.secondaryInformation(from: self.person)
		footerLabel.text = self.personDetailInformation.footnote(from: self.person)

		// Configure image view height constraint
		primaryImageViewHeightConstraint?.isActive = false
		self.layoutIfNeeded()
	}

	/// Configure the cell with the given character details.
	fileprivate func configureCellWithCharacter() {
		typeImageView.image = self.characterDetailInformation.imageValue
		typeLabel.text = self.characterDetailInformation.stringValue
		headlineLabel.text = self.characterDetailInformation.information(from: self.character)
		primaryLabel.text = self.characterDetailInformation.primaryInformation(from: self.character)
		primaryImageView.image = self.characterDetailInformation.primaryImage(from: self.character)
		secondaryLabel.text = self.characterDetailInformation.secondaryInformation(from: self.character)
		footerLabel.text = self.characterDetailInformation.footnote(from: self.character)

		// Configure image view height constraint
		primaryImageViewHeightConstraint?.isActive = false
		self.layoutIfNeeded()
	}

	/// Configure the cell with the given episode details.
	fileprivate func configureCellWithEpisode() {
		typeImageView.image = self.episodeDetailInformation.imageValue
		typeLabel.text = self.episodeDetailInformation.stringValue
		headlineLabel.text = self.episodeDetailInformation.information(from: self.episode)
		primaryLabel.text = self.episodeDetailInformation.primaryInformation(from: self.episode)
		primaryImageView.image = self.episodeDetailInformation.primaryImage(from: self.episode)
		secondaryLabel.text = self.episodeDetailInformation.secondaryInformation(from: self.episode)
		footerLabel.text = self.episodeDetailInformation.footnote(from: self.episode)

		// Configure image view height constraint
		primaryImageViewHeightConstraint?.isActive = false
		self.layoutIfNeeded()
	}

	/// Configure the cell with the given show details.
	fileprivate func configureCellWithShow() {
		typeImageView.image = self.showDetailInformation.imageValue
		typeLabel.text = self.showDetailInformation.stringValue
		headlineLabel.text = self.showDetailInformation.information(from: self.show)
		primaryLabel.text = self.showDetailInformation.primaryInformation(from: self.show)
		primaryImageView.image = self.showDetailInformation.primaryImage(from: self.show)
		secondaryLabel.text = self.showDetailInformation.secondaryInformation(from: self.show)
		footerLabel.text = self.showDetailInformation.footnote(from: self.show)

		switch self.showDetailInformation {
		case .airDates:
			primaryImageViewHeightConstraint?.isActive = primaryImageView.image != nil
			secondaryLabel.textAlignment = .right
			secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		default:
			primaryImageViewHeightConstraint?.isActive = false
			secondaryLabel.textAlignment = .natural
			secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
		self.layoutIfNeeded()
	}

	/// Configure the cell with the given studio details.
	fileprivate func configureCellWithStudio() {
		typeImageView.image = self.studioDetailInformation.imageValue
		typeLabel.text = self.studioDetailInformation.stringValue
		headlineLabel.text = self.studioDetailInformation.information(from: self.studio)
		primaryLabel.text = self.studioDetailInformation.primaryInformation(from: self.studio)
		primaryImageView.image = self.studioDetailInformation.primaryImage(from: self.studio)
		secondaryLabel.text = self.studioDetailInformation.secondaryInformation(from: self.studio)
		footerLabel.text = self.studioDetailInformation.footnote(from: self.studio)

		// Configure image view height constraint
		primaryImageViewHeightConstraint?.isActive = false
		self.layoutIfNeeded()
	}
}
