# Fluid variables for Ruby.
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# This code is in the public domain.

# Documentation and examples are in fluid-doc-and-examples.rb.
# They're there because the documentation messes up Emacs fontification
# and makes the code harder to work with.

class Fluid
                                                         ### Environment ###

  # An environment holds variable->value bindings. Each
  # variable name is an entry in a hash table. It is
  # associated with a stack of values. Environments are
  # manipulated by objects of class Var.
  class Environment < Hash
    def create(var_name)  self[var_name] = []; end
    def destroy(var_name)  delete(var_name); end
    def has?(var_name)  has_key?(var_name); end
    def unbound?(var_name)  self[var_name] == []; end
    def set(var_name, value)   self[var_name][-1] = value; end
    def get(var_name)  self[var_name][-1]; end
    def push_binding(var_name, var_value)  self[var_name].push(var_value); end
    def pop_binding(var_name)   self[var_name].pop; end
  end

  # All fluid variables are managed by one environment.
  @@environment = Environment.new


                                                                 ### Var ###

  # There are different kinds of variables. They use the environment
  # differently. 
  class Var
    attr_reader :name,           # Canonicalize all names to symbols.
                :original_name   # Retain original name for error messages.

    # Factory method that returns subclasses of Var.
    def Var.build(original_name, environment, value_destructor=nil)
      klass = (global?(original_name)) ? GlobalVar : FluidVar
      klass.build(original_name, environment, value_destructor)
    end

    def Var.global?(string_or_symbol)
      ?$ == string_or_symbol.to_s[0]
    end

    def initialize(original_name, environment, value_destructor)
      @original_name = original_name
      @name = Var.ensure_symbol(original_name)
      @environment = environment
      @value_destructor = value_destructor
    end

    # These two methods are the ones used to manipulate the
    # environment. Note subclasses.
    def push_binding(value)
      create unless @environment.has?(name)
      @environment.push_binding(name, value)
    end

    def pop_binding
      previous = @environment.pop_binding(name)
      apply_value_destructor(previous) if @value_destructor
      destroy if @environment.unbound?(name)
    end

  protected
    def create
      # I would prefer acceptability of the name to be checked in the
      # class.build method, before other work is done. However, some
      # acceptability is most cleanly checked when the variable is
      # created, so I decided to do all checking here.
      assert_acceptable_name
      @environment.create(name)
    end

    def destroy
      @environment.destroy(name)
    end

    def apply_value_destructor(value)
      if @value_destructor.respond_to? :call
        @value_destructor.call(value)
      else
        value.send(@value_destructor)
      end
    end

    def assert_acceptable_name
      subclass_responsibility
    end

    def Var.ensure_symbol(original_name)
      original_name.to_s.intern
    end
  end

                                                             ### FluidVar ###

  # FluidVars are those accessed via "Fluid.varname". This subclass
  # contains the code for adding those getters and setters.
  class FluidVar < Var

    def FluidVar.build(*args)
      new(*args)  # No subclasses to build specially.
    end

    def create
      super
      Fluid.create_getter(name)
      Fluid.create_setter(name)
    end

    def destroy
      super
      Fluid.delete_getter(name)
      Fluid.delete_setter(name)
    end
      
    def assert_acceptable_name
      unless name.to_s =~ /^[a-z_]\w*$/
        raise NameError, "'#{original_name}' is not a good fluid variable name. It can't be used as a method name."
      end

      if Fluid.methods.include?(name.to_s)
        raise NameError, "'#{original_name}' cannot be a fluid variable. It's already a method of Fluid's."
      end
    end
  end


                                                           ### GlobalVar ###

  # GlobalVars are the subclass that handles binding and unbinding of
  # Ruby globals.
  #
  # Note: although $defout and $> are synonyms, they are not treated
  # as such. This works because Ruby makes sure that changes to one
  # change the other. So if you assign to $defout within a block that
  # sets $>, exiting the block will undo the assignment.
  class GlobalVar < Var
    def GlobalVar.build(original_name, environment, value_destructor)
      if "$stderr" == original_name.to_s
        StderrVar.new(original_name, environment, value_destructor)
      else
        new(original_name, environment, value_destructor)
      end
    end

    # The original value of the global is, in effect, an outermost
    # binding, one not created with Fluid.let. A binding has to be made
    # here so that unbinding works on exit from the Fluid.let block. 
    def create
      super
      push_binding(instance_eval("#{name.to_s}"))
    end

    # The environment really just holds values for unbinding.
    # Access to the newly-bound variable within the Fluid.let block
    # is through the global itself. So it needs to be set and reset
    # by these methods.
    def push_binding(value)
      super
      set_global
    end

    def pop_binding
      super
      set_global
    end

    def set_global
      evalme = "#{name.to_s} = @environment.get(#{name.inspect})"
      # puts evalme
      instance_eval evalme
    end

    def assert_acceptable_name
      if name == :$!
        raise NameError, 
          "Changing '$!' while an exception is being raised causes odd behavior," +
          "so it's not allowed in Fluid.let."
      elsif name == :$stdin
        # See globals/stdin.rb for reasons.
        raise NameError, 
          "'#{name}' is not allowed in Fluid.let. It cannot be correctly" + 
          "restored after the let's block completes."
      elsif name == :$stdout
        # See globals/stdout.rb for reasons.
        raise NameError, 
          "'#{name}' is not allowed in Fluid.let. It cannot be correctly" + 
          "restored after the let's block completes. Use $defout instead."
      end
    end
  end

                                                           ### StderrVar ###
  
  # $stderr is a special global in two ways (see below). If $stdin and
  # $stdout could be made to work, they'd have to be treated
  # similarly.
  class StderrVar < GlobalVar
    
    # The original value of $stderr has to be cloned before it's
    # saved. If the original value is restored, output is lost.
    def push_binding(value)
      value = value.dup if value == STDERR
      super(value)
    end

    # $stderr must be set to the new value before the old value is
    # destroyed. If the setting is done at the end (as in superclasses),
    # writes will fail.
    def pop_binding
      previous = @environment.pop_binding(name)
      set_global
      apply_value_destructor(previous) if @value_destructor
      destroy if @environment.unbound?(name)
    end
  end


                                                               ### Fluid ###
  def Fluid.let(*var_specs)
    unwind_list = create_dynamic_context(var_specs)

    begin
      return yield if block_given?
    ensure
      unwind_dynamic_context unwind_list
    end
  end

  def Fluid.defvar(name, value = nil)
    if Var.global?(name)
      raise NameError, "Fluid.defvar of a global can never have an effect, so it's not allowed."
    end

    var = Var.build(name, @@environment)
    unless @@environment.has?(var.name)
      value = yield if block_given?
      var.push_binding(value)
    end
  end

  def Fluid.has?(name)
    return true if Var.global?(name)
    @@environment.has?(Var.ensure_symbol(name))
  end

  def Fluid.method_missing(symbol, *args)
    symbol = symbol.to_s.gsub(/=/, '')
    raise NameError, "'#{symbol}' has not been defined with Fluid.let or Fluid.defvar."
  end

private

  def Fluid.create_dynamic_context(var_specs)
    var_list = []

    var_specs.each { |one_spec|
      one_spec = [one_spec] unless one_spec.class == Array
      name = one_spec[0]
      value = one_spec[1]
      value_destructor = one_spec[2]

      var = Var.build(name, @@environment, value_destructor)
      assert_variable_name_is_not_duplicate(var.name, var_list)
      var.push_binding(value)
      var_list.push(var)
    }
    var_list
  end

  def Fluid.unwind_dynamic_context(var_list)
    var_list.each { | var | var.pop_binding }
  end

  def Fluid.create_getter(var)
    evalme = %Q{
      def Fluid.#{var.to_s}
        @@environment.get(#{var.inspect})
      end
    }
    # puts evalme
    class_eval evalme
  end

  def Fluid.create_setter(var)
    evalme = %Q{
      def Fluid.#{var.to_s}=(value)
        @@environment.set(#{var.inspect}, value)
      end
    }
    # puts evalme
    class_eval evalme
  end

  def Fluid.delete_fluid_method(name)
    evalme = %Q{
      class << Fluid
        remove_method(#{name.inspect})
      end
    }
    #puts evalme
    class_eval evalme
  end

  def Fluid.delete_getter(var)
    delete_fluid_method(var)
  end
  def Fluid.delete_setter(var)
    delete_fluid_method("#{var}=".intern)
  end


  def Fluid.assert_variable_name_is_not_duplicate(name_symbol,
                                                  already_defined = [])
    if already_defined.detect { | e | e.name == name_symbol }
      raise NameError, "'#{name_symbol}' is defined twice in the same Fluid.let."
    end
  end
end
