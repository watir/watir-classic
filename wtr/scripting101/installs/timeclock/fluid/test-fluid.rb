require "test/unit"
require 'fluid.rb'

class TestFluid < Test::Unit::TestCase

                                                                ### Utilities

  # Like assert_raises, except check for expected message as well.
  def assert_raises_with_message(expected_exception, expected_message)
    begin
      yield
    rescue expected_exception => exception
      assert_equal(expected_message, exception.message)
    rescue => exception
      fail("Expected #{expected_exception}; got #{exception}")
    else
      fail("Expected #{expected_exception}; got nothing.")
    end
  end

  def assert_tempfile_equals(lines, name)
    read = File.readlines(name)
    read.map { | l | l.chomp! }
    assert_equal(lines, read)
    File.delete(name)
  end


                                                              ### Tests
  def test_one_variable_uninitialized
    Fluid.let(:a) {
      assert_equal(nil, Fluid.a)
    }
  end

  def test_one_variable_initialized
    Fluid.let([:a, 1]) {
      assert_equal(1, Fluid.a)
    }
  end

  # Couple of notes about this test.
  # - It checks that fluid variable names can be strings or symbols.
  # - It checks that the values can be complex objects or references.
  def test_multiple_variables
    dval = ["dval"]
    Fluid.let([:a, 1],
              :b,
              ["c", [1, 2]],
              [:d, dval]) {
      assert_equal(1, Fluid.a)
      assert_equal(nil, Fluid.b)
      assert_equal([1, 2], Fluid.c)
      assert_equal(dval, Fluid.d)
    }
  end

        
  def test_fluid_variable_assignment
    Fluid.let(["a", 1]) {
      assert_equal(1, Fluid.a)
      Fluid.a = 2
      assert_equal(2, Fluid.a)
      Fluid.let("a") {
        assert_equal(nil, Fluid.a)
      }
      assert_equal(2, Fluid.a)
    }
  end

  # Assignment is parallel, as in Lisp let, not let*
  # This is inherent in Ruby arg evaluation, but thought I would
  # document it here. let* is impossible, I think. 
  def test_assignment_is_parallel
    Fluid.let([:dawn, "best beloved"]) {
      assert_equal("best beloved", Fluid.dawn)
      Fluid.let([:dawn, "wife"],
                [:paul, "child of #{Fluid.dawn}"]) {
        assert_equal("wife", Fluid.dawn)
        assert_equal("child of best beloved", Fluid.paul)
      }
    }
  end

  # Test that pushing and popping of values works correctly.
  # Note that this also checks whether the no-op form (no vars)
  # in fact has no effect.
  def test_nesting_behavior_simple_within_method
    Fluid.let([:a, 1]) {
      assert_equal(1, Fluid.a)
      Fluid.let {
        assert_equal(1, Fluid.a)
        Fluid.let([:a, 2]) {
          assert_equal(2, Fluid.a)
        }
        assert_equal(1, Fluid.a)
      }
      assert_equal(1, Fluid.a)
    }
  end

  # Check that multiple variables are pushed and popped appropriately.
  def test_nesting_behavior_complex_within_method
    Fluid.let([:a, 1], :b) {
      assert_equal(1, Fluid.a)
      assert_equal(nil, Fluid.b)
      Fluid.let(:a) {
        assert_equal(nil, Fluid.a)
        assert_equal(nil, Fluid.b)
        Fluid.let([:b, 'b'],
                  [:a, [1, 2]]) {
          assert_equal([1,2], Fluid.a)
          assert_equal('b', Fluid.b)
        }
        assert_equal(nil, Fluid.a)
        assert_equal(nil, Fluid.b)
      }
      assert_equal(1, Fluid.a)
      assert_equal(nil, Fluid.b)
    }
  end

  # UNWINDING      
  # This is an example that shows how bindings are unwound or not
  # unwound as control passes out of a block in various ways
  # that involve calls to other methods. Shows how variable bindings
  # are independent of the call stack.
  def test_nesting_behavior_across_methods
    Fluid.let([:paul, 6],
              [:sophie, 5]) {
      ordinary_subfunction # add one to age.
      assert_equal(7, Fluid.paul)
      assert_equal(6, Fluid.sophie)

      # Values are unwound in presence of catch.
      catch_value = catch(:catcher) {
        Fluid.let([:paul, 66]) {
          assert_equal(66, Fluid.paul)
          assert_equal(6, Fluid.sophie)
          throwing_subfunction
          # This changes both variables, but only
          # the change to Sophie will be visible outside the let block
        }
      }
      assert_equal(55600, catch_value)
      assert_equal(7, Fluid.paul)
      assert_equal("sophster", Fluid.sophie)
      
      # Values are unwound with exceptions as well
      begin
        Fluid.let([:sophie, "leewit"]) {
          assert_equal(7, Fluid.paul)
          assert_equal("leewit", Fluid.sophie)
          raising_subfunction
          # This changes both variables, but only
          # the change to Paul will be visible outside the let block
        }
      rescue RuntimeError
        assert_equal(nil, Fluid.paul)
        assert_equal("sophster", Fluid.sophie)
        return
      end
      fail("Should not reach here.")
    }
  end

  def ordinary_subfunction
    assert_equal(6, Fluid.paul)
    assert_equal(5, Fluid.sophie)
    Fluid.paul += 1
    Fluid.sophie += 1
  end

  def throwing_subfunction
    assert_equal(66, Fluid.paul)
    assert_equal(6, Fluid.sophie)
    # This change will be unwound as computation passes
    # outside the Let block, which binds Paul.
    Fluid.paul += 55534
    # This will not, since the let block does not bind
    # sophie.
    Fluid.sophie = "sophster"
    throw :catcher, Fluid.paul
  end

  def raising_subfunction
    assert_equal(7, Fluid.paul)
    assert_equal("leewit", Fluid.sophie)
    # This change will be unowund as computation passes
    # outside the Let block, which binds sophie.
    Fluid.sophie = nil

    # This change will be visible outside the let block, which
    # does not bind paul.
    Fluid.paul = nil
    raise "Here comes the exception"
  end

  # END UNWINDING      

      
  def test_unbound_reference
    assert_raises_with_message(NameError,
           "'unbound' has not been defined with Fluid.let or Fluid.defvar.") {
      Fluid.let(:a) {
        puts(Fluid.unbound)
      }
    }
  end

  def test_unbound_assignment
    assert_raises_with_message(NameError,
          "'also_unbound' has not been defined with Fluid.let or Fluid.defvar.") {
      Fluid.also_unbound = 1
    }
  end

  def test_bindings_vanish
    Fluid.let(:establish_binding) {
      assert_equal(nil, Fluid.establish_binding)
    }
    assert_raises_with_message(NameError,
          "'establish_binding' has not been defined with Fluid.let or Fluid.defvar.") {
      Fluid.establish_binding = 1
    }
  end
    
  def test_block_yields_last_value
    result = Fluid.let([:a,1], [:b, 2]) {
      Fluid.a + Fluid.b
    }
    assert_equal(3, result)
  end

  def test_some_names_are_not_allowed
    assert_raises_with_message(NameError,
      "'let' cannot be a fluid variable. It's already a method of Fluid's.") {
      Fluid.let(:let) {fail("How'd I get here?")}
    }

    assert_raises_with_message(NameError,
      "'send' cannot be a fluid variable. It's already a method of Fluid's.") {
      Fluid.let(:send) {fail("How'd I get here?")}
    }
  end

  def test_duplicates_in_let
    assert_raises_with_message(NameError,
      "'duplicate' is defined twice in the same Fluid.let.") {
      Fluid.let(:duplicate, :unique, ["duplicate", 1]) {
        fail("How'd I get here?")
      }
    }
  end

  def test_defvar_simple
    Fluid.defvar(:defvar_simple_a)
    Fluid.defvar("defvar_simple_b", 1)
    Fluid.defvar(:defvar_simple_c) { [1, 2] }
    
    assert_equal(nil, Fluid.defvar_simple_a)
    assert_equal(1, Fluid.defvar_simple_b)
    assert_equal([1, 2], Fluid.defvar_simple_c)

    Fluid.let([:defvar_simple_a, 99],
              [:defvar_simple_b, 999],
              [:defvar_simple_c, "000"]) {
      assert_equal(99, Fluid.defvar_simple_a)
      assert_equal(999, Fluid.defvar_simple_b)
      assert_equal("000", Fluid.defvar_simple_c)
    }

    assert_equal(nil, Fluid.defvar_simple_a)
    assert_equal(1, Fluid.defvar_simple_b)
    assert_equal([1, 2], Fluid.defvar_simple_c)
  end

  def test_defvar_once_only
    Fluid.defvar("defvar_once_hello_5", "first value")
    Fluid.defvar(:defvar_once_hello_5, "second value")
    assert_equal("first value", Fluid.defvar_once_hello_5)

    # Same is true of implicit nil.
    Fluid.defvar(:defvar_once_hello_5)
    assert_equal("first value", Fluid.defvar_once_hello_5)

    # Moreover, blocks are not evaluated at all the second time.
    Fluid.defvar(:defvar_once_hello_5) { fail "Should not be reached" }
    assert_equal("first value", Fluid.defvar_once_hello_5)
  end

  def test_defvar_within_let  # has no effect
    assert_raises_with_message(NameError,
          "'a' has not been defined with Fluid.let or Fluid.defvar.") {
      Fluid.a
    }

    Fluid.let([:a, 1]) {
      assert_equal(1, Fluid.a)
      Fluid.defvar(:a, 999)
      assert_equal(1, Fluid.a)
    }
      
    assert_raises_with_message(NameError,
          "'a' has not been defined with Fluid.let or Fluid.defvar.") {
      Fluid.a
    }
  end
        
  def test_variable_names_are_method_names
    assert_raises_with_message(NameError,
       "'blank name' is not a good fluid variable name. It can't be used as a method name.") {
      Fluid.let("blank name") {}
    }

    assert_raises_with_message(NameError,
       "'9foo' is not a good fluid variable name. It can't be used as a method name.") {
      Fluid.let("9foo".intern) {}
    }

    assert_raises_with_message(NameError,
       "'a=b' is not a good fluid variable name. It can't be used as a method name.") {
      Fluid.defvar("a=b") {}
    }

    # Underscores are legal method names, though:
    Fluid.defvar("_", 5)
    assert_equal(5, Fluid._)
    Fluid.defvar("_t", 7)
    assert_equal(7, Fluid._t)
  end

  def test_destructor_called
    outer_file = "destructor_called_outer.out"
    outer_text = %w{outer-line-1 outer-line-2}
    middle_file = "destructor_called_middle.out"
    middle_text = %w{middle-line-1 middle-line-2 middle-line-3}
    inner_file = "destructor_called_inner.out"
    inner_text = %w{inner-line-1 inner-line-2}

    Fluid.defvar(:io, File.open(outer_file, "w"))
    Fluid.io.puts(outer_text[0])

    middle_stream = nil # to check if stream is closed
    Fluid.let(["io", File.open(middle_file, "w")]) { # NOT closed.
      Fluid.io.puts(middle_text[0])

      inner_stream = nil   # to check if stream is closed.
      Fluid.let(["io", File.open(inner_file, "w"), :close]) {
        Fluid.io.puts(inner_text[0])
        inner_stream = Fluid.io
        inner_stream.puts(inner_text[1])
      }
      assert_raises(IOError) {
        inner_stream.puts("Never seen")
      }
      middle_stream = Fluid.io
      middle_stream.puts(middle_text[1])
    }
    middle_stream.puts(middle_text[2]) # still available.
    middle_stream.close # So that, on Windows, we can look at contents.
    
    Fluid.io.puts(outer_text[1])
    Fluid.io.close

    assert_tempfile_equals(outer_text, outer_file)
    assert_tempfile_equals(middle_text, middle_file)
    assert_tempfile_equals(inner_text, inner_file)
  end

  def test_block_destructor
    value = "destructor_called"
    destructor_called = false
    p = proc { | x | destructor_called = x }

    assert_equal(value * 2, 
                  Fluid.let([:_t_d_, value, p]) {
                    Fluid._t_d_ * 2
                  })
    assert_equal(value, destructor_called)
  end

  def test_var_checking
    assert_equal(false, Fluid.has?(:log))
    assert_equal(false, Fluid.has?('log'))
    Fluid.defvar(:log)
    assert_equal(true, Fluid.has?(:log))
    assert_equal(true, Fluid.has?('log'))

    assert_equal(false, Fluid.has?(:another_log))
    assert_equal(false, Fluid.has?('another_log'))
    Fluid.let( [:another_log, 5] ) {
      assert_equal(true, Fluid.has?(:another_log))
      assert_equal(true, Fluid.has?('another_log'))
    }
    assert_equal(false, Fluid.has?(:another_log))
    assert_equal(false, Fluid.has?('another_log'))
  end    


  #### GLOBALS

  def test_bound_global
    assert_equal($global, nil)
    Fluid.let(["$global", 5]) {
      assert_equal(5, $global)
      Fluid.let([:local, 'local'], # mix fluid and globals, just in case.
                ["$global", 'global']) {
        assert_equal('global', $global)
        assert_equal('local', Fluid.local)
        $global = 2334
      }
      assert_equal(5, $global)
      $global = 3434
    }
    assert_equal($global, nil)

    # Binding a predefined global variable has an effect.
    assert_equal(nil, "UP" =~ /up/)
    Fluid.let(["$=", :case_insensitivity]) {
      assert_equal(0, "UP" =~ /up/)
    }
    assert_equal(nil, "UP" =~ /up/)
  end

  def test_has_global
    # Global variables are always considered bound.
    assert_equal(true, Fluid.has?("$has_global_undef"))
    $has_global = 5
    assert_equal(true, Fluid.has?("$has_global"))
    Fluid.let( [ "$has_global", 99 ] ) {
      assert_equal(true, Fluid.has?("$has_global"))
    }
    assert_equal(true, Fluid.has?("$has_global"))
  end

  def test_exception_global
    # Assigning $! causes odd behavior.
    # Disallow it.

    assert_raises_with_message(NameError,
      "Changing '$!' while an exception is being raised causes odd behavior," +
      "so it's not allowed in Fluid.let.") {
      Fluid.let(["$!", Exception.new("overridden")]) {
        raise "this should never be executed"
      }
    }
  end

  def test_stdin_global
    # Stdin is buffered in such a way that text from the inner binding
    # is visible after a let unbinds. See globals/stdin.rb (Ruby 1.6)

    assert_raises_with_message(NameError,
      "'$stdin' is not allowed in Fluid.let. It cannot be correctly" + 
      "restored after the let's block completes.") {
      Fluid.let(["$stdin", nil]) {
        raise "this should never be executed"
      }
    }
  end

  def test_stdout_global
    # $stdout can be bound, but when it exits from the let, it will be
    # buffered differently than $defout. If both are used, lines will be
    # out of order. See globals/stdout.rb. (Ruby 1.6)

    assert_raises_with_message(NameError,
      "'$stdout' is not allowed in Fluid.let. It cannot be correctly" + 
      "restored after the let's block completes. Use $defout instead.") {
      Fluid.let(["$stdout", nil]) {
        raise "this should never be executed"
      }
    }
  end

  def test_global_parallel_assignment
    $g1 = 1
    $g2 = 2
    Fluid.let(["$g1", 11],
              ["$g2", $g1 + 1]) {
      assert_equal(11, $g1)
      assert_equal(2, $g2) # NOT 12
    }
    assert_equal(1, $g1)
    assert_equal(2, $g2)
  end

  def test_sequential_globals
    $g1 = 1
    $g2 = 2
    Fluid.let(["$g1", $g2],
              ["$g2", $g1]) {
      assert_equal(2, $g1)
      assert_equal(1, $g2)
    }
    assert_equal(1, $g1)
    assert_equal(2, $g2)

    Fluid.let(["$g1", $g2],
              ["$g2", $g1]) {
      assert_equal(2, $g1)
      assert_equal(1, $g2)
    }
    assert_equal(1, $g1)
    assert_equal(2, $g2)
  end

  def test_global_defvar
    assert_raises_with_message(NameError,
     "Fluid.defvar of a global can never have an effect, so it's not allowed.") {
      Fluid.defvar("$defvar", 33)
    }
  end

  def test_defout
    # Note that these variables must be kept in sync with those in
    # test-defout.rb.
    outer_file = "defout_outer.out"
    outer_text = %w{outer-line-1 outer-line-2}
    middle_file = "defout_middle.out"
    middle_text = %w{middle-line-1 middle-line-2 middle-line-3}
    inner_file = "defout_inner.out"
    inner_text = %w{inner-line-1 inner-line-2 inner-line-3 inner-line-4}
    assign_file = "defout_assign.out"
    assign_text = %w{assign-line-1 assign-line-2 assign-line-3}

    system("ruby test-defout.rb > #{outer_file}")

    assert_tempfile_equals(outer_text, outer_file)
    assert_tempfile_equals(middle_text, middle_file)
    assert_tempfile_equals(inner_text, inner_file)
    assert_tempfile_equals(assign_text, assign_file)
  end

  def test_stderr
    # Note that these variables must be kept in sync with those in
    # test-stderr.rb.
    outer_file = "stderr_outer.out"
    outer_text = %w{outer-line-1 outer-line-2 outer-line-3}
    middle_file = "stderr_middle.out"
    middle_text = %w{middle-line-1 middle-line-2}
    inner_file = "stderr_inner.out"
    inner_text = %w{inner-line-1}

    system("ruby test-stderr.rb 2> #{outer_file}")

    assert_tempfile_equals(outer_text, outer_file)
    assert_tempfile_equals(middle_text, middle_file)
    assert_tempfile_equals(inner_text, inner_file)
  end

end
