//
//  HomeCollectionViewController+Delegates.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/04/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension HomeCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch self.dataSource.sectionIdentifier(for: indexPath.section) {
		case .banner(let exploreCategory), .episode(let exploreCategory), .small(let exploreCategory), .medium(let exploreCategory), .large(let exploreCategory), .upcoming(let exploreCategory), .video(let exploreCategory), .profile(let exploreCategory), .music(let exploreCategory):
			switch exploreCategory.attributes.exploreCategoryType {
			case .shows, .mostPopularShows, .upcomingShows, .newShows:
				guard let show = self.cache[indexPath] as? Show else { return }
				self.show(.showDetailsSegue, sender: show)
			case .literatures, .mostPopularLiteratures, .upcomingLiteratures, .newLiteratures:
				guard let literature = self.cache[indexPath] as? Literature else { return }
				self.show(.literatureDetailsSegue, sender: literature)
			case .games, .mostPopularGames, .upcomingGames, .newGames:
				guard let game = self.cache[indexPath] as? Game else { return }
				self.show(.gameDetailsSegue, sender: game)
			case .episodes, .upNextEpisodes:
				guard let episode = self.cache[indexPath] as? Episode else { return }
				self.show(.episodeDetailsSegue, sender: [indexPath: episode])
			case .genres:
				guard let genre = self.cache[indexPath] as? Genre else { return }
				self.show(.exploreSegue, sender: genre)
			case .themes:
				guard let theme = self.cache[indexPath] as? Theme else { return }
				self.show(.exploreSegue, sender: theme)
			case .characters:
				guard let character = self.cache[indexPath] as? Character else { return }
				self.show(.characterSegue, sender: character)
			case .people:
				guard let person = self.cache[indexPath] as? Person else { return }
				self.show(.personSegue, sender: person)
			case .songs:
				guard let showSong = self.cache[indexPath] as? ShowSong else { return }
				self.show(.songDetailsSegue, sender: showSong.song)
			case .recap:
				guard let recap = self.cache[indexPath] as? Recap else { return }
				self.show(.reCapSegue, sender: recap)
			}
		case .legal:
			self.present(.legalSegue, sender: nil)
		default: break
		}
	}

	// MARK: - Managing Context Menus
	override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let exploreCategory = self.exploreCategories[safe: indexPath.section] else { return nil }
		let collectionViewCell = collectionView.cellForItem(at: indexPath)

		switch exploreCategory.attributes.exploreCategoryType {
		case .shows, .upcomingShows, .mostPopularShows, .newShows:
			guard let show = self.cache[indexPath] as? Show else { return nil }
			return show.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .literatures, .upcomingLiteratures, .mostPopularLiteratures, .newLiteratures:
			guard let literature = self.cache[indexPath] as? Literature else { return nil }
			return literature.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .games, .upcomingGames, .mostPopularGames, .newGames:
			guard let game = self.cache[indexPath] as? Game else { return nil }
			return game.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .episodes, .upNextEpisodes:
			guard let episode = self.cache[indexPath] as? Episode else { return nil }
			return episode.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .songs:
			guard
				let musicLockupCollectionViewCell = collectionViewCell as? MusicLockupCollectionViewCell,
				let song = musicLockupCollectionViewCell.song,
				let showSong = self.cache[indexPath] as? ShowSong
			else { return nil }
			return showSong.song.contextMenuConfiguration(in: self, userInfo: [
				"indexPath": indexPath,
				"song": song
			], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .genres:
			guard let genres = self.cache[indexPath] as? Genre else { return nil }
			return genres.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .themes:
			guard let themes = self.cache[indexPath] as? Theme else { return nil }
			return themes.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .characters:
			guard let character = self.cache[indexPath] as? Character else { return nil }
			return character.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .people:
			guard let person = self.cache[indexPath] as? Person else { return nil }
			return person.contextMenuConfiguration(in: self, userInfo: ["indexPath": indexPath], sourceView: collectionViewCell?.contentView, barButtonItem: nil)
		case .recap:
			guard let recap = self.cache[indexPath] as? Recap else { return nil }
			let identifier = indexPath as NSCopying

			return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
				let reCapCollectionViewController = ReCapCollectionViewController()
				reCapCollectionViewController.year = recap.attributes.year
				reCapCollectionViewController.month = recap.attributes.month
				return reCapCollectionViewController
			})
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension HomeCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPress button: UIButton) {
		guard let segueID = reusableView.segueID as? SegueIdentifiers else { return }
		self.show(segueID, sender: reusableView.indexPath)
	}
}

// MARK: - BaseLockupCollectionViewCellDelegate
extension HomeCollectionViewController: BaseLockupCollectionViewCellDelegate {
	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressStatus button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		let modelID: KurozoraItemID

		switch cell.libraryKind {
		case .shows:
			guard let show = self.cache[indexPath] else { return }
			modelID = show.id
		case .literatures:
			guard let literature = self.cache[indexPath] else { return }
			modelID = literature.id
		case .games:
			guard let game = self.cache[indexPath] else { return }
			modelID = game.id
		}

		let oldLibraryStatus = cell.libraryStatus
		let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: LibraryStatus.alertControllerItems(for: cell.libraryKind), currentSelection: oldLibraryStatus, action: { title, value in
			Task {
				do {
					let libraryUpdateResponse = try await KService.addToLibrary(cell.libraryKind, status: value, itemIDs: [modelID]).response()

					switch cell.libraryKind {
					case .shows:
						let show = self.cache[indexPath] as? Show
						show?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .literatures:
						let literature = self.cache[indexPath] as? Literature
						literature?.attributes.library?.update(using: libraryUpdateResponse.data)
					case .games:
						let game = self.cache[indexPath] as? Game
						game?.attributes.library?.update(using: libraryUpdateResponse.data)
					}

					// Update entry in library
					cell.libraryStatus = value
					button.setTitle("\(title) ▾", for: .normal)

					let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
					NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

					// Request review
					ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: value))
				} catch let error as APIError {
					self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
					print("----- Add to library failed", error.message)
				}
			}
		})

		if cell.libraryStatus != .none {
			actionSheetAlertController.addAction(UIAlertAction(title: L10n.removeFromLibrary, style: .destructive, handler: { _ in
				Task {
					do {
						let libraryUpdateResponse = try await KService.removeFromLibrary(cell.libraryKind, itemIDs: [modelID]).response()

						switch cell.libraryKind {
						case .shows:
							let show = self.cache[indexPath] as? Show
							show?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .literatures:
							let literature = self.cache[indexPath] as? Literature
							literature?.attributes.library?.update(using: libraryUpdateResponse.data)
						case .games:
							let game = self.cache[indexPath] as? Game
							game?.attributes.library?.update(using: libraryUpdateResponse.data)
						}

						// Update entry in library
						cell.libraryStatus = .none
						button.setTitle(L10n.add.uppercased(), for: .normal)

						let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
						NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
					} catch let error as APIError {
						self.presentAlertController(title: "Can't Remove From Your Library 😔", message: error.message)
						print("----- Remove from library failed", error.message)
					}
				}
			}))
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = button
			popoverController.sourceRect = button.bounds
		}

		if (self.navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	func baseLockupCollectionViewCell(_ cell: BaseLockupCollectionViewCell, didPressReminder button: UIButton) async {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }
		guard let show = self.cache[indexPath] as? Show else { return }
		await show.toggleReminder(on: self)
		cell.configureReminderButton(for: show.attributes.library?.reminderStatus)
	}
}

// MARK: - EpisodeLockupCollectionViewCellDelegate
extension HomeCollectionViewController: EpisodeLockupCollectionViewCellDelegate {
	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressWatchStatusButton button: UIButton) async {
		let isSignedIn = await WorkflowController.shared.isSignedIn()
		guard isSignedIn else { return }

		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode
		else { return }
		cell.watchStatusButton.isEnabled = false
		await episode.updateWatchStatus(userInfo: ["indexPath": indexPath])
		cell.watchStatusButton.isEnabled = true
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressShowButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let showIdentity = episode.relationships?.shows?.data.first
		else { return }

		self.show(.showDetailsSegue, sender: showIdentity)
	}

	func episodeLockupCollectionViewCell(_ cell: EpisodeLockupCollectionViewCell, didPressSeasonButton button: UIButton) {
		guard
			let indexPath = self.collectionView.indexPath(for: cell),
			let episode = self.cache[indexPath] as? Episode,
			let seasonIdentity = episode.relationships?.seasons?.data.first
		else { return }

		self.show(.episodesListSegue, sender: seasonIdentity)
	}
}

// MARK: - MusicLockupCollectionViewCellDelegate
extension HomeCollectionViewController: MusicLockupCollectionViewCellDelegate {
	func showButtonPressed(_ sender: UIButton, indexPath: IndexPath) {
		guard let show = self.exploreCategories[indexPath.section].relationships.showSongs?.data[indexPath.item].show else { return }
		self.show(.showDetailsSegue, sender: show)
	}
}

// MARK: - ActionBaseExploreCollectionViewCellDelegate
extension HomeCollectionViewController: ActionBaseExploreCollectionViewCellDelegate {
	func actionButtonPressed(_ sender: UIButton, cell: ActionBaseExploreCollectionViewCell) {
		guard let indexPath = self.collectionView.indexPath(for: cell) else { return }

		switch cell.self {
		case is ActionLinkExploreCollectionViewCell:
			let quickLink = self.quickLinks[indexPath.item]

			let kWebViewController = KWebViewController()
			kWebViewController.title = quickLink.title
			kWebViewController.url = quickLink.url

			let kNavigationController = KNavigationController(rootViewController: kWebViewController)
			kNavigationController.modalPresentationStyle = .custom

			self.present(kNavigationController, animated: true)
		case is ActionButtonExploreCollectionViewCell:
			let quickAction = self.quickActions[indexPath.item]
			self.present(quickAction.segueID, sender: nil)
		default: break
		}
	}
}
