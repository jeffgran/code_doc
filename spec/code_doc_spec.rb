require_relative '../lib/code_doc'
describe CodeDoc do

  before(:all) do
    CodeDoc.debug! # turn debug output on
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

  it 'returns an empty hash for classes without docs' do
    CodeDoc.for(String).should == {
      instance_methods: {},
      singleton_methods: {}
    }
  end

end
