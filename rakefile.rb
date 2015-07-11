#!/bin/
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'tmpdir'

PWD = File.dirname(__FILE__)
OUTPUT_DIR = File.join(PWD, 'output')
SOLUTION_SLN = 'Log4NetExtensions.sln'
GIT_REPOSITORY = %x[git config --get remote.origin.url].split('://')[1]
match = (ENV['TRAVIS_BRANCH'] || '').match(/^release\/(.*)$/)
VERSION = "#{match && match[1] ? match[1] : '0.0'}.#{ENV['TRAVIS_BUILD_NUMBER']}"
#Environment variables: http://docs.travis-ci.com/user/environment-variables/
directory OUTPUT_DIR
task :build => [OUTPUT_DIR] do
  raise 'Nuget restore failed' if !system("nuget restore #{SOLUTION_SLN}")
  system('nuget install NUnit.Runners -Version 2.6.4 -OutputDirectory testrunner')
  raise 'Build failed' if !system("xbuild /p:Configuration=Release #{SOLUTION_SLN}")
  Dir.mktmpdir do |tmp|
    nuspec = File.join(tmp, 'TcpAppender.nuspec')
    File.write(nuspec, "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<package xmlns=\"http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd\">
  <metadata>
    <id>Log4NetExtensions.TcpAppender</id>
    <title>Log4NetExtensions.TcpAppender</title>
    <version>#{VERSION}</version>
    <authors>Warren Parad</authors>
    <owners>Warren Parad</owners>
    <projectUrl>https://#{GIT_REPOSITORY}</projectUrl>
    <description>TcpAppender for Log4Net</description>
    <dependencies>
      <dependency id=\"log4net\" version=\"2.0.3\" />
    </dependencies>
  </metadata>
</package>
")
	package_directory = File.expand_path(File.join(tmp, 'package'))
	binaries_directory = File.join(package_directory, 'lib', 'net40')
    FileUtils.mkdir_p(binaries_directory)
    FileUtils.cp_r(Dir[File.join(PWD, 'src/Log4NetExtensions/obj/Release','**', '*.{dll,mdb,xml}')], binaries_directory)
    raise 'Nuget packing failed' if !system("nuget pack '#{nuspec}' -Basepath #{package_directory} -OutputDirectory #{OUTPUT_DIR}")
  end

  if ENV['TRAVIS']
    #Setup up deploy
    puts %x[git config --global user.email "builds@travis-ci.com"]
    puts %x[git config --global user.name "Travis CI"]
    tag = VERSION
    puts %x[git tag #{tag} -a -m "Generated tag from TravisCI for build #{ENV['TRAVIS_BUILD_NUMBER']}"]
    puts "Pushing Git tag #{tag}."
    %x[git push --quiet https://#{ENV['GIT_TAG_PUSHER']}@#{GIT_REPOSITORY} #{tag} > /dev/null 2>&1]
  end
end
