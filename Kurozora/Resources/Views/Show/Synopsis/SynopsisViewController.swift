//
//  SynopsisViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class SynopsisViewController: KViewController, StoryboardInstantiable {
	static var storyboardName: String = "Synopsis"

	// MARK: - IBOutlets
	@IBOutlet weak var synopsisTextView: KTextView!

	// MARK: - Properties
	var synopsis: String?

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		self.synopsisTextView.text = self.synopsis
	}

	// MARK: - IBActions
	@IBAction func dismissPressed(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
}
