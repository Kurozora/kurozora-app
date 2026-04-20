//
//  LibraryCompactCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class LibraryCompactCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.primaryLabel.isHidden = false
		self.posterImageView?.accessibilityLabel = nil

		#if targetEnvironment(macCatalyst)
		self.posterImageView?.toolTip = nil
		#endif
	}

	// MARK: - Functions
	/// Configure the cell with the given show's details.
	///
	/// - Parameters:
	///    - show: The show to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	///    - titleVisibility: The compact-layout title visibility to apply.
	func configure(using show: Show, showSelectionIcon: Bool, titleVisibility: KKLibrary.CompactTitleVisibility) {
		super.configure(using: show, showSelectionIcon: showSelectionIcon)

		let hasRealPoster = !(show.attributes.poster?.url.isEmpty ?? true)
		self.applyTitleVisibility(titleVisibility, hasRealPoster: hasRealPoster, title: show.attributes.title)
	}

	/// Configure the cell with the given literature's details.
	///
	/// - Parameters:
	///    - literature: The literature to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	///    - titleVisibility: The compact-layout title visibility to apply.
	func configure(using literature: Literature, showSelectionIcon: Bool, titleVisibility: KKLibrary.CompactTitleVisibility) {
		super.configure(using: literature, showSelectionIcon: showSelectionIcon)

		let hasRealPoster = !(literature.attributes.poster?.url.isEmpty ?? true)
		self.applyTitleVisibility(titleVisibility, hasRealPoster: hasRealPoster, title: literature.attributes.title)
	}

	/// Configure the cell with the given game's details.
	///
	/// - Parameters:
	///    - game: The game to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	///    - titleVisibility: The compact-layout title visibility to apply.
	func configure(using game: Game, showSelectionIcon: Bool, titleVisibility: KKLibrary.CompactTitleVisibility) {
		super.configure(using: game, showSelectionIcon: showSelectionIcon)

		let hasRealPoster = !(game.attributes.poster?.url.isEmpty ?? true)
		self.applyTitleVisibility(titleVisibility, hasRealPoster: hasRealPoster, title: game.attributes.title)
	}

	// MARK: - Helpers
	/// Hides the title label when requested so the enclosing stack view collapses its space,
	/// and surfaces the title via VoiceOver and Mac Catalyst hover when it's no longer visible.
	///
	/// - Parameters:
	///    - visibility: The effective title visibility to apply.
	///    - hasRealPoster: Whether the configured item has non-placeholder poster art.
	///    - title: The series title used for accessibility and hover recovery when the label is hidden.
	private func applyTitleVisibility(_ visibility: KKLibrary.CompactTitleVisibility, hasRealPoster: Bool, title: String?) {
		let shouldHide = (visibility == .never) || (visibility == .smart && hasRealPoster)

		self.primaryLabel.isHidden = shouldHide
		self.posterImageView?.accessibilityLabel = shouldHide ? title : nil

		#if targetEnvironment(macCatalyst)
		self.posterImageView?.toolTip = shouldHide ? title : nil
		#endif
	}
}
