#
# Be sure to run `pod lib lint BetweenKit.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BetweenKit"
  s.version          = "2.0.0"
  s.summary          = "iOS UI framework that allows developers to build drag-and-drop fluidity into their user interfaces more easily."
  s.homepage         = "https://github.com/ice3-software/i3-dragndrop"
  s.license          = 'MIT'
  s.author           = { "Stephen Fortune" => "steve.fortune@icecb.com" }
  s.source           = { :git => "https://github.com/ice3-software/i3-dragndrop.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'BetweenKit' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/Header/BetweenKit.h'
  s.frameworks = 'UIKit'
end
