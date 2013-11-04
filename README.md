# CodeDoc

(CodeDoc is currently in the "proof-of-concept" stage. Hopefully I'll get back to implementing the rest of the idea Real Soon Now)

There are already multiple documentation mechanisms for ruby. Most famous is RDoc(http://rdoc.sourceforge.net/). A notable newcomer is TomDoc (http://tomdoc.org/).

So why write another one? Because I think the existing systems are all just variations of the same flawed idea: documentation in comments with special comment-syntax.

Here's an alternative. We already have a perfectly good language called Ruby, so why not use Ruby itself to document our code?

This idea comes from lisp -- one of the coolest things about lisp is the way it is self-documenting. In emacs, for example, you can surf around the documentation for the program from within the program, while it's running. If you load up new code, you can see the documentation for that code immediately. If a function gets overwritten with a new signature, you can see the updated documentation (for the function's signature at least) in real-time.

The ruby world already has a precedent for this: rake's descriptions. A typical rake task definition has two parts: the description and the task itself. Contrived example:

    desc "prints the current date and time to the console"
    task :datetime do
      puts Time.now.to_s
    end

The call to `desc` defines a description for the task that follows. I think we can take this idea much, much further and create a robust system for documenting all of our code with code itself.

This is a silly example of code_doc-documented code (this works in code_doc 0.0.2):

    class TestClass

      desc 'this is the #foo method. it does nothing.'
      arg :arg, 'this is the arg. it is not used.'
      ret 'the string "foo"'
      def foo(arg)
        "foo"
      end

      desc 'this is the #bar method.'
      arg :baz, "baz is a pointless argument. don't pass it in"
      ret  'nothing useful'
      def self.bar(baz=nil)
        nil
      end

    end

    CodeDoc.for(TestClass)

    #=> {
          :instance_methods => {
            :foo => {
              :desc => "this is the #foo method. it does nothing.",
              :args => {
                :arg => "this is the arg. it is not used."
              },
              :ret => "the string \"foo\""
            }
          },
          :singleton_methods => {
            :bar => {
              :desc => "this is the #bar method.",
              :args => {
                :baz => "baz is a pointless argument. don't pass it in"
              },
              :ret => "nothing useful"
            }
          }
        }

Okay, so then what do you do with it? Anything you want! How beautiful is it that for each documented class and method in your code, you'll get a hash of all the information about those classes and methods? You are in ruby code with a hash of all the documentation information. Your only limitation is your imagination. You can output the docs as simply as `pp docs`, as above, or as complex as you want, with html markup, etc. It should be exceedingly easy for newcomers to this system to write new formatters. All you have to do is write a method that takes a hash and outputs whatever you want.

Another possibility this opens up is validating the documentation. Want to make sure you don't forget to document any code? You could turn on a "strict mode" (not yet implemented in v 0.0.1) that would raise an error if you don't fully describe all the methods in all your classes.

One objection I can imagine is that this ends up using a lot more memory than the comment-documentation, because you actually store all those doc strings in memory. That's true. But if this was a big concern for running in production, we could implement a "production mode" that turns all of the CodeDoc methods into null-methods that just return and don't do anything. Use the extra memory in dev and to generate the documentation, but don't sacrifice anything in production.


## Features

- `desc` to describe a method
- `arg` to describe an argument for a method
- `ret` to describe what a method returns
- `desc`, `ret`, `arg` for class methods (singleton methods) too

## TODO

- describe a class or a module
- implement "strict mode" to require documentation for all classes/methods
- basic/default text and html formatter/outputter
- track file and line numbers as well, to allow for "open this file at this line" type of behavior
- ?

## Installation

Add this line to your application's Gemfile:

    gem 'code_doc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install code_doc


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
