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
		self.setPosterToolTip(nil)
		#endif
	}

	// MARK: - Functions
	/// Configures the cell with the given local library entry.
	///
	/// - Parameters:
	///    - entry: The local library entry to render.
	///    - showSelectionIcon: A boolean value that indicates whether the selection icon is visible.
	///    - titleVisibility: The compact-layout title visibility to apply.
	func configure(using entry: LocalLibraryEntry, showSelectionIcon: Bool, titleVisibility: LibraryCompactTitleVisibility) {
		super.configure(using: entry, showSelectionIcon: showSelectionIcon)

		let hasRealPoster = !(entry.posterURL?.isEmpty ?? true)
		self.applyTitleVisibility(titleVisibility, hasRealPoster: hasRealPoster, title: entry.title)
	}

	// MARK: - Helpers
	/// Hides the title label when requested so the enclosing stack view collapses its space,
	/// and surfaces the title via VoiceOver and Mac Catalyst hover when it's no longer visible.
	///
	/// - Parameters:
	///    - visibility: The effective title visibility to apply.
	///    - hasRealPoster: Whether the configured item has non-placeholder poster art.
	///    - title: The series title used for accessibility and hover recovery when the label is hidden.
	private func applyTitleVisibility(_ visibility: LibraryCompactTitleVisibility, hasRealPoster: Bool, title: String?) {
		let shouldHide = (visibility == .never) || (visibility == .smart && hasRealPoster)

		self.primaryLabel.isHidden = shouldHide
		self.posterImageView?.accessibilityLabel = shouldHide ? title : nil

		#if targetEnvironment(macCatalyst)
		self.setPosterToolTip(shouldHide ? title : nil)
		#endif
	}

	#if targetEnvironment(macCatalyst)
	/// Replaces the poster's tooltip interaction so hover help reflects the latest title.
	///
	/// - Parameter toolTip: The tooltip text to display, or `nil` to remove any existing tooltip.
	private func setPosterToolTip(_ toolTip: String?) {
		guard let posterImageView = self.posterImageView else { return }

		for interaction in posterImageView.interactions where interaction is UIToolTipInteraction {
			posterImageView.removeInteraction(interaction)
		}

		if let toolTip {
			posterImageView.addInteraction(UIToolTipInteraction(defaultToolTip: toolTip))
		}
	}
	#endif
}
