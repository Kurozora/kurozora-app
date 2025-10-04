//
//  EditProfileViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// TextFieldTag is used to identify the text fields in the EditProfileViewController.
enum TextFieldTag: Int {
	/// Indicates the username text field.
	case username
	/// Indicates the nickname text field.
	case nickname
}

/// ImageEditKind is used to determine which image view is currently being edited.
enum ImageEditKind {
	/// Indicates the profile image is being edited.
	case profile
	/// Indicates the banner image is being edited.
	case banner
	/// Indicates no image is being edited.
	case none
}

class EditProfileViewController: KViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bioTextView: KTextView!

	@IBOutlet weak var usernameTextField: KTextField!
	@IBOutlet weak var displayNameTextField: KTextField!

	@IBOutlet weak var selectBannerImageButton: KButton!
	@IBOutlet weak var placeholderBannerImageEditButton: UIButton!

	@IBOutlet weak var selectProfileImageButton: KButton!
	@IBOutlet weak var placeholderProfileImageEditButton: UIButton!

	@IBOutlet weak var profileBadgeStackView: ProfileBadgeStackView!
	@IBOutlet var containerViews: [UIView]!

	// MARK: - Properties
	var user: User! = User.current

	private lazy var imagePickerManager = ImagePickerManager(presenter: self)

	var imageEditKind: ImageEditKind = .none
	var placeholderText = "Describe yourself!"

	var originalUsernameText: String? {
		didSet {
			self.editedUsernameText = self.originalUsernameText
		}
	}
	var editedUsernameText: String?

	var originalNicknameText: String? {
		didSet {
			self.editedNicknameText = self.originalNicknameText
		}
	}
	var editedNicknameText: String?

	var originalBioText: String? {
		didSet {
			self.editedBioText = self.originalBioText
		}
	}
	var editedBioText: String?

	var originalProfileImage: UIImage! = UIImage() {
		didSet {
			self.editedProfileImage = self.originalProfileImage
		}
	}
	var editedProfileImage: UIImage! = UIImage()
	var editedProfileImageURL: URL?

	var originalBannerImage: UIImage! = UIImage() {
		didSet {
			self.editedBannerImage = self.originalBannerImage
		}
	}
	var editedBannerImage: UIImage! = UIImage()
	var editedBannerImageURL: URL?

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

		let canEditUsername = user.attributes.canChangeUsername ?? (user.attributes.isPro || user.attributes.isSubscribed)
		self.usernameTextField.text = user.attributes.slug
		self.usernameTextField.placeholder = user.attributes.slug
		self.usernameTextField.isEnabled = canEditUsername
		self.usernameTextField.clearButtonMode = canEditUsername ? .always : .never
		self.usernameTextField.alpha = canEditUsername ? 1.0 : 0.5
		self.usernameTextField.delegate = self

		self.displayNameTextField.text = user.attributes.username
		self.displayNameTextField.placeholder = user.attributes.username
		self.displayNameTextField.delegate = self

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
		self.originalUsernameText = self.usernameTextField.text
		self.originalNicknameText = self.displayNameTextField.text
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
		self.view.endEditing(true)
		self.updateProfileDetails()
	}

	/// Cancel profile changes.
	///
	/// - Parameter sender: The object requesting the cancellation of the edit mode.
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.confirmCancel(showingUpdate: self.hasChanges)
	}

	/// Select the profile image.
	///
	/// - Parameter sender: The object requesting the selection of the profile image.
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.imageEditKind = .profile
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedProfileImage.isEqual(to: self.placeholderImage()))
	}

	/// Select the banner image.
	///
	/// - Parameter sender: The object requesting the selection of the banner image.
	@IBAction func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.imageEditKind = .banner
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedBannerImage.isEqual(to: self.placeholderImage()))
	}
}

// MARK: - Configure Views
extension EditProfileViewController {
	private func configureViews() {
		self.configurePlaceholderViews()
		self.configureBannerImageView()
		self.configureContainerViews()
		self.configureProfileBadgeStackView()
	}

	private func configurePlaceholderViews() {
		self.placeholderProfileImageEditButton.layerCornerRadius = self.placeholderProfileImageEditButton.frame.size.height / 2
		self.placeholderBannerImageEditButton.layerCornerRadius = self.placeholderBannerImageEditButton.frame.size.height / 2
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

	private func configureProfileBadgeStackView() {
		self.profileBadgeStackView.delegate = self
	}
}

// MARK: - ImagePickerManagerDataSource
extension EditProfileViewController: ImagePickerManagerDataSource {
	func imagePickerManagerTitle() -> String {
		switch self.imageEditKind {
		case .profile:
			return "Profile Photo"
		case .banner:
			return "Banner Photo"
		case .none:
			return ""
		}
	}

	func imagePickerManagerSubtitle() -> String {
		switch self.imageEditKind {
		case .profile:
			return "Choose a photo that represents you!"
		case .banner:
			return "Choose a breathtaking photo!"
		case .none:
			return ""
		}
	}
}

// MARK: - ImagePickerManagerDelegate
extension EditProfileViewController: ImagePickerManagerDelegate {
	func placeholderImage() -> UIImage {
		switch self.imageEditKind {
		case .profile:
			self.user.attributes.profilePlaceholderImage
		case .banner:
			self.user.attributes.bannerPlaceholderImage
		case .none:
			UIImage()
		}
	}

	func imagePickerManager(didFinishPicking imageURL: URL, image: UIImage) {
		switch self.imageEditKind {
		case .profile:
			self.profileImageView.setImage(with: imageURL.absoluteString, placeholder: self.user.attributes.profilePlaceholderImage)
			self.editedProfileImageURL = imageURL
		case .banner:
			self.bannerImageView.setImage(with: imageURL.absoluteString, placeholder: self.user.attributes.bannerPlaceholderImage)
			self.editedBannerImageURL = imageURL
		case .none: break
		}

		// Reset selected image view
		self.imageEditKind = .none
	}

	func imagePickerManagerDidRemovePickedImage() {
		switch self.imageEditKind {
		case .profile:
			if !self.editedProfileImage.isEqual(to: self.placeholderImage()) {
				self.profileImageView.image = self.placeholderImage()
				self.editedProfileImage = self.profileImageView.image
			}
		case .banner:
			if !self.editedBannerImage.isEqual(to: self.placeholderImage()) {
				self.bannerImageView.image = self.placeholderImage()
				self.editedBannerImage = self.bannerImageView.image
			}
		case .none: break
		}

		// Reset selected image view
		self.imageEditKind = .none
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

extension EditProfileViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let textFieldTag = TextFieldTag(rawValue: textField.tag) else { return }

		switch textFieldTag {
		case .username:
			self.editedUsernameText = textField.text
		case .nickname:
			self.editedNicknameText = textField.text
		}
	}
}

// MARK: - UITextViewDelegate
extension EditProfileViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		self.editedBioText = textView.text
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

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		if url.absoluteString.starts(with: "https://kurozora.app/profile") {
			Task { [weak self] in
				guard let self = self else { return }
				let username = url.lastPathComponent
				guard let userIdentity = await self.getUserIdentity(username: username) else { return }
				let deeplink = url.absoluteString
					.replacingOccurrences(of: "https://kurozora.app/", with: "kurozora://")
					.replacingOccurrences(of: username, with: "\(userIdentity.id)")

				UIApplication.shared.kOpen(nil, deepLink: URL(string: deeplink))
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
