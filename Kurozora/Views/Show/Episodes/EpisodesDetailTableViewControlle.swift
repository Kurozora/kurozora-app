//
//  EpisodesDetailTableViewControlle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Cosmos

protocol EpisodesDetailTableViewControlleDelegate: class {
	func updateWatchStatus(with watchStatus: WatchStatus)
}

class EpisodesDetailTableViewControlle: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var screenshotImageView: UIImageView?
	@IBOutlet weak var shadowImageView: UIImageView? {
		didSet {
			shadowImageView?.theme_tintColor = KThemePicker.backgroundColor.rawValue
		}
	}
	@IBOutlet weak var episodeNumberLabel: UILabel!
	@IBOutlet weak var episodeTitleLabel: UILabel!
	@IBOutlet weak var episodeFirstAiredLabel: UILabel!
	@IBOutlet weak var episodeWatchedButton: UIButton!
	@IBOutlet weak var episodeMoreButton: UIButton!
	@IBOutlet weak var cosmosView: CosmosView!

	// MARK: - Properties
	var episodeCell: EpisodesCollectionViewCell?
	var episodeElement: EpisodesElement? {
		didSet {
			_prefersActivityIndicatorHidden = true
			tableView.reloadData()
		}
	}
	weak var delegate: EpisodesDetailTableViewControlleDelegate?

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		configureEpisodeDetails(from: episodeCell)
	}

	// MARK: - Functions
	fileprivate func updateWatchStatus(with watchStatus: WatchStatus) {
		if watchStatus == .watched {
			episodeWatchedButton.isEnabled = true
			episodeWatchedButton.isHidden = false
			episodeWatchedButton.tag = 1
			episodeWatchedButton.backgroundColor = .kurozora
			episodeWatchedButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		} else {
			episodeWatchedButton.isEnabled = true
			episodeWatchedButton.isHidden = false
			episodeWatchedButton.tag = 0
			episodeWatchedButton.backgroundColor = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1).withAlphaComponent(0.80)
			episodeWatchedButton.tintColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1).withAlphaComponent(0.80)
		}
	}

	fileprivate func configureEpisodeDetails(from cell: EpisodesCollectionViewCell?) {
		guard let cell = episodeCell else { return }
		// Episode Misc
		title = cell.episodeNumberLabel.text
		screenshotImageView?.image = cell.episodeImageView.image.unwrapped(or: R.image.placeholders.showEpisode()!)
		episodeNumberLabel.text = cell.episodeNumberLabel.text
		episodeTitleLabel.text = cell.episodeTitleLabel.text
		episodeFirstAiredLabel.text = cell.episodeFirstAiredLabel.text

		// Cosmos View
		cosmosView.rating = cell.cosmosView.rating

		// Episode Watched Button
		episodeWatchedButton.tag = cell.episodeWatchedButton.tag
		episodeWatchedButton.backgroundColor = cell.episodeWatchedButton.backgroundColor
		episodeWatchedButton.tintColor = cell.episodeWatchedButton.tintColor
	}

	// MARK: - IBActions
	@IBAction func episodeWatchedButtonPressed(_ sender: UIButton) {
		guard let episodeID = episodeElement?.id else { return }
		let watchStatus: WatchStatus = episodeWatchedButton.tag == 0 ? .watched : .notWatched

		KService.updateEpisodeWatchStatus(episodeID, withWatchStatus: watchStatus) { result in
			switch result {
			case .success(let watchStatus):
				DispatchQueue.main.async {
					self.delegate?.updateWatchStatus(with: watchStatus)
					self.updateWatchStatus(with: watchStatus)
				}
			case .failure:
				break
			}
		}
	}

	@IBAction func episodeMoreButtonPressed(_ sender: UIButton) {
		let tag = episodeWatchedButton.tag
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		action.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { (_) in
			self.episodeWatchedButtonPressed(sender)
		}))
		action.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

		//Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
		}

		self.present(action, animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension EpisodesDetailTableViewControlle {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
}

// MARK: - UITableViewDelegate
extension EpisodesDetailTableViewControlle {
}
