Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "MapirServices"
  spec.version      = "1.0.0"
  spec.summary      = "A wrapper to access services of Map.ir in a Swift-y way."
  spec.homepage     = "https://support.map.ir"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #


  spec.authors            = { "Map.ir"        => "info@map.ir",
                              "Alireza Asadi" => "a.asadi@map.ir" }
  spec.social_media_url   = "https://twitter.com/map_ir_Official"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.platform        = :ios, "9.0"
  spec.swift_versions  = ["5.1", "5.2"]


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source       = { :git => "https://github.com/map-ir/mapir-ios-sdk-services.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "Source/**/*.swift"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.frameworks = "Foundation", "CoreLocation"

end
