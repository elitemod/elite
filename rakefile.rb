require 'rake'
require 'fileutils'
include FileUtils

# set constant values:
UT2004_FOLDER = File.expand_path('../')
UMAKE_EXE = "C:/UMake.exe"

# get version info
buildVersion = nil
open("version.txt") do |f|
	buildVersion = f.read
end

desc "Make a new version"
task :default do
	packageName = "EliteMod_v#{buildVersion}"
	target = "#{UT2004_FOLDER}/#{packageName}"

    puts "Creating Package ... #{target}"
    FileUtils.mkdir_p("#{target}/Classes");
    FileUtils.cp_r(FileList.new('*').exclude("*.rb"), target);
	
    files = FileList.new("#{target}/**/*.uc");
	files.each do |file_name|
	  originalSource = File.read(file_name)
	  updatedSource = originalSource.gsub(/EliteMod\./, "#{packageName}.")
	  File.open(file_name, "w") {|file| file.puts updatedSource}
	end

	system("#{UMAKE_EXE} #{target}");
end
