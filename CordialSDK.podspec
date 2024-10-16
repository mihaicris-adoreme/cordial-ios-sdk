Pod::Spec.new do |spec|

  spec.name          = "CordialSDK"
  spec.version       = "4.5.0"
  spec.summary       = "CordialSDK"

  spec.description   = <<-DESC
    The Cordial SDK allows application developers to pass customer and event data from their applications to the Cordial platform.
  DESC

  spec.homepage      = "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "12.0"

  spec.swift_version = "4.2"

  spec.source        = { :git => "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk.git", :tag => "#{spec.version}" }

  spec.ios.vendored_frameworks = "Sources/CordialSDK.xcframework"

  spec.static_framework = true

end
