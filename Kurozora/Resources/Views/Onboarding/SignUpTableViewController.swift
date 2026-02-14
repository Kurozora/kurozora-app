//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class SignUpTableViewController: AccountOnboardingTableViewController {
	// MARK: - Properties
	private let headerView = UIView()
	private let titleLabel = KLabel()
	private let subtitleLabel = KLabel()
	private let circularView = CircularView()
	private let profileImageView = ProfileImageView(frame: .zero)
	private let overlayButton = KButton()
	private let placeholderProfileImageEditButton = UIButton()

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

		self.configureView()

		// Configure properties
		self.originalProfileImage = self.placeholderImage()
		self.accountOnboardingType = self.isSIWA ? .siwa : .signUp
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.updateTableHeaderWidth()
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
	func configureView() {
		self.configureViews()
		self.configureViewHierarchy()
		self.configureViewConstraints()
		self.tableView.tableHeaderView = self.headerView
	}

	func configureViews() {
		self.configureTableHeaderView()
		self.configureTitleLabel()
		self.configureSubtitleLabel()
		self.configureCircularView()
		self.configureProfileImageView()
		self.configureOverlayButton()
		self.configurePlaceholderViews()
	}

	func configureTableHeaderView() {
		self.headerView.frame = CGRect(x: 0, y: 0, width: 0, height: 200)
	}

	private func updateTableHeaderWidth() {
		guard let headerView = self.tableView.tableHeaderView else { return }
		let width = self.tableView.bounds.width
		guard width > 0 else { return }

		if headerView.frame.width != width {
			headerView.frame.size.width = width
			self.tableView.tableHeaderView = headerView
		}
	}

	func configureTitleLabel() {
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.text = Trans.Onboarding.signUpHeadline
		self.titleLabel.font = .preferredFont(forTextStyle: .title1)
		self.titleLabel.textAlignment = .center
	}

	func configureSubtitleLabel() {
		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.text = Trans.Onboarding.signUpSubheadline
		self.subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
		self.subtitleLabel.textAlignment = .center
		self.subtitleLabel.numberOfLines = 0
	}

	func configureCircularView() {
		self.circularView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureProfileImageView() {
		self.profileImageView.translatesAutoresizingMaskIntoConstraints = false
	}

	func configureOverlayButton() {
		self.overlayButton.translatesAutoresizingMaskIntoConstraints = false
		self.overlayButton.clipsToBounds = true
		self.overlayButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
		self.overlayButton.setTitleColor(UIColor(red: 1, green: 0.576, blue: 0, alpha: 1), for: .normal)
		self.overlayButton.addTarget(self, action: #selector(self.chooseImageButtonPressed(_:)), for: .touchUpInside)
	}

	func configurePlaceholderViews() {
		self.placeholderProfileImageEditButton.translatesAutoresizingMaskIntoConstraints = false
		self.placeholderProfileImageEditButton.layerCornerRadius = 12
		self.placeholderProfileImageEditButton.backgroundColor = UIColor(white: 0.333, alpha: 1.0)
		self.placeholderProfileImageEditButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
		self.placeholderProfileImageEditButton.setImage(UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small)), for: .normal)
		self.placeholderProfileImageEditButton.isUserInteractionEnabled = false
	}

	func configureViewHierarchy() {
		self.headerView.addSubview(self.titleLabel)
		self.headerView.addSubview(self.subtitleLabel)
		self.headerView.addSubview(self.circularView)

		self.circularView.addSubview(self.profileImageView)
		self.circularView.addSubview(self.overlayButton)

		self.headerView.addSubview(self.placeholderProfileImageEditButton)
	}

	func configureViewConstraints() {
		NSLayoutConstraint.activate([
			// Title label
			self.titleLabel.topAnchor.constraint(equalTo: self.headerView.topAnchor, constant: 20),
			self.titleLabel.centerXAnchor.constraint(equalTo: self.headerView.centerXAnchor),
			self.titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.headerView.layoutMarginsGuide.leadingAnchor),
			self.headerView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor),

			// Subtitle label
			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
			self.subtitleLabel.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor),
			self.subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.headerView.layoutMarginsGuide.leadingAnchor),
			self.headerView.layoutMarginsGuide.trailingAnchor.constraint(greaterThanOrEqualTo: self.subtitleLabel.trailingAnchor),

			// Circular view
			self.circularView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 30),
			self.circularView.centerXAnchor.constraint(equalTo: self.subtitleLabel.centerXAnchor),
			self.circularView.widthAnchor.constraint(equalToConstant: 80),
			self.circularView.heightAnchor.constraint(equalToConstant: 80),
			self.headerView.bottomAnchor.constraint(equalTo: self.circularView.bottomAnchor, constant: 10),

			// Profile image view
			self.profileImageView.topAnchor.constraint(equalTo: self.circularView.topAnchor),
			self.profileImageView.leadingAnchor.constraint(equalTo: self.circularView.leadingAnchor),
			self.profileImageView.trailingAnchor.constraint(equalTo: self.circularView.trailingAnchor),
			self.profileImageView.bottomAnchor.constraint(equalTo: self.circularView.bottomAnchor),

			// Overlay button
			self.overlayButton.topAnchor.constraint(equalTo: self.circularView.topAnchor),
			self.overlayButton.leadingAnchor.constraint(equalTo: self.circularView.leadingAnchor),
			self.overlayButton.trailingAnchor.constraint(equalTo: self.circularView.trailingAnchor),
			self.overlayButton.bottomAnchor.constraint(equalTo: self.circularView.bottomAnchor),

			// Pencil button
			self.placeholderProfileImageEditButton.topAnchor.constraint(equalTo: self.circularView.topAnchor),
			self.placeholderProfileImageEditButton.trailingAnchor.constraint(equalTo: self.circularView.trailingAnchor),
			self.placeholderProfileImageEditButton.widthAnchor.constraint(equalToConstant: 24),
			self.placeholderProfileImageEditButton.heightAnchor.constraint(equalToConstant: 24),
		])
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
