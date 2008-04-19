class TestUnitToRspecConverter

  attr_accessor :test_case, :filename
  
  def initialize(filename)
    self.filename = filename
  end
  
  def convert
    self.read
    [:remove_comments_from_asserts, :convert_method_name, :convert_assert_false, 
     :convert_assert_true, :convert_assert_equal, :convert_test_helper, 
     :convert_test_unit_class_declaration, :convert_setup_method].each { |m| self.send m }    
    self.write
  end
  
  def read
    self.test_case = File.read(self.filename)
  end
  
  def write
    FileUtils.mkdir_p(File.dirname(spec_name))
    File.open self.spec_name, "w+" do |file|
      file.flush
      file << self.test_case
    end
  end
  
  def spec_name
    tmp = self.filename.clone
    tmp.gsub!(/test\/functional/,"spec/controllers")
    tmp.gsub!(/test\/unit/,"spec/models")
    tmp.gsub!(/test\/helper/,"spec/helpers")
    tmp.gsub!(/_test\.rb/,"_spec.rb")
  end
  
  # def setup => before(:each) do
  def convert_setup_method
    test_case.gsub!(/def setup/,"before(:all) do")
  end
  
  # class VideoTest < Test::Unit::TestCase
  # => describe Video do
  def convert_test_unit_class_declaration
    test_case.gsub!(/class ([A-Za-z0-9]*)Test \< Test::Unit::TestCase/) { |s| "describe #{$1} do" }
  end
  
  # require File.dirname(__FILE__) + '/../test_helper' 
  # => require File.dirname(__FILE__) + '/../spec_helper'
  def convert_test_helper
    test_case.gsub!(/test_helper/,'spec_helper')
  end
  
  # def test_foo -> it "test_foo" do
  def convert_method_name
    test_case.gsub!(/def test_([a-z_]*)$/) { |s| "it '#{$1.gsub('_',' ')}' do" }
  end
  
  # assert !foo -> foo.should_not be_true
  def convert_assert_false
    test_case.gsub!(/assert !(.*)$/) { |s| "#{$1}.should_not be_true" }
  end
  
  # assert foo, "something should something"
  # -> assert foo
  def remove_comments_from_asserts
    test_case.gsub!(/(assert !?.*), (".*")$/) { |s| "#{$1}" } 
  end
  
  
  # assert foo -> foo.should be_true
  def convert_assert_true
    test_case.gsub!(/assert (.*)$/) { |s| "#{$1}.should be_true" }
  end
  
  # assert_equal foo, bar -> bar.should == foo
  def convert_assert_equal
    test_case.gsub!(/assert_equal (.*), (.*)$/) { |s| "#{$2}.should == #{$1}" }
  end
  
end