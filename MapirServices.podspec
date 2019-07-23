Pod::Spec.new do |s|

  s.name                      = "MapirServices"
  s.version                   = "0.1.0"
  s.summary                   = "a SDK to access services of map.ir."

  s.homepage                  = "https://support.map.ir/"
  s.license                   = { :type => "MIT", :file => "LICENSE" }

  s.author                    = { "Map.ir" => "a.asadi@map.ir" }
  s.source                    = { :git => "https://github.com/map-ir/ios-sdk-v1-services-beta", :tag => "v#{s.version}" }

  # --- iOS ------------------------------------------------- #

  s.platform                  = :ios
  s.ios.deployment_target     = '9.0'

  # --- macOS ----------------------------------------------- #
  # s.platform                  = :osx
  # s.osx.deployment_target     = '10.10'

  s.requires_arc              = true
  s.module_name               = "MapirServiecs"
  s.swift_version             = '5.0'
  s.source_files              = "Sources/**/*.{swift, h}"

  s.frameworks                = "Foundation", "CoreLocation"

  s.dependency "Polyline", "~> 4.2.1"

end
