//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView
import MobileCoreServices

class SignUpTableViewController: AccountOnboardingTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var selectButton: KButton!

	// MARK: - Properties
	lazy var imagePicker = UIImagePickerController()
	var profileImageFilePath: String? = nil
	var isSIWA = false

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure properties
		self.accountOnboardingType = isSIWA ? .siwa : .signUp
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			if User.isPro {
				imagePicker.mediaTypes = [(kUTTypeGIF as String), (kUTTypePNG as String), (kUTTypeJPEG as String)]
			} else {
				imagePicker.mediaTypes = [(kUTTypePNG as String), (kUTTypeJPEG as String)]
			}
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			SCLAlertView().showWarning("Well, this is awkward.", subTitle: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self
		self.present(imagePicker, animated: true, completion: nil)
	}

	/// Fetches the user's profile details.
	func getProfileDetails() {
		KService.getProfileDetails { result in
			switch result {
			case .success:
				// Save user in keychain.
				if let username = User.current?.attributes.username {
					try? KurozoraDelegate.shared.keychain.set(KService.authenticationKey, key: username)
					UserSettings.set(username, forKey: .selectedAccount)
				}
			case .failure: break
			}
		}
	}

	//MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		switch self.accountOnboardingType {
		case .signUp:
			guard let username = textFieldArray.first??.trimmedText else { return }
			guard let emailAddress = textFieldArray[1]?.trimmedText else { return }
			guard let password = textFieldArray.last??.text else { return }
			let profileImage = profileImageView.image

			KService.signUp(withUsername: username, emailAddress: emailAddress, password: password, profileImage: profileImage) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success:
					let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
					alertController.showSuccess("Hooray!", subTitle: "Account created successfully! Please check your email for confirmation.")
					alertController.addButton("Done", action: {
						self.dismiss(animated: true, completion: nil)
					})
				case .failure: break
				}
			}
		case .siwa:
			let username = textFieldArray.first??.trimmedText

			KService.updateInformation(profileImageFilePath: profileImageFilePath, username: username) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success:
					// Get user details after completing account setup.
					self.getProfileDetails()

					let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
					alertController.showSuccess("Hooray!", subTitle: "Account created successfully!")
					alertController.addButton("Done", action: {
						self.dismiss(animated: true, completion: nil)
					})
				case .failure: break
				}
			}
		default: break
		}
	}

	@IBAction func chooseImageButtonPressed(_ sender: UIButton) {
		let alert = UIAlertController(title: "Profile Photo", message: "Choose an awesome photo 😉", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		default:
			break
		}

		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - KTableViewControllerDataSource
extension SignUpTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			OnboardingTextFieldTableViewCell.self,
			OnboardingFooterTableViewCell.self
		]
	}
}

//MARK: - UIImagePickerControllerDelegate
extension SignUpTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.profileImageView.image = editedImage
		}

		if let imageURL = info[.imageURL] as? URL {
			profileImageFilePath = imageURL.absoluteString
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
