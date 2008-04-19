require File.dirname(__FILE__) + '/../lib/test_unit_to_rspec_converter'
task :convert_to_rspec do
  converted_count = 0
  DIRECTORIES = ["test/functional","test/unit","test/helpers"]
  DIRECTORIES.each do |directory|
    next unless File.exists?(directory)
    Dir.entries(directory).each do |file|
      next if IGNORED_DIRS = ['.','..','.svn','.DS_Store'].include?(File.basename(file))
      full_path = File.join(directory,file)
      if File.file?(full_path)
        test_case = TestUnitToRspecConverter.new(full_path)
        test_case.convert
        converted_count += 1
      end
    end
  end
  puts "Test::Unit to RSpec conversion finished. #{converted_count} files converted."
end