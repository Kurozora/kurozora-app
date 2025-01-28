# Getting Started with Kurozora

KurozoraKit provides seamless access to the Kurozora API, allowing you to interact with anime, manga, games, music, and more. This guide will walk you through initializing KurozoraKit, setting up custom services, and making API requests.

## Overview

KurozoraKit simplifies API integration by offering a modular and configurable approach. With KurozoraKit, you can:

- Initialize the client with custom API endpoints.
- Use additional services like secure storage via Keychain.
- Make asynchronous API requests to fetch data with Swift concurrency.

## Initialize

KurozoraKit can be implemented using one line in the `global` scope.

```swift
let kurozoraKit = KurozoraKit()
```

KurozoraKit allows you to set your own API endpoint. For example, if you have a custom API endpoint for debugging purposes, you can set it like this:

```swift
let kurozoraKit = KurozoraKit(apiEndpoint: .custom("https://kurozora.debug/api/"))
```

KurozoraKit also accepts a `KKServices` object to enable and manage extra functionality. For example to manage Keychain data you can do something like the following:

```swift
// Prepare Keychain with your desired setting.
let appIdentifierPrefix = Bundle.main.infoDictionary?["AppIdentifierPrefix"] as! String
let keychain = Keychain(service: app_name, accessGroup: "\(appIdentifierPrefix)com.company.shared")
	.synchronizable(true)
	.accessibility(.afterFirstUnlock)

// Pass the keychain object.
let services = KKServices(keychain: keychain)

// Pass KKService
let kurozoraKit = KurozoraKit(authenticationKey: bearer_token).services(services)
```

You can also be chain desired methods instead of passing data as parameter.

```swift
let services = KKServices().keychainDefaults(keychain)
let kurozoraKit = KurozoraKit()
	.authenticationKey(bearer_token)
	.services(services)
```

## Making API Requests

Once KurozoraKit is initialized, you can start making API requests.

### Retrieve Explore Data

To retrieve data for the explore page, use the getExplore method with a specified genre ID:

```swift
let genreID = "1234"

do {
	let exploreCategoryResponse = try await kurozoraKit.getExplore(genreID: genreID).value
	print(exploreCategoryResponse.data)
} catch {
	print("Failed to fetch explore: \(error)")
	// Handle error case…
}
```

### Retrieve User Profile

To retrieve a user's profile using their ID, you can use the following:

- NOTE: You don't usually need to create a ``UserIdentity`` object directly; you can get it from other API calls, such as when using ``KurozoraKit/KurozoraKit/getFollowList(forUser:_:next:limit:)``.

```swift
let userIdentity = UserIdentity(id: "12345")

do {
	let userProfileResponse = try await kurozoraKit.getDetails(forUser: userIdentity).value
	print(userProfileResponse.data)
} catch {
	print("Failed to fetch user profile: \(error)")
	// Handle error case…
}
```

### Search for Content

KurozoraKit provides a search API to find anime, manga, games, and more based on keywords:

```swift
let searchQuery = "Re:Zero"
let scope = KKSearchScope.kurozora
let types = [KKSearchType.show]

do {
	let searchResponse = try await kurozoraKit.search(scope, of: types, for: query).value
	print(searchResponse.data)
} catch {
	print("Search failed: \(error)")
	// Handle error case…
}
```
