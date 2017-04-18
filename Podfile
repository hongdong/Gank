source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

def shared_pods
    pod 'Moya'
    pod 'Moya/RxSwift'
    pod 'RxSwift'
	pod 'RxDataSources'
	pod 'Reusable'
	pod 'Kingfisher'
	pod 'Alamofire'
    pod 'Then'
    pod 'SnapKit'
    pod 'EZSwiftExtensions'
    pod 'Action'
    pod 'RxOptional'
    pod 'ObjectMapper'
    pod 'NoticeBar'
    pod 'SwiftWebVC'
end

target :'Gank' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

