
Pod::Spec.new do |s|

s.name         = "TSCoreDataStore"
s.version      = "0.0.1"
s.summary      = "TSCoreDataStore gives easy access to core data and parsing data"
s.author       = "Richard Moult"
s.source_files = 'classes/*.{h,m}'
s.requires_arc = true
s.platform     = :ios, '7.0'
s.source       = {:git => "https://github.com/trickysquirrel/TSCoreDataStore.git", :tag=> '0.0.1'}

end
