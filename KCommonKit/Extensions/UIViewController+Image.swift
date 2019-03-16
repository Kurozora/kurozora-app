//
//  UIViewController+Image.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import AXPhotoViewer
import FLAnimatedImage

extension UIViewController {
    public func presentPhotoViewControllerWith(url image: String?) {
        guard let imageUrl = URL(string: image ?? "") else {return}
        
        let photoUrl = [AXPhoto(url: imageUrl)]
        
        // Set datasource
        let datasource = AXPhotosDataSource(photos: photoUrl)
        
        // Create an instance of AXPhotosViewController
        let photosViewController = AXPhotosViewController(dataSource: datasource)
        
        // Present the video
        present(photosViewController, animated: true, completion: nil)
    }
    
    public func presentPhotoViewControllerWith(string image: String?) {
        guard let image = image else {return}
        
        let photoUrl = [AXPhoto(image: UIImage(named: image))]
        
        // Set datasource
        let datasource = AXPhotosDataSource(photos: photoUrl)
        
        // Create an instance of AXPhotosViewController
        let photosViewController = AXPhotosViewController(dataSource: datasource)
        
        // Present the video
        present(photosViewController, animated: true, completion: nil)
    }
}
