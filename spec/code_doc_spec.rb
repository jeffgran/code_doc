require_relative '../lib/code_doc'
describe CodeDoc do

  before(:all) do
    CodeDoc.debug! # turn debug output on

    desc "an example class for testing purposes"
    class UsingDef
      desc 'this is foo'
      arg :arg, 'this is the arg for foo'
      ret 'returns "foo"'
      def foo(arg)
        "foo"
      end

      desc "this is #bar"
      arg :arg, "this is the arg for bar"
      ret 'returns "bar"'
      def self.bar(arg)
        "bar"
      end

      class << self
        desc "this is #baz"
        arg :arg, "this is the arg for baz"
        ret 'returns "baz"'
        def baz(arg)
          "baz"
        end
      end
      
    end
  end

  let(:instance_result) do
    {    
      :foo => {
        :desc => "this is foo", 
        :args => {
          :arg => "this is the arg for foo"
        }, 
        :ret => "returns \"foo\""
      }
    }
  end
  
  let(:singleton_result) do
    {    
      :bar => {
        :desc => "this is #bar", 
        :args => {
          :arg => "this is the arg for bar"
        }, 
        :ret => "returns \"bar\""
      },
      :baz => {
        :desc => "this is #baz", 
        :args => {
          :arg => "this is the arg for baz"
        }, 
        :ret => "returns \"baz\""
      }
    }
  end

  it 'records data for an instance method defined using `def` directly from the class' do
    UsingDef.code_doc_instance_methods.should == instance_result
  end

  it 'records data for an instance method defined using `def` using CodeDoc.for' do
    CodeDoc.for(UsingDef)[:instance_methods].should == instance_result
  end

  it 'records data for a singleton method defined using `def` directly from the class' do
    UsingDef.code_doc_singleton_methods.should == singleton_result
  end

  it 'records data for a singleton method defined using `def` using CodeDoc.for' do
    CodeDoc.for(UsingDef)[:singleton_methods].should == singleton_result
  end

  it 'not fail for classes without docs' do
    CodeDoc.for(String)[:instance_methods].should eq({})
    CodeDoc.for(String)[:singleton_methods].should eq({})
  end

  it 'records the description for a new class' do
    CodeDoc.for(UsingDef)[:desc].should eq 'an example class for testing purposes'
  end



  let(:mymodule){
    desc "this is a test module"
    module MyModule
      desc 'this is a mod method'
      arg :num, "the number of peeps in the mod squad"
      ret 'a numerical rating of how mod your squad is'
      def mod_method(num)
        num
      end
    end
    MyModule
  }

  let(:mymodule_instance_methods) do
    {
      mod_method: {
        desc: 'this is a mod method',
        args: {
          num: "the number of peeps in the mod squad"
        },
        ret: 'a numerical rating of how mod your squad is'
      }
    }
  end
  
  it 'records the description for a new module' do
    CodeDoc.for(mymodule)[:desc].should eq 'this is a test module'
  end

  it 'records data for methods in a new module' do
    CodeDoc.for(mymodule)[:instance_methods].should eq mymodule_instance_methods
  end


  
  let(:class_with_included_module) do
    class ClassWithModule
      include mymodule
    end
  end

  # hmmm... should we report them for the class, or just report the inherited module, and report it on the module?
  # it 'records that a module has been inherited by a class' do
  #   CodeDoc.for(ClassWithModule)[:included_modules].should eq([:MyModule])
  # end

  

end
