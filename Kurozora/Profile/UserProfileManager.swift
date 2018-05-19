//
//  UserProfileManager.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import RSKImageCropper
//import Bolts
//import Parse
import KDatabaseKit

public protocol UserProfileManagerDelegate: class {
    func selectedAvatar(avatar: UIImage)
    func selectedBanner(banner: UIImage)
}

public class UserProfileManager: NSObject {
//
//    static let ImageMinimumSideSize: CGFloat = 120
//    static let ImageMaximumSideSize: CGFloat = 400
//
//    var viewController: UIViewController!
//    var delegate: UserProfileManagerDelegate?
//    var imagePicker: UIImagePickerController!
//    var selectingAvatar = true
//
//    public func initWith(controller: UIViewController, delegate: UserProfileManagerDelegate) {
//        self.viewController = controller
//        self.delegate = delegate
//    }
//
//    public func selectAvatar() {
//        selectingAvatar = true
//        selectImage()
//    }
//
//    public func selectBanner() {
//        selectingAvatar = false
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
//        avatar: UIImage?,
//        user: User,
//        loginInWithFacebook: Bool) -> BFTask {
//
//        if !loginInWithFacebook &&
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
//                    user.avatarThumb = self.avatarThumbImageToPFFile(avatar)
//
//                    // Add user detail object
//                    let userDetails = UserDetails()
//                    userDetails.avatarRegular = self.avatarRegularImageToPFFile(avatar)
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
//        avatar: UIImage? = nil,
//        banner: UIImage? = nil,
//        about: String? = nil
//        ) -> BFTask {
//
//        if let email = email, !email.validEmail(viewController: viewController) {
//            return BFTask(error: NSError(domain: "", code: 0, userInfo: nil))
//        }
//
//        if let avatar = avatar {
//            user.avatarThumb = self.avatarThumbImageToPFFile(avatar)
//            user.details.avatarRegular = self.avatarRegularImageToPFFile(avatar)
//        }
//
//        if let email = email {
//            user.email = email
//        }
//
//        if let banner = banner, let avatarRegularData = UIImagePNGRepresentation(banner) {
//            user.banner = PFFile(name:"banner.png", data: avatarRegularData)
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
//    func avatarThumbImageToPFFile(avatar: UIImage?) -> PFFile {
//        let avatar = avatar ?? UIImage(named: "default-avatar")!
//        let thumbAvatar = UIImage.imageWithImage(avatar, newSize: CGSize(width: UserProfileManager.ImageMinimumSideSize, height: UserProfileManager.ImageMinimumSideSize))
//        let avatarThumbData = UIImagePNGRepresentation(thumbAvatar)
//        return PFFile(name:"avatarThumb.png", data: avatarThumbData!)!
//    }
//
//    func avatarRegularImageToPFFile(avatar: UIImage?) -> PFFile {
//        let avatar = avatar ?? UIImage(named: "default-avatar")!
//        let regularAvatar = UIImage.imageWithImage(avatar, maxSize: CGSize(width: UserProfileManager.ImageMaximumSideSize, height: UserProfileManager.ImageMaximumSideSize))
//        let avatarRegularData = UIImagePNGRepresentation(regularAvatar)
//        return PFFile(name:"avatarRegular.png", data: avatarRegularData!)!
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
//                if self.selectingAvatar {
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
//
//    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
//    }
//}
//
//extension UserProfileManager: RSKImageCropViewControllerDelegate {
//
//    public func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//
//        if selectingAvatar {
//            delegate?.selectedAvatar(avatar: croppedImage)
//        } else {
//            delegate?.selectedBanner(banner: croppedImage)
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
