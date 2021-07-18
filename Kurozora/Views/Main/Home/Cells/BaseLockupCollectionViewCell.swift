//
//  BaseLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BaseLockupCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: UILabel?
	@IBOutlet weak var secondaryLabel: UILabel?
	@IBOutlet weak var bannerImageView: UIImageView?
	@IBOutlet weak var posterImageView: UIImageView?
	@IBOutlet weak var libraryStatusButton: KTintedButton?

	// MARK: - Properties
	var showDetailsCollectionViewController: ShowDetailsCollectionViewController?
	var show: Show! {
		didSet {
			configureCell()
		}
	}
	var genre: Genre! = nil {
		didSet {
			self.show = nil
			configureCell()
		}
	}
	var libraryStatus: KKLibrary.Status = .none

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let show = self.show else { return }

		// Configure title
		self.primaryLabel?.text = show.attributes.title

		// Configure genres
		self.secondaryLabel?.text = show.attributes.genres?.joined(separator: ", ") ?? "-"

		// Configure banner
		if let bannerBackgroundColor = self.show.attributes.banner?.backgroundColor {
			self.bannerImageView?.backgroundColor = UIColor(hexString: bannerBackgroundColor)
		}
		self.bannerImageView?.setImage(with: self.show.attributes.banner?.url ?? "", placeholder: R.image.placeholders.showBanner()!)

		// Configure poster
		if let posterBackgroundColor = self.show.attributes.poster?.backgroundColor {
			self.posterImageView?.backgroundColor = UIColor(hexString: posterBackgroundColor)
		}
		self.posterImageView?.setImage(with: self.show.attributes.poster?.url ?? "", placeholder: R.image.placeholders.showPoster()!)

		// Configure library status
		if let libraryStatus = self.show.attributes.libraryStatus {
			self.libraryStatus = libraryStatus
		}
		self.libraryStatusButton?.setTitle(self.libraryStatus != .none ? "\(self.libraryStatus.stringValue.capitalized) ▾" : "ADD", for: .normal)
	}

	// MARK: - IBActions
	@IBAction func chooseStatusButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			let oldLibraryStatus = self.libraryStatus
			let actionSheetAlertController = UIAlertController.actionSheetWithItems(items: KKLibrary.Status.alertControllerItems, currentSelection: oldLibraryStatus, action: { [weak self] (title, value)  in
				guard let self = self else { return }
				KService.addToLibrary(withLibraryStatus: value, showID: self.show.id) { [weak self] result in
					guard let self = self else { return }
					switch result {
					case .success:
						// Update entry in library
						self.libraryStatus = value
						self.libraryStatusButton?.setTitle("\(title) ▾", for: .normal)

						let libraryAddToNotificationName = Notification.Name("AddTo\(value.sectionValue)Section")
						NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
					case .failure:
						break
					}
				}
			})

			if self.libraryStatus != .none {
				actionSheetAlertController.addAction(UIAlertAction.init(title: "Remove from library", style: .destructive, handler: { [weak self] _ in
					guard let self = self else { return }
					KService.removeFromLibrary(showID: self.show.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success(let libraryUpdate):
							self.show.attributes.update(using: libraryUpdate)
							self.libraryStatus = .none
							self.libraryStatusButton?.setTitle("ADD", for: .normal)

							let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
						case .failure:
							break
						}
					}
				}))
			}

			// Present the controller
			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
			}

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(actionSheetAlertController, animated: true, completion: nil)
			}
		}
	}
}
