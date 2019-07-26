//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

//protocol LibraryCellDelegate: class {
//    func cellPressedWatched(cell: LibraryCollectionViewCell, anime: Anime)
//    func cellPressedEpisodeThread(cell: LibraryCollectionViewCell, anime: Anime, episode: Episode)
//}

class LibraryCollectionViewCell: UICollectionViewCell {
//    weak var delegate: LibraryAnimeCellDelegate?
//    var anime: Anime?
//    weak var episode: Episode?
//    var currentCancellationToken: Operation?
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var userProgressLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton?
//	@IBOutlet weak var cellShadowView: UIView!
	@IBOutlet weak var posterShadowView: UIView?
	@IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var episodeImageView: UIImageView?

	var libraryElement: LibraryElement? {
		didSet {
			setup()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	fileprivate func setup() {
		self.hero.id = nil

		guard let libraryElement = libraryElement else { return }
		guard let showTitle = libraryElement.title else { return }

		if titleLabel != nil, userProgressLabel != nil, episodeImageView != nil {
			self.titleLabel.hero.id = "library_\(showTitle)_title"
			self.titleLabel.text = libraryElement.title
			self.userProgressLabel.hero.id = "library_\(showTitle)_progress"
			self.userProgressLabel.text = "TV ·  \(libraryElement.episodeCount ?? 0) ·  \(libraryElement.averageRating ?? 0)"

			self.episodeImageView?.hero.id = "library_\(showTitle)_banner"
			if let backgroundThumbnail = libraryElement.backgroundThumbnail, backgroundThumbnail != "" {
				let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
				let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
				self.episodeImageView?.kf.indicatorType = .activity
				self.episodeImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
			} else {
				self.episodeImageView?.image = #imageLiteral(resourceName: "placeholder_banner")
			}

			self.posterShadowView?.applyShadow()
		}

		self.posterView.hero.id = "library_\(showTitle)_poster"
		if let posterThumbnail = libraryElement.posterThumbnail, posterThumbnail != "" {
			let posterThumbnailUrl = URL(string: posterThumbnail)
			let resource = ImageResource(downloadURL: posterThumbnailUrl!)
			self.posterView.kf.indicatorType = .activity
			self.posterView.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_poster"), options: [.transition(.fade(0.2))])
		} else {
			self.posterView.image = #imageLiteral(resourceName: "placeholder_poster")
		}

		self.contentView.applyShadow()
	}
//    @IBAction func watchedPressed(sender: AnyObject) {
//
//        if let anime = anime, let progress = anime.progress ?? anime.publicProgress {
//
//            progress.watchedEpisodes += 1
//            progress.updatedEpisodes(anime.episodes)
//            progress.saveInBackground()
//            LibrarySyncController.updateAnime(progress)
//        }
//
//        delegate?.cellPressedWatched(cell: self, anime:anime!)
//        watchedButton?.animateBounce()
//    }
//
//    override func configureWithAnime(
//        anime: Anime,
//        canFadeImages: Bool = true,
//        showEtaAsAired: Bool = false,
//        showLibraryEta: Bool = false,
//        publicAnime: Bool = false) {
//
//        super.configureWithAnime(anime, canFadeImages: canFadeImages, showEtaAsAired: showEtaAsAired, showLibraryEta: showLibraryEta, publicAnime: publicAnime)
//
//        self.anime = anime
//
//        if let progress = publicAnime ? anime.publicProgress : anime.progress {
//
//            watchedButton?.isEnabled = true
//            let title = FontAwesome.Watched.rawValue
//            watchedButton?.setTitle(title, for: UIControlState.normal)
//
//            userProgressLabel.text = "\(anime.type) · " + FontAwesome.Watched.rawValue + " \(progress.watchedEpisodes)/\(anime.episodes)   " + FontAwesome.Rated.rawValue + " \(progress.score)"
//
//            if let episodeImageView = episodeImageView {
//                if progress.myAnimeListList() == .Watching {
//                    setEpisodeImageView(anime, nextEpisode: progress.watchedEpisodes)
//                } else {
//                    episodeImageView.setImageFrom(urlString: anime.fanartThumbURLString() ?? "")
//                }
//            }
//
//            if progress.myAnimeListList() == .Completed || progress.myAnimeListList() == .Dropped || (progress.watchedEpisodes == anime.episodes && anime.episodes != 0) {
//                watchedButton?.isEnabled = false
//            }
//        }
//    }
//
//    func setEpisodeImageView(anime: Anime, nextEpisode: Int?) {
//
//        if let cancelToken = currentCancellationToken {
//            cancelToken.cancel()
//        }
//
//        let newCancelationToken = Operation()
//        currentCancellationToken = newCancelationToken
//
//        episodeImageView?.image = nil
//        episode = nil
//        anime.episodeList().continueWithExecutor(BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//            if newCancelationToken.cancelled {
//                return nil
//            }
//
//            guard let episodes = task.result as? [Episode],
//                let nextEpisode = nextEpisode, episodes.count > nextEpisode else {
//                    self.episodeImageView?.setImageFrom(urlString: anime.fanart ?? anime.imageUrl ?? "")
//                    return nil
//            }
//
//            let episode = episodes[nextEpisode]
//            self.episode = episode
//            self.episodeImageView?.setImageFrom(urlString: episode.imageURLString())
//
//            return nil
//        })
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func pressedEpisodeImageView(sender: AnyObject) {
//        if let episode = episode {
//            delegate?.cellPressedEpisodeThread(cell: self, anime: episode.anime, episode: episode)
//        }
//    }
    
}
