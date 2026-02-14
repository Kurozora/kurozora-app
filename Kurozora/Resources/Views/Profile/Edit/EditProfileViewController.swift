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
	// MARK: - Views
	private var scrollView: UIScrollView!
	private var contentView: UIView!

	private var bannerContainerView: UIView!
	private var bannerImageView: UIImageView!
	private var bannerEditIndicatorButton: UIButton!
	private var bannerTapButton: UIButton!

	private var profileHeaderView: UIView!
	private var profilePhotoWrapperView: UIView!
	private var profileImageView: ProfileImageView!
	private var profileTapButton: UIButton!
	private var placeholderProfileImageEditButton: UIButton!

	private var usernameLabel: KLabel!
	private var profileBadgeStackView: ProfileBadgeStackView!

	private var formStackView: UIStackView!

	private var usernameContainerView: UIView!
	private var usernameSectionLabel: KSecondaryLabel!
	private var usernameTextField: KTextField!

	private var displayNameContainerView: UIView!
	private var displayNameSectionLabel: KSecondaryLabel!
	private var displayNameTextField: KTextField!

	private var bioContainerView: UIView!
	private var bioSectionLabel: KSecondaryLabel!
	private var bioTextView: KTextView!

	private var containerViews: [UIView]!

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
	init(user: User) {
		super.init(nibName: nil, bundle: nil)
		self.user = user
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.configureView()
		self.configureProfile()

		self.navigationController?.presentationController?.delegate = self
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

	// MARK: - Actions
	private func saveButtonPressed() {
		self.view.endEditing(true)
		self.updateProfileDetails()
	}

	private func cancelButtonPressed() {
		self.confirmCancel(showingUpdate: self.hasChanges)
	}

	private func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.imageEditKind = .profile
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedProfileImage.isEqual(to: self.placeholderImage()))
	}

	private func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.imageEditKind = .banner
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedBannerImage.isEqual(to: self.placeholderImage()))
	}
}

// MARK: - Configure Views
private extension EditProfileViewController {
	func configureView() {
		self.configureNavigationBarItems()
		self.configureViews()
	}

	func configureNavigationBarItems() {
		self.title = "Profile"

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .stop, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.cancelButtonPressed()
		})

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .save, primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }
			self.saveButtonPressed()
		})
	}

	func configureViews() {
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.configureBannerImageView()
		self.configureContainerViews()
		self.configureProfileBadgeStackView()
	}

	func configureViewHierarchy() {
		// Scroll view
		self.scrollView = UIScrollView()
		self.scrollView.translatesAutoresizingMaskIntoConstraints = false
		self.scrollView.showsHorizontalScrollIndicator = false
		self.view.addSubview(self.scrollView)

		// Content view
		self.contentView = UIView()
		self.contentView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.backgroundColor = .clear
		self.scrollView.addSubview(self.contentView)

		// Banner container
		self.bannerContainerView = UIView()
		self.bannerContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.bannerContainerView.clipsToBounds = true
		self.contentView.addSubview(self.bannerContainerView)

		self.bannerImageView = UIImageView()
		self.bannerImageView.translatesAutoresizingMaskIntoConstraints = false
		self.bannerImageView.contentMode = .scaleAspectFill
		self.bannerImageView.clipsToBounds = true
		self.bannerContainerView.addSubview(self.bannerImageView)

		self.bannerEditIndicatorButton = UIButton(type: .system)
		self.bannerEditIndicatorButton.translatesAutoresizingMaskIntoConstraints = false
		self.bannerEditIndicatorButton.isUserInteractionEnabled = false
		self.bannerEditIndicatorButton.backgroundColor = UIColor(white: 0.333, alpha: 1.0)
		self.bannerEditIndicatorButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
		self.bannerEditIndicatorButton.configuration = {
			var config = UIButton.Configuration.plain()
			config.image = UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
			return config
		}()
		self.bannerEditIndicatorButton.layerCornerRadius = 12
		self.bannerContainerView.addSubview(self.bannerEditIndicatorButton)

		self.bannerTapButton = UIButton(type: .custom)
		self.bannerTapButton.translatesAutoresizingMaskIntoConstraints = false
		self.bannerTapButton.addAction(UIAction { [weak self] action in
			guard let self = self, let sender = action.sender as? UIButton else { return }
			self.selectBannerImageButtonPressed(sender)
		}, for: .touchUpInside)
		self.bannerContainerView.addSubview(self.bannerTapButton)

		// Profile header
		self.profileHeaderView = UIView()
		self.profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.profileHeaderView)

		// Profile photo wrapper
		self.profilePhotoWrapperView = UIView()
		self.profilePhotoWrapperView.translatesAutoresizingMaskIntoConstraints = false
		self.profileHeaderView.addSubview(self.profilePhotoWrapperView)

		let profileCircularView = CircularView(frame: .zero)
		profileCircularView.translatesAutoresizingMaskIntoConstraints = false
		profileCircularView.clipsToBounds = true
		self.profilePhotoWrapperView.addSubview(profileCircularView)

		self.profileImageView = ProfileImageView(frame: .zero)
		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
		self.profileImageView.contentMode = .scaleToFill
		self.profileImageView.clipsToBounds = true
		profileCircularView.addSubview(self.profileImageView)

		self.profileTapButton = UIButton(type: .custom)
		self.profileTapButton.translatesAutoresizingMaskIntoConstraints = false
		self.profileTapButton.clipsToBounds = true
		self.profileTapButton.addAction(UIAction { [weak self] action in
			guard let self = self, let sender = action.sender as? UIButton else { return }
			self.selectProfileImageButtonPressed(sender)
		}, for: .touchUpInside)
		profileCircularView.addSubview(self.profileTapButton)

		self.placeholderProfileImageEditButton = UIButton(type: .system)
		self.placeholderProfileImageEditButton.translatesAutoresizingMaskIntoConstraints = false
		self.placeholderProfileImageEditButton.isUserInteractionEnabled = false
		self.placeholderProfileImageEditButton.backgroundColor = UIColor(white: 0.333, alpha: 1.0)
		self.placeholderProfileImageEditButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
		self.placeholderProfileImageEditButton.configuration = {
			var config = UIButton.Configuration.plain()
			config.image = UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
			return config
		}()
		self.placeholderProfileImageEditButton.layerCornerRadius = 12
		self.profilePhotoWrapperView.addSubview(self.placeholderProfileImageEditButton)

		// Username label
		self.usernameLabel = KLabel()
		self.usernameLabel.translatesAutoresizingMaskIntoConstraints = false
		self.usernameLabel.font = .boldSystemFont(ofSize: 17)
		self.usernameLabel.isHidden = true
		self.usernameLabel.numberOfLines = 2
		self.usernameLabel.lineBreakMode = .byTruncatingTail
		self.profileHeaderView.addSubview(self.usernameLabel)

		// Profile badge stack view
		self.profileBadgeStackView = ProfileBadgeStackView()
		self.profileBadgeStackView.translatesAutoresizingMaskIntoConstraints = false
		self.profileBadgeStackView.spacing = 4
		self.profileHeaderView.addSubview(self.profileBadgeStackView)

		// Form stack view
		self.formStackView = UIStackView()
		self.formStackView.translatesAutoresizingMaskIntoConstraints = false
		self.formStackView.axis = .vertical
		self.formStackView.spacing = UIStackView.spacingUseSystem
		self.contentView.addSubview(self.formStackView)

		// Username container
		self.usernameContainerView = UIView()
		self.usernameContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.formStackView.addArrangedSubview(self.usernameContainerView)

		self.usernameSectionLabel = KSecondaryLabel()
		self.usernameSectionLabel.translatesAutoresizingMaskIntoConstraints = false
		self.usernameSectionLabel.text = "USERNAME"
		self.usernameSectionLabel.font = .preferredFont(forTextStyle: .caption1)
		self.usernameContainerView.addSubview(self.usernameSectionLabel)

		self.usernameTextField = KTextField()
		self.usernameTextField.translatesAutoresizingMaskIntoConstraints = false
		self.usernameTextField.font = .systemFont(ofSize: 14)
		self.usernameTextField.borderStyle = .roundedRect
		self.usernameTextField.textContentType = .username
		self.usernameTextField.tag = TextFieldTag.username.rawValue
		self.usernameContainerView.addSubview(self.usernameTextField)

		// Display name container
		self.displayNameContainerView = UIView()
		self.displayNameContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.formStackView.addArrangedSubview(self.displayNameContainerView)

		self.displayNameSectionLabel = KSecondaryLabel()
		self.displayNameSectionLabel.translatesAutoresizingMaskIntoConstraints = false
		self.displayNameSectionLabel.text = "DISPLAY NAME"
		self.displayNameSectionLabel.font = .preferredFont(forTextStyle: .caption1)
		self.displayNameContainerView.addSubview(self.displayNameSectionLabel)

		self.displayNameTextField = KTextField()
		self.displayNameTextField.translatesAutoresizingMaskIntoConstraints = false
		self.displayNameTextField.font = .systemFont(ofSize: 14)
		self.displayNameTextField.borderStyle = .roundedRect
		self.displayNameTextField.clearButtonMode = .always
		self.displayNameTextField.textContentType = .username
		self.displayNameTextField.tag = TextFieldTag.nickname.rawValue
		self.displayNameContainerView.addSubview(self.displayNameTextField)

		// Bio container
		self.bioContainerView = UIView()
		self.bioContainerView.translatesAutoresizingMaskIntoConstraints = false
		self.formStackView.addArrangedSubview(self.bioContainerView)

		self.bioSectionLabel = KSecondaryLabel()
		self.bioSectionLabel.translatesAutoresizingMaskIntoConstraints = false
		self.bioSectionLabel.text = "ABOUT ME"
		self.bioSectionLabel.font = .preferredFont(forTextStyle: .caption1)
		self.bioContainerView.addSubview(self.bioSectionLabel)

		self.bioTextView = KTextView()
		self.bioTextView.translatesAutoresizingMaskIntoConstraints = false
		self.bioTextView.isScrollEnabled = false
		self.bioTextView.tag = 2
		self.bioContainerView.addSubview(self.bioTextView)

		// Container views collection
		self.containerViews = [self.usernameContainerView, self.displayNameContainerView, self.bioContainerView]

		// Store circular view reference for constraints
		self._profileCircularView = profileCircularView
	}

	// Store reference for constraints
	private var _profileCircularView: CircularView? {
		get { objc_getAssociatedObject(self, &AssociatedKeys.circularView) as? CircularView }
		set { objc_setAssociatedObject(self, &AssociatedKeys.circularView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	func configureViewConstraints() {
		guard let profileCircularView = self._profileCircularView else { return }

		NSLayoutConstraint.activate([
			// Scroll view - pinned to safe area
			self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

			// Content view
			self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

			// Banner container
			self.bannerContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.bannerContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.bannerContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.bannerContainerView.heightAnchor.constraint(equalToConstant: 150),

			// Banner image view
			self.bannerImageView.topAnchor.constraint(equalTo: self.bannerContainerView.topAnchor),
			self.bannerImageView.leadingAnchor.constraint(equalTo: self.bannerContainerView.leadingAnchor),
			self.bannerImageView.trailingAnchor.constraint(equalTo: self.bannerContainerView.trailingAnchor),
			self.bannerImageView.bottomAnchor.constraint(equalTo: self.bannerContainerView.bottomAnchor),

			// Banner edit indicator
			self.bannerEditIndicatorButton.topAnchor.constraint(equalTo: self.bannerContainerView.topAnchor, constant: 8),
			self.bannerEditIndicatorButton.trailingAnchor.constraint(equalTo: self.bannerContainerView.trailingAnchor, constant: -8),
			self.bannerEditIndicatorButton.widthAnchor.constraint(equalToConstant: 24),
			self.bannerEditIndicatorButton.heightAnchor.constraint(equalTo: self.bannerEditIndicatorButton.widthAnchor),

			// Banner tap button
			self.bannerTapButton.topAnchor.constraint(equalTo: self.bannerImageView.topAnchor),
			self.bannerTapButton.leadingAnchor.constraint(equalTo: self.bannerImageView.leadingAnchor),
			self.bannerTapButton.trailingAnchor.constraint(equalTo: self.bannerImageView.trailingAnchor),
			self.bannerTapButton.bottomAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor),

			// Profile header
			self.profileHeaderView.centerYAnchor.constraint(equalTo: self.bannerContainerView.bottomAnchor),
			self.profileHeaderView.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
			self.profileHeaderView.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
			self.profileHeaderView.heightAnchor.constraint(equalToConstant: 98),

			// Profile photo wrapper
			self.profilePhotoWrapperView.topAnchor.constraint(greaterThanOrEqualTo: self.profileHeaderView.topAnchor),
			self.profilePhotoWrapperView.leadingAnchor.constraint(equalTo: self.profileHeaderView.layoutMarginsGuide.leadingAnchor),
			self.profilePhotoWrapperView.bottomAnchor.constraint(equalTo: self.profileBadgeStackView.bottomAnchor),

			// Circular view
			profileCircularView.topAnchor.constraint(equalTo: self.profilePhotoWrapperView.topAnchor),
			profileCircularView.leadingAnchor.constraint(equalTo: self.profilePhotoWrapperView.leadingAnchor),
			profileCircularView.trailingAnchor.constraint(equalTo: self.profilePhotoWrapperView.trailingAnchor),
			profileCircularView.bottomAnchor.constraint(equalTo: self.profilePhotoWrapperView.bottomAnchor),
			profileCircularView.widthAnchor.constraint(equalToConstant: 80),
			profileCircularView.heightAnchor.constraint(equalToConstant: 80),

			// Profile image view
			self.profileImageView.topAnchor.constraint(equalTo: profileCircularView.topAnchor),
			self.profileImageView.leadingAnchor.constraint(equalTo: profileCircularView.leadingAnchor),
			self.profileImageView.trailingAnchor.constraint(equalTo: profileCircularView.trailingAnchor),
			self.profileImageView.bottomAnchor.constraint(equalTo: profileCircularView.bottomAnchor),

			// Profile tap button
			self.profileTapButton.topAnchor.constraint(equalTo: profileCircularView.topAnchor),
			self.profileTapButton.leadingAnchor.constraint(equalTo: profileCircularView.leadingAnchor),
			self.profileTapButton.trailingAnchor.constraint(equalTo: profileCircularView.trailingAnchor),
			self.profileTapButton.bottomAnchor.constraint(equalTo: profileCircularView.bottomAnchor),

			// Placeholder profile image edit button
			self.placeholderProfileImageEditButton.trailingAnchor.constraint(equalTo: profileCircularView.trailingAnchor),
			self.placeholderProfileImageEditButton.topAnchor.constraint(equalTo: profileCircularView.topAnchor),
			self.placeholderProfileImageEditButton.widthAnchor.constraint(equalToConstant: 24),
			self.placeholderProfileImageEditButton.heightAnchor.constraint(equalTo: self.placeholderProfileImageEditButton.widthAnchor),

			// Username label
			self.usernameLabel.leadingAnchor.constraint(equalTo: self.profilePhotoWrapperView.trailingAnchor, constant: 8),
			self.usernameLabel.topAnchor.constraint(equalTo: self.bannerContainerView.bottomAnchor, constant: 8),

			// Profile badge stack view
			self.profileBadgeStackView.leadingAnchor.constraint(equalTo: self.usernameLabel.leadingAnchor),
			self.profileBadgeStackView.topAnchor.constraint(equalTo: self.usernameLabel.bottomAnchor),
			self.profileBadgeStackView.bottomAnchor.constraint(equalTo: self.profileHeaderView.bottomAnchor),
			self.profileBadgeStackView.heightAnchor.constraint(equalToConstant: 20),

			// Form stack view
			self.formStackView.topAnchor.constraint(equalTo: self.profileHeaderView.bottomAnchor, constant: 8),
			self.formStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.formStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.formStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),

			// Username container
			self.usernameSectionLabel.topAnchor.constraint(equalTo: self.usernameContainerView.topAnchor, constant: 8),
			self.usernameSectionLabel.leadingAnchor.constraint(equalTo: self.usernameContainerView.leadingAnchor, constant: 8),
			self.usernameSectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.usernameContainerView.trailingAnchor),

			self.usernameTextField.topAnchor.constraint(equalTo: self.usernameSectionLabel.bottomAnchor, constant: 8),
			self.usernameTextField.leadingAnchor.constraint(equalTo: self.usernameContainerView.leadingAnchor, constant: 8),
			self.usernameTextField.trailingAnchor.constraint(equalTo: self.usernameContainerView.trailingAnchor, constant: -8),
			self.usernameTextField.bottomAnchor.constraint(equalTo: self.usernameContainerView.bottomAnchor, constant: -8),
			self.usernameTextField.heightAnchor.constraint(equalToConstant: 34),

			// Display name container
			self.displayNameSectionLabel.topAnchor.constraint(equalTo: self.displayNameContainerView.topAnchor, constant: 8),
			self.displayNameSectionLabel.leadingAnchor.constraint(equalTo: self.displayNameContainerView.leadingAnchor, constant: 8),
			self.displayNameSectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.displayNameContainerView.trailingAnchor),

			self.displayNameTextField.topAnchor.constraint(equalTo: self.displayNameSectionLabel.bottomAnchor, constant: 8),
			self.displayNameTextField.leadingAnchor.constraint(equalTo: self.displayNameContainerView.leadingAnchor, constant: 8),
			self.displayNameTextField.trailingAnchor.constraint(equalTo: self.displayNameContainerView.trailingAnchor, constant: -8),
			self.displayNameTextField.bottomAnchor.constraint(equalTo: self.displayNameContainerView.bottomAnchor, constant: -8),
			self.displayNameTextField.heightAnchor.constraint(equalToConstant: 34),

			// Bio container
			self.bioSectionLabel.topAnchor.constraint(equalTo: self.bioContainerView.topAnchor, constant: 8),
			self.bioSectionLabel.leadingAnchor.constraint(equalTo: self.bioContainerView.leadingAnchor, constant: 8),
			self.bioSectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.bioContainerView.trailingAnchor),

			self.bioTextView.topAnchor.constraint(equalTo: self.bioSectionLabel.bottomAnchor, constant: 8),
			self.bioTextView.leadingAnchor.constraint(equalTo: self.bioContainerView.layoutMarginsGuide.leadingAnchor),
			self.bioTextView.trailingAnchor.constraint(equalTo: self.bioContainerView.layoutMarginsGuide.trailingAnchor),
			self.bioTextView.bottomAnchor.constraint(equalTo: self.bioContainerView.bottomAnchor, constant: -8),
			self.bioTextView.heightAnchor.constraint(equalToConstant: 100),
		])
	}

	func configureBannerImageView() {
		self.bannerImageView.theme_backgroundColor = KThemePicker.tintColor.rawValue
	}

	func configureContainerViews() {
		self.containerViews.forEach { containerView in
			containerView.layerCornerRadius = 12.0
			containerView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}

	func configureProfileBadgeStackView() {
		self.profileBadgeStackView.delegate = self
	}
}

// MARK: - Associated Keys
private struct AssociatedKeys {
	nonisolated(unsafe) static var circularView: UInt8 = 0
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
		let badgeViewController = BadgeViewController()
		badgeViewController.profileBadge = profileBadge

		badgeViewController.popoverPresentationController?.sourceView = button
		badgeViewController.popoverPresentationController?.sourceRect = button.bounds

		self.present(badgeViewController, animated: true, completion: nil)
	}
}
