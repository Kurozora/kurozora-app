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
    pod 'EmptyDataSet-Swift', '~> 4.2'
	pod 'ESTabBarController-swift', '~> 2.6'
	pod 'KeychainAccess', '~> 3.1'
	pod 'Kingfisher'
	#    pod 'Lightbox', '2.1.2'
	pod 'NVActivityIndicatorView'
	pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
	#    pod 'Shimmer', '1.0.2'
	#    pod 'SnowGlobe'
	pod 'SwiftTheme', '~> 0.4'
	pod 'SwifterSwift', '~> 4.3'
	pod 'SwipeCellKit'
	pod 'Tabman', '~> 1.10'
	pod 'TRON', '~> 4.0'
	pod 'UIImageColors', '2.0.0'
end

def kurozora_pods
    # pod 'Hero'
	pod 'ColorSlider'
	pod 'Cosmos', '~> 17.0'
	pod 'IQKeyboardManagerSwift', '~> 6'
	pod 'NGAParallaxMotion', '~> 1.1'
	pod 'NotificationBannerSwift', '1.8.0'
	pod 'PusherSwift'
	pod 'RevealingSplashView', :git => 'https://github.com/PiXeL16/RevealingSplashView.git', :commit => 'master'
	pod 'RichEditorView'
	pod 'RichTextView'
	# pod 'Siren' for app update notifications
	pod 'WhatsNew'
end

# MARK: - Targets
target 'Kurozora' do
    kurozora_pods
    common_pods
end

target 'KCommonKit' do
	common_pods
end

target 'KDatabaseKit' do
#    common_pods
end

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
	
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '4.2'
		end
	end
end
