//
//  UserProfileManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation
import UIKit
//import RSKImageCropper
//import Bolts
//import Parse

public protocol UserProfileManagerDelegate: class {
    func selectedProfileImage(profileImage: UIImage)
    func selectedBannerImage(bannerImage: UIImage)
}

public class UserProfileManager: NSObject {
//
//    static let ImageMinimumSideSize: CGFloat = 120
//    static let ImageMaximumSideSize: CGFloat = 400
//
//    var viewController: UIViewController!
//    var delegate: UserProfileManagerDelegate?
//    var imagePicker: UIImagePickerController!
//    var selectingProfileImage = true
//
//    public func initWith(controller: UIViewController, delegate: UserProfileManagerDelegate) {
//        self.viewController = controller
//        self.delegate = delegate
//    }
//
//    public func selectProfileImage() {
//        selectingProfileImage = true
//        selectImage()
//    }
//
//    public func selectBanner() {
//        selectingProfileImage = false
//        selectImage()
//    }
//
//    func selectImage() {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
//            if imagePicker == nil {
//                imagePicker = UIImagePickerController()
//            }
//
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
//            imagePicker.allowsEditing = false
//
//            viewController.present(imagePicker, animated: true, completion: nil)
//        }
//    }
//
//    public func createUser(
//        viewController: UIViewController,
//        username: String,
//        password: String,
//        email: String,
//        profileImage: UIImage?,
//        user: User,
//        signInInWithFacebook: Bool) -> BFTask {
//
//        if !signInInWithFacebook &&
//            !password.validPassword(viewController: viewController) {
//            return BFTask(error: NSError(
//                domain: "Kurozora.App",
//                code: 700,
//                userInfo: ["error": "Password must be at least 6 characters long"])
//            )
//        }
//
//        if !email.validEmail(viewController: viewController) {
//            return BFTask(error: NSError(
//                domain: "Kurozora.App",
//                code: 700,
//                userInfo: ["error": "Email is invalid"])
//            )
//        }
//
//        if !username.validUsername(viewController: viewController) {
//            return BFTask(error: NSError(
//                domain: "Kurozora.App",
//                code: 700,
//                userInfo: ["error": "Username is invalid"])
//            )
//        }
//
//        return username
//            .usernameIsUnique()
//            .continueWithExecutor(
//                BFExecutor.mainThreadExecutor(),
//                withSuccessBlock: { (task: BFTask!) -> AnyObject! in
//
//                    if let users = task.result as? [User], users.count != 0 {
//                        let error = NSError(
//                            domain: "Kurozora.App",
//                            code: 700,
//                            userInfo: ["error": "User exists, try another one"]
//                        )
//                        return BFTask(error: error)
//                    }
//
//                    let createdWithFacebook: Bool
//
//                    // Fill user fields
//                    if user.username == nil {
//                        createdWithFacebook = false
//                        user.username = username.lowercaseString
//                        user.password = password
//                    } else {
//                        createdWithFacebook = true
//                    }
//
//                    user.aozoraUsername = username
//                    user.email = email
//                    user.profileImageThumb = self.profileImageThumbImageToPFFile(profileImage)
//
//                    // Add user detail object
//                    let userDetails = UserDetails()
//                    userDetails.profileImageRegular = self.profileImageRegularImageToPFFile(profileImage)
//                    userDetails.about = ""
//                    userDetails.planningAnimeCount = 0
//                    userDetails.watchingAnimeCount = 0
//                    userDetails.completedAnimeCount = 0
//                    userDetails.onHoldAnimeCount = 0
//                    userDetails.droppedAnimeCount = 0
//                    userDetails.gender = "Not specified"
//                    userDetails.joinDate = Date()
//                    userDetails.posts = 0
//                    userDetails.watchedTime = 0.0
//                    user.details = userDetails
//
//                    if createdWithFacebook {
//                        return user.saveInBackground()
//                    } else {
//                        return user.signUpInBackground()
//                    }
//
//            }).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
//
//                if let error = task.error {
//                    let errorMessage = error.userInfo["error"] as! String
//                    viewController.presentBasicAlertWithTitle("Error", message: errorMessage)
//                    return BFTask(error: NSError(domain: "", code: 0, userInfo: nil))
//                } else {
//                    return nil
//                }
//            })
//
//    }
//
//
//    public func updateUser(
//        viewController: UIViewController,
//        user: User,
//        email: String? = nil,
//        profileImage: UIImage? = nil,
//        bannerImage: UIImage? = nil,
//        about: String? = nil
//        ) -> BFTask {
//
//        if let email = email, !email.validEmail(viewController: viewController) {
//            return BFTask(error: NSError(domain: "", code: 0, userInfo: nil))
//        }
//
//        if let profileImage = profileImage {
//            user.profileImageThumb = self.profileImageThumbImageToPFFile(profileImage)
//            user.details.profileImageRegular = self.profileImageRegularImageToPFFile(profileImage)
//        }
//
//        if let email = email {
//            user.email = email
//        }
//
//        if let banner = banner, let profileImageRegularData = UIImagePNGRepresentation(banner) {
//            user.banner = PFFile(name:"banner.png", data: profileImageRegularData)
//        }
//
//        if let about = about {
//            user.details.about = about
//        }
//
//        return user.saveInBackground().continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
//
//            if let error = task.error {
//                let errorMessage = error.userInfo["error"] as! String
//                viewController.presentBasicAlertWithTitle("Error", message: errorMessage)
//                return BFTask(error: error)
//            } else {
//                return nil
//            }
//        })
//
//    }
//
//    // MARK: - Internal functions
//
//    func profileImageThumbImageToPFFile(profileImage: UIImage?) -> PFFile {
//        let profileImage = profileImage ?? UIImage(named: "default-avatar")!
//        let thumbProfileImage = UIImage.imageWithImage(profileImage, newSize: CGSize(width: UserProfileManager.ImageMinimumSideSize, height: UserProfileManager.ImageMinimumSideSize))
//        let profileImageThumbData = UIImagePNGRepresentation(thumbProfileImage)
//        return PFFile(name:"profileImageThumb.png", data: profileImageThumbData!)!
//    }
//
//    func profileImageRegularImageToPFFile(profileImage: UIImage?) -> PFFile {
//        let profileImage = profileImage ?? UIImage(named: "default-avatar")!
//        let regularProfileImage = UIImage.imageWithImage(profileImage, maxSize: CGSize(width: UserProfileManager.ImageMaximumSideSize, height: UserProfileManager.ImageMaximumSideSize))
//        let profileImageRegularData = UIImagePNGRepresentation(regularProfileImage)
//        return PFFile(name:"profileImageRegular.png", data: profileImageRegularData!)!
//    }
//
//}
//
//extension UserProfileManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    public func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
//        viewController.dismiss(animated: true, completion: { () -> Void in
//
//            if image.size.width < UserProfileManager.ImageMinimumSideSize || image.size.height < UserProfileManager.ImageMinimumSideSize {
//                self.viewController.presentBasicAlertWithTitle(title: "Pick a larger image", message: "Select an image with at least 120x120px")
//            } else {
//                let imageCropVC: RSKImageCropViewController!
//
//                if self.selectingProfileImage {
//                    imageCropVC = imageCropViewController(image: image)
//                } else {
//                    imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.Custom)
//                    imageCropVC.dataSource = self
//                }
//
//                imageCropVC.delegate = self
//                self.viewController.presentViewController(imageCropVC, animated: true, completion: nil)
//            }
//        })
//    }
//}
//
//extension UserProfileManager: RSKImageCropViewControllerDelegate {
//
//    public func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//
//        if selectingProfileImage {
//            delegate?.selectedProfileImage(profileImage: croppedImage)
//        } else {
//            delegate?.selectedBannerImage(bannerImage: croppedImage)
//        }
//    }
//
//    public func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
//}
//
//extension UserProfileManager: RSKImageCropViewControllerDataSource {
//
//    public func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController) -> CGRect {
//        let imageHeight: CGFloat = 120
//        let yPosition = (viewController.view.bounds.size.height - imageHeight) / 2
//        return CGRect(x: 0, y: yPosition, width: viewController.view.bounds.size.width, height: imageHeight)
//    }
//
//    public func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController) -> UIBezierPath {
//        let imageHeight: CGFloat = 120
//        let yPosition = (viewController.view.bounds.size.height - imageHeight) / 2
//        return UIBezierPath(rect: CGRect(x: 0, y: yPosition, width: viewController.view.bounds.size.width, height: imageHeight))
//    }
//
//    public func imageCropViewControllerCustomMovementRect(controller: RSKImageCropViewController) -> CGRect {
//        return controller.maskRect
//    }
}
