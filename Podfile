target 'Life' do
platform :ios, '13.0'
use_frameworks!

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
  end
 end
end

  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  pod 'Firebase/Firestore'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
<<<<<<< HEAD
  pod 'Firebase/AppCheck'
=======
  
>>>>>>> master
  pod 'SkyFloatingLabelTextField', '~> 3.0'
  pod 'IQKeyboardManagerSwift'
  pod 'DPOTPView'
  pod 'JGProgressHUD'
  pod 'FlagPhoneNumber'
  pod 'BEMCheckBox'
  pod 'CryptoSwift'
  pod 'MessageKit'
  pod 'RealmSwift'
  pod 'NYTPhotoViewer'
  pod 'Reachability'
  pod 'ProgressHUD'
  pod 'RNCryptor-objc'
  pod 'SwiftyAvatar', '~> 1.1'
  pod 'QRCodeReader.swift', '~> 10.1.0'
  pod 'FittedSheets'
  pod 'Kingfisher'
<<<<<<< HEAD
  pod 'SCLAlertView'
  pod 'FormTextField'
  pod 'CreditCardValidator'
=======
  pod 'UIColor_Hex_Swift'
#  pod 'SCLAlertView'
#pod 'OneSignal', '>= 3.0.0', '< 4.0'
#pod 'SinchRTC'

>>>>>>> master
  target 'LifeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'LifeUITests' do
    # Pods for testing
  end

end
