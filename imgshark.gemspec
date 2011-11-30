# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dickburt/version"
Gem::Specification.new do |s|
  s.name        = "imgshark"
  s.version     = Dickburt::VERSION
  s.authors     = ["Tyler Montgomery"]
  s.email       = ["tyler@everlater.com"]
  s.homepage    = "http://github.com/ubermajestix/imgshark"
  s.summary     = %q{Resizes images, stores info in Redis, puts new image on S3}
  s.description = %q{sharking about}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis',      '~> 2.0 '
  s.add_dependency 'aws-s3',     '~> 0.6.2'
  s.add_dependency 'yajl-ruby',  '~> 1.0.0'
  s.add_dependency 'map',        '~> 4.5.0'
  s.add_dependency 'http',       '~> 0.0.2'
  s.add_dependency 'rmagick',    '~> 2.13.1'

  s.add_development_dependency 'rspec', '~> 2.6.0'
  s.add_development_dependency 'vcr',   '~> 1.3.3'
end
