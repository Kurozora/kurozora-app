source 'https://github.com/kiritokatklian/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def kurozora_pods
	pod 'Cosmos'
	pod 'DiffableDataSources'
	pod 'ESTabBarController-swift'
	pod 'EmptyDataSet-Swift'
	pod 'IBPCollectionViewCompositionalLayout'
	pod 'KeychainAccess'
	pod 'Kingfisher'
	pod 'KurozoraKit', path: '../KurozoraKit'
	pod 'NotificationBannerSwift'
	pod 'R.swift'
	pod 'ReachabilitySwift'
#	pod 'RichTextView'
	pod 'Solar'
	pod 'SPStorkController'
#	pod 'SnowGlobe'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'SwipeCellKit'
	pod 'Tabman'
	pod 'TRON'
	pod 'TRON/SwiftyJSON'
	pod 'UIImageColors'
	pod 'WhatsNew'
#	pod 'Zip'
end

# MARK: - Targets
target 'Kurozora' do
	kurozora_pods
end

# MARK: - Post install scripts
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
			config.build_settings['SWIFT_VERSION'] = '5.0'
		end
	end
end
