//
//  EpisodeDetailsCollectionViewController+UICollectionViewDelegate.swift
//  Kurozora
//
//  Created by Khoren Katklian on 27/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

extension EpisodeDetailsCollectionViewController {
	override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		guard let sectionHeaderReusableView = view as? TitleHeaderCollectionReusableView else { return }
		guard let episodeDetailSection = EpisodeDetail.Section(rawValue: indexPath.section) else { return }
		sectionHeaderReusableView.delegate = self
		sectionHeaderReusableView.configure(withTitle: episodeDetailSection.stringValue, indexPath: indexPath)
	}
}
