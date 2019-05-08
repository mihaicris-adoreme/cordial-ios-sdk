Pod::Spec.new do |spec|

  spec.name          = "CordialSDK"
  spec.version       = "0.0.1"
  spec.summary       = "A short description of CordialSDK."

  spec.description   = <<-DESC
	A long description of CordialSDK.
  DESC

  spec.homepage      = "https://gitlab.com/CordialExperiences/mobile/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "11.0"

  spec.source        = { :git => "https://gitlab.com/CordialExperiences/mobile/ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "CordialSDK", "CordialSDK/**/*.{swift}"

  spec.requires_arc  = true

end
