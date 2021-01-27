source 'https://github.com/kiritokatklian/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def kurozora_pods
	pod 'Cosmos'
	pod 'ESTabBarController-swift'
	pod 'KeychainAccess'
	pod 'Kingfisher'
	pod 'KurozoraKit'#, path: '../KurozoraKit'
	pod 'R.swift'
	pod 'ReachabilitySwift'
	pod 'Solar'
#	pod 'SnowGlobe'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'Tabman'
	pod 'TRON'
	pod 'TRON/SwiftyJSON'
	pod 'WhatsNew'
end

# MARK: - Targets
target 'Kurozora' do
	kurozora_pods
end

# MARK: - Post install scripts
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
			config.build_settings['SWIFT_VERSION'] = '5.0'
		end
	end
end
