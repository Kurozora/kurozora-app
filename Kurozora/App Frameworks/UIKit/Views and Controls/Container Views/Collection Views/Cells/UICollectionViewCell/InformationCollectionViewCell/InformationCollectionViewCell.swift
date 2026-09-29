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

	// MARK: - Views
	/// The week of dates marking today and the next release.
	private let scheduleWeekView: ScheduleWeekView = {
		let scheduleWeekView = ScheduleWeekView()
		scheduleWeekView.translatesAutoresizingMaskIntoConstraints = false
		scheduleWeekView.isHidden = true
		return scheduleWeekView
	}()

	/// The gap the week of dates keeps above the secondary label.
	private var scheduleWeekBottomConstraint: NSLayoutConstraint?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	nonisolated override func awakeFromNib() {
		super.awakeFromNib()

		MainActor.assumeIsolated {
			self.typeImageView?.theme_tintColor = KThemePicker.subTextColor.rawValue
			self.primaryImageView?.theme_tintColor = KThemePicker.textColor.rawValue

			self.configureScheduleWeekView()
		}
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.setScheduleWeekHidden(true)
	}

	// MARK: - Functions
	/// Pins the week of dates over the slot the primary image occupies.
	private func configureScheduleWeekView() {
		guard let container = self.primaryImageView?.superview else { return }
		container.addSubview(self.scheduleWeekView)

		let bottomConstraint = self.secondaryLabel.topAnchor.constraint(greaterThanOrEqualTo: self.scheduleWeekView.bottomAnchor, constant: 8.0)
		self.scheduleWeekBottomConstraint = bottomConstraint

		NSLayoutConstraint.activate([
			self.scheduleWeekView.topAnchor.constraint(equalTo: self.primaryImageView.topAnchor),
			self.scheduleWeekView.leadingAnchor.constraint(equalTo: self.primaryImageView.leadingAnchor),
			self.scheduleWeekView.trailingAnchor.constraint(equalTo: self.primaryImageView.trailingAnchor)
		])
	}

	/// Collapses or reveals the week of dates.
	///
	/// - Parameter isHidden: Whether the week of dates is collapsed.
	private func setScheduleWeekHidden(_ isHidden: Bool) {
		self.scheduleWeekView.isHidden = isHidden
		self.scheduleWeekBottomConstraint?.isActive = !isHidden
	}

	/// Lays out the week of dates for the given release.
	///
	/// - Parameter releaseDate: The day the next release lands on.
	private func configureScheduleWeek(for releaseDate: Date?) {
		self.setScheduleWeekHidden(releaseDate == nil)
		self.scheduleWeekView.configure(releaseDate: releaseDate)
	}

	/// Sizes the label under the headline.
	///
	/// - Parameter isSubtitle: Whether the label reads as a subtitle.
	private func configureSubtitleFont(for isSubtitle: Bool) {
		self.primaryLabel.font = isSubtitle
			? .preferredFont(forTextStyle: .subheadline)
			: .preferredFont(forTextStyle: .title3)
	}

	/// The shared settings used to initialize the cell.
	fileprivate func sharedInit() {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		self.layerCornerRadius = 22
		self.layer.cornerCurve = .continuous
	}

	/// Configure the cell with the given person details.
	func configure(using person: Person, for personDetailInformation: PersonDetail.Information) {
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
	func configure(using character: Character, for characterDetailInformation: CharacterDetail.Information) {
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
		self.configureSubtitleFont(for: showDetailInformation == .languages)

		switch showDetailInformation {
		case .airDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		case .broadcast:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)

			self.configureScheduleWeek(for: showDetailInformation.releaseDate(from: show))
		default:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given cached library entry.
	func configure(using entry: LocalLibraryEntry, for showDetailInformation: ShowDetail.Information) {
		self.configureFromCachedEntry(
			image: showDetailInformation.imageValue,
			type: showDetailInformation.stringValue,
			headline: showDetailInformation.information(from: entry),
			primary: showDetailInformation.primaryInformation(from: entry)
		)
	}

	/// Configure the cell with the given cached library entry.
	func configure(using entry: LocalLibraryEntry, for literatureDetailInformation: LiteratureDetail.Information) {
		self.configureFromCachedEntry(
			image: literatureDetailInformation.imageValue,
			type: literatureDetailInformation.stringValue,
			headline: literatureDetailInformation.information(from: entry),
			primary: literatureDetailInformation.primaryInformation(from: entry)
		)
	}

	/// Configure the cell with the given cached library entry.
	func configure(using entry: LocalLibraryEntry, for gameDetailInformation: GameDetail.Information) {
		self.configureFromCachedEntry(
			image: gameDetailInformation.imageValue,
			type: gameDetailInformation.stringValue,
			headline: gameDetailInformation.information(from: entry),
			primary: nil
		)
	}

	/// Configure the cell with the given values.
	private func configureFromCachedEntry(image: UIImage?, type: String, headline: String?, primary: String?) {
		self.typeImageView.image = image
		self.typeLabel.text = type
		self.headlineLabel.text = headline
		self.primaryLabel.text = primary
		self.primaryImageView.image = nil
		self.secondaryLabel.text = nil
		self.footerLabel.text = nil

		self.primaryImageViewHeightConstraint?.isActive = false
		self.secondaryLabel.textAlignment = .natural
		self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
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
		self.configureSubtitleFont(for: literatureDetailInformation == .languages)

		switch literatureDetailInformation {
		case .publicationDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		case .publication:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)

			self.configureScheduleWeek(for: literatureDetailInformation.releaseDate(from: literature))
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
		self.configureSubtitleFont(for: gameDetailInformation == .languages)

		switch gameDetailInformation {
		case .publicationDates:
			self.primaryImageViewHeightConstraint?.isActive = self.primaryImageView.image != nil
			self.secondaryLabel.textAlignment = .right
			self.secondaryLabel.font = .preferredFont(forTextStyle: .headline)
		case .publication:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)

			self.configureScheduleWeek(for: gameDetailInformation.releaseDate(from: game))
		default:
			self.primaryImageViewHeightConstraint?.isActive = false
			self.secondaryLabel.textAlignment = .natural
			self.secondaryLabel.font = .preferredFont(forTextStyle: .body)
		}
	}

	/// Configure the cell with the given studio details.
	func configure(using studio: Studio, for studioDetailInformation: StudioDetail.Information) {
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
