//
//  KRichTextEditor.swift
//  KRichTextEditor
//
//  Created by Khoren Katklian on 01/12/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

public class KRichTextEditor {
	public init() {}
	
	public class func bundle() -> Bundle {
		return Bundle(for: self)
	}

	public class func editorStoryboard() -> UIStoryboard {
		return UIStoryboard(name: "editor", bundle: bundle())
	}

	public static var shared = KRichTextEditor()
}
