Pod::Spec.new do |s|

  s.name                      = "MapirServices"
  s.version                   = "0.5.0"
  s.summary                   = "a SDK to access services of map.ir."

  s.homepage                  = "https://support.map.ir/"
  s.social_media_url          = 'https://twitter.com/map_ir_Official'
  s.license                   = { :type => "MIT", :file => "LICENSE" }

  s.author                    = { "Map.ir"        => "support@map.ir",
                                  "Alireza Asadi" => "a.asadi@map.ir" }
  s.documentation_url         = 'https://support.map.ir/developers/iservice/'
  s.source                    = { :git => "https://github.com/map-ir/ios-sdk-v1-services-beta", :tag => s.version.to_s }

  # --- iOS ------------------------------------------------- #
  s.ios.deployment_target     = '9.0'
  s.ios.framework             = 'UIKit'

  # --- macOS ----------------------------------------------- #
  s.osx.deployment_target     = '10.10'
  s.osx.framework             = 'AppKit'

  # --- watchOS --------------------------------------------- #
  s.watchos.deployment_target = '3.0'
  s.watchos.framework         = 'UIKit'

  # --- tvOS ------------------------------------------------ #
  s.tvos.deployment_target    = '9.0'
  s.tvos.framework            = 'UIKit'

  s.requires_arc              = true
  s.module_name               = "MapirServiecs"
  s.swift_version             = '5.0'
  s.source_files              = "Sources/**/*.{swift, h}"

  s.frameworks                = "Foundation", "CoreLocation"

  s.dependency "Polyline", "~> 4.2.1"

end
