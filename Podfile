platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

inhibit_all_warnings!

link_with 'LiFX Widget', 'LiFX Widget Companion', 'LiFX Widget Companion WatchKit Extension', 'LiFX Widget Companion WatchKit App'
pod 'LIFXAPIWrapper'

target :companion do
       link_with 'LiFX Widget Companion'
       pod 'SVProgressHUD'
end

post_install do |add_app_extension_macro|
    add_app_extension_macro.project.targets.each do |target|
        if target.name == "Pods-AFNetworking"
            target.build_configurations.each do |config|
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'AF_APP_EXTENSIONS=1']
            end
        end
    end
end