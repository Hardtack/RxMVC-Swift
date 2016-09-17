Pod::Spec.new do |s|
  s.name             = "RxMVC"
  s.version          = "0.2.0-beta.1"
  s.summary          = "Model-View-Controller pattern with RxSwift"
  s.description      = <<-DESC
Model-View-Controller pattern with RxSwift.
                       DESC
  s.homepage         = "https://github.com/Hardtack/RxMVC-Swift"
  s.license          = 'MIT'
  s.author           = { "Choi Geonu" => "6566gun@gmail.com" }
  s.source           = { :git => "https://github.com/Hardtack/RxMVC-Swift.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'RxMVC/Classes/**/*'
  s.resource_bundles = {
  }

  s.dependency 'RxSwift',    '~> 3.0.0-beta.1'
  s.dependency 'RxCocoa',    '~> 3.0.0-beta.1'
end
