Pod::Spec.new do |spec|

  spec.name          = "CordialAppExtensions_Objective-C"
  spec.version       = "0.3.1"
  spec.summary       = "CordialSDK extensions."

  spec.description   = <<-DESC
	CordialAppExtensions_Objective-C
  DESC

  spec.homepage      = "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "10.0"

  spec.swift_version = "4.2"

  spec.source        = { :git => "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "CordialAppExtensions_Objective-C", "CordialAppExtensions_Objective-C/CordialAppExtensions_Objective-C/**/*.{h,m}"

  spec.requires_arc  = true

end
