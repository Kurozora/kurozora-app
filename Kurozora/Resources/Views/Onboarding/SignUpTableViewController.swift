//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SignUpTableViewController: AccountOnboardingTableViewController, StoryboardInstantiable {
	static var storyboardName: String = "Onboarding"

	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var placeholderProfileImageEditButton: UIButton!

	// MARK: - Properties
	private lazy var imagePickerManager = ImagePickerManager(presenter: self)
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
	var editedProfileImageURL: URL?
	var isSIWA = false
	var onSignUp: (() -> Void)?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureViews()

		// Configure properties
		self.originalProfileImage = self.placeholderImage()
		self.accountOnboardingType = self.isSIWA ? .siwa : .signUp
	}

	// MARK: - Functions
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
			guard let username = textFieldArray.first??.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
			guard let emailAddress = textFieldArray[1]?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
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
			let username = textFieldArray.first??.text?.trimmingCharacters(in: .whitespacesAndNewlines)

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
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedProfileImage.isEqual(to: self.placeholderImage()))
	}
}

// MARK: - Configure Views
private extension SignUpTableViewController {
	func configureViews() {
		self.configurePlaceholderViews()
	}

	func configurePlaceholderViews() {
		self.placeholderProfileImageEditButton.layerCornerRadius = self.placeholderProfileImageEditButton.frame.size.height / 2
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

// MARK: - ImagePickerManagerDataSource
extension SignUpTableViewController: ImagePickerManagerDataSource {
	func imagePickerManagerTitle() -> String {
		return "Profile Photo"
	}

	func imagePickerManagerSubtitle() -> String {
		return "Choose a photo that represents you!"
	}
}

// MARK: - ImagePickerManagerDelegate
extension SignUpTableViewController: ImagePickerManagerDelegate {
	func placeholderImage() -> UIImage {
		#imageLiteral(resourceName: "Placeholders/User Profile")
	}

	func imagePickerManager(didFinishPicking imageURL: URL, image: UIImage) {
		self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: .Placeholders.userProfile)
		self.editedProfileImage = image
		self.editedProfileImageURL = imageURL
	}

	func imagePickerManagerDidRemovePickedImage() {
		if !self.editedProfileImage.isEqual(to: self.placeholderImage()) {
			self.profileImageView.image = self.placeholderImage()
			self.editedProfileImage = self.profileImageView.image
		}
	}
}
