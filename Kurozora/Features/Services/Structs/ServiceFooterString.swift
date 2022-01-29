//
//  ServiceFooterString.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/**
	Set of available service footer strings.

	- Tag: ServiceFooterString
*/
struct ServiceFooterString {
	/// The footer string for the MAL Improt view.
	static let malImport: String = "Kurozora does not guarantee all shows will be imported to your library. Once the request has been processed a notification which contains the status of the import request will be sent. Furthermore the uploaded file is deleted as soon as the import request has been processed."

	/// The footer string for the Redeem view.
	static let redeem: String = "Redeeming a code will immediately apply the credits onto your account. Please keep in mind Kurozora codes are redeemable only once per account and expire after one use."

	/// The footer string for the Sign in with Apple view.
	static let signInWithApple: String = "Kurozora offers Sign in with Apple for users who want the extra peace of mind when it comes to security and privacy. Sign in with Apple is a convenient way to sign in to apps and sites while having more control over the information you share. Kurozora is restricted to asking only for your name and email address, and Apple won’t track your app activity or build a profile of you."

	/// The footer string for the Subscription view.
	static let subscription: String = "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase."

	/// The footer string for the Tip Jar view.
	static let tipJar: String = "Payment will be charged to your Apple ID account at the confirmation of purchase. Unlike Kurozora+ subscription, tips are a one time purchase. Your account will be charged only once every time you tip."

	/// The footer string to visit privacy policy.
	static var visitPrivacyPolicy: ThemeAttributedStringPicker = {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		let themeAttributedString = ThemeAttributedStringPicker {
			let attributedString = NSMutableAttributedString(string: "For more information, please visit our ", attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: "Privacy Policy", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			return attributedString
		}
		return themeAttributedString
	}()
}
