<p align="center"><img src="https://developer.kurozora.app/assets/images/icons/KurozoraKit.png"></p>

<p align="center">
    <sup><b>KurozoraKit</b></sup>
</p>

# KurozoraKit [![Swift 5](https://img.shields.io/badge/Swift-5-orange.svg?style=flat&logo=Swift)](https://swift.org) [![Platform](https://img.shields.io/badge/Platform-iOS%20|%20iPadOS%20|%20macOS-lightgrey.svg?style=flat&logo=Apple)](https://www.apple.com/ios) [![License: GPL v3](https://img.shields.io/badge/License-AGPLv3-blue.svg?style=flat)](https://www.gnu.org/licenses/agpl-3.0) [![Documentation](https://img.shields.io/badge/Documentation-100%25-green.svg?style=flat)](https://developer.kurozora.app/KurozoraKit) [![Discord](https://img.shields.io/discord/449250093623934977?style=flat&label=Discord&logo=Discord&color=7289DA)](https://discord.gg/bHUmr3h)

[KurozoraKit](https://developer.kurozora.app/kurozorakit) lets users manage their anime library and access many other serices from your app. When users provide permission to access their Kurozora account, they can use your app to share anime, add anime to their library, and discover any of the millions of anime in the Kurozora catalog. If your app detects that the user is not yet a Kurozora member, you can offer them to create an account within your app.

KurozoraKit is designed to be:

* **🛠 Intuitive:** KurozoraKit is built with Swift, one of the **fast**, **modern**, **safe** and **interactive** programming languages.

* **✨ Magical:** The kit is carefully designed to work as efficient and reliable as you would expect it to.

* **📚 Documented:** With up to 100% documentation coverage.

* **⚙️ Reliable:** Built for the best [API](https://github.com/musa11971/kurozora-web). The way KurozoraKit works together with the Kurozora API is truly otherworldly.

# Requirements

KurozoraKit has been tested to work on iOS 12.0+ and macOS 10.15+.  It also works best with Swift 5.0+

To use KurozoraKit in your project, you need to install it first.

## Installation

KurozoraKit is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'KurozoraKit'
```

## Usage
KurozoraKit can be implemented using one line in the `global` scope.

```swift
let kurozoraKit = KurozoraKit()
```

KurozoraKit also accepts a `KKServices` object to enable and manage extra functionality. For example to manage Keychain data and enable built-in HUD alerts you can do something like the following:

```swift
// Prepare Keychain with your desired setting.
let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String
let keychain = Keychain(service: "AppName", accessGroup: "\(appIdentifierPrefix)com.company.shared").synchronizable(true).accessibility(.afterFirstUnlock)

// Pass the keychain object and enable built-in alerts.
let services = KKServices(keychain: keychain, showAlerts: true)

// Pass KKService
let kurozoraKit = KurozoraKit(authenticationKey: "bearer-token").services(services)
```

You can also be chain desired methods instead of passing data as parameter.

```swift
let services = KKServices().showAlerts(false).keychainDefaults(keychain)
let kurozoraKit = KurozoraKit().authenticationKey("bearer-token").services(services)
```

After setting up KurozoraKit you can use an API by calling its own method. For example, to get the explore page data, you do the following:

```swift
let genreID = 1

kurozoraKit.getExplore(genreID) { result in
	switch result {
	case .success(let success):
		// Handle success case…
	case .failure(let error):
		// Handle error case…
	}
}
```

# Contributing

Read the [Contributing Guide](CONTRIBUTING) to learn about reporting issues, contributing code, and more ways to contribute.

# Security

If you happen to find a security vulnerability, we would appreciate you letting us know at kurozoraapp@gmail.com and allowing us to respond before disclosing the issue publicly.

# Getting in Touch

If you have any questions or just want to say hi, join the Kurozora [Discord](https://discord.gg/bHUmr3h) and drop a message on the #development channel.

# Author

Khoren Katklian, a.k.a Kiritokatklian or simply Kirito.

# License

KurozoraKit is available under the GNU Affero General Public License v3.0 license. See the [LICENSE](LICENSE) file for more info.
