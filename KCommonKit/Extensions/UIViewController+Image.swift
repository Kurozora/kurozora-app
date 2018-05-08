//
//  UIViewController+Image.swift
//  KCommonKit
//
//  Created by Khoren Katklian on 02/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import Foundation
//import Lightbox
//
//extension UIViewController {
//
//    public func presentImageViewController(imageView: UIImageView, imageUrl: NSURL) {
//
//        let imageInfo = JTSImageInfo()
//        if let image = imageView.image {
//            imageInfo.image = image
//        }
//
//        imageInfo.imageURL = imageUrl
//
//        imageInfo.referenceRect = imageView.frame
//        imageInfo.referenceView = imageView
//
//        let controller = LightboxController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
//        controller.interactionsDelegate = self
//        controller.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
//    }
//}
//
//extension UIViewController: JTSImageViewControllerInteractionsDelegate {
//    public func imageViewerDidLongPress(imageViewer: JTSImageViewController!, atRect rect: CGRect) {
//
//        let imageUrl = imageViewer.imageInfo.imageURL
//
//        guard let imageData = NSData(contentsOfURL: imageUrl) else {
//            return
//        }
//        let objectsToShare = [imageData]
//
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        activityVC.excludedActivityTypes = [UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList,UIActivityTypePrint];
//        imageViewer.presentViewController(activityVC, animated: true, completion: nil)
//    }
//}
