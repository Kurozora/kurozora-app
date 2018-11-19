//
//  EpisodeCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 11/10/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
//import FBSDKMessengerShareKit
import KDatabaseKit

protocol EpisodeCellDelegate: class {
    func episodeCellWatchedPressed(cell: EpisodeCell)
    func episodeCellMorePressed(cell: EpisodeCell)
}

class EpisodeCell: UICollectionViewCell {
    //
    //    enum WatchStatus {
    //        case Disabled
    //        case Watched
    //        case NotWatched
    //    }
    //
    //    weak var delegate: EpisodeCellDelegate?

    @IBOutlet weak var episodeImageView: UIImageView!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    @IBOutlet weak var episodeFirstAiredLabel: UILabel!

    //    let numberAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]
    //    let titleAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
    //
    //    func configureCellWithEpisode(episode: Episode, watchStatus: WatchStatus) {
    //        let episodeNumber = NSAttributedString(string: "Ep \(episode.number) · ", attributes: numberAttributes)
    //        let episodeTitle = NSAttributedString(string: episode.title ?? "", attributes: titleAttributes)
    //
    //        let attributedString = NSMutableAttributedString()
    //        attributedString.appendAttributedString(episodeNumber)
    //        attributedString.appendAttributedString(episodeTitle)
    //
    //
    //        titleLabel.attributedText = attributedString
    //        screenshotImageView.setImageFrom(urlString: episode.imageURLString(), animated: true)
    //
    //        firstAiredLabel.text = episode.firstAired?.mediumDate() ?? ""
    //
    //        switch watchStatus {
    //        case .Disabled:
    //            watchedButton.isEnabled = false
    //            watchedButton.backgroundColor = UIColor.clear
    //            watchedButton.setImage(UIImage(named: "icon-check"), for: .normal)
    //        case .Watched:
    //            watchedButton.isEnabled = true
    //            watchedButton.backgroundColor = UIColor.textBlue()
    //            watchedButton.setImage(UIImage(named: "icon-check-selected"), for: .normal)
    //        case .NotWatched:
    //            watchedButton.isEnabled = true
    //            watchedButton.backgroundColor = UIColor.clear
    //            watchedButton.setImage(UIImage(named: "icon-check"), for: .normal)
    //        }
    //    }
    //
    //    @IBAction func morePressed(sender: AnyObject) {
    //        delegate?.episodeCellMorePressed(cell: self)
    //    }
    //
    //    @IBAction func watchedPressed(sender: AnyObject) {
    //        delegate?.episodeCellWatchedPressed(cell: self)
    //    }
    //
    //    @IBAction func shareOnMessengerPressed(sender: AnyObject) {
    //        if UIApplication.shared.canOpenURL(URL(string: "fb-messenger://")!) {
    //            FBSDKMessengerSharer.shareImage(screenshotImageView.image, withOptions: nil)
    //        }
    //    }
}
