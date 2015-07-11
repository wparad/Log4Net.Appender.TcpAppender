#!/bin/
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'tmpdir'

PWD = __dir__
OUTPUT_DIR = File.join(PWD, 'output')
SOLUTION_SLN = 'Log4NetExtensions.sln'

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
  rescue Exception => exception
    system('ls -alR')
    raise
  end
end
