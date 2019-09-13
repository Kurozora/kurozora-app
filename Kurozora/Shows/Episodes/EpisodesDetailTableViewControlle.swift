//
//  EpisodesDetailTableViewControlle.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Cosmos

protocol EpisodesDetailTableViewControlleDelegate: class {
	func updateWatchedStatus(with watchStatus: Bool)
}

class EpisodesDetailTableViewControlle: UITableViewController {
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

	var episodeCell: EpisodesCollectionViewCell?
	var episodeElement: EpisodesElement?
	weak var delegate: EpisodesDetailTableViewControlleDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		configureEpisodeDetails(from: episodeCell)

		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

	// MARK: - Functions
	fileprivate func updateWatchedStatus(with status: Bool) {
		if status {
			episodeWatchedButton.isEnabled = true
			episodeWatchedButton.isHidden = false
			episodeWatchedButton.tag = 1
			episodeWatchedButton.backgroundColor = #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)
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
		screenshotImageView?.image = cell.episodeImageView.image.unwrapped(or: #imageLiteral(resourceName: "placeholder_episode_image"))
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
		var watched = 0

		if episodeWatchedButton.tag == 0 {
			watched = 1
		}

		Service.shared.mark(asWatched: watched, forEpisode: episodeID) { (watchStatus) in
			DispatchQueue.main.async {
				self.delegate?.updateWatchedStatus(with: watchStatus)
				self.updateWatchedStatus(with: watchStatus)
			}
		}
	}

	@IBAction func episodeMoreButtonPressed(_ sender: UIButton) {
		let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let tag = episodeWatchedButton.tag
		controller.addAction(UIAlertAction(title: (tag == 0) ? "Mark as Watched" : "Mark as Unwatched", style: .default, handler: { (_) in
			self.episodeWatchedButtonPressed(sender)
		}))
		controller.addAction(UIAlertAction(title: "Rate", style: .default, handler: nil))
		controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		self.present(controller, animated: true, completion: nil)
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
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}
