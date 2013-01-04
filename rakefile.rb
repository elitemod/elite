require 'rake'
require 'fileutils'
include FileUtils

# config:
UT2004_FOLDER = File.expand_path('../')
UMAKE_EXE = "C:/UMake.exe"

# read version file
buildVersion = nil
open("version.txt") do |f|
	buildVersion = f.read
end

desc "Make a new version"
task :default do
	packageName = "EliteMod_#{buildVersion}"
	target = "#{UT2004_FOLDER}/#{packageName}"

	# -------------------------------------------------------
    puts "Creating Package ... #{target}"
    FileUtils.mkdir_p("#{target}/Classes");
    FileUtils.cp_r(FileList.new('*').exclude("*.rb"), target);
	
	# -------------------------------------------------------
    puts "- Updating sources to refer to new package"
    files = FileList.new("#{target}/**/*.uc");
	files.each do |file_name|
	  originalSource = File.read(file_name)
	  updatedSource = originalSource.gsub(/EliteMod\./, "#{packageName}.")
	  File.open(file_name, "w") {|file| file.puts updatedSource}
	end

	# -------------------------------------------------------
    puts "- Creating a matching UMake INI File"
    files = FileList.new("#{target}/*.ini");
	files.each do |file_name|
	  originalSource = File.read(file_name)
	  updatedSource = originalSource.gsub(/\=EliteMod/, "=#{packageName}")
	  File.open(file_name, "w") {|file| file.puts updatedSource}
	end

	# -------------------------------------------------------
    puts "- Running UMake"
	system("#{UMAKE_EXE} #{target}");

	# -------------------------------------------------------
	puts "Done."
end
