//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import UniformTypeIdentifiers

class SignUpTableViewController: AccountOnboardingTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var selectButton: KButton!

	// MARK: - Properties
	lazy var imagePicker = UIImagePickerController()
	var originalProfileImage: UIImage! = UIImage() {
		didSet {
			self.editedProfileImage = self.originalProfileImage
		}
	}
	var editedProfileImage: UIImage! = UIImage() {
		didSet {
			self.viewIfLoaded?.setNeedsLayout()
		}
	}
	var isSIWA = false

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure properties
		self.originalProfileImage = #imageLiteral(resourceName: "Placeholders/User Profile")
		self.accountOnboardingType = isSIWA ? .siwa : .signUp
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
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

	/**
		Disables or enables the user interaction on the current view. Also shows a loading indicator.

		- Parameter disable: Indicates whether to disable the interaction.
	*/
	func disableUserInteraction(_ disable: Bool) {
		self.navigationItem.hidesBackButton = disable
		self.navigationItem.rightBarButtonItem?.isEnabled = !disable
		self._prefersActivityIndicatorHidden = !disable
		self.view.isUserInteractionEnabled = !disable
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		switch self.accountOnboardingType {
		case .signUp:
			guard let username = textFieldArray.first??.trimmedText else { return }
			guard let emailAddress = textFieldArray[1]?.trimmedText else { return }
			guard let password = textFieldArray.last??.text else { return }
			let profileImage = !self.originalProfileImage.isEqual(to: self.editedProfileImage) ? self.editedProfileImage : nil

			// Disable user interaction.
			self.disableUserInteraction(true)

			// Perform sign up request.
			KService.signUp(withUsername: username, emailAddress: emailAddress, password: password, profileImage: profileImage) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success:
					// Re-enable user interaction.
					self.disableUserInteraction(false)

					// Present welcome message.
					self.presentAlertController(title: "Hooray!", message: "Account created successfully! Please check your email for confirmation.", defaultActionButtonTitle: "Done") { [weak self] _ in
						self?.dismiss(animated: true, completion: nil)
					}
				case .failure:
					// Re-enable user interaction.
					self.disableUserInteraction(false)
				}
			}
		case .siwa:
			let username = textFieldArray.first??.trimmedText

			// If `originalProfileImage` is equal to `editedProfileImage`, then no change has happened: return `nil`
			// If `originalProfileImage` is not equal to `editedProfileImage`, then something changed: return `editedProfileImage`
			let profileImage = self.originalProfileImage.isEqual(to: self.editedProfileImage) ? nil : self.editedProfileImage

			// Disable user interaction.
			self.disableUserInteraction(true)

			// Perform information update request.
			KService.updateInformation(profileImage: profileImage, username: username) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success:
					// Get user details after completing account setup.
					self.getProfileDetails()

					// Re-enable user interaction.
					self.disableUserInteraction(false)

					// Present welcome message.
					self.presentAlertController(title: "Hooray!", message: "Your account was successfully created!", defaultActionButtonTitle: "Done") { [weak self] _ in
						self?.dismiss(animated: true, completion: nil)
					}
				case .failure:
					// Re-enable user interaction.
					self.disableUserInteraction(false)
				}
			}
		default: break
		}
	}

	@IBAction func chooseImageButtonPressed(_ sender: UIButton) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: "Profile Photo", message: "Choose an awesome photo 😉") { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if !self.editedProfileImage.isEqual(to: #imageLiteral(resourceName: "Placeholders/User Profile")) {
				actionSheetAlertController.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
					self.profileImageView.image = #imageLiteral(resourceName: "Placeholders/User Profile")
					self.editedProfileImage = self.profileImageView.image
				}))
			}

			if let popoverController = actionSheetAlertController.popoverPresentationController {
				popoverController.sourceView = sender
				popoverController.sourceRect = sender.bounds
				popoverController.permittedArrowDirections = .up
			}
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
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

// MARK: - UIImagePickerControllerDelegate
extension SignUpTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.profileImageView.image = editedImage
			self.editedProfileImage = editedImage
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
