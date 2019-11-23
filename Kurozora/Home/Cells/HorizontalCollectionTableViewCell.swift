//
//  HorizontalCollectionTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/03/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class HorizontalCollectionTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

	// MARK: - Properties
	var cellStyle: HorizontalCollectionCellStyle! {
		didSet {
			guard let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
			let contentSize = calculateCellStyleSize(for: collectionViewLayout)
			collectionViewHeightConstraint.constant = contentSize.height + 10
			self.setNeedsUpdateConstraints()
			self.layoutIfNeeded()
		}
	}
	var shows: [ShowDetailsElement]? = nil {
		didSet {
			collectionView.reloadData()
		}
	}
	var genres: [GenreElement]? = nil {
		didSet {
			shows = nil
			collectionView.reloadData()
		}
	}
	var contentOffset: CGFloat! {
		get {
			return collectionView.contentOffset.x
		}
		set {
			collectionView.setContentOffset(CGPoint(x: newValue >= 0 ? newValue : 0, y: 0), animated: false)
		}
	}
	var contentSize: CGSize?

	// MARK: - Functions
	@available(iOS 13.0, macCatalyst 13.0, *)
	private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		guard let identifier = configuration.identifier as? [String: Any] else { return nil }
		guard let indexPath = identifier["IndexPath"] as? IndexPath else { return nil }
		guard let exploreBaseCollectionViewCell = collectionView.cellForItem(at: indexPath) as? ExploreBaseCollectionViewCell else { return nil }

		let parameters = UIPreviewParameters()
		parameters.backgroundColor = .clear

		let view = exploreBaseCollectionViewCell.bannerImageView ?? exploreBaseCollectionViewCell.posterImageView ?? exploreBaseCollectionViewCell
		return UITargetedPreview(view: view, parameters: parameters)
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func makeContextMenu(for show: ShowDetailsElement?) -> UIMenu {
		let title = show?.title ?? ""

		let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
			guard let showID = show?.id else { return }
			var shareText: [String] = ["https://kurozora.app/anime/\(showID)\nYou should watch this anime via @KurozoraApp"]

			if !title.isEmpty {
				shareText = ["https://kurozora.app/anime/\(showID)\nYou should watch \"\(title)\" via @KurozoraApp"]
			}

			let activityVC = UIActivityViewController(activityItems: shareText, applicationActivities: [])

			if (self.parentViewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
				self.parentViewController?.present(activityVC, animated: true, completion: nil)
			}
		}

		// Create our menu with both the edit menu and the share action
		return UIMenu(title: "", children: [share])
	}
}

// MARK: - UICollectionViewDataSource
extension HorizontalCollectionTableViewCell: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if shows != nil {
			guard let showsCount = shows?.count else { return 0 }
			return showsCount
		}

		guard let genresCount = genres?.count else { return 0 }
		return genresCount
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let exploreCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellStyle.identifierString, for: indexPath) as! ExploreBaseCollectionViewCell

		if shows != nil {
			exploreCell.showDetailsElement = shows?[indexPath.row]
		} else {
			exploreCell.genreElement = genres?[indexPath.row]
		}

		#if !targetEnvironment(macCatalyst)
		if traitCollection.forceTouchCapability == .available {
			self.parentViewController?.registerForPreviewing(with: exploreCell, sourceView: exploreCell)
		}
		#endif

		return exploreCell
	}
}

// MARK: - UICollectionViewDelegate
extension HorizontalCollectionTableViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.8,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
		}, completion: nil)
	}

	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		UIView.animate(withDuration: 0.5,
					   delay: 0.0,
					   usingSpringWithDamping: 0.4,
					   initialSpringVelocity: 0.2,
					   options: .beginFromCurrentState,
					   animations: {
						cell?.transform = CGAffineTransform.identity
		}, completion: nil)
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		guard let selectedShow = self.shows?[indexPath.row] else { return nil }
		guard let selectedShowID = selectedShow.id else { return nil }

		let identifier = ["IndexPath": indexPath, "ShowID": selectedShowID] as NSCopying
		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(for: selectedShow)
		})
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		makeTargetedPreview(for: configuration)
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
		makeTargetedPreview(for: configuration)
	}

	@available(iOS 13.0, macCatalyst 13.0, *)
	func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		guard let identifier = configuration.identifier as? [String: Any] else { return }
		guard let showID = identifier["ShowID"] as? Int else { return }

		if let homeTableViewController = self.parentViewController as? HomeCollectionViewController {
			animator.addCompletion {
				homeTableViewController.performSegue(withIdentifier: "ShowDetailsSegue", sender: showID)
			}
		}
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HorizontalCollectionTableViewCell: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		guard let collectionViewLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
		var cellStyleSize = cellStyle.sizeValue

		cellStyleSize = calculateCellStyleSize(for: collectionViewLayout)

		return cellStyleSize
	}

	func calculateCellStyleSize(for collectionViewLayout: UICollectionViewFlowLayout) -> CGSize {
		var cellStyleSize = contentSize ?? cellStyle.sizeValue

		if cellStyleSize != contentSize {
			if UIScreen.main.bounds.size.width < cellStyleSize.width {
				let sizeWidth = self.frame.width - collectionViewLayout.minimumInteritemSpacing - collectionViewLayout.sectionInset.left - collectionViewLayout.sectionInset.right
				let sizeHeight = (cellStyleSize.height / cellStyleSize.width) * sizeWidth + collectionViewLayout.sectionInset.bottom
				cellStyleSize = CGSize(width: sizeWidth, height: sizeHeight)
			}
		}

		contentSize = cellStyleSize
		return cellStyleSize
	}
}
