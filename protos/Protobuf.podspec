Pod::Spec.new do |s|
  s.name         = "Protobuf"
  s.summary      = "Protobuf"
  s.homepage     = "https://github.com/KyoheiG3/ProtobufExample"
  s.version      = "0.0.1"
  s.author       = { "Kyohei Ito" => "je.suis.kyohei@gmail.com" }
  s.ios.deployment_target = '8.0'
  s.source       = { :path => '.' }
  s.source_files  = "**/*.swift"
  s.requires_arc = true
  s.dependency 'SwiftProtobuf'
end
