require File.dirname(__FILE__) + '/../lib/test_unit_to_rspec_converter'

describe TestUnitToRspecConverter do
  
  before(:each) do
    @convertor = TestUnitToRspecConverter.new("unit_test.rb")
  end
  
  it "should generate spec path" do
    @convertor.spec_name.should == "unit_spec.rb"
  end
  
  it "should generate controller spec path" do
    @convertor.filename = "something/test/functional/unit_test.rb"
    @convertor.spec_name.should == "something/spec/controllers/unit_spec.rb"
  end
  
  it "should generate model spec path" do
    @convertor.filename = "something/test/unit/unit_test.rb"
    @convertor.spec_name.should == "something/spec/models/unit_spec.rb"
  end
  
  it "should generate helper spec path" do
    @convertor.filename = "something/test/helper/unit_test.rb"
    @convertor.spec_name.should == "something/spec/helpers/unit_spec.rb"
  end
  
  it "should convert setup method" do
    @convertor.test_case = "def setup"
    @convertor.convert_setup_method
    @convertor.test_case.should == "before(:all) do"
  end
  
  it "should convert class declaration" do
    @convertor.test_case = "class UnitTest < Test::Unit::TestCase"
    @convertor.convert_test_unit_class_declaration
    @convertor.test_case.should == "describe Unit do"
  end
  
  it "should convert class declaration with a number in there" do
    @convertor.test_case = "class Unit1Test < Test::Unit::TestCase"
    @convertor.convert_test_unit_class_declaration
    @convertor.test_case.should == "describe Unit1 do"
  end
  
  it "should convert test helper" do
    @convertor.test_case = "require File.dirname(__FILE__) + '/../test_helper'"
    @convertor.convert_test_helper
    @convertor.test_case.should == "require File.dirname(__FILE__) + '/../spec_helper'"
  end
  
  it "should convert method name" do
    @convertor.test_case = "def test_should_not_do_something_or_something_like_that"
    @convertor.convert_method_name
    @convertor.test_case.should == "it 'should not do something or something like that' do"
  end
  
  it "should convert short method name" do
    @convertor.test_case = "def test_should"
    @convertor.convert_method_name
    @convertor.test_case.should == "it 'should' do"
  end
  
  it "should convert assert false" do
    @convertor.test_case = "assert !@user.errors.on(:name).nil?"
    @convertor.convert_assert_false
    @convertor.test_case.should == "@user.errors.on(:name).nil?.should_not be_true"
  end
  # assert foo, "something should something"
  # -> assert foo
  it "should remove comments from asserts" do
    @convertor.test_case = 'assert @user.valid?, "something"'
    @convertor.remove_comments_from_asserts
    @convertor.test_case.should == 'assert @user.valid?'
  end
  
  it "should convert assert true" do
    @convertor.test_case = "assert @user.valid?"
    @convertor.convert_assert_true
    @convertor.test_case.should == "@user.valid?.should be_true"
  end
  
  #it "should convert assert true and discard comment" do
  #  @convertor.test_case = "assert @user.valid?, \"something something\""
  #  @convertor.convert_assert_true
  #  @convertor.test_case.should == "@user.valid?.should be_true"
  #end
  
  it "should convert assert equal" do
    @convertor.test_case = "assert_equal 'test@domain.com', @user.email"
    @convertor.convert_assert_equal
    @convertor.test_case.should == "@user.email.should == 'test@domain.com'"
  end
  
end