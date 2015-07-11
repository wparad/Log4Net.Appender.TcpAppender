#!/bin/
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'tmpdir'

PWD = File.dirname(__FILE__)
OUTPUT_DIR = File.join(PWD, 'output')
SOLUTION_SLN = 'Log4NetExtensions.sln'

#Environment variables: http://docs.travis-ci.com/user/environment-variables/
directory OUTPUT_DIR
task :build => [OUTPUT_DIR] do
  begin
    raise 'Nuget restore failed' if !system("nuget restore #{SOLUTION_SLN}")
    system('nuget install NUnit.Runners -Version 2.6.4 -OutputDirectory testrunner')
    raise 'Build failed' if !system("xbuild /p:Configuration=Release #{SOLUTION_SLN}")
    Dir.mktmpdir do |tmp|
      FileUtils.cp_r(Dir['src/Log4NetExtensions/bin/Release/**'], tmp)
      raise 'Nuget packing failed' if !system("nuget pack 'TcpAppender.nuspec' -Basepath #{tmp} -OutputDirectory #{OUTPUT_DIR}")
    end

    #Setup up deploy
    puts %x[git config --global user.email "builds@travis-ci.com"]
    puts %x[git config --global user.name "Travis CI"]
    tag = "0.1.#{ENV['TRAVIS_BUILD_NUMBER']}"
    puts %x[git tag #{tag} -a -m "Generated tag from TravisCI for build #{ENV['TRAVIS_BUILD_NUMBER']}"]
    puts %x[git push --quiet https://#{ENV['GIT_TAG_PUSHER']}@github.com/wparad/Log4Net.Appender.TcpAppender.git #{tag} > /dev/null 2>&1]
  rescue Exception => exception
    system('ls -alR')
    raise
  end
end
