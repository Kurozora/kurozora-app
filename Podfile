source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

def common_pods
    pod 'TRON', '~> 4.0'
#    pod 'Lightbox', '2.1.2'
    pod 'SwifterSwift', '~> 4.3'
    pod 'KeychainAccess', '~> 3.1'
    pod 'UIImageColors', '2.0.0'
    pod 'ESTabBarController-swift', '~> 2.6'
#    pod 'SnowGlobe'
    pod 'SwiftTheme', '~> 0.4'
    pod 'GrowingTextView', '~> 0.5'
    pod 'Kingfisher', '~> 4.0'
    pod 'AXPhotoViewer'
    pod 'EmptyDataSet-Swift', '~> 4.2'
    pod 'BottomPopup'
    pod 'Tabman', '~> 1.10'
	pod 'NVActivityIndicatorView'
end

def project_pods
	pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git', :branch => 'master'
#    pod 'Shimmer', '1.0.2'
    pod 'Bolts-Swift', :git => 'https://github.com/BoltsFramework/Bolts-Swift', :commit => 'e9baa72d04521c3b25ef4fa6fef12b340953ee02'
end

def kurozora_pods
    # pod 'Hero'
	pod 'AMPopTip'
	pod 'Cosmos', '~> 17.0'
	pod 'IQKeyboardManagerSwift', '~> 6'
	pod 'NGAParallaxMotion', '~> 1.1'
	pod 'NotificationBannerSwift', '1.8.0'
	pod 'PusherSwift'
	pod 'RevealingSplashView', :git => 'https://github.com/PiXeL16/RevealingSplashView.git', :commit => 'master'
	pod 'WhatsNew'
    # pod 'Siren' for app update notifications
end

target 'Kurozora' do
    kurozora_pods
    common_pods
    project_pods
end

target 'KDatabaseKit' do
    common_pods
    project_pods
end

target 'KCommonKit' do
    common_pods
end

target 'KRichTextEditor' do
#	pod 'Notepad'
	project_pods
	pod 'RichEditorView'
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
