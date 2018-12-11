# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DesignFlower' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DesignFlower
  
  # Realm
  pod 'RealmSwift'

  # Camear Manager
  pod 'CameraManager', '~> 4.2'
  
  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  
  # Image Caching
  pod 'SDWebImage', '~> 4.0'
  
end

post_install do |installer|
  # Specify Swift version for pods
  installer.pods_project.targets.each do |target|
    if ['CameraManager'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.0'
      end
    end
  end
end
