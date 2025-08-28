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
	@IBOutlet weak var languageLabel: KSecondaryLabel!
	@IBOutlet weak var tvRatingLabel: KSecondaryLabel!
	@IBOutlet weak var timezoneLabel: KSecondaryLabel!

	// MARK: - Properties
	var languages: [String: String] = [:]
	var tvRatings: [String: String] = [:]
	var timezones: [String: String] = [:]
	var selectedLanguage: [String: String].Element = ("", "")
	var selectedTVRating: [String: String].Element = ("", "")
	var selectedTimezone: [String: String].Element = ("", "")

	var selectedAccountSetting: AccountSetting?

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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.configureUserDetails()
	}

	// MARK: - Functions
	/// Configures the view with the user's details.
	func configureUserDetails() {
		guard let user = User.current else { return }

		// Configure username
		self.usernameLabel.text = user.attributes.username

		// Configure email address
		self.userEmailLabel.text = user.attributes.email

		// Configure profile image
		user.attributes.profileImage(imageView: self.profileImageView)

		// Configure preferences
		self.selectedLanguage = self.languages.first(where: { $0.key == user.attributes.preferredLanguage }) ?? self.selectedLanguage
		self.selectedTVRating = self.tvRatings.first(where: { $0.key == user.attributes.preferredTVRating?.string }) ?? self.selectedTVRating
		self.selectedTimezone = self.timezones.first(where: { $0.key == user.attributes.preferredTimezone }) ?? self.selectedTimezone

		self.languageLabel.text = self.selectedLanguage.value
		self.tvRatingLabel.text = self.selectedTVRating.value.replacingOccurrences(of: " - .*", with: "", options: .regularExpression)
		self.timezoneLabel.text = self.selectedTimezone.value.replacingOccurrences(of: ".*\\/|\\s*\\(.*\\)", with: "", options: .regularExpression)
	}

	func loadOptions(from file: String) -> [String: String] {
		if let path = Bundle.main.path(forResource: file, ofType: "plist"),
		   let plist = FileManager.default.contents(atPath: path) {
			return (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String: String]) ?? [:]
		} else {
			return [:]
		}
	}

	func updateInformation() async {
		let selectedLanguage = self.selectedLanguage.key
		let selectedTVRating = self.selectedTVRating.key.int
		let selectedTimezone = self.selectedTimezone.key

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
		case .account:
			switch indexPath.row {
			case 0:
				self.selectedAccountSetting = .language

				let viewController = SettingsPickerTableViewController(items: self.languages, selectedKey: self.selectedLanguage.key)
				viewController.title = "Language"
				viewController.delegate = self
				self.show(viewController, sender: nil)
			case 1:
				self.selectedAccountSetting = .tvRating

				let viewController = SettingsPickerTableViewController(items: self.tvRatings, selectedKey: self.selectedTVRating.key)
				viewController.title = "TV Rating"
				viewController.delegate = self
				self.show(viewController, sender: nil)
			case 2:
				self.selectedAccountSetting = .timezone

				let viewController = SettingsPickerTableViewController(items: self.timezones, selectedKey: self.selectedTimezone.key)
				viewController.title = "Time Zone"
				viewController.delegate = self
				self.show(viewController, sender: nil)
			default: break
			}
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
				alertController.addAction(UIAlertAction(title: Trans.deletePermanently, style: .destructive) { [weak self] _ in
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

extension AccountTableViewController: SettingsPickerTableViewControllerDelegate {
	func settingsPickerTableViewController(_ controller: SettingsPickerTableViewController, didSelectKey key: String) async {
		switch self.selectedAccountSetting {
		case .language:
			self.selectedLanguage = self.selectedLanguage.key == key ? self.selectedLanguage : (key, self.languages[key] ?? "")
			await self.updateInformation()
		case .tvRating:
			self.selectedTVRating = self.selectedTVRating.key == key ? self.selectedTVRating : (key, self.tvRatings[key] ?? "")
			await self.updateInformation()
		case .timezone:
			self.selectedTimezone = self.selectedTimezone.key == key ? self.selectedTimezone : (key, self.timezones[key] ?? "")
			await self.updateInformation()
		default: break
		}

		self.configureUserDetails()
	}
}
