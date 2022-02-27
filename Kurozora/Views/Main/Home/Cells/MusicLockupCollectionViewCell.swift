//
//  MusicLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

protocol MusicLockupCollectionViewCellDelegate: AnyObject {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath)
}

class MusicLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet var tertiaryLable: KSecondaryLabel!

	/// A button representing the show a music belongs to.
	@IBOutlet var showButton: KButton!

	/// A button representing the type of the music.
	@IBOutlet var typeButton: UIButton!

	// MARK: - Properties
	/// The index path of the cell within the parent collection view.
	var indexPath: IndexPath?

	/// The `MusicLockupCollectionViewCellDelegate` object responsible for delegating actions.
	weak var delegate: MusicLockupCollectionViewCellDelegate?

	// MARK: - Functions
	/// Configures the cell with the given `ShowSong` object.
	///
	/// - Parameter showSong: The `ShowSong` objet used to confgiure the cell.
	/// - Parameter indexPath: The index path of the cell within the collection view.
	/// - Parameter showEpisodes: Whether to show which episodes this song played in.
	/// - Parameter showShow: Whether to show which show this song belongs to.
	override func configureCell(with showSong: ShowSong, at indexPath: IndexPath, showEpisodes: Bool = true, showShow: Bool = false) {
		self.indexPath = indexPath

		// Configure title
		self.primaryLabel?.text = showSong.song.attributes.title

		// Configure artist
		self.secondaryLabel?.text = showSong.song.attributes.artist

		// Configure episodes
		self.tertiaryLable.isHidden = !showEpisodes
		self.tertiaryLable.text = "Episode: \(showSong.attributes.episodes)"

		// Confgiure type button
		self.typeButton.setTitle("\(showSong.attributes.type.abbreviatedStringValue) #\(showSong.attributes.position)", for: .normal)
		self.typeButton.backgroundColor = showSong.attributes.type.backgroundColorValue
		self.typeButton.setTitleColor(.white, for: .normal)

		// Confgiure type button
		self.showButton.isHidden = !showShow
		self.showButton.setTitle(showSong.show?.attributes.title, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func showButtonPressed(_ sender: UIButton) {
		guard let indexPath = indexPath else { return }
		self.delegate?.showButtonPressed(sender, indexPath: indexPath)
	}
}
