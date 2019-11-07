//
//  RichTextView+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/11/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import RichTextView

extension RichTextView {
	var textView: UITextView? {
		return self.subviews[0] as? UITextView
	}
}
