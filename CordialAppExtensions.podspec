Pod::Spec.new do |spec|

  spec.name          = "CordialAppExtensions"
  spec.version       = "0.1.5"
  spec.summary       = "CordialAppExtensions"

  spec.description   = <<-DESC
	CordialSDK extensions.
  DESC

  spec.homepage      = "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "11.0"

  spec.swift_version = "4.2"

  spec.source        = { :git => "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "CordialAppExtensions", "CordialAppExtensions/CordialAppExtensions/**/*.{swift}"

  spec.requires_arc  = true

end
