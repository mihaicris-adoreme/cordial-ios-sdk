Pod::Spec.new do |spec|

  spec.name          = "CordialAppExtensions"
  spec.version       = "4.1.2"
  spec.summary       = "CordialAppExtensions"

  spec.description   = <<-DESC
    The CordialAppExtensions allows application developers extend custom functionality and make it available to users.
  DESC

  spec.homepage      = "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk"

  spec.license       = "MIT"

  spec.author        = "Cordial Experience, Inc."

  spec.platform      = :ios, "12.0"

  spec.swift_version = "4.2"

  spec.source        = { :git => "https://gitlab.com/cordialinc/mobile-sdk/ios-sdk.git", :tag => "#{spec.version}" }

  spec.source_files  = "CordialAppExtensions", "Sources/CordialAppExtensions/**/*.{swift}"

  spec.requires_arc  = true

end
