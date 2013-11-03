require_relative '../lib/code_doc'
describe CodeDoc do

  before(:all) do
    class UsingDef
      desc 'this is foo'
      arg :arg, 'this is foo'
      ret 'returns "foo"'
      def foo(arg)
        "foo"
      end
    end
  end

  let(:result) do
    {    
      :foo => {
        :desc => "this is foo", 
        :args => {
          :arg => "this is foo"
        }, 
        :ret => "returns \"foo\""
      }
    }
  end

  it 'records data for an instance method defined using `def` directly from the class' do
    UsingDef.code_doc_instance_methods.should == result
  end

  it 'records data for an instance method defined using `def` using CodeDoc.for' do
    CodeDoc.for(UsingDef).should == result
  end

  it 'returns an empty hash for classes without docs' do
    CodeDoc.for(String).should == {}
  end

end
