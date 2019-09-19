source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def common_pods
	pod 'KeychainAccess'
	pod 'Kingfisher', :git => 'https://github.com/onevcat/Kingfisher.git', :commit => 'xcode11'
#	pod 'SnowGlobe'
#	pod 'UIImageColors'
end

def kurozora_pods
	pod 'AXPhotoViewer'
	pod 'Cosmos'
	pod 'ESTabBarController-swift'
	pod 'EmptyDataSet-Swift'
	pod 'Hero'
	pod 'IQKeyboardManagerSwift'
	pod 'NotificationBannerSwift'
	pod 'PusherSwift'
	pod 'RevealingSplashView', :git => 'https://github.com/PiXeL16/RevealingSplashView.git', :commit => 'master'
	pod 'RichTextView'
	pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
	pod 'SPStorkController'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'SwipeCellKit'
	pod 'Tabman'
	pod 'TRON', '~> 5.0.0-beta.5'
	pod 'TRON/SwiftyJSON'
	pod 'WhatsNew'
	pod "WordPress-Aztec-iOS"
#	pod 'Zip'
end

# MARK: - Targets
target 'Kurozora' do
    kurozora_pods
    common_pods
end

target 'KCommonKit' do
	common_pods
end

# MARK: - Post install scripts
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '5.0'
		end
	end
end
