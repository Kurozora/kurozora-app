//
//  ProfileNavigable.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/02/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import UIKit

@MainActor
protocol ProfileNavigable: UIViewController, UINavigationControllerDelegate {
	/// Performs segue to the profile view.
	func segueToProfile() async

	/// The profile bar button item that initiates the segue to the profile view when tapped.
	/// This is used to update the state of the button when the profile view is presented or dismissed.
	var profileBarButtonItem: ProfileBarButtonItem! { get set }
}

extension ProfileNavigable {
	func segueToProfile() async {
		let isSignedIn = await WorkflowController.shared.isSignedIn(on: self)
		guard isSignedIn else { return }

		let profileTableViewController = ProfileTableViewController()

		if #available(iOS 18.0, *) {
			if let tabBarController = self.tabBarController as? KTabBarController,
			   let sidebarBottomProfileView = tabBarController.sidebar.bottomBarView as? KSidebarBottomProfileView {
				sidebarBottomProfileView.isSelected = true
				profileTableViewController.sidebarBottomProfileView = sidebarBottomProfileView
				tabBarController.selectedTab = nil
			}
		}

		self.show(profileTableViewController, sender: nil)
	}
}
