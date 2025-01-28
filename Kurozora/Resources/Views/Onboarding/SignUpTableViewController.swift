//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

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
	var editedProfileImageURL: URL? = nil
	var isSIWA = false
	var onSignUp: (() -> Void)?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure properties
		self.originalProfileImage = #imageLiteral(resourceName: "Placeholders/User Profile")
		self.accountOnboardingType = self.isSIWA ? .siwa : .signUp
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			self.imagePicker.sourceType = .camera
			self.imagePicker.delegate = self
			self.present(self.imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		self.imagePicker.sourceType = .photoLibrary
		self.imagePicker.delegate = self
		self.present(self.imagePicker, animated: true, completion: nil)
	}

	/// Fetches the user's profile details.
	func getProfileDetails() async {
		do {
			_ = try await KService.getProfileDetails()

			// Save user in keychain.
			if let slug = User.current?.attributes.slug {
				try? SharedDelegate.shared.keychain.set(KService.authenticationKey, key: slug)
				UserSettings.set(slug, forKey: .selectedAccount)
			}
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	func signUp(withUsername username: String, emailAddress: String, password: String, profileImage: UIImage?) async {
		do {
			_ = try await KService.signUp(withUsername: username, emailAddress: emailAddress, password: password, profileImage: profileImage).value

			self.presentAlertController(title: Trans.signUpAlertHeadline, message: Trans.signUpAlertSubheadline, defaultActionButtonTitle: Trans.done) { [weak self] _ in
				guard let self = self else { return }
				self.dismiss(animated: true) {
					self.onSignUp?()
				}
			}
		} catch let error as KKAPIError {
			self.presentAlertController(title: Trans.signUpErrorAlertHeadline, message: error.message)
			print(error.message)
		} catch {
			print(error.localizedDescription)
		}

		// Re-enable user interaction.
		self.disableUserInteraction(false)
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
			Task { [weak self] in
				guard let self = self else { return }
				await self.signUp(withUsername: username, emailAddress: emailAddress, password: password, profileImage: profileImage)
			}
		case .siwa:
			let username = textFieldArray.first??.trimmedText

			// If `originalProfileImage` is equal to `editedProfileImage`, then no change has happened: return `nil`
			// If `originalProfileImage` is not equal to `editedProfileImage`, then something changed: return `editedProfileImage`
			let profileImageURL = self.originalProfileImage.isEqual(to: self.editedProfileImage) ? nil : self.editedProfileImageURL
			let profileImageRequest: ProfileUpdateImageRequest? = profileImageURL == nil ? nil : .update(url: profileImageURL)

			// Disable user interaction.
			self.disableUserInteraction(true)

			Task {
				do {
					let profileUpdateRequest = ProfileUpdateRequest(username: nil, nickname: username, biography: nil, profileImageRequest: profileImageRequest, bannerImageRequest: nil, preferredLanguage: nil, preferredTVRating: nil, preferredTimezone: nil)

					// Perform information update request.
					let userUpdateResponse = try await KService.updateInformation(profileUpdateRequest).value
					User.current?.attributes.update(using: userUpdateResponse.data)

					// Get user details after completing account setup.
					await self.getProfileDetails()

					// Present welcome message.
					self.presentAlertController(title: "Hooray!", message: "Your account was successfully created!", defaultActionButtonTitle: Trans.done) { [weak self] _ in
						guard let self = self else { return }
						self.dismiss(animated: true) {
							self.onSignUp?()
						}
					}
				} catch {
					print(error.localizedDescription)
				}

				// Re-enable user interaction.
				self.disableUserInteraction(false)
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
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
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
		if let imageURL = info[.imageURL] as? URL, let originalImage = info[.originalImage] as? UIImage {
			self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: R.image.placeholders.userProfile()!)
			self.editedProfileImage = originalImage
			self.editedProfileImageURL = imageURL
		}

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
