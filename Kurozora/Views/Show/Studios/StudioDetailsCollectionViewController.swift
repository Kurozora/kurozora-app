//
//  StudioDetailsCollectionViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioDetailsCollectionViewController: KCollectionViewController {
	// MARK: - Properties
	var studioID: Int = 0
	var studio: Studio! {
		didSet {
			_prefersActivityIndicatorHidden = true
		}
	}
	var shows: [Show] = []
	var dataSource: UICollectionViewDiffableDataSource<StudioDetailsSection, Int>! = nil

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

		DispatchQueue.global(qos: .background).async {
			self.fetchStudios()
		}
	}

	// MARK: - Functions
	func fetchStudios() {
		KService.getDetails(forStudioID: studioID, including: ["shows"]) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let studios):
				self.studio = studios.first
				self.shows = studios.first?.relationships?.shows?.data ?? []
				self.configureDataSource()
			case .failure: break
			}
		}
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.studioDetailsCollectionViewController.showDetailsSegue.identifier {
			if let showDetailCollectionViewController = segue.destination as? ShowDetailsCollectionViewController {
				if let show = (sender as? BaseLockupCollectionViewCell)?.show {
					showDetailCollectionViewController.showID = show.id
				}
			}
		} else if segue.identifier == R.segue.studioDetailsCollectionViewController.showsListSegue.identifier {
			if let showsListCollectionViewController = segue.destination as? ShowsListCollectionViewController {
				showsListCollectionViewController.studioID = self.studio.id
			}
		}
	}
}

// MARK: - UICollectionViewDelegate
extension StudioDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let baseLockupCollectionViewCell = collectionView.cellForItem(at: indexPath) as? BaseLockupCollectionViewCell {
			performSegue(withIdentifier: R.segue.studioDetailsCollectionViewController.showDetailsSegue, sender: baseLockupCollectionViewCell)
		}
	}
}

// MARK: - InformationButtonCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: InformationButtonCollectionViewCellDelegate {
	func informationButtonCollectionViewCell(_ cell: InformationButtonCollectionViewCell, didPressButton button: UIButton) {
		guard cell.studioDetailsInformationSection == .website else { return }
		guard let websiteURL = self.studio.attributes.websiteUrl?.url else { return }
		UIApplication.shared.kOpen(websiteURL)
	}
}

// MARK: - TextViewCollectionViewCellDelegate
extension StudioDetailsCollectionViewController: TextViewCollectionViewCellDelegate {
	func textViewCollectionViewCell(_ cell: TextViewCollectionViewCell, didPressButton button: UIButton) {
		if let synopsisKNavigationController = R.storyboard.synopsis.instantiateInitialViewController() {
			if let synopsisViewController = synopsisKNavigationController.viewControllers.first as? SynopsisViewController {
				synopsisViewController.title = cell.textViewCollectionViewCellType.stringValue
				synopsisViewController.synopsis = self.studio.attributes.about
			}
			synopsisKNavigationController.modalPresentationStyle = .fullScreen
			self.present(synopsisKNavigationController, animated: true)
		}
	}
}

// MARK: - TitleHeaderCollectionReusableViewDelegate
extension StudioDetailsCollectionViewController: TitleHeaderCollectionReusableViewDelegate {
	func titleHeaderCollectionReusableView(_ reusableView: TitleHeaderCollectionReusableView, didPressButton button: UIButton) {
		self.performSegue(withIdentifier: reusableView.segueID, sender: reusableView.indexPath)
	}
}
