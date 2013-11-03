require 'rubygems'

require 'active_support/core_ext'
require 'sender'
require 'awesome_print'

module CodeDoc
  class DocumentationMissing < Exception;end

  def self.debug?
    true
    #false
  end

  def self.for(klass)
    return {} unless klass.respond_to?(:code_doc_instance_methods)
    klass.code_doc_instance_methods
  end
end

String.send(:alias_method, :undent, :strip_heredoc)

class Class
  def desc(d)
    @_code_doc_desc = d
  end

  def arg(name, description)
    @_code_doc_args ||={}
    @_code_doc_args[name] = description
  end

  def ret(r)
    @_code_doc_ret = r
  end

  #-----------------------------------------------------------------------------
  desc "hooks each time a method is added and keeps track of the documentation"
  arg :name, "the name of the method that was just added"
  #-----------------------------------------------------------------------------
  def method_added(name)
    return unless @_code_doc_desc || @_code_doc_args || @_code_doc_ret

    calling_class = Kernel.backtrace[1][:object]
    

    # won't work.
    # maybe make users include a module into their classes to "prove" they own
    # it, so we can enforce it only in classes they own?
    #
    # if CodeDoc.strict? and @_code_doc_desc.blank?
    #   raise CodeDoc::DocumentationMissing, 
    #   "Must supply a description for #{calling_class}##{name}"
    # end

    if CodeDoc.debug?
      puts "Documenting #{calling_class}##{name}"
      puts "  Description:"
      puts "    #{@_code_doc_desc.undent}"
      puts "  Args:"
      if @_code_doc_args.blank?
        puts "    none"
      else
        @_code_doc_args.each do |name, desc|
          puts "    #{name}: #{desc}"
        end
      end
      puts "  Returns: #{@_code_doc_ret}"
      puts ''
    end


    @_code_doc_instance_methods ||= {}
    @_code_doc_instance_methods[name] = {
      desc: @_code_doc_desc,
      args: @_code_doc_args,
      ret: @_code_doc_ret
    }
    

    @_code_doc_desc = @_code_doc_args = @_code_doc_ret = nil
  end


  #-----------------------------------------------------------------------------
  desc <<-DESC
    hooks each time a singleton method is added and keeps track of the 
    documentation
  DESC
  #-----------------------------------------------------------------------------
  def singleton_method_added(name)
    # puts "singleton method_added: #{name}"
    # puts "to: #{Kernel.backtrace[1][:object]}"#.instance_method(name)
  end



  #-----------------------------------------------------------------------------
  ret <<-DESC
    a hash whose keys are the symbols representing all the documented instance
    methods in this class, and whose values are the hash of documentation
    information for the corresponding methods. 
    Example (for class Foo with instance method #bar): 
      {
        :bar => {
          :desc => "this is the #bar method.",
          :args => {
            :arg => "this is the arg"
          },
          :ret => "nil, because it just calls Kernel#puts"
        }
      }
  DESC
  #-----------------------------------------------------------------------------
  def code_doc_instance_methods
    @_code_doc_instance_methods ||= {}
  end

  

end





class Foo

  #-----------------------------------------------------------------------------
  desc "this is the #bar method. it is similar to the #foo method"
  arg :arg, "this is the arg"
  ret "nil, because it just calls Kernel#puts"
  #-----------------------------------------------------------------------------
  def bar(arg)
    puts "bar #{arg}!"
  end

  #-----------------------------------------------------------------------------
  desc "this is the #cmethod method. it is similar to the #bar method"
  #-----------------------------------------------------------------------------
  def self.cmethod
    "foo"
  end
  
end

# puts "name:"
# puts Foo.instance_method(:bar).name.inspect

# puts "arity:"
# puts Foo.instance_method(:bar).arity.inspect

# puts "parameters:"
# puts Foo.instance_method(:bar).parameters.inspect

# puts "location:"
# puts Foo.instance_method(:bar).source_location.inspect
