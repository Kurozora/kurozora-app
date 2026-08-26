//
//  TrailerFeaturedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/08/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

/// Reports interactions with the featured trailer cell.
protocol TrailerFeaturedCollectionViewCellDelegate: AnyObject {
	/// Tells the delegate the reader pressed the featured title's library button.
	///
	/// - Parameters:
	///    - cell: The cell whose button was pressed.
	///    - button: The button that was pressed.
	func trailerFeaturedCollectionViewCell(_ cell: TrailerFeaturedCollectionViewCell, didPressAdd button: UIButton) async
}

/// A cell that leads the page with the featured trailer and its details.
class TrailerFeaturedCollectionViewCell: KCollectionViewCell {
	// MARK: - Views
	/// The container the featured player is placed into.
	let playerContainer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layerCornerRadius = 16.0
		view.layer.masksToBounds = true
		return view
	}()

	/// The featured title.
	private let titleLabel: KLabel = {
		let label = KLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .title2).bold
		label.numberOfLines = 2
		return label
	}()

	/// The featured title's genres.
	private let genreLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .subheadline)
		label.numberOfLines = 1
		return label
	}()

	/// The featured title's synopsis.
	private let synopsisLabel: KSecondaryLabel = {
		let label = KSecondaryLabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .preferredFont(forTextStyle: .callout)
		label.numberOfLines = 0
		return label
	}()

	/// The featured title's poster.
	private let posterImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layerCornerRadius = 8.0
		return imageView
	}()

	/// The button that puts the featured title in the library.
	private let addButton: KTintedButton = {
		let button = KTintedButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 15.0, weight: .medium)
		button.layerCornerRadius = 15.0
		return button
	}()

	/// The stack arranging the player beside or above the details.
	private let contentStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 16.0
		stackView.alignment = .top
		return stackView
	}()

	// MARK: - Properties
	override var isSkeletonEnabled: Bool { false }

	/// The object responsible for delegating interactions.
	weak var delegate: TrailerFeaturedCollectionViewCellDelegate?

	/// The kind of library the featured title belongs to.
	private(set) var libraryKind: LibraryKind = .shows

	/// The width the player takes beside the details on wide layouts.
	private var playerWidthConstraint: NSLayoutConstraint?

	// MARK: - Initializers
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		guard self.traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass else { return }
		self.applyResponsiveLayout()
	}

	/// Configures the cell's view hierarchy and layout.
	private func sharedInit() {
		self.addButton.addTarget(self, action: #selector(self.addButtonPressed(_:)), for: .touchUpInside)
		self.addButton.setContentHuggingPriority(.required, for: .horizontal)
		self.addButton.setContentCompressionResistancePriority(.required, for: .horizontal)

		let titleStackView = UIStackView(arrangedSubviews: [self.titleLabel, self.genreLabel])
		titleStackView.axis = .vertical
		titleStackView.spacing = 4.0

		let headerStackView = UIStackView(arrangedSubviews: [self.posterImageView, titleStackView])
		headerStackView.axis = .horizontal
		headerStackView.spacing = 12.0
		headerStackView.alignment = .top

		let buttonStackView = UIStackView(arrangedSubviews: [self.addButton, UIView()])
		buttonStackView.axis = .horizontal

		let detailsStackView = UIStackView(arrangedSubviews: [headerStackView, self.synopsisLabel, buttonStackView])
		detailsStackView.axis = .vertical
		detailsStackView.spacing = 8.0
		detailsStackView.alignment = .fill
		detailsStackView.setCustomSpacing(16.0, after: self.synopsisLabel)

		self.contentStackView.addArrangedSubview(self.playerContainer)
		self.contentStackView.addArrangedSubview(detailsStackView)
		self.contentView.addSubview(self.contentStackView)

		let playerWidthConstraint = self.playerContainer.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor, multiplier: 0.6)
		self.playerWidthConstraint = playerWidthConstraint

		NSLayoutConstraint.activate([
			self.contentStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10.0),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10.0),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20.0),

			self.playerContainer.heightAnchor.constraint(equalTo: self.playerContainer.widthAnchor, multiplier: 9.0 / 16.0),

			self.posterImageView.widthAnchor.constraint(equalToConstant: 90.0),
			self.posterImageView.heightAnchor.constraint(equalTo: self.posterImageView.widthAnchor, multiplier: 3.0 / 2.0)
		])

		self.applyResponsiveLayout()
	}

	/// Switches between the side-by-side and stacked layouts for the current width.
	private func applyResponsiveLayout() {
		let isWide = self.traitCollection.horizontalSizeClass == .regular
		self.contentStackView.axis = isWide ? .horizontal : .vertical
		self.playerWidthConstraint?.isActive = isWide
	}

	// MARK: - Functions
	/// Configures the cell with the given show.
	///
	/// - Parameter show: The show to display.
	func configure(using show: Show?) {
		guard let show = show else { return }

		self.libraryKind = .shows
		self.titleLabel.text = show.attributes.title
		self.genreLabel.text = show.attributes.genres?.localizedJoined()
		self.synopsisLabel.text = show.attributes.synopsis
		show.attributes.posterImage(imageView: self.posterImageView)
		self.updateLibraryButton(status: show.libraryAttributes?.status)
	}

	/// Configures the cell with the given game.
	///
	/// - Parameter game: The game to display.
	func configure(using game: Game?) {
		guard let game = game else { return }

		self.libraryKind = .games
		self.titleLabel.text = game.attributes.title
		self.genreLabel.text = game.attributes.genres?.localizedJoined()
		self.synopsisLabel.text = game.attributes.synopsis
		game.attributes.posterImage(imageView: self.posterImageView)
		self.updateLibraryButton(status: game.libraryAttributes?.status)
	}

	/// Updates the library button for the given status.
	///
	/// - Parameter status: The title's library status.
	func updateLibraryButton(status: LibraryStatus?) {
		let status = status ?? .none

		if status == .none {
			self.addButton.setTitle(L10n.add.uppercased(with: Locale.current), for: .normal)
			return
		}

		let title: String
		switch self.libraryKind {
		case .shows: title = status.showStringValue
		case .literatures: title = status.literatureStringValue
		case .games: title = status.gameStringValue
		}
		self.addButton.setTitle("\(title.capitalized(with: Locale.current)) ▾", for: .normal)
	}

	/// Notifies the delegate that the library button was pressed.
	///
	/// - Parameter sender: The button that was pressed.
	@objc private func addButtonPressed(_ sender: UIButton) {
		Task { [weak self] in
			guard let self = self else { return }
			await self.delegate?.trailerFeaturedCollectionViewCell(self, didPressAdd: sender)
		}
	}
}
