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
	func configure(using person: Person, for personDetailInformation: PersonInformation) {
		self.typeImageView.image = personDetailInformation.imageValue
		self.typeLabel.text = personDetailInformation.stringValue
		self.headlineLabel.text = personDetailInformation.information(from: person)
		self.primaryLabel.text = personDetailInformation.primaryInformation(from: person)
		self.primaryImageView.image = personDetailInformation.primaryImage(from: person)
		self.secondaryLabel.text = personDetailInformation.secondaryInformation(from: person)
		self.footerLabel.text = personDetailInformation.footnote(from: person)

		// Configure image view height constraint
		self.primaryImageViewHeightConstraint?.isActive = false
	}

	/// Configure the cell with the given character details.
	func configure(using character: Character, for characterDetailInformation: CharacterInformation) {
		self.typeImageView.image = characterDetailInformation.imageValue
		self.typeLabel.text = characterDetailInformation.stringValue
		self.headlineLabel.text = characterDetailInformation.information(from: character)
		self.primaryLabel.text = characterDetailInformation.primaryInformation(from: character)
		self.primaryImageView.image = characterDetailInformation.primaryImage(from: character)
		self.secondaryLabel.text = characterDetailInformation.secondaryInformation(from: character)
		self.footerLabel.text = characterDetailInformation.footnote(from: character)

		// Configure image view height constraint
		self.primaryImageViewHeightConstraint?.isActive = false
	}

	/// Configure the cell with the given episode details.
	func configure(using episode: Episode, for episodeDetailInformation: EpisodeDetail.Information) {
		self.typeImageView.image = episodeDetailInformation.imageValue
		self.typeLabel.text = episodeDetailInformation.stringValue
		self.headlineLabel.text = episodeDetailInformation.information(from: episode)
		self.primaryLabel.text = episodeDetailInformation.primaryInformation(from: episode)
		self.primaryImageView.image = episodeDetailInformation.primaryImage(from: episode)
		self.secondaryLabel.text = episodeDetailInformation.secondaryInformation(from: episode)
		self.footerLabel.text = episodeDetailInformation.footnote(from: episode)

		// Configure image view height constraint
		self.primaryImageViewHeightConstraint?.isActive = false
	}

	/// Configure the cell with the given show details.
	func configure(using show: Show, for showDetailInformation: ShowDetail.Information) {
		self.typeImageView.image = showDetailInformation.imageValue
		self.typeLabel.text = showDetailInformation.stringValue
		self.headlineLabel.text = showDetailInformation.information(from: show)
		self.primaryLabel.text = showDetailInformation.primaryInformation(from: show)
		self.primaryImageView.image = showDetailInformation.primaryImage(from: show)
		self.secondaryLabel.text = showDetailInformation.secondaryInformation(from: show)
		self.footerLabel.text = showDetailInformation.footnote(from: show)

		switch showDetailInformation {
		case .airDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		default:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given literature details.
	func configure(using literature: Literature, for literatureDetailInformation: LiteratureDetail.Information) {
		self.typeImageView.image = literatureDetailInformation.imageValue
		self.typeLabel.text = literatureDetailInformation.stringValue
		self.headlineLabel.text = literatureDetailInformation.information(from: literature)
		self.primaryLabel.text = literatureDetailInformation.primaryInformation(from: literature)
		self.primaryImageView.image = literatureDetailInformation.primaryImage(from: literature)
		self.secondaryLabel.text = literatureDetailInformation.secondaryInformation(from: literature)
		self.footerLabel.text = literatureDetailInformation.footnote(from: literature)

		switch literatureDetailInformation {
		case .publicationDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		default:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given game details.
	func configure(using game: Game, for gameDetailInformation: GameDetail.Information) {
		self.typeImageView.image = gameDetailInformation.imageValue
		self.typeLabel.text = gameDetailInformation.stringValue
		self.headlineLabel.text = gameDetailInformation.information(from: game)
		self.primaryLabel.text = gameDetailInformation.primaryInformation(from: game)
		self.primaryImageView.image = gameDetailInformation.primaryImage(from: game)
		self.secondaryLabel.text = gameDetailInformation.secondaryInformation(from: game)
		self.footerLabel.text = gameDetailInformation.footnote(from: game)

		switch gameDetailInformation {
		case .publicationDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		default:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given studio details.
	func configure(using studio: Studio, for studioDetailInformation: StudioInformation) {
		self.typeImageView.image = studioDetailInformation.imageValue
		self.typeLabel.text = studioDetailInformation.stringValue
		self.headlineLabel.text = studioDetailInformation.information(from: studio)
		self.primaryLabel.text = studioDetailInformation.primaryInformation(from: studio)
		self.primaryImageView.image = studioDetailInformation.primaryImage(from: studio)
		self.secondaryLabel.text = studioDetailInformation.secondaryInformation(from: studio)
		self.footerLabel.text = studioDetailInformation.footnote(from: studio)

		// Configure image view height constraint
		self.primaryImageViewHeightConstraint?.isActive = false
	}
}
