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
	// MARK: - Properties
	private(set) var profileImageView: ProfileImageView!
	private(set) var placeholderProfileImageEditButton: UIButton!

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

		self.configureTableHeaderView()
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

			self.presentAlertController(title: Trans.Onboarding.signUpAlertHeadline, message: Trans.Onboarding.signUpAlertSubheadline, defaultActionButtonTitle: Trans.done) { [weak self] _ in
				guard let self = self else { return }
				self.dismiss(animated: true) {
					self.onSignUp?()
				}
			}
		} catch let error as KKAPIError {
			self.presentAlertController(title: Trans.Onboarding.signUpErrorAlertHeadline, message: error.message)
			print(error.message)
		} catch {
			print(error.localizedDescription)
		}

		// Re-enable user interaction.
		self.disableUserInteraction(false)
	}

	// MARK: - Actions
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

	@objc func chooseImageButtonPressed(_ sender: UIButton) {
		self.imagePickerManager.chooseImageButtonPressed(sender, showingRemoveAction: !self.editedProfileImage.isEqual(to: self.placeholderImage()))
	}
}

// MARK: - Configure Views
private extension SignUpTableViewController {
	func configureTableHeaderView() {
		let headerView = UIView()
		headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 200)

		// Title label
		let titleLabel = KLabel()
		titleLabel.text = Trans.Onboarding.signUpHeadline
		titleLabel.font = .preferredFont(forTextStyle: .title1)
		titleLabel.textColor = .white
		titleLabel.textAlignment = .center
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(titleLabel)

		// Subtitle label
		let subtitleLabel = KLabel()
		subtitleLabel.text = Trans.Onboarding.signUpSubheadline
		subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
		subtitleLabel.textColor = .white
		subtitleLabel.textAlignment = .center
		subtitleLabel.numberOfLines = 0
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(subtitleLabel)

		// Circular view with profile image
		let circularView = CircularView()
		circularView.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(circularView)

		let profileImageView = ProfileImageView(frame: .zero)
		profileImageView.backgroundColor = UIColor(red: 0.584, green: 0.616, blue: 0.678, alpha: 1.0)
		profileImageView.translatesAutoresizingMaskIntoConstraints = false
		circularView.addSubview(profileImageView)
		self.profileImageView = profileImageView

		let overlayButton = KButton(type: .custom)
		overlayButton.clipsToBounds = true
		overlayButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
		overlayButton.setTitleColor(UIColor(red: 1, green: 0.576, blue: 0, alpha: 1), for: .normal)
		overlayButton.translatesAutoresizingMaskIntoConstraints = false
		overlayButton.addTarget(self, action: #selector(chooseImageButtonPressed(_:)), for: .touchUpInside)
		circularView.addSubview(overlayButton)

		// Pencil icon button
		let pencilButton = UIButton(type: .system)
		pencilButton.isUserInteractionEnabled = false
		pencilButton.backgroundColor = UIColor(white: 0.333, alpha: 1.0)
		pencilButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
		pencilButton.setImage(UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small)), for: .normal)
		pencilButton.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(pencilButton)
		self.placeholderProfileImageEditButton = pencilButton

		NSLayoutConstraint.activate([
			// Title label
			titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
			titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: headerView.layoutMarginsGuide.leadingAnchor),
			headerView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),

			// Subtitle label
			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			subtitleLabel.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
			subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: headerView.layoutMarginsGuide.leadingAnchor),
			headerView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: subtitleLabel.trailingAnchor),

			// Circular view
			circularView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
			circularView.centerXAnchor.constraint(equalTo: subtitleLabel.centerXAnchor),
			circularView.widthAnchor.constraint(equalToConstant: 80),
			circularView.heightAnchor.constraint(equalToConstant: 80),
			headerView.bottomAnchor.constraint(equalTo: circularView.bottomAnchor, constant: 10),

			// Profile image view
			profileImageView.topAnchor.constraint(equalTo: circularView.topAnchor),
			profileImageView.leadingAnchor.constraint(equalTo: circularView.leadingAnchor),
			profileImageView.trailingAnchor.constraint(equalTo: circularView.trailingAnchor),
			profileImageView.bottomAnchor.constraint(equalTo: circularView.bottomAnchor),

			// Overlay button
			overlayButton.topAnchor.constraint(equalTo: circularView.topAnchor),
			overlayButton.leadingAnchor.constraint(equalTo: circularView.leadingAnchor),
			overlayButton.trailingAnchor.constraint(equalTo: circularView.trailingAnchor),
			overlayButton.bottomAnchor.constraint(equalTo: circularView.bottomAnchor),

			// Pencil button
			pencilButton.topAnchor.constraint(equalTo: circularView.topAnchor),
			pencilButton.trailingAnchor.constraint(equalTo: circularView.trailingAnchor),
			pencilButton.widthAnchor.constraint(equalToConstant: 24),
			pencilButton.heightAnchor.constraint(equalToConstant: 24),
		])

		self.tableView.tableHeaderView = headerView
	}

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
