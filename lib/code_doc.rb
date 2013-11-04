require 'rubygems'

require 'active_support/core_ext'
require 'sender'
require 'awesome_print'

String.send(:alias_method, :undent, :strip_heredoc)

module CodeDoc
  class DocumentationMissing < Exception;end

  def self.debug?
    @@debug ||= false
  end

  def self.debug!
    @@debug = true
  end

  def self.debug=(newval)
    @@debug = newval
  end

  def self.debug!
    @@debug = true
  end
  

  def self.for(klass)
    return {} unless klass.respond_to?(:code_doc_instance_methods)

    return {
      desc: klass.code_doc_desc,
      included_modules: klass.code_doc_included_modules,
      instance_methods: klass.code_doc_instance_methods,
      singleton_methods: klass.code_doc_singleton_methods
    }
  end
  
end


class Module
  attr_accessor :_code_doc_instance_methods
  attr_accessor :_code_doc_singleton_methods

  def is_singleton_class?
    # thanks to Avdi Grimm @ http://devblog.avdi.org/2010/09/23/determining-singleton-class-status-in-ruby/
    return false unless respond_to?(:ancestors)
    !(ancestors.include?(self))
  end

  def nearest_singleton_class
    is_singleton_class? ? self : self.singleton_class
  end
  
  def desc(d)
    if is_singleton_class?
      @_code_doc_desc = d
    else
      obj = nearest_singleton_class
      obj.desc(d)
    end
  end

  def arg(name, description)
    if is_singleton_class?
      @_code_doc_args ||={}
      @_code_doc_args[name] = description
    else
      obj = self.singleton_class
      obj.arg(name, description)
    end
  end

  def ret(r)
    if is_singleton_class?
      @_code_doc_ret = r
    else
      obj = is_singleton_class? ? self : self.singleton_class
      obj.ret(r)
    end
  end

  def code_doc_document_method(opts)
    name = opts[:name]
    obj = self
    # won't work...
    # maybe make users include a module into their classes to "prove" they own
    # it, so we can enforce it only in classes they own?
    #
    # if CodeDoc.strict? and @_code_doc_desc.blank?
    #   raise CodeDoc::DocumentationMissing, 
    #   "Must supply a description for #{obj}##{name}"
    # end
    
    return unless @_code_doc_desc || @_code_doc_args || @_code_doc_ret

    if CodeDoc.debug?
      puts "Documenting #{obj}##{name}"
      puts "  Description:"
      puts "    #{@_code_doc_desc}"
      puts "  Args:"
      if @_code_doc_args.blank?
        puts "    none"
      else
        @_code_doc_args.each do |argname, argdesc|
          puts "    #{argname}: #{argdesc}"
        end
      end
      puts "  Returns: #{@_code_doc_ret}"
      puts ''
    end


    docinfo = {
      desc: @_code_doc_desc,
      args: @_code_doc_args,
      ret: @_code_doc_ret
    }
    
    if opts[:scope] == :instance
      obj._code_doc_instance_methods ||= {}
      obj._code_doc_instance_methods[name] = docinfo
    elsif opts[:scope] == :singleton
      obj._code_doc_singleton_methods ||= {}
      obj._code_doc_singleton_methods[name] = docinfo
    end

    @_code_doc_desc = @_code_doc_args = @_code_doc_ret = nil
  end
  

  #-----------------------------------------------------------------------------
  desc "hooks each time a method is added and keeps track of the documentation"
  arg :name, "the name of the method that was just added"
  #-----------------------------------------------------------------------------
  def method_added(name)
    nearest_singleton_class.code_doc_document_method({
      name: name,
      scope: :instance
    })
    # there is no super
  end


  #-----------------------------------------------------------------------------
  desc <<-DESC.undent
    hooks each time a singleton method is added and keeps track of the 
    documentation
  DESC
  arg :name, "the name of the method that was just added"
  #-----------------------------------------------------------------------------
  def singleton_method_added(name)
    nearest_singleton_class.code_doc_document_method({
      name: name,
      scope: :singleton
    })
    super
  end

  #-----------------------------------------------------------------------------
  ret <<-DESC.undent
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
    self.nearest_singleton_class._code_doc_instance_methods || {}
  end


  def code_doc_singleton_methods
    self.nearest_singleton_class._code_doc_singleton_methods || {}
  end

  alias _code_doc_include include
  def include(m)
    @@_code_doc_included_modules ||= []
    @@_code_doc_included_modules << m
    _code_doc_include(m)
  end

  def code_doc_included_modules
    @@_code_doc_included_modules ||=[]
  end

end


class Object
  def desc(d)
    @@_code_doc_desc = d
  end

  def code_doc_desc
    @@_code_doc_desc ||= nil
  end
  
end
