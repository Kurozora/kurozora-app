//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class RegisterTableViewController: BaseOnboardingTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var shadowView: UIView!
	@IBOutlet weak var profileImageView: UIImageView! {
		didSet {
			profileImageView.theme_borderColor = KThemePicker.borderColor.rawValue
		}
	}
	@IBOutlet weak var selectButton: UIButton! {
		didSet {
			selectButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	// MARK: - Properties
	lazy var imagePicker = UIImagePickerController()

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingType = .register

		// Apply shadow
		self.shadowView.applyShadow(cornerRadius: profileImageView.bounds.height / 2)
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "RegisterTableViewController")
	}

	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
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

	//MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		let username = textFieldArray[0]?.trimmedText
		let email = textFieldArray[1]?.trimmedText
		let password = textFieldArray[2]?.text
		let profileImage = profileImageView.image

		KService.shared.register(withUsername: username, email: email, password: password, profileImage: profileImage) { (success) in
			if success {
				let alertController = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
				alertController.showSuccess("Hooray!", subTitle: "Account created successfully! Please check your email for confirmation!")
				alertController.addButton("Done", action: {
					self.navigationController?.popViewController(animated: true)
					self.dismiss(animated: true, completion: nil)
				})
			}
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

//MARK: - UIImagePickerControllerDelegate
extension RegisterTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.profileImageView.image = editedImage
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
