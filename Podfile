source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def common_pods
	pod 'AXPhotoViewer'
	pod 'EmptyDataSet-Swift'
	pod 'ESTabBarController-swift'
	pod 'KeychainAccess'
	pod 'Kingfisher'
	pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
#	pod 'Shimmer'
#	pod 'SnowGlobe'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'SwipeCellKit'
	pod 'Tabman'
	pod 'TRON', '~> 5.0.0-beta.5'
	pod 'TRON/SwiftyJSON'
#	pod 'UIImageColors'
end

def kurozora_pods
	pod 'Hero'
	pod 'ColorSlider'
	pod 'Cosmos'
	pod 'IQKeyboardManagerSwift'
	pod 'IBAnimatable'
	pod 'NotificationBannerSwift'
	pod 'PusherSwift'
	pod 'RevealingSplashView', :git => 'https://github.com/PiXeL16/RevealingSplashView.git', :commit => 'master'
	pod 'RichEditorView'
	pod 'RichTextView'
	pod 'Solar'
	pod 'SPStorkController'
	pod 'WhatsNew'
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
