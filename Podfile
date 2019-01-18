# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DesignFlower' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DesignFlower
  
  # Realm
  pod 'RealmSwift'

  # Camera Manager
  pod 'CameraManager', '~> 4.2'
  
  # Network
  pod 'Moya/RxSwift'
  
  # PromiseKit/Alamofire
  pod 'PromiseKit', '~> 4.0'
  pod 'PromiseKit/Alamofire', '~> 4.0'
  
  # HTTP Status Code Enum
  pod 'HTTPStatusCodes', '~> 3.1.1'
  
  # SwiftyJSON
  #pod 'SwiftyJSON'
  
  # Pod for progress
  pod 'SVProgressHUD'
  
  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'
  
  # Layout Helpers
  pod 'SnapKit', '~> 4.0.0'
  
  # Image Caching
  pod 'SDWebImage', '~> 4.0'
  
  # Location Services
  pod 'SwiftLocation', '~> 3.2.3'
  pod 'CountryAndCity'
  
  # Rate View
  pod 'YCRateView'
  
  # IQ Keyboard Manager
  pod 'IQKeyboardManagerSwift'
  
  # Table View Dragger
  pod 'TableViewDragger'
  
  # Kingfisher
  pod 'Kingfisher', '~> 4.8.0'
  
  # iCarousel
  pod 'iCarousel'
  
  # Collection align
  pod 'AlignedCollectionViewFlowLayout'
  
  # Fabric
  pod 'Fabric'
  pod 'Crashlytics'
  
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
