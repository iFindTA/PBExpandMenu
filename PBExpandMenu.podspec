Pod::Spec.new do |s|

  s.name         = "PBExpandMenu"
  s.version      = "1.0.0"
  s.summary      = "expand menu for iOS development."
  s.description  = "expand menu for FLK.Inc iOS Developers, such as click/choose/pick etc."

  s.homepage     = "https://github.com/iFindTA"
  s.license      = "MIT (LICENSE)"
  s.author             = { "nanhujiaju" => "hujiaju@hzflk.com" }

  s.platform     = :ios, "8.0"
  #s.source       = { :git => "http://192.168.10.99/iOSKits/NetServicePro.git", :tag => "#{s.version}" }
  s.source       = { :git => "https://github.com/iFindTA/PBExpandMenu.git", :tag => "#{s.version}" }
  s.source_files  = "PBExpandMenu/Pod/Classes/*.{h,m}"
  s.public_header_files = "PBExpandMenu/Pod/Classes/*.h"

  s.resources    = "PBExpandMenu/Pod/Assets/*.*"

  #s.libraries    = "CommonCrypto"
  s.frameworks  = "UIKit","Foundation","SystemConfiguration"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  s.requires_arc = true

  #s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/CommonCrypto,$(SRCROOT)/FLKNetService/Core","CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" =>"YES","ONLY_ACTIVE_ARCH" => "NO"}
  #s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include","CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" =>"YES","ONLY_ACTIVE_ARCH" => "NO"}
  #s.dependency "JSONKit", "~> 1.4"
end
