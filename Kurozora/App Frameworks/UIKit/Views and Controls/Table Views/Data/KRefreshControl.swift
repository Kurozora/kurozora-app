//
//  KRefreshControl.swift
//  Kurozora
//
//  Created by Khoren Katklian on 05/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

/**
	A themed standard control that can initiate the refreshing of a scroll view’s contents.

	A `KRefreshControl` object is a standard control that you attach to any [UIScrollView](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuiscrollview) object, including table views and collection views. Add this control to scrollable views to give your users a standard way to refresh their contents. When the user drags the top of the scrollable content area downward, the scroll view reveals the refresh control, begins animating its progress indicator, and notifies your app. You use that notification to update your content and dismiss the refresh control.

	The refresh control lets you know when to update your content using the target-action mechanism of [UIControl](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuicontrol). Upon activation, the refresh control calls the action method you provided at configuration time. When adding your action method, configure it to listen for the [valueChanged](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuicontrol%2Fevent%2F1618238-valuechanged) event, as shown in the following example code. Use your action method to update your content, and call the refresh control’s [endRefreshing()](apple-reference-documentation://ls%2Fdocumentation%2Fuikit%2Fuirefreshcontrol%2F1624848-endrefreshing) method when you are done.

	```
	func configureRefreshControl() {
	    // Add the refresh control to your UIScrollView object.
	    myScrollingView.refreshControl = KRefreshControl()
	    myScrollingView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
	}

	@objc func handleRefreshControl() {
	    // Update your content…

	    // Dismiss the refresh control.
	    DispatchQueue.main.async {
	        self.myScrollingView.refreshControl?.endRefreshing()
	   }
	}
	```

	The tint color is pre-configured with the currently selected theme.
	You can add a refresh control to your interface programmatically or by using Interface Builder.

	- Tag: KRefreshControl
*/
class KRefreshControl: UIRefreshControl {
	// MARK: - Initializers
	override init() {
		super.init()
		self.sharedInit()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - Functions
	/// The shared settings used to initialize the refresh control.
	func sharedInit() {
		self.theme_tintColor = KThemePicker.tintColor.rawValue
	}
}
