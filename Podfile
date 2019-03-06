source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# MARK: - Defs
def common_pods
	pod 'BottomPopup'
	pod 'AXPhotoViewer'
	pod 'EmptyDataSet-Swift'
	pod 'ESTabBarController-swift'
	pod 'KeychainAccess'
	pod 'Kingfisher'
	#    pod 'Lightbox', '2.1.2'
	pod 'NVActivityIndicatorView'
	pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
	#    pod 'Shimmer', '1.0.2'
	#    pod 'SnowGlobe'
	pod 'SwiftTheme'
	pod 'SwifterSwift'
	pod 'SwipeCellKit'
	pod 'Tabman'
	pod 'TRON'
	# pod 'UIImageColors'
end

def kurozora_pods
	# pod 'Hero'
	pod 'ColorSlider'
	pod 'Cosmos'
	pod 'IQKeyboardManagerSwift'
	pod 'MBProgressHUD'
	pod 'NGAParallaxMotion'
	pod 'NotificationBannerSwift', '1.8.0'
	pod 'PusherSwift'
	pod 'RevealingSplashView', :git => 'https://github.com/PiXeL16/RevealingSplashView.git', :commit => 'master'
	pod 'RichEditorView'
	pod 'RichTextView'
	# pod 'Siren' for app update notifications
	pod 'WhatsNew'
	# pod 'Zip'
end

# MARK: - Targets
target 'Kurozora' do
    kurozora_pods
    common_pods
end

target 'KCommonKit' do
	common_pods
end

# Require Swift version 4.2 on all pods
post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '4.2'
		end
	end
end
