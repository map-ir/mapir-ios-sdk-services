Pod::Spec.new do |s|
  s.name                      = "MapirServices"
  s.version                   = "1.0.0"
  s.summary                   = "MapirServices"
  s.homepage                  = "https://github.com/AlirezaAsadi/MapirServices"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Alireza Asadi" => "alireza.asadi.36@gmail.com" }
  s.source                    = { :git => "https://github.com/AlirezaAsadi/MapirServices.git", :tag => s.version.to_s }
  s.ios.deployment_target     = "8.0"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target     = "10.10"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
