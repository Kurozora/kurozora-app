//
//  ProfileTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView
import MobileCoreServices

class ProfileTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var profileNavigationItem: UINavigationItem!

	@IBOutlet weak var profileImageView: ProfileImageView!
	@IBOutlet weak var usernameLabel: KLabel!
	@IBOutlet weak var onlineIndicatorLabel: KSecondaryLabel!
	@IBOutlet weak var bannerImageView: UIImageView!
	@IBOutlet weak var bioTextView: KTextView!

	@IBOutlet weak var followButton: KTintedButton!

	@IBOutlet weak var buttonsStackView: UIStackView!
	@IBOutlet weak var reputationButton: KButton!
	@IBOutlet weak var badgesButton: KButton!
	@IBOutlet weak var followingButton: KButton!
	@IBOutlet weak var followersButton: KButton!

	@IBOutlet weak var proBadgeButton: UIButton!
	@IBOutlet weak var tagBadgeButton: UIButton!

	@IBOutlet weak var selectBannerImageButton: KButton!
	@IBOutlet weak var selectProfileImageButton: KButton!
	@IBOutlet weak var editProfileButton: KTintedButton!

	@IBOutlet weak var separatorView: SeparatorView!
	@IBOutlet weak var bannerImageViewHeightConstraint: NSLayoutConstraint!

	// MARK: - Properties
	#if !targetEnvironment(macCatalyst)
	var refreshController = UIRefreshControl()
	#endif

	var userID = User.current?.id ?? 0
	var user: User! = User.current {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.userID = self.user.id
			self.configureProfile()
		}
	}

	var dismissButtonIsEnabled: Bool = false {
		didSet {
			if dismissButtonIsEnabled {
				enableDismissButton()
			}
		}
	}
	var feedMessages: [FeedMessage] = [] {
		didSet {
			tableView.reloadEmptyDataSet()
		}
	}
	var nextPageURL: String?

	var currentImageView: UIImageView?
	var placeholderText = "Describe yourself!"
	var editingMode: Bool = false

	var imagePicker = UIImagePickerController()
	var profileImageFilePath: String? = nil
	var oldLeftBarItems: [UIBarButtonItem]?
	var oldRightBarItems: [UIBarButtonItem]?

	var bioTextCache: String?
	var profileImageCache: UIImage?
	var bannerImageCache: UIImage?

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup banner image height
		self.bannerImageViewHeightConstraint.constant = view.height / 3
		self.view.setNeedsUpdateConstraints()
		self.view.layoutIfNeeded()

		// Add Refresh Control to Table View
		#if !targetEnvironment(macCatalyst)
		tableView.refreshControl = refreshController
		refreshController.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!", attributes: [NSAttributedString.Key.foregroundColor: UIColor.kurozora])
		refreshController.addTarget(self, action: #selector(refreshProfileData(_:)), for: .valueChanged)
		#endif

		// Fetch posts
		DispatchQueue.global(qos: .background).async {
			self.fetchUserDetails()
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	// MARK: - Functions
	/**
		Refresh the profile by fetching new items from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshProfileData(_ sender: Any) {
		#if !targetEnvironment(macCatalyst)
		refreshController.attributedTitle = NSAttributedString(string: "Refreshing profile details...", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
		#endif
		self.nextPageURL = nil
		self.fetchUserDetails()
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

			let detailLabel = self.user?.id == User.current?.id ? "There are no messages on your feed!" : "There are no messages on this feed! Be the first to message :D"
			let verticalOffset = (self.tableView.tableHeaderView?.height ?? 0 - self.view.height) / 2

			view.titleLabelString(NSAttributedString(string: "No Posts", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabel, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.comment())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(verticalOffset < 0 ? 0 : verticalOffset)
				.verticalSpace(10)
				.isScrollAllowed(true)
		}
	}

	/// Fetches posts for the user whose page is being viewed.
	private func fetchFeedMessages() {
		KService.getFeedMessages(forUserID: self.userID, next: nextPageURL) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let feedMessageResponse):
				// Reset data if necessary
				if self.nextPageURL == nil {
					self.feedMessages = []
				}

				// Append new data and save next page url
				self.feedMessages.append(contentsOf: feedMessageResponse.data)
				self.nextPageURL = feedMessageResponse.next

				if self.tableView.numberOfSections != 0 {
					self.tableView.reloadSections([0], with: .automatic)
				}
			case .failure: break
			}
		}

		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshController.endRefreshing()
			#endif
		}
	}

	/// Fetches user detail.
	private func fetchUserDetails() {
		KService.getProfile(forUserID: self.userID) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let users):
				self.user = users.first

				// Reset refresh controller title
				#if !targetEnvironment(macCatalyst)
				self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh profile details!", attributes: [NSAttributedString.Key.foregroundColor: KThemePicker.tintColor.colorValue])
				#endif
			case .failure: break
			}
		}

		self.fetchFeedMessages()
	}

	/// Configure the profile view with the details of the user whose page is being viewed.
	private func configureProfile() {
		let centerAlign = NSMutableParagraphStyle()
		centerAlign.alignment = .center

		// Configure username
		usernameLabel.text = self.user?.attributes.username
		usernameLabel.isHidden = false

		// Configure online status
		onlineIndicatorLabel.text = self.user?.attributes.activityStatus.stringValue
		onlineIndicatorLabel.isHidden = false

		// Configure profile image
		profileImageView.image = self.user?.attributes.profileImage

		// Configure banner image
		if let bannerImageURL = self.user?.attributes.bannerImageURL {
			bannerImageView.setImage(with: bannerImageURL, placeholder: R.image.placeholders.userBanner()!)
		}

		// Configure user bio
		if let biography = self.user?.attributes.biography {
			self.bioTextView.text = biography
		}

		// Configure reputation count
		if let reputationCount = self.user?.attributes.reputationCount {
			let count = NSAttributedString(string: reputationCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nReputation", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let reputationButtonTitle = NSMutableAttributedString()
			reputationButtonTitle.append(count)
			reputationButtonTitle.append(title)

			self.reputationButton.setAttributedTitle(reputationButtonTitle, for: .normal)
		}

		// Configure following & followers count
		if let followingCount = self.user?.attributes.followingCount {
			let count = NSAttributedString(string: followingCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowing", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followingButtonTitle = NSMutableAttributedString()
			followingButtonTitle.append(count)
			followingButtonTitle.append(title)

			self.followingButton.setAttributedTitle(followingButtonTitle, for: .normal)
		}

		if let followerCount = self.user?.attributes.followerCount {
			let count = NSAttributedString(string: followerCount.kkFormatted, attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nFollowers", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let followersButtonTitle = NSMutableAttributedString()
			followersButtonTitle.append(count)
			followersButtonTitle.append(title)

			self.followersButton.setAttributedTitle(followersButtonTitle, for: .normal)
		}

		// Configure edit button
		self.editProfileButton.isHidden = !(self.user?.id == User.current?.id)

		// Configure follow button
		self.updateFollowButton()

		// Configure pro badge
		self.proBadgeButton.isHidden = !(self.user?.attributes.isPro ?? false)

		// Configure badge & badge button
		if let badges = self.user?.relationships?.badges?.data {
			// Configure user badge (a.k.a tag)
			if !badges.isEmpty {
				self.tagBadgeButton.isHidden = false
				for badge in badges {
					self.tagBadgeButton.setTitle(badge.attributes.name, for: .normal)
					self.tagBadgeButton.setTitleColor(UIColor(hexString: badge.attributes.textColor), for: .normal)
					self.tagBadgeButton.backgroundColor = UIColor(hexString: badge.attributes.backgroundColor)
					self.tagBadgeButton.borderColor = UIColor(hexString: badge.attributes.textColor)
					self.profileImageView.borderColor = UIColor(hexString: badge.attributes.textColor)
					break
				}
			} else {
				self.tagBadgeButton.isHidden = true
			}

			// Configure badge button
			let count = NSAttributedString(string: "\(badges.count)", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.textColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let title = NSAttributedString(string: "\nBadges", attributes: [
				NSAttributedString.Key.foregroundColor: KThemePicker.subTextColor.colorValue,
				NSAttributedString.Key.paragraphStyle: centerAlign
			])
			let badgesButtonTitle = NSMutableAttributedString()
			badgesButtonTitle.append(count)
			badgesButtonTitle.append(title)

			self.badgesButton.setAttributedTitle(badgesButtonTitle, for: .normal)
		}

		// Configure AutoLayout
		self.tableView.setTableHeaderView(headerView: self.tableView.tableHeaderView)

		// First layout update
		self.tableView.updateHeaderViewFrame()
	}

	/// Hides and unhides elements to prepare for starting and ending of the edit mode.
	private func editMode(_ enabled: Bool) {
		editingMode = enabled
		if enabled {
			UIView.animate(withDuration: 0.5) {
				self.buttonsStackView.alpha = 0.5
				self.buttonsStackView.isUserInteractionEnabled = false

				// Hide edit button
				self.editProfileButton.alpha = 0

				// Save old actions
				self.oldLeftBarItems = self.profileNavigationItem.leftBarButtonItems
				self.oldRightBarItems = self.profileNavigationItem.rightBarButtonItems

				// Remove old actions
				self.profileNavigationItem.setLeftBarButton(nil, animated: true)
				self.profileNavigationItem.setRightBarButton(nil, animated: true)

				// Set new actions
				let leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelProfileEdit(_:)))
				let rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.applyProfileEdit(_:)))
				self.profileNavigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
				self.profileNavigationItem.setRightBarButton(rightBarButtonItem, animated: true)

				// Enable other relevant actions
				self.selectProfileImageButton.alpha = 1
				self.selectBannerImageButton.alpha = 1

				// Stop scrolling
				self.tableView.isScrollEnabled = false
				self.tableView.visibleCells.forEach {
					$0.alpha = 0.5
					$0.isUserInteractionEnabled = false
				}

				// Setup bio text if necessary
				self.textViewDidEndEditing(self.bioTextView)
			}

			// Enable bio editing
			self.bioTextView.isEditable = true
		} else {
			UIView.animate(withDuration: 0.5) {
				self.buttonsStackView.alpha = 1
				self.buttonsStackView.isUserInteractionEnabled = true

				// Unhide edit button
				self.editProfileButton.alpha = 1

				// Hide select buttons
				self.selectProfileImageButton.alpha = 0
				self.selectBannerImageButton.alpha = 0

				// Show relevant actions
				self.profileNavigationItem.setLeftBarButton(nil, animated: true)
				self.profileNavigationItem.setRightBarButton(nil, animated: true)

				self.profileNavigationItem.setLeftBarButtonItems(self.oldLeftBarItems, animated: true)
				self.profileNavigationItem.setRightBarButtonItems(self.oldRightBarItems, animated: true)

				// Enable scrolling
				self.tableView.isScrollEnabled = true
				self.tableView.visibleCells.forEach {
					$0.alpha = 1
					$0.isUserInteractionEnabled = true
				}

				// Reset bio text if necessary
				if self.bioTextView.text == self.placeholderText {
					self.bioTextView.text = ""
				}
			}

			// Disable bio editing
			self.bioTextView.isEditable = false
		}
	}

	/**
		Cancel profile edit mode and return to view mode.

		- Parameter sender: The object requesting the cancelation of the edit mode.
	*/
	@objc func cancelProfileEdit(_ sender: Any) {
		// User doesn't want changes to be saved, pute everything back.
		self.bioTextView.text = self.bioTextCache
		self.profileImageView.image = self.profileImageCache
		self.bannerImageView.image = self.bannerImageCache

		// Return to view mode
		editMode(false)
		self.tableView.updateHeaderViewFrame()
	}

	/**
		Apply profile changes.

		- Parameter sender: The object requesting the changes to be applied.
	*/
	@objc func applyProfileEdit(_ sender: UIBarButtonItem) {
		var bioText: String? = bioTextView.text.trimmed
		var bannerImage = bannerImageView.image
		var bioTextUnchanged = false

		// If everything is the same then dismiss and don't send a request to apply new information.
		if self.bioTextCache == self.placeholderText,
		   self.bioTextView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue {
			bioTextUnchanged = true
			bioText = nil
		}

		if bioTextUnchanged &&
			self.profileImageFilePath == nil,
			self.bannerImageCache == bannerImage {
			// Nothing to change, clear the cache.
			self.bioTextCache = nil
			self.profileImageCache = nil
			self.bannerImageCache = nil
			self.editMode(false)
			return
		}

		// If the banner is the same, then ignore.
		if self.bannerImageCache == bannerImage {
			bannerImage = UIImage().cropped(to: .zero)
		}

		// User wants to save changes, clear the cache.
		self.bioTextCache = nil
		self.profileImageCache = nil
		self.bannerImageCache = nil

		KService.updateInformation(biography: bioText, bannerImage: bannerImage, profileImageFilePath: profileImageFilePath) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				self.editMode(false)
			case .failure: break
			}
		}
	}

	/// Enable and show the dismiss button.
	func enableDismissButton() {
		// Save old actions
		self.oldLeftBarItems = self.profileNavigationItem.leftBarButtonItems

		// Remove old actions
		self.profileNavigationItem.setLeftBarButton(nil, animated: true)

		// Set new actions
		let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissButtonPressed))
		self.profileNavigationItem.setLeftBarButton(leftBarButtonItem, animated: true)
	}

	/// Dismiss the view. Used by the dismiss button when viewing other users' profile.
	@objc fileprivate func dismissButtonPressed() {
		dismiss(animated: true, completion: nil)
	}

	/// Performs segue to `FavoriteShowsCollectionViewController` with `FavoriteShowsSegue` as the identifier.
	fileprivate func showFavoriteShowsList() {
		if let favoriteShowsCollectionViewController = R.storyboard.library.favoriteShowsCollectionViewController() {
			favoriteShowsCollectionViewController.user = self.user
			favoriteShowsCollectionViewController.dismissButtonIsEnabled = true

			let kNavigationViewController = KNavigationController(rootViewController: favoriteShowsCollectionViewController)
			self.present(kNavigationViewController, animated: true)
		}
	}

	/// Builds and presents an action sheet.
	fileprivate func showActionList(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Go to last watched episode
		if User.isSignedIn {
			let showFavoriteShowsList = UIAlertAction.init(title: "Favorite shows", style: .default, handler: { (_) in
				self.showFavoriteShowsList()
			})
			showFavoriteShowsList.setValue(UIImage(systemName: "heart.circle"), forKey: "image")
			showFavoriteShowsList.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			alertController.addAction(showFavoriteShowsList)
		}

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		alertController.view.theme_tintColor = KThemePicker.tintColor.rawValue

		//Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		self.present(alertController, animated: true, completion: nil)
	}

	/// Updated the `followButton` with the follow status of the user.
	fileprivate func updateFollowButton() {
		let followStatus = self.user?.attributes.followStatus ?? .disabled
		switch followStatus {
		case .followed:
			self.followButton.setTitle("＋ Follow", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case  .notFollowed:
			self.followButton.setTitle("✓ Following", for: .normal)
			self.followButton.isHidden = false
			self.followButton.isUserInteractionEnabled = true
		case .disabled:
			self.followButton.setTitle("＋ Follow", for: .normal)
			self.followButton.isHidden = true
			self.followButton.isUserInteractionEnabled = false
		}
	}

	// MARK: - IBActions
	@IBAction func editProfileButtonPressed(_ sender: UIButton) {
		// Cache current profile data
		self.bioTextCache = self.bioTextView.text.isNilOrEmpty ? placeholderText : self.bioTextView.text.trimmed
		self.profileImageCache = self.profileImageView.image
		self.bannerImageCache = self.bannerImageView.image

		editMode(true)
	}

	@IBAction func followButtonPressed(_ sender: UIButton) {
		WorkflowController.shared.isSignedIn {
			KService.updateFollowStatus(forUserID: self.user.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let followUpdate):
					self.user?.attributes.update(using: followUpdate)
					self.updateFollowButton()
				case .failure: break
				}
			}
		}
	}

	@IBAction func moreBarButtonPressed(_ sender: UIBarButtonItem) {
		showActionList(sender)
	}

	// MARK: - Segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == R.segue.profileTableViewController.badgeSegue.identifier {
			if let badgesTableViewController = segue.destination as? BadgesTableViewController {
				badgesTableViewController.user = self.user
			}
		} else if let followTableViewController = segue.destination as? FollowTableViewController {
			followTableViewController.user = self.user

			if segue.identifier == R.segue.profileTableViewController.followingSegue.identifier {
				followTableViewController.followList = .following
			} else if segue.identifier == R.segue.profileTableViewController.followersSegue.identifier {
				followTableViewController.followList = .followers
			}
		} else if let fmDetailsTableViewController = segue.destination as? FMDetailsTableViewController {
			if let feedMessageID = sender as? Int {
				fmDetailsTableViewController.feedMessageID = feedMessageID
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ProfileTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.feedMessages.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let feedMessageCell: BaseFeedMessageCell!

		if feedMessages[indexPath.row].attributes.isReShare || feedMessages[indexPath.row].attributes.isReply {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageReShareCell, for: indexPath)
		} else {
			feedMessageCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.feedMessageCell, for: indexPath)
		}

		feedMessageCell.liveReplyEnabled = User.current?.id == self.userID
		feedMessageCell.liveReShareEnabled = User.current?.id == self.userID
		feedMessageCell.feedMessage = self.feedMessages[indexPath.row]
		return feedMessageCell
	}
}

// MARK: - UITableViewDelegate
extension ProfileTableViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let baseFeedMessageCell = tableView.cellForRow(at: indexPath) as? BaseFeedMessageCell {
			self.performSegue(withIdentifier: R.segue.feedTableViewController.feedMessageDetailsSegue.identifier, sender: baseFeedMessageCell.feedMessage.id)
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let numberOfRows = tableView.numberOfRows()

		if indexPath.row == numberOfRows - 5 {
			if self.nextPageURL != nil {
				self.fetchFeedMessages()
			}
		}
	}
}

// MARK: - KTableViewDataSource
extension ProfileTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			FeedMessageCell.self,
			FeedMessageReShareCell.self
		]
	}
}

// MARK: - KRichTextEditorViewDelegate
extension ProfileTableViewController: KFeedMessageTextEditorViewDelegate {
	func updateMessages(with feedMessages: [FeedMessage]) {
		for feedMessage in feedMessages {
			self.feedMessages.prepend(feedMessage)
		}

		if self.tableView.numberOfSections != 0 {
			self.tableView.reloadSections([0], with: .automatic)
		}
	}

	func segueToOPFeedDetails(_ feedMessage: FeedMessage) {
		self.performSegue(withIdentifier: R.segue.profileTableViewController.feedMessageDetailsSegue.identifier, sender: feedMessage.id)
	}
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileTableViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		if let editedImage = info[.editedImage] as? UIImage {
			self.currentImageView?.image = editedImage
		}

		if let imageURL = info[.imageURL] as? URL {
			profileImageFilePath = imageURL.absoluteString
		}

		//Dismiss the UIImagePicker after selection
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}

	// MARK: - Functions
	/// Open the camera if the device has one, otherwise show a warning.
	func openCamera() {
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
			imagePicker.allowsEditing = true
			if User.isPro {
				imagePicker.mediaTypes = [(kUTTypeGIF as String), (kUTTypePNG as String), (kUTTypeJPEG as String)]
			} else {
				imagePicker.mediaTypes = [(kUTTypePNG as String), (kUTTypeJPEG as String)]
			}
			imagePicker.delegate = self
			self.present(imagePicker, animated: true, completion: nil)
		} else {
			SCLAlertView().showWarning("Well, this is awkward.", subTitle: "You don't seem to have a camera 😓")
		}
	}

	/// Open the Photo Library so the user can choose an image.
	func openPhotoLibrary() {
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self

		self.present(imagePicker, animated: true, completion: nil)
	}

	// MARK: - IBActions
	@IBAction func selectProfileImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = self.profileImageView
		let alert = UIAlertController(title: "Profile Photo", message: "Choose an awesome photo 😉", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		if UIDevice.isPad {
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		}

		self.present(alert, animated: true, completion: nil)
	}

	@IBAction func selectBannerImageButtonPressed(_ sender: UIButton) {
		self.currentImageView = self.bannerImageView
		let alert = UIAlertController(title: "Banner Photo", message: "Choose a breathtaking photo 🌄", preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Take a photo 📷", style: .default, handler: { _ in
			self.openCamera()
		}))

		alert.addAction(UIAlertAction(title: "Choose from Photo Library 🏛", style: .default, handler: { _ in
			self.openPhotoLibrary()
		}))

		alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		if UIDevice.isPad {
			alert.popoverPresentationController?.sourceView = sender
			alert.popoverPresentationController?.sourceRect = sender.bounds
			alert.popoverPresentationController?.permittedArrowDirections = .up
		}

		self.present(alert, animated: true, completion: nil)
	}
}

// MARK: - UITextViewDelegate
extension ProfileTableViewController: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		bioTextCache = textView.text
		if textView.text == placeholderText && textView.textColor == KThemePicker.textFieldPlaceholderTextColor.colorValue && editingMode {
			textView.text = ""
			textView.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	func textViewDidChange(_ textView: UITextView) {
		DispatchQueue.main.async {
			self.tableView.updateHeaderViewFrame()
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty && editingMode {
			textView.text = placeholderText
			textView.theme_textColor = KThemePicker.textFieldPlaceholderTextColor.rawValue
		}
	}
}
