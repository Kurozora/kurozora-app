//
//  UIViewController+Image.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import AXPhotoViewer
import FLAnimatedImage

extension UIViewController {
    public func presentPhotoViewControllerWithURL(_ imageUrl: String?) {
        guard let imageURL = URL(string: imageUrl ?? "") else {return}
        
        let photo = [AXPhoto(
            attributedTitle: nil,
            attributedDescription: nil,
            attributedCredit: nil,
            url: imageURL)]
        
        // Set datasource
        let datasource = AXPhotosDataSource(photos: photo)
        
        // Create an instance of AXPhotosViewController
        let photosViewController = AXPhotosViewController(dataSource: datasource)
        
        // Present the video
        present(photosViewController, animated: true, completion: nil)
    }
}
