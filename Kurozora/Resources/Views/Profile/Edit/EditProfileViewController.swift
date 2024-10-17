//
//  EditProfileViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum TextFieldTag: Int {
	case username
	case nickname
	case biography
}

class EditProfileViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bioTextView: KTextView!

	@IBOutlet weak var usernameTextView: KTextView!
	@IBOutlet weak var displayNameTextView: KTextView!

	@IBOutlet weak var selectBannerImageButton: KButton!
	@IBOutlet weak var placeholderBannerImageEditButton: UIButton!

	@IBOutlet weak var selectProfileImageButton: KButton!
	@IBOutlet weak var placeholderProfileImageEditButton: UIButton!

	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet var containerViews: [UIView]!

	// MARK: - Properties
	var user: User! = User.current

	var currentImageView: String = ""
	var placeholderText = "Describe yourself!"

	var originalUsernameText: String? = nil {
		didSet {
			self.editedUsernameText = self.originalUsernameText
		}
	}
	var editedUsernameText: String? = nil

	var originalNicknameText: String? = nil {
		didSet {
			self.editedNicknameText = self.originalNicknameText
		}
	}
	var editedNicknameText: String? = nil

	var originalBioText: String? = nil {
		didSet {
			self.editedBioText = self.originalBioText
		}
	}
	var editedBioText: String? = nil

	var originalProfileImage: UIImage! = UIImage() {
		didSet {
			self.editedProfileImage = self.originalProfileImage
		}
	}
	var editedProfileImage: UIImage! = UIImage()
	var editedProfileImageURL: URL? = nil

	var originalBannerImage: UIImage! = UIImage() {
		didSet {
			self.editedBannerImage = self.originalBannerImage
		}
	}
	var editedBannerImage: UIImage! = UIImage()
	var editedBannerImageURL: URL? = nil

	var hasChanges: Bool {
		return self.originalUsernameText != self.editedUsernameText
		|| self.originalNicknameText != self.editedNicknameText
		|| self.originalBioText != self.editedBioText
		|| self.profileImageHasChanges
		|| self.bannerImageHasChanges
	}
	var profileImageHasChanges: Bool {
		return !self.originalProfileImage.isEqual(to: self.editedProfileImage)
	}
	var bannerImageHasChanges: Bool {
		return !self.originalBannerImage.isEqual(to: self.editedBannerImage)
	}

	// MARK: - Initializers
	/// Initialize a new instance of EditProfileViewController with the given user object.
	///
	/// - Parameter user: The `User` object to use when initializing the view controller.
	///
	/// - Returns: an initialized instance of EditProfileViewController.
	static func `init`(with user: User) -> EditProfileViewController {
		if let editProfileViewController = R.storyboard.profile.editProfileViewController() {
			editProfileViewController.user = user
			return editProfileViewController
		}

		fatalError("Failed to instantiate EditProfileViewController with the given User object.")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureViews()
		self.configureProfile()
	}

	// MARK: - Functions
	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		guard let user = self.user else { return }

		// Configure username
		self.usernameLabel.text = user.attributes.username
		self.usernameLabel.isHidden = false

		self.usernameTextView.text = user.attributes.slug
		self.usernameTextView.isEditable = user.attributes.canChangeUsername ?? (user.attributes.isPro || user.attributes.isSubscribed)
		self.usernameTextView.delegate = self

		self.displayNameTextView.text = user.attributes.username
		self.displayNameTextView.isEditable = true
		self.displayNameTextView.delegate = self

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure banner image
		user.attributes.bannerImage(imageView: self.bannerImageView)

		// Configure user bio
		self.bioTextView.setAttributedText(user.attributes.biographyMarkdown?.markdownAttributedString())
		self.bioTextView.isScrollEnabled = true
		self.bioTextView.isEditable = true
		self.bioTextView.delegate = self

		// Badges
		self.profileBadgeStackView.configure(for: user)

		// Set the original values
		self.originalUsernameText = self.usernameTextView.text
		self.originalNicknameText = self.displayNameTextView.text
		self.originalBioText = self.bioTextView.text
		self.originalProfileImage = self.profileImageView.image
		self.originalBannerImage = self.bannerImageView.image
	}

	func cancelProfileEdit() {
		// User doesn't want changes to be saved, pute everything back.
		self.bioTextView.text = self.originalBioText
		self.profileImageView.image = self.originalProfileImage.copy() as? UIImage
		self.bannerImageView.image = self.originalBannerImage.copy() as? UIImage

		self.dismiss(animated: true)
	}

	/// Confirm whether to cancel the profile update.
	///
	/// - Parameter showingUpdate: Indicates whether to show the update option.
	func confirmCancel(showingUpdate: Bool) {
		// Present a UIAlertController as an action sheet to have the user confirm losing any recent changes.
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }

			// Only ask if the user wants to send if they attempt to pull to dismiss, not if they tap Cancel.
			if showingUpdate {
				// Send action.
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.update, style: .default) { _ in
					self.updateProfileDetails()
				})
			}

			// Discard action.
			actionSheetAlertController.addAction(UIAlertAction(title: Trans.discard, style: .destructive) { _ in
				self.cancelProfileEdit()
			})
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = self.navigationItem.leftBarButtonItem
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Update the user's profile details.
	///
	/// Sends `nil` if nothing should be updated.
	/// Sends an empty instance of the object to delete it.
	/// Otherwise sends the data that should be updated.
	func updateProfileDetails() {
		let username = self.originalUsernameText == self.editedUsernameText ? nil : self.editedUsernameText
		let nickname = self.originalNicknameText == self.editedNicknameText ? nil : self.editedNicknameText
		let biography = self.originalBioText == self.editedBioText ? nil : self.editedBioText

		// If `originalProfileImage` is equal to `editedProfileImage`, then no change has happened: return `nil`
		// If `originalProfileImage` is not equal to `editedProfileImage`, then something changed: return `editedProfileImage`
		// If `editedProfileImage` is equal to the user's placeholder, then the user removed the current profile image: return `UIImage()`
		let profileImageRequest: ProfileUpdateImageRequest?
		var profileImageURL: URL? = URL(string: "kurozora://profileimage")
		if let indefinitiveProfileImage = self.originalProfileImage.isEqual(to: self.editedProfileImage) ? nil : self.editedProfileImage {
			profileImageURL = indefinitiveProfileImage.isEqual(to: self.user.attributes.profilePlaceholderImage) ? nil : self.editedProfileImageURL
			profileImageRequest = profileImageURL == nil ? .delete : .update(url: profileImageURL)
		} else {
			profileImageRequest = nil
		}

		// If `originalBannerImage` is equal to `editedBannerImage`, then no change has happened: return `nil`
		// If `originalBannerImage` is not equal to `editedBannerImage`, then something changed: return `editedBannerImage`
		// If `editedBannerImage` is equal to the user's placeholder, then the user removed the current banner image: return `UIImage()`
		let bannerImageRequest: ProfileUpdateImageRequest?
		var bannerImageURL: URL? = URL(string: "kurozora://bannerimage")
		if let indefinitiveBannerImage = self.originalBannerImage.isEqual(to: self.editedBannerImage) ? nil : self.editedBannerImage {
			bannerImageURL = indefinitiveBannerImage.isEqual(to: self.user.attributes.bannerPlaceholderImage) ? nil : self.editedBannerImageURL
			bannerImageRequest = bannerImageURL == nil ? .delete : .update(url: bannerImageURL)
		} else {
			bannerImageRequest = nil
		}

		Task {
			do {
				let profileUpdateRequest = ProfileUpdateRequest(
					username: username,
					nickname: nickname,
					biography: biography,
					profileImageRequest: profileImageRequest,
					bannerImageRequest: bannerImageRequest,
					preferredLanguage: nil,
					preferredTVRating: nil,
					preferredTimezone: nil
				)

				// Perform update request.
				let userUpdateResponse = try await KService.updateInformation(profileUpdateRequest).value
				User.current?.attributes.update(using: userUpdateResponse.data)

				self.dismiss(animated: true)
			} catch let error as KKAPIError {
				self.presentAlertController(title: "Error Updating Profile", message: error.message)
				print(error.localizedDescription)
			} catch {
				print(error.localizedDescription)
			}
		}
	}

	// MARK: - IBActions
	/// Save profile changes.
	///
	/// - Parameter sender: The object requesting the changes to be applied.
	@IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
		self.updateProfileDetails()
	}

	/// Cancel profile changes.
	///
	/// - Parameter sender: The object requesting the cancelation of the edit mode.
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.confirmCancel(showingUpdate: self.hasChanges)
	}
}

// MARK: - Confgiure Views
extension EditProfileViewController {
	private func configureViews() {
		self.configurePlaceholderViews()
		self.configureBannerImageView()
		self.configureContainerViews()
		self.configureProileBadgeStackView()
	}

	private func configurePlaceholderViews() {
		self.placeholderProfileImageEditButton.layerCornerRadius = self.placeholderProfileImageEditButton.height / 2
		self.placeholderBannerImageEditButton.layerCornerRadius = self.placeholderBannerImageEditButton.height / 2
	}

	private func configureBannerImageView() {
		self.bannerImageView.theme_backgroundColor = KThemePicker.tintColor.rawValue
	}

	private func configureContainerViews() {
		self.containerViews.forEach { containerView in
			containerView.layerCornerRadius = 12.0
			containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	private func configureProileBadgeStackView() {
		self.profileBadgeStackView.delegate = self
	}
}

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if self.currentImageView == "profile" {
			if let originalImage = info[.originalImage] as? UIImage, let user = User.current {
				self.editedProfileImage = originalImage

				if let imageURL = info[.imageURL] as? URL {
					self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: user.attributes.profilePlaceholderImage)
					self.editedProfileImageURL = imageURL
				} else {
					// Create a temporary image path
					let imageName = UUID().uuidString
					let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName, conformingTo: .image)

					// Save the image into the temporary path
					let data = originalImage.jpegData(compressionQuality: 0.1)
					try? data?.write(to: imageURL, options: [.atomic])

					// Save the image path
					self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: user.attributes.profilePlaceholderImage)
					self.editedProfileImageURL = imageURL
				}
			}
		} else if self.currentImageView == "banner" {
			if let originalImage = info[.originalImage] as? UIImage, let user = User.current {
				self.editedBannerImage = originalImage

				if let imageURL = info[.imageURL] as? URL {
					self.bannerImageView.setImage(with: imageURL.absoluteString, placeholder: user.attributes.bannerPlaceholderImage)
					self.editedBannerImageURL = imageURL
				} else {
					// Create a temporary image path
					let imageName = UUID().uuidString
					let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent(imageName, conformingTo: .image)

					// Save the image into the temporary path
					let data = originalImage.jpegData(compressionQuality: 0.1)
					try? data?.write(to: imageURL, options: [.atomic])

					// Save the image path
					self.bannerImageView.setImage(with: imageURL.absoluteString, placeholder: user.attributes.bannerPlaceholderImage)
					self.editedBannerImageURL = imageURL
				}
			}
		}

		// Reset selcted image view
		self.currentImageView = ""

		// Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			let imagePicker = UIImagePickerController()
			imagePicker.sourceType = .camera
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			self.presentAlertController(title: "Well, this is awkward.", message: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self
		self.present(imagePicker, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = "profile"

		let actionSheetAlertController = UIAlertController.actionSheet(title: "Profile Photo", message: "Choose an awesome photo 😉") { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if !self.editedProfileImage.isEqual(to: self.user.attributes.profilePlaceholderImage) {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
					self.profileImageView.image = self.user.attributes.profilePlaceholderImage
					self.editedProfileImage = self.profileImageView.image
				}))
			}
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
			popoverController.permittedArrowDirections = .up
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}

	@IBAction func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = "banner"

		let actionSheetAlertController = UIAlertController.actionSheet(title: "Banner Photo", message: "Choose a breathtaking photo 🌄") { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			actionSheetAlertController.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
				self.openCamera()
			}))

			actionSheetAlertController.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
				self.openPhotoLibrary()
			}))

			if !self.editedBannerImage.isEqual(to: self.user.attributes.bannerPlaceholderImage) {
				actionSheetAlertController.addAction(UIAlertAction(title: Trans.remove, style: .destructive, handler: { _ in
					self.bannerImageView.image = self.user.attributes.bannerPlaceholderImage
					self.editedBannerImage = self.bannerImageView.image
				}))
			}
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.sourceView = sender
			popoverController.sourceRect = sender.bounds
			popoverController.permittedArrowDirections = .up
		}

		self.present(actionSheetAlertController, animated: true, completion: nil)
	}
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension EditProfileViewController: UIAdaptivePresentationControllerDelegate {
	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		// The system calls this delegate method whenever the user attempts to pull down to dismiss and `isModalInPresentation` is false.
		// Clarify the user's intent by asking whether they want to cancel or update.
		self.confirmCancel(showingUpdate: true)
	}
}

// MARK: - UITextViewDelegate
extension EditProfileViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		guard let textFieldTag = TextFieldTag(rawValue: textView.tag) else { return }

		switch textFieldTag {
		case .username:
			self.editedUsernameText = textView.text
		case .nickname:
			self.editedNicknameText = textView.text
		case .biography:
			self.editedBioText = textView.text
		}
	}

	func getUserIdentity(username: String) async -> UserIdentity? {
		do {
			let userIdentityResponse = try await KService.searchUsers(for: username).value
			return userIdentityResponse.data.first
		} catch {
			print("-----", error.localizedDescription)
			return nil
		}
	}

	func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if URL.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = URL.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = URL.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")
					.url

				UIApplication.shared.kOpen(nil, deepLink: deeplink)
			}

			return false
		}

		return true
	}
}

// MARK: - ProfileBadgeStackViewDelegate
extension EditProfileViewController: ProfileBadgeStackViewDelegate {
	func profileBadgeStackView(_ view: ProfileBadgeStackView, didPress button: UIButton, for profileBadge: ProfileBadge) {
		if let badgeViewController = R.storyboard.badge.instantiateInitialViewController() {
			badgeViewController.profileBadge = profileBadge

			badgeViewController.popoverPresentationController?.sourceView = button
			badgeViewController.popoverPresentationController?.sourceRect = button.bounds

			self.present(badgeViewController, animated: true, completion: nil)
		}
	}
}
