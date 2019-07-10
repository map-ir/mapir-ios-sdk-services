Pod::Spec.new do |s|

  s.name                      = "MapirServices"
  s.version                   = "1.0.0"
  s.summary                   = "a SDK to access services of map.ir using pure swift."

  s.homepage                  = "https://support.map.ir/"
  s.license                   = { :type => "MIT", :file => "LICENSE.md" }

  s.author                    = { "Map.ir" => "a.asadi@map.ir" }
  s.source                    = { :http => "https://srv-file2.gofile.io/download/As7PDN/mapir-ios-sdk-services-100.zip", :flatten => true }

  s.platform                  = :ios
  s.ios.deployment_target     = "10.0"
  s.module_name               = "MapirServiecs"

  s.vendored_frameworks       = 'Frameworks/MapirServices.framework'

  s.frameworks                = "Foundation"

end
