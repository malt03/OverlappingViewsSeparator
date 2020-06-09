Pod::Spec.new do |s|
  s.name             = 'OverlappingViewsSeparator'
  s.version          = '0.0.3'
  s.summary          = 'separate overlapping views'

  s.description      = <<-DESC
OverlappingViewsSeparator is a library for separate overlapping views.
                       DESC

  s.homepage         = 'https://github.com/malt03/OverlappingViewsSeparator'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'Koji Murata' => 'malt.koji@gmail.com' }
  s.source           = { git: 'https://github.com/malt03/OverlappingViewsSeparator.git', tag: "v#{s.version}" }

  s.source_files = "Sources/**/*.swift"

  s.swift_version = "5.2"
  s.ios.deployment_target = "8.0"
end
