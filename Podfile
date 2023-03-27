source 'https://cdn.cocoapods.org'
# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def kurozora_pods
	pod 'Cosmos'
	pod 'ESTabBarController-swift'
	pod 'FLEX', :configurations => ['Debug']
	pod 'IQKeyboardManagerSwift'
	pod 'KeychainAccess'
	pod 'Kingfisher'
	pod 'KurozoraKit'#, path: '../KurozoraKit'
	pod 'R.swift'
	pod 'ReachabilitySwift'
	pod 'Solar'
#	pod 'SnowGlobe'
	pod 'SPConfetti'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'Tabman'
	pod 'TRON', '5.5.0-beta.1'
	pod 'TRON/SwiftyJSON'
	pod 'WhatsNew'
	pod 'XCDYouTubeKit', :git => 'https://github.com/armendh/XCDYouTubeKit', :branch => 'master', :commit => '651a6a51c695c5819eb51ba2f98d0b64094315b9'
end

# MARK: - Targets
target 'Kurozora' do
	kurozora_pods
end

# MARK: - Post install scripts
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
			config.build_settings['SWIFT_VERSION'] = '5.0'
		end

		if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle" # <--- this
			target.build_configurations.each do |config|
				config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
			end
		end
	end
end
