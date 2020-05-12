Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name                      = "MapirServices"
  s.version                   = "1.0.0"
  s.summary                   = "a SDK to access services of Map.ir in a Swifty way."
  s.homepage                  = "https://support.map.ir/"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license                   = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author                    = { "Map.ir"        => "info@map.ir",
                                  "Alireza Asadi" => "a.asadi@map.ir" }
  
  s.social_media_url          = 'https://twitter.com/map_ir_Official'

  s.documentation_url         = 'https://support.map.ir/developers/iservice/'


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.platform                  = :ios, "9.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source                    = { :git => "https://github.com/map-ir/ios-sdk-v1-services", :tag => s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.module_name               = "MapirServiecs"
  s.swift_version             = '5.1'
  s.source_files              = "Source/**/*.{swift, h}"
  s.frameworks                = "Foundation", "CoreLocation"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc              = true
  s.dependency "Polyline", "~> 4.2.1"

end
