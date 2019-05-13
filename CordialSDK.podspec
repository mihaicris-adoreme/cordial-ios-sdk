Pod::Spec.new do |spec|

  spec.name          = "CordialSDK"
  spec.version       = "0.0.3"
  spec.summary       = "The Cordial SDK."

  spec.description   = <<-DESC
	The Cordial SDK allows application developers to pass customer and event data from their applications to the Cordial platform.
  DESC

  spec.homepage      = "https://gitlab.com/CordialExperiences/mobile/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "11.0"

  spec.swift_version = "4.2"

  spec.source        = { :git => "https://gitlab.com/CordialExperiences/mobile/ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "CordialSDK", "CordialSDK/**/*.{swift}"

  spec.resource_bundles = { "CordialSDK" => ["CordialSDK/**/*.{xcdatamodeld}"] }

  spec.requires_arc  = true

end
