require 'timeclock/client/html/Formatting'
require 'timeclock/client/html/PageSketch'
require 'timeclock/client/tutil.rb'

module Timeclock
  module Client
    module Html

      class FormattingTests < ClientTestCase
        include Formatting

        ## Intermediate-level formatting utilities
        ## We test only one, since they're all created the same way.
        def test_body
          p = PageSketch.new('test title')
          assert_equal(".<body>
                        .</body>".after_dots,
                       p.body)

          assert_equal(".<body>
                        .  hi
                        .</body>".after_dots,
                       p.body('hi'))
          assert_equal(".<body>
                        .  hi
                        .  there
                        .</body>".after_dots,
                       p.body('hi', 'there'))

          assert_equal('.<body arg="foo">
                        .  interior
                        .</body>'.after_dots,
                       p.body({:arg => 'foo'}, 
                              'interior'))
        end

        ## Utilities for creating nestings of tags.
        def test_center
          assert_equal({:align => 'center'}, PageSketch.new('untitled').center)
          assert_equal({:align => 'center', :bgcolor => 'color'},
                       PageSketch.new('untitled').center('color'))
        end

        # Need a subclass to test command_form.
        class SessionishPageSketch < PageSketch
          def session_id
            600219
          end
        end

        def test_command_form
          sketch = SessionishPageSketch.new('title')
          xhtml = sketch.command_form('cmd', 'text-to-find', 'and-more')

          assert_match(/action="cmd"/, xhtml)
          assert_match(/text-to-find/, xhtml)
          assert_match(/and-more/, xhtml)
          assert_match(/name="session".*type="hidden".*value="#{sketch.session_id}"/, xhtml)
        end



        ## Private formatting utilities
        def test_shifting
          p = PageSketch.new('ignored')

          assert_equal("  a", p.rshift("a"))
          assert_equal("  a\n  b\n   c",
                       p.rshift("a\nb\n c"))
        end

        def test_tight_wrapping
          p = PageSketch.new('ignored')

          assert_equal("<title>TITLE</title>",
                       p.tight('title', "TITLE"))

          assert_equal("<p><b>bolded paragraph</b></p>",
                       p.tight("p",
                               p.tight("b", "bolded paragraph")))
        end

        def test_tight_attributes
          p = PageSketch.new('ignored')

          assert_equal(%Q{<b name="fred;bo"></b>},
                       p.tight("b", { :name=>'fred;bo' }))
        end

        def test_expansive_wrapping
          p = PageSketch.new('ignored')

          assert_equal(".<title>
                        .  TITLE
                        .</title>".after_dots,
                       p.expansive("title", "TITLE"))

          assert_equal(".<body>
                        .  <p>
                        .    <b>
                        .      a paragraph
                        .    </b>
                        .  </p>
                        .</body>".after_dots,
                       p.expansive("body", 
                                   p.expansive("p", 
                                               p.expansive("b", 
                                                           "a paragraph"))))
          assert_equal(".<body>
                        .  <p>
                        .    text
                        .  </p>
                        .  <p>
                        .    more text
                        .  </p>
                        .</body>".after_dots,
                       p.expansive("body", 
                                   p.expansive("p", "text"),
                                   p.expansive("p", "more text")))
        end

        def test_expansive_attributes
          p = PageSketch.new('ignored')

          assert_equal(%Q{.<head arg="value" arg2="value2">
                          .</head>}.after_dots,
                       p.expansive("head",
                                   { :arg=>'value', :arg2=>'value2' }))

          # duplication forces me to sort keys, not depend on luck.
          # Observe also how the call looks with other arguments. 
          assert_equal(%Q{.<head arg="value" arg2="value2">
                          .  block of text
                          .  <p>tight</p>
                          .</head>}.after_dots,
                       p.expansive("head",
                                   { :arg2=>'value2', :arg=>'value'},
                                   'block of text',
                                   p.tight('p', 'tight')))
        end
 


        def test_tight_and_expansive_wrapping
          p = PageSketch.new('ignored')
          assert_equal(".<head>
                        .  <title>my title</title>
                        .</head>".after_dots,
                       p.expansive("head", 
                                   p.tight("title", "my title")))
        end


        def test_no_attributes_to_separate
          attributes, content = attributes_and_contents(["1", "2"])
          assert_equal([], attributes)
          assert_equal(["1", "2"], content)
        end

        def test_one_hash_of_attributes_to_separate
          attributes, content = attributes_and_contents([{'align'=>'center',
                                                          'size'=>4},
                                                         "1", "2"])
          assert_equal([' align="center"', ' size="4"'], attributes)
          assert_equal(["1", "2"], content)
        end

        def test_two_hashes_of_attributes_to_separate
          # Note that we are in reverse alphabetical order. Attributes are
          # sorted to make testing deterministic.
          attributes, content = attributes_and_contents([{'size'=>4},
                                                         {'align'=>'center'},
                                                         "2", "1"])
          assert_equal([' align="center"', ' size="4"'], attributes)
          assert_equal(["2", "1"], content)
        end

        def test_all_hashes_of_attributes_are_separated
          attributes, content = attributes_and_contents([{'size'=>4}, 
                                                         "2", 
                                                         {'align'=>'center'},
                                                         "1"])
          assert_equal([' align="center"', ' size="4"'], attributes)
          assert_equal(["2", "1"], content)
        end

        todo 'Should it be an error when the hashes contain the same key?'

      end
    end
  end
end
