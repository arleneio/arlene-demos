Pod::Spec.new do |spec|
  spec.name             = 'arlene-ios-sdk'
  spec.module_name      = 'Arlene'
  spec.version          = '0.1.0'
  spec.license          = { :type => 'New BSD', :file => 'LICENSE' }
  spec.homepage         = 'https://github.com/arleneio/arlene-ios-sdk'
  spec.authors          = { 'Arlene' => 'support@arlene.io' }
  spec.summary          = 'The Official Arlene Client SDK allows developers to easily monetize their XR apps using a native 3D ad formats.'
  spec.description      = <<-DESC
                            Arlene is a hosted ad serving solution built specifically for mobile XR publishers.\n
                            Grow your mobile advertising business with the first ARkit based ad framework, optimized \n
                            for XR environments, and earn revenue by connecting to the world's first XR focused \n
                            mobile ad network. \n\n
                            To learn more or sign up for an account, go to https://www.arlene.io. \n
                          DESC
  spec.social_media_url = 'https://twitter.com/arlene_io'
  spec.source           = { :git => 'https://github.com/arleneio/arlene-ios-sdk.git', :tag => '0.1.0' }
  spec.requires_arc     = true
  spec.ios.deployment_target = '11.0'
  spec.frameworks       = [
                            'ARKit',
                            'SceneKit',
                            'UIKit',
                            'CoreGraphics',
                            'Foundation',
                          ]
  spec.weak_frameworks  = [
                            'AdSupport',
                            'StoreKit',
                            'WebKit'
                          ]
  spec.source_files = "**/**/*.{swift}"
  spec.resources = "source/**/*.{png,jpeg,jpg,storyboard,xib,xcassets,shader}"
  # spec.resources = '/Pod/Resources/**/*.{shader}'
  spec.swift_version = "4.2"
  # spec.default_subspecs = 'ArleneSDK'
  spec.pod_target_xcconfig = {
    "SWIFT_VERSION" => "4.2",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS" => "DEBUG SEEMS_TO_HAVE_VALIDATE_VERTEX_ATTRIBUTE_BUG SEEMS_TO_HAVE_PNG_LOADING_BUG",
    "WEAK_REFERENCES_IN_MANUAL_RETAIN_RELEASE" => "No"
  }

end
