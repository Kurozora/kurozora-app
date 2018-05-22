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
    pod 'Alamofire', '4.7.2'
    pod 'SwiftyJSON', '4.1.0'
    pod 'TTTAttributedLabel-moolban', '2.0.0.2'
    pod 'SDWebImage', '4.3.3'
    pod 'SDWebImage/GIF', '4.3.3'
    pod 'FLAnimatedImage', '1.0.12'
end

def project_pods
    pod 'Fabric', '1.7.6'
    pod 'Crashlytics', '3.10.1'
    pod 'NGAParallaxMotion', '1.1.0'
    pod 'Shimmer', '1.0.2'
    pod 'XLPagerTabStrip', '8.0.1'
    pod 'Lightbox', '2.1.2'
    pod 'WhatsNew', '0.4.3'
    pod 'Bolts-Swift', :git => 'https://github.com/BoltsFramework/Bolts-Swift', :commit => 'e9baa72d04521c3b25ef4fa6fef12b340953ee02'
end

target 'Kurozora' do
    # Pods for Kurozora
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

