Pod::Spec.new do |s|

  s.name                      = "MapirServices"
  s.version                   = "0.1.0"
  s.summary                   = "a SDK to access services of map.ir."

  s.homepage                  = "https://support.map.ir/"
  s.license                   = { :type => "MIT", :file => "LICENSE" }

  s.author                    = { "Map.ir" => "a.asadi@map.ir" }
  s.source                    = { :git => "https://github.com/map-ir/ios-sdk-v1-services-beta", :tag => s.version }

  s.platform                  = :ios
  s.ios.deployment_target     = "10.0"
  s.module_name               = "MapirServiecs"

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = "Sources/**/*.swift"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resources = ['MapirServices/Resources/*/*', 'MapirServices/Resources/*']

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

  s.dependency "Polyline", "~> 4.2.1"

  s.swift_version = '5.0'


  s.frameworks                = "Foundation", "CoreLocation"

end
