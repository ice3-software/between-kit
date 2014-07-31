Pod::Spec.new do |s|
  s.name             = "I3DragNDrop"
  s.version          = "1.1.0"
  s.summary          = "Objective-C helper class(es) for the iOS platform that handle drag and drop logic between 2 UITableView s and/or UICollectionView s."
  s.homepage         = "https://github.com/ice3-software/i3-dragndrop"
  s.license          = 'MIT'
  s.author           = { "Steve Fortune" => "steve.fortune@icecb.com" }
  s.source           = { :git => "https://github.com/ice3-software/i3-dragndrop.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.public_header_files = 'Pod/Classes/**/*.h'
end
