//
//  Song+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import MusicKit

extension KKSong {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any?])
	-> UIContextMenuConfiguration? {
		let identifier = userInfo["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return SongDetailsCollectionViewController.`init`(with: self.id)
		}) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	func makeContextMenu(in viewController: UIViewController?, userInfo: [AnyHashable: Any?]) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "Play" element
		if let song = userInfo["song"] as? MKSong {
			let isPlaying = MusicManager.shared.currentSong == song && MusicManager.shared.isPlaying
			let title = isPlaying ? "Pause" : "Play"
			let image = isPlaying ? UIImage(systemName: "pause.fill") : UIImage(systemName: "play.fill")
			let playAction = UIAction(title: title, image: image) { _ in
				self.playSong(song: song)
			}
			menuElements.append(playAction)
		}

		if MusicManager.shared.hasAMSubscription {
			var addElements: [UIMenuElement] = []
			// Create "Add to Apple Music" element
			if let song = userInfo["song"] as? MKSong {
				let title = song.isInLibrary ? "In Apple Music Library" : "Add to Apple Music"
				let image = song.isInLibrary ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
				let addAction = UIAction(title: title, image: image) { _ in
					if song.isInLibrary {
						self.showRemoveFromLibraryAlert(for: song, on: viewController)
					} else {
						Task {
							_ = await self.addToLibrary(song: song)
						}
					}
				}
				addElements.append(addAction)
			}
			menuElements.append(UIMenu(title: "", options: .displayInline, children: addElements))
		}

		var viewOnElements: [UIMenuElement] = []
		// Create "View on Amazon Music" element
		if let amazonID = self.attributes.amazonID, let amazonMusicLink = URL.amazonMusicURL(amazonID: amazonID) {
			let amazonMusicAction = UIAction(title: Trans.viewOnAmazonMusic, image: R.image.symbols.musicSmileCircleFill()) { _ in
				UIApplication.shared.kOpen(amazonMusicLink)
			}
			viewOnElements.append(amazonMusicAction)
		}

		// Create "View on Apple Music" element
		if let song = userInfo["song"] as? MKSong,
		   let appleMusicLink = song.song.url {
			let amAction = UIAction(title: Trans.viewOnAppleMusic, image: R.image.symbols.musicNoteCircleFill()) { _ in
				UIApplication.shared.kOpen(appleMusicLink)
			}
			viewOnElements.append(amAction)
		}

		// Create "View on Deezer" element
		if let deezerID = self.attributes.deezerID, let deezerLink = URL.deezerURL(deezerID: deezerID) {
			let deezerAction = UIAction(title: Trans.viewOnDeezer, image: R.image.symbols.musicWaveformCircleFill()) { _ in
				UIApplication.shared.kOpen(deezerLink)
			}
			viewOnElements.append(deezerAction)
		}

		// Create "View on Spotify" element
		if let spotifyID = self.attributes.spotifyID, let spotifyLink = URL.spotifyURL(spotifyID: spotifyID) {
			let spotifyAction = UIAction(title: Trans.viewOnSpotify, image: R.image.symbols.wave3UpCircleFill()) { _ in
				UIApplication.shared.kOpen(spotifyLink)
			}
			viewOnElements.append(spotifyAction)
		}

		// Create "View on YouTube Music" element
		if let youtubeID = self.attributes.youtubeID, let youtubeLink = URL.youtubeURL(youtubeID: youtubeID) {
			let spotifyAction = UIAction(title: Trans.viewOnYouTube, image: R.image.symbols.playCircleCircleFill()) { _ in
				UIApplication.shared.kOpen(youtubeLink)
			}
			viewOnElements.append(spotifyAction)
		}
		menuElements.append(UIMenu(title: "", options: .displayInline, children: viewOnElements))

		// Create "share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Present share sheet for the song.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "https://kurozora.app/songs/\(self.id)\nListen to \"\(self.attributes.originalTitle)\" by \"\(self.attributes.artist)\" on @KurozoraApp"
		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let view = view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}

		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Play the given song.
	///
	/// - Parameters:
	///    - song: The song to play.
	func playSong(song: MKSong) {
		MusicManager.shared.play(song: song, playButton: nil)
	}

	/// Rate the song with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the song if rated successfully.
	func rate(using rating: Double, description: String?) async -> Double? {
		let songIdentity = SongIdentity(id: self.id)

		do {
			_ = try await KService.rateSong(songIdentity, with: rating, description: description).value

			// Update current rating for the user.
			self.attributes.library?.rating = rating

			// Update review only if the user removes it explicitly.
			if description != nil {
				self.attributes.library?.review = description
			}

			return rating
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	/// Add song to Apple Music Library.
	///
	/// - Parameters:
	///    - song: The song to add.
	func addToLibrary(song: MKSong) async -> Bool {
		return await MusicManager.shared.add(song: song)
	}

	/// Present an alert to the user that the song cannot be removed from the library.
	///
	/// - Parameters:
	///   - viewController: The view controller to present the alert on.
	private func showRemoveFromLibraryAlert(for song: MKSong, on viewController: UIViewController?) {
		var actions: [UIAlertAction] = []

		if let libraryID = song.relationship?.library?.data.first?.id {
			actions.append(UIAlertAction(title: "Show in Library", style: .default, handler: { _ in
				guard let url = URL(string: "music://music.apple.com/library/songs/\(libraryID)") else { return }
				UIApplication.shared.kOpen(nil, deepLink: url)
			}))
		}

		viewController?.presentAlertController(title: "How to Remove", message: "Songs added to your Apple Music Library cannot be removed from Kurozora due to API limitations. Please remove the song from your library manually in the Music app.", actions: actions)
	}
}
