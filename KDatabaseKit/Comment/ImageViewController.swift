//
//  ImageViewController.swift
//  KDatabaseKit
//
//  Created by Khoren Katklian on 17/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation

protocol ImageViewControllerDelegate: class {
    func imageViewControllerSelected(imageData: ImageData)
}

public class ImageViewController: UIViewController {
//
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var imageView: FLAnimatedImageView!
//
//    weak var delegate: ImageViewControllerDelegate?
//    var imageData: ImageData!
//    var animatedImage: FLAnimatedImage?
//
//    func initWith(imageData: ImageData) {
//        self.imageData = imageData
//    }
//
//    func initWith(imageData: ImageData, animatedImage: FLAnimatedImage) {
//        initWith(imageData: imageData)
//        self.animatedImage = animatedImage
//    }
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let animatedImage = animatedImage {
//            imageView.animatedImage = animatedImage
//        } else {
//            imageView.setImageFrom(urlString: imageData.url, animated: true)
//        }
//
//        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
//    }
//
//    override public func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
//    }
//
//    // MARK: - IBActions
//
//    @IBAction func backPressed(sender: AnyObject) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func selectPressed(sender: AnyObject) {
//        dismissViewControllerAnimated(true, completion: { () -> Void in
//            self.delegate?.imageViewControllerSelected(imageData: self.imageData)
//        })
//    }
//}
//
//extension ImageViewController: UIScrollViewDelegate {
//    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//
//    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//
//    }
}
