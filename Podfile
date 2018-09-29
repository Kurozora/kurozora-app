source 'https://github.com/CocoaPods/Specs.git'
# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

plugin 'cocoapods-keys', {
    :project => 'Kurozora',
    :keys => [
        'KListClientID',
        'KListClientSecret'
    ]
}

inhibit_all_warnings!

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

def common_pods
    pod 'TRON', '~> 4.0'
    pod 'TTTAttributedLabel-moolban', '2.0.0.2'
#    pod 'Lightbox', '2.1.2'
    pod 'SwifterSwift', '4.3.0'
    pod 'KeychainAccess', '3.1.1'
    pod 'SCLAlertView', '0.8'
    pod 'UIImageColors', '2.0.0'
    pod 'ESTabBarController-swift', '2.6.2'
    pod 'FSPagerView', :git => 'https://github.com/WenchaoD/FSPagerView', commit: '6e0a2b7fc95d7ba262b324337e1479f81a829da6'
#    pod 'SnowGlobe'
    pod 'SwiftTheme', '0.4.1'
    pod 'GrowingTextView', '~> 0.5'
    pod 'RevealingSplashView'
    pod 'Kingfisher', '~> 4.0'
    pod 'AXPhotoViewer'
#    pod 'CRRefresh', '1.0.0'
end

def project_pods
    pod 'IQKeyboardManagerSwift', '6.0.3'
    pod 'NGAParallaxMotion', '1.1.0'
    pod 'ImagePicker', '3.0.0'
#    pod 'Shimmer', '1.0.2'
    pod 'XLPagerTabStrip', '8.0.1'
    pod 'WhatsNew', '0.4.3'
    pod 'Bolts-Swift', :git => 'https://github.com/BoltsFramework/Bolts-Swift', :commit => 'e9baa72d04521c3b25ef4fa6fef12b340953ee02'
end

def kurozora_pods
    # pod 'Hero'
    pod 'Cosmos', '~> 16.0'
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

# Workaround for Cocoapods issue #7606
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
