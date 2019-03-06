//
//  EpisodeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit

protocol EpisodeCellDelegate: class {
    func episodeCellWatchedPressed(cell: EpisodeCell)
}

class EpisodeCell: UICollectionViewCell {
	enum WatchStatus {
		case Disabled
		case Watched
		case NotWatched
	}

	weak var delegate: EpisodeCellDelegate?

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeFirstAiredLabel: UILabel!
	@IBOutlet weak var episodeWatchedButton: UIButton!

    func configureCellWithEpisode(watchStatus: WatchStatus) {
        switch watchStatus {
        case .Disabled:
            episodeWatchedButton.isEnabled = false
			episodeWatchedButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
        case .Watched:
            episodeWatchedButton.isEnabled = true
			episodeWatchedButton.setTitleColor(#colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1), for: .normal)
        case .NotWatched:
            episodeWatchedButton.isEnabled = true
            episodeWatchedButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6156862745, blue: 0.6784313725, alpha: 1), for: .normal)
        }
    }

	@IBAction func watchedButtonPressed(_ sender: UIButton) {
		delegate?.episodeCellWatchedPressed(cell: self)
	}
}
