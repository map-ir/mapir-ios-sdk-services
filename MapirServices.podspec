Pod::Spec.new do |s|

  s.name                      = "MapirServices"
  s.version                   = "0.1.0"
  s.summary                   = "a SDK to access services of map.ir using pure swift."

  s.homepage                  = "https://support.map.ir/"
  s.license                   = { :type => "MIT", :file => "LICENSE" }

  s.author                    = { "Map.ir" => "a.asadi@map.ir" }
  s.source                    = { :http => "https://srv-file5.gofile.io/download/eTOayk/mapir-services-ios-sdk-0.1.0.zip", :flatten => true }

  s.platform                  = :ios
  s.ios.deployment_target     = "10.0"
  s.module_name               = "MapirServiecs"

  s.vendored_frameworks       = 'Framework/MapirServices.framework'

  s.frameworks                = "Foundation", "CoreLocation"

end
