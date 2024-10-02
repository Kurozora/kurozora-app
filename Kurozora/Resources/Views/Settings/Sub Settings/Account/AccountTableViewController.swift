//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

enum AccountSetting {
	case language
	case tvRating
	case timezone
}

class AccountTableViewController: SubSettingsViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var userEmailLabel: KSecondaryLabel!
	@IBOutlet weak var languageButton: KButton!
	@IBOutlet weak var tvRatingButton: KButton!
	@IBOutlet weak var timezoneButton: KButton!

	// MARK: - Properties
	var languages: [String: String] = [:]
	var tvRatings: [String: String] = [:]
	var timezones: [String: String] = [:]
	var selectedLanguage: String = "en"
	var selectedTVRating: String = "4"
	var selectedTimezone: String = "UTC"

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		self.configureUserDetails()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.title = "Kurozora Account"

		self.languages = self.loadOptions(from: "App Languages")
		self.tvRatings = self.loadOptions(from: "App TV Ratings")
		// If the user doesn't have `R18+` already enabled, then hide it along with the `All` option,
		// just to make sure underaged users, who are more likely to be using the app than the website,
		// don't have access to those options. Adults will figure out how to change it on the website...
		// probably...
		if (User.current?.attributes.preferredTVRating != 5 && User.current?.attributes.preferredTVRating != -1)
			|| User.current == nil {
			self.tvRatings.removeValue(forKey: "-1") // All
			self.tvRatings.removeValue(forKey: "5") // R18+
		}
		self.timezones = self.loadOptions(from: "App Timezones")

		self.configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		guard let user = User.current else { return }

		// Setup username.
		self.usernameLabel.text = user.attributes.username

		// Setup email address.
		self.userEmailLabel.text = user.attributes.email

		// Setup profile image.
		user.attributes.profileImage(imageView: self.profileImageView)

		self.selectedLanguage = self.languages.first(where: { $0.key == user.attributes.preferredLanguage })?.value ?? self.selectedLanguage
		self.selectedTVRating = self.tvRatings.first(where: { $0.key == user.attributes.preferredTVRating?.string })?.value ?? self.selectedTVRating
		self.selectedTimezone = self.timezones.first(where: { $0.key == user.attributes.preferredTimezone })?.value ?? self.selectedTimezone

		self.languageButton.titleLabel?.numberOfLines = 0
		self.languageButton.contentHorizontalAlignment = .trailing
		self.languageButton.menu = self.configureMenu(accountSetting: .language, options: self.languages.map({ $0.value }), selected: self.selectedLanguage)

		self.tvRatingButton.titleLabel?.numberOfLines = 0
		self.tvRatingButton.contentHorizontalAlignment = .trailing
		self.tvRatingButton.menu = self.configureMenu(accountSetting: .tvRating, options: self.tvRatings.map({ $0.value }), selected: self.selectedTVRating)

		self.timezoneButton.titleLabel?.numberOfLines = 0
		self.timezoneButton.contentHorizontalAlignment = .trailing
		self.timezoneButton.menu = self.configureMenu(accountSetting: .timezone, options: self.timezones.map({ $0.value }), selected: self.selectedTimezone)
	}

	func loadOptions(from file: String) -> [String: String] {
		if let path = Bundle.main.path(forResource: file, ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			return (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
		} else {
			return [:]
		}
	}

	func configureMenu(accountSetting: AccountSetting, options: [String], selected: String) -> UIMenu {
		return UIMenu(title: "", options: .singleSelection, children: options.sorted().map { option in
			return UIAction(title: option, state: option == selected ? .on : .off) { [weak self] action in
				guard let self = self else { return }

				switch accountSetting {
				case .language:
					self.selectedLanguage = action.title
				case .tvRating:
					self.selectedTVRating = action.title
				case .timezone:
					self.selectedTimezone = action.title
				}

				self.updateInformation()
			}
		})
	}

	func updateInformation() {
		guard let selectedLanguage = self.languages.first(where: { $0.value == self.selectedLanguage })?.key else { return }
		guard let selectedTVRating = self.tvRatings.first(where: { $0.value == self.selectedTVRating })?.key.int else { return }
		guard let selectedTimezone = self.timezones.first(where: { $0.value == self.selectedTimezone })?.key  else { return }

		Task {
			do {
				let profileUpdateRequest = ProfileUpdateRequest(username: nil, nickname: nil, biography: nil, profileImageRequest: nil, bannerImageRequest: nil, preferredLanguage: selectedLanguage, preferredTVRating: selectedTVRating,
					preferredTimezone: selectedTimezone)

				// Perform update request.
				let userUpdateResponse = try await KService.updateInformation(profileUpdateRequest).value
				User.current?.attributes.update(using: userUpdateResponse.data)
				NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .signInWithApple:
			if User.current?.attributes.siwaIsEnabled ?? false {
				return 0
			}
		default: break
		}

		return super.tableView(tableView, numberOfRowsInSection: section)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath as IndexPath, animated: true)

		switch Section(rawValue: indexPath.section) {
		case .danger:
			switch indexPath.row {
			case 0:
				let alertController = self.presentAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", defaultActionButtonTitle: "No, keep me signed in 😅")
				alertController.addAction(UIAlertAction(title: "Yes, sign me out 🤨", style: .destructive) { [weak self] _ in
					guard let self = self else { return }

					Task {
						await WorkflowController.shared.signOut()
						self.dismiss(animated: true, completion: nil)
					}
				})
			case 1:
				let alertController = self.presentAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? Once your account is deleted, all of its resources and data will be permanently deleted. Please enter your password to confirm you would like to permanently delete your account.", defaultActionButtonTitle: Trans.cancel)
				alertController.addTextField { textField in
					textField.textType = .password
					textField.placeholder = Trans.password
				}
				alertController.addAction(UIAlertAction(title: "Delete Permanently", style: .destructive) { [weak self] _ in
					guard let self = self else { return }
					guard let passwordTextField = alertController.textFields?.first else { return }
					guard let password = passwordTextField.text else { return }

					Task {
						if await WorkflowController.shared.deleteUser(password: password) {
							self.dismiss(animated: true, completion: nil)
						}
					}
				})
			default: break
			}
		default: break
		}
	}
}

// MARK: - UITableViewDelegate
extension AccountTableViewController {
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .signInWithApple:
			if User.current?.attributes.siwaIsEnabled ?? false {
				return .leastNormalMagnitude
			}
		default: break
		}

		return super.tableView(tableView, heightForHeaderInSection: section)
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .signInWithApple:
			if User.current?.attributes.siwaIsEnabled ?? false {
				return .leastNormalMagnitude
			}
		default: break
		}

		return super.tableView(tableView, heightForFooterInSection: section)
	}
}

extension AccountTableViewController {
	/// List of account table section layout kind.
	enum Section: Int, CaseIterable {
		/// The section for account settings.
		case account

		/// The section for library settings.
		case library

		/// The section for Sign in with Apple.
		case signInWithApple

		/// The section for the session view.
		case session

		/// The section for dangerous actions.
		case danger
	}

	enum Rows: Int, CaseIterable {
		/// The row for the language settings.
		case language
		/// The row for the tv rating settings.
		case tvRating
		/// The row for the timezone settings.
		case timezone
		/// The row for the import library settings.
		case importLibrary
		/// The row for the delete library settings.
		case deleteLibrary
		/// The row for the Sign in with Apple settings.
		case signInWithApple
		/// The row for the sign out settings.
		case signOut
		/// The row for the delete account settings.
		case deleteAccount
	}
}
