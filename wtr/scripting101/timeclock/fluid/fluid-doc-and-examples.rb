# Fluid variables and temporarily bound globals.
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# This code is in the public domain.

require 'fluid'

=begin

Class (({Fluid})) provides dynamically scoped ("fluid") variables modeled
after those of Common Lisp. It also gives you a convenient way to
reversibly change the values of globals.

== Globals

Suppose that you want to change the value of (({$defout}))
temporarily. Here's how:

  require 'fluid'

  Fluid.let(["$defout", File.open("logfile", "w"), :close]) {
    puts "This will go to 'logfile'."
  }
  puts "This will not."

Notice that the IO stream is closed after the original value is
restored.

You could do this yourself with (({begin...ensure...end})), but (({Fluid.let}))
is a bit more concise. Moreover, certain global variables (like
(({$stderr}))) have to be set and restored specially, in a way that's
historically confused people. Finally, some variables (like
(({$stdin})) and (({$stdout}))) can't be successfully restored.
(({Fluid.let})) refuses to try, which makes problems that would otherwise be
obscure more clear.

== An Alternative to Globals

When you use (({Fluid.let})), you're distinguishing two parts of your
program: a part that uses the variable's value, and another part that
wraps the first part. In the above example, code that logs to
(({$defout})) is wrapped by code that decides where logging should go.

Quite often, this wrapping is nested. For
example, you might use (({Fluid.let})) to produce a nicely nested
trace like this:

  fact(5)
    fact(4)
      fact(3)
        fact(2)
          fact(1)
          fact(1) => 1
        fact(2) => 2
      fact(3) => 6
    fact(4) => 24
  fact(5) => 120

The code is shown below. In effect, it wraps each call to (({fact}))
in a (({Fluid.let})) that increases the indentation level. Each return
from (({fact})) decreases the level. So when you are executing
(({fact(1)})), you're inside five nested (({Fluid.let})) blocks. 

A problem with globals is that they can be used in lots of different
ways. If you see a global in some code, you don't necessarily know
whether it's being used in this wrapping style or in some other
way. Globals are not "intention revealing". 

Enter fluid variables. 

  require 'fluid'
  
  Fluid.let([:var1, 1]) {
    puts(Fluid.var1)  # prints 1
  }
  puts(Fluid.var1)    # error - Fluid.var1 does not exist

(({Fluid.var1})) is much like a global, but whenever you see it in
code, you know that code is intended to be wrapped inside a (({Fluid.let})).

Like globals, fluid variables can be referenced outside of the method
that creates them. Suppose you have this method:

  def incrementing_printer
    Fluid.var1 += 1
    puts(Fluid.var1)
  end

That method could be called from anywhere without error, so long as a
(({Fluid.let})) for (({var1})) were executing:

  Fluid.let([:var1, 0]) {
    3.times do 
      incrementing_printer  # prints 1, 2, 3
    end
  }

Here's how the indented tracing shown above could be
implemented. Rather than use (({Fluid.let})) directly, I'll use it in
a special-purpose (({indenting-trace})) method. Here's (({fact})):

  def fact(n)
    indenting_trace('fact', n) {   # wrapping method
      if (n <= 1)
        n
      else
        n * fact(n-1)
      end
    }
  end

Here's the definition of (({indenting_trace})): 

  Fluid.defvar(:indent, "")  # initial value.

  def indenting_trace(name, *args)
    call_string = "#{Fluid.indent}#{name}(#{args.join(', ')})"
    puts call_string
    retval = Fluid.let([:indent, Fluid.indent + "  "]) {
      yield
    }
    puts "#{call_string} => #{retval.inspect}"
    retval
  end

Here's a final example that shows the syntax and behavior of
(({Fluid.let})). See also the more formal description below.

  Fluid.let([:var1, 1],
            [:var2, 2]) {
    puts(Fluid.var1)              # prints 1
    puts(Fluid.var2)              # prints 2
    Fluid.let([:var2, "new 2"],
              [:var3, "new 3"]) {
      puts(Fluid.var1)               # prints 1, as above.
      puts(Fluid.var2)               # prints "new 2"
      puts(Fluid.var3)               # prints "new 3"
    }
    puts(Fluid.var1)              # prints 1
    puts(Fluid.var2)              # Back to printing 2
    puts(Fluid.var3)              # error - that variable no longer exists.
  }


== Class Methods 
--- Fluid.let(variable-specifications) { block } 

    Puts the variable specifications in effect, then executes the block,
    undoes the variable specifications, and returns the block's value.

    A single variable specification has one of three forms. A variable name by
    itself is given the value nil:

      Fluid.let(:will_have_value_nil) {...}

    A variable specification may also be a two-element array, where the
    first element is the variable name and the second is its value:

      Fluid.let([:will_have_value_1, 1]) {...}

    Finally, there may be a third element in the array, the ((*value destructor*)). It is most often
    used to close an open file:
  
      Fluid.let([:out, File.open("logfile", 'w'), :close]) {...}

    Specifically, the value destructor may be either a (({Proc})) or the
    name of a method. If it's the name of a method, 
    it is sent as a message to the value of the
    second argument.
    Otherwise, it's a (({Proc})) that's called with the value of the second
    argument as 
    its single parameter: 

      Fluid.let([:out, File.open("logfile", 'w'),
                       proc {|io| io.close}]) {...}

    The three forms can be mixed.

    From the moment the block begins to execute until the moment it returns,
    getters and setters for the variables are made class methods of Fluid:

      Fluid.let([:var, 1]) {
        Fluid.var       # has value 1
        Fluid.var = 2   # change value to 2
      }

    If, however, the variable name begins with '$', (({Fluid.let})) realizes
    it's a global variable and gives that variable a new value. 
    No getters or setters are created.
    The old
    value is still restored when the block exits.

    References to the variable needn't be in the lexical scope of the
    (({Fluid.let})). They can be anywhere in the program.

    Variable names can be strings or symbols.

    Variable specifications are undone even if the block exits with a
    throw or an exception.

    If a fluid variable (like (({Fluid.myvar}))) is used when no block of 
    a (({Fluid.let})) that names it
    is executing,
    a (({NameError})) results. (But see also ((<Fluid.defvar>)).)

--- Fluid.defvar(name, optional-value) { optional-block } 

    A global declaration of a fluid variable. After executing this code:

      Fluid.defvar(:global, 5) 

    (({Fluid.global})) will normally everywhere have the value 5, unless it's
    changed by assignment or (({Fluid.let})).

    However, (({Fluid.defvar})) has effect only the first time it's executed.
    That is, given this sequence:

      Fluid.defvar(:global, 5)
      Fluid.defvar(:global, 6666666)

    (({Fluid.global})) has value 5. The second (({Fluid.defvar})) is ignored. [Note:
    I'm not at all sure this behavior is useful, but it's the way 
    Common Lisp does it. ]

    A (({Fluid.defvar})) executed while a (({Fluid.let})) block is in effect will
    have no effect:

      Fluid.let([:not_global, 1]) {
        Fluid.defvar(:not_global, 5555)   # Fluid.not_global == 1
      }
      # The defvar has had no effect, so Fluid.not_global
      # has no value after the block.

    (({Fluid.defvar})) can take a block as an argument:

      Fluid.defvar(:var) { long_and_expensive_computation }
      
    The block is only executed if its value would be assigned to the
    variable.

    The first argument to (({Fluid.defvar})) may not be the name of 
    a global variable. 
=end

## EXAMPLES

Fluid.defvar(:indent, "")

def indenting_trace(name, *args)
  call_string = "#{Fluid.indent}#{name}(#{args.join(', ')})"
  puts call_string
  retval = Fluid.let([:indent, Fluid.indent + "  "]) {
    yield
  }
  puts "#{call_string} => #{retval.inspect}"
  retval
end

def fact(n)
  indenting_trace('fact', n) {
    if (n <= 1)
      n
    else
      n * fact(n-1)
    end
  }
end

def global_example
  Fluid.let([:$defout, File.open("logfile", "w"), :close]) {
    puts "This is an example"
  }
  puts "As an example of using Fluid.let with globals,"
  puts "look for 'This is an example' in file 'logfile'."
end

if __FILE__ == $0
  fact(5)
  global_example
end
