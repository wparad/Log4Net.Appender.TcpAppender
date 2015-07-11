#!/bin/
require 'rake'
require 'rake/clean'

SOLUTION_SLN = 'Log4NetExtensions.sln'
task :build do
  begin
    raise 'Nuget restore failed' if !system("nuget restore #{SOLUTION_SLN}")
    system('nuget install NUnit.Runners -Version 2.6.4 -OutputDirectory testrunner')
    raise 'Build failed' if !system("xbuild /p:Configuration=Release #{SOLUTION_SLN}")
  rescue Exception => exception
    system('ls -alR')
    raise
  end
end
